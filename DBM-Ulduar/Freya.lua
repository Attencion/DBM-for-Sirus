local mod	= DBM:NewMod("Freya", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210501000000")

mod:SetCreatureID(32906)
mod:RegisterCombat("combat")
mod:RegisterKill("yell", L.YellKill)
mod:SetUsedIcons(6, 7, 8)

mod:RegisterEvents(
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"UNIT_DIED",
	"CHAT_MSG_MONSTER_YELL"
)

-- Trash: 33430 Guardian Lasher (flower)
-- 33355 (nymph)
-- 33354 (tree)

--
-- Elder Stonebark (ground tremor / fist of stone)
-- Elder Brightleaf (unstable sunbeam)

local canInterrupt
do
	local class = select(2, UnitClass("player"))
	canInterrupt = class == "WARRIOR"
        or class == "ROGUE"
        or class == "DEATHKNIGHT"
end

local warnPhase2			= mod:NewPhaseAnnounce(2, 3)
local warnSimulKill			= mod:NewAnnounce("WarnSimulKill", 1)
local warnFury				= mod:NewTargetAnnounce(312880, 3)
local warnRoots				= mod:NewTargetAnnounce(312860, 3)
local warnAlliesOfNature	= mod:NewSpellAnnounce(62678, 4)
local warnTremor			= mod:NewCountAnnounce(312842, 3)

local specWarnSparkWhip     = mod:NewSpecialWarning("SpecWarnSparkWhip", canInterrupt) --Плеть
local specWarnAllies		= mod:NewSpecialWarningSwitch(62678, nil, nil, nil, 1, 2) --Призыв защитников
local specWarnFury			= mod:NewSpecialWarningYou(312880, nil, nil, nil, 1, 2) --Гнев природы
local specWarnTremor		= mod:NewSpecialWarningCast(312842, "SpellCaster", nil, nil, 2, 2) --Кик каста
local specWarnBeam			= mod:NewSpecialWarningMove(312888, nil, nil, nil, 1, 2) --Нестабильная энергия

local enrage 				= mod:NewBerserkTimer(600)
local timerAlliesOfNature	= mod:NewCDTimer(60, 62678, "Призыв союзников", nil, nil, 1, nil, DBM_CORE_DAMAGE_ICON)
local timerSimulKill		= mod:NewTimer(12, "TimerSimulKill")
local timerFury				= mod:NewTargetTimer(10, 312880, nil, nil, nil, 3, nil)
local timerTremorCD			= mod:NewCDTimer(35, 312842, nil, nil, nil, 7, nil)

mod:AddBoolOption("HealthFrame", true)
mod:AddBoolOption("YellOnRoots", true)
mod:AddSetIconOption("FuryIcon", 312880, true, false, {8, 7})
mod:AddSetIconOption("RootsIcon", 312860, true, false, {6})

mod.vb.tremorCount = 0

local adds		= {}
local rootedPlayers 	= {}
local altIcon 		= true
local killTime		= 0
local iconId		= 6

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 32906, "Freya")
	self.vb.tremorCount = 0
	enrage:Start()
	table.wipe(adds)
	timerAlliesOfNature:Start(10)		
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 32906, "Freya", wipe)
	DBM.BossHealth:Hide()
	DBM.RangeCheck:Hide()	
end

local function showRootWarning()
	warnRoots:Show(table.concat(rootedPlayers, "< >"))
	table.wipe(rootedPlayers)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(62859, 312842, 312489, 62437) then --дрожание
		self.vb.tremorCount = self.vb.tremorCount + 1
		warnTremor:Show(self.vb.tremorCount)
		specWarnTremor:Show()
		timerTremorCD:Start(nil, self.vb.tremorCount+1)	
	end
end 

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(62678, 62873) then --Призыв защитников
		timerAlliesOfNature:Start()
		specWarnAllies:Show()
		specWarnAllies:Play("changetarget")
		warnAlliesOfNature:Show()
	elseif args:IsSpellID(62648, 62939, 312875, 312522) then --Плеть
		specWarnSparkWhip:Show()
		specWarnSparkWhip:Play("kickcast")
	elseif args:IsSpellID(63571, 62589, 312527, 312880) then --Гнев природы
		altIcon = not altIcon	--Alternates between Skull and X
		self:SetIcon(args.destName, altIcon and 7 or 8, 10)
		warnFury:Show(args.destName)
		if args:IsPlayer() then -- only cast on players; no need to check destFlags
			PlaySoundFile("Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav")
			specWarnFury:Show()
            DBM.RangeCheck:Show(8)
		end
		timerFury:Start(args.destName)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(62861, 62438, 312490, 312507, 312843, 312860) then --железные корни
		iconId = iconId - 1
		self:SetIcon(args.destName, iconId, 15)
		table.insert(rootedPlayers, args.destName)
		self:Unschedule(showRootWarning)
		if #rootedPlayers >= 3 then
			showRootWarning()
		else
			self:Schedule(0.5, showRootWarning)
		end
	elseif args:IsSpellID(62451, 62865, 312535, 312888) and args:IsPlayer() then --Нестабильная энергия
		specWarnBeam:Show()
	end 
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(62519, 312486, 312839) then
		warnPhase2:Show()
		timerAlliesOfNature:Cancel()
	elseif args:IsSpellID(62861, 62438, 312490, 312507, 312843, 312860) then --железные корни
		self:RemoveIcon(args.destName)
		iconId = iconId + 1
    elseif args:IsSpellID(63571, 62589, 312527, 312880) then --Гнев природы
        DBM.RangeCheck:Hide()
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.SpawnYell then
	timerAlliesOfNature:Start()
		if self.Options.HealthFrame then
			if not adds[33202] then DBM.BossHealth:AddBoss(33202, L.WaterSpirit) end -- ancient water spirit
			if not adds[32916] then DBM.BossHealth:AddBoss(32916, L.Snaplasher) end  -- snaplasher
			if not adds[32919] then DBM.BossHealth:AddBoss(32919, L.StormLasher) end -- storm lasher
		end
		adds[33202] = true
		adds[32916] = true
		adds[32919] = true	
	elseif msg == L.SpawnYelll then
	timerAlliesOfNature:Start()
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 33202 or cid == 32916 or cid == 32919 then
		if self.Options.HealthFrame then
			DBM.BossHealth:RemoveBoss(cid)
		end
		if (GetTime() - killTime) > 20 then
			killTime = GetTime()
			timerSimulKill:Start()
			warnSimulKill:Show()
		end
		adds[cid] = nil
		local counter = 0
		for i, v in pairs(adds) do
			counter = counter + 1
		end
		if counter == 0 then
			timerSimulKill:Stop()
		end
	end

end
