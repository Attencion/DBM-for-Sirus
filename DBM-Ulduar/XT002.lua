local mod	= DBM:NewMod("XT002", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210429162400")
mod:SetCreatureID(33293)
mod:SetUsedIcons(7, 8)

mod:RegisterCombat("yell", L.YellPull)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"SPELL_DAMAGE",
	"SPELL_MISSED",
	"UNIT_HEALTH"
)

local warnLightBomb					= mod:NewTargetAnnounce(312941, 3)
local warnGravityBomb				= mod:NewTargetAnnounce(312943, 4)
local warnPhase2					= mod:NewPhaseAnnounce(2)
local warnPhase2Soon				= mod:NewAnnounce("WarnPhase2Soon", 2)

local specWarnLightBomb				= mod:NewSpecialWarningMoveAway(312941, nil, nil, nil, 1, 2) --свет
local specWarnGravityBomb			= mod:NewSpecialWarningRun(312943, nil, nil, nil, 1, 2) --бомба
local specWarnTympanicTantrum		= mod:NewSpecialWarningDodgeCount(312939, nil, nil, nil, 2, 2) --раскаты
local specWarnConsumption			= mod:NewSpecialWarningMove(312948, nil, nil, nil, 1, 2) --Хард мод войд зона

local enrageTimer					= mod:NewBerserkTimer(600)
local timerTympanicTantrum			= mod:NewCastTimer(8, 312939, nil, nil, nil, 2, nil)
local timerTympanicTantrumCD		= mod:NewCDTimer(30, 312939, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON..DBM_CORE_HEALER_ICON)
local timerLightBomb				= mod:NewTargetTimer(9, 312588, nil, nil, nil, 3, nil, DBM_CORE_HEALER_ICON)
local timerLightBombCD		        = mod:NewCDTimer(20, 312588, nil, "Healer", nil, 3, nil, DBM_CORE_HEALER_ICON)
local timerGravityBomb				= mod:NewTargetTimer(9, 312943, nil, nil, nil, 3, nil, DBM_CORE_DEADLY_ICON)
local timerGravityBombCD			= mod:NewCDTimer(20, 312943, nil, nil, nil, 3, nil, DBM_CORE_DEADLY_ICON)
local timerAchieve					= mod:NewAchievementTimer(205, 6749, "TimerSpeedKill")

local yellGravityBomb		        = mod:NewYell(312943)
local yellLightBomb		       		= mod:NewYell(312941)

mod:AddSetIconOption("SetIconOnGravityBombTarget", 312943, true, false, {8})
mod:AddSetIconOption("SetIconOnLightBombTarget", 312588, true, false, {7})
mod:AddBoolOption("RangeFrame", true)
mod:AddBoolOption("PlaySoundOnSpell", true)

mod.vb.phase = 0
mod.vb.tantrumCount = 0

local warned_preP1 = false
local warned_preP2 = false

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 33293, "XT002")
	enrageTimer:Start(-delay)
	timerAchieve:Start()
	self.vb.phase = 1
	self.vb.tantrumCount = 0
	warned_preP1 = false
	warned_preP2 = false
	if mod:IsDifficulty("heroic10") then
		timerTympanicTantrumCD:Start(35-delay)
	else
		timerTympanicTantrumCD:Start(68-delay)
	end
	if self.Options.RangeFrame then
		DBM.RangeCheck:Show(20)	   
    end
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 33293, "XT002", wipe)
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(62776, 312586, 312939) then --Раскаты ярости
		self.vb.tantrumCount = self.vb.tantrumCount + 1
		specWarnTympanicTantrum:Show(self.vb.tantrumCount)
		timerTympanicTantrum:Start()
		timerTympanicTantrumCD:Start(nil, self.vb.tantrumCount+1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(63018, 65121, 312588, 312941) then --Опаляющий свет
		warnLightBomb:Show(args.destName)
		timerLightBomb:Start(args.destName)
		timerLightBombCD:Start()
		if args:IsPlayer() and self.Options.RangeFrame then
			specWarnLightBomb:Show()
			specWarnLightBomb:Play("moveaway")
			yellLightBomb:Yell()
			DBM.RangeCheck:Show(8)
		end
		if self.Options.SetIconOnLightBombTarget then
			self:SetIcon(args.destName, 7, 9)
		end
	elseif args:IsSpellID(63024, 64234, 312590, 312943) then --Гравибомба
		warnGravityBomb:Show(args.destName)
		timerGravityBomb:Start(args.destName)
		timerGravityBombCD:Start()
		if args:IsPlayer() and self.Options.PlaySoundOnSpell then
			specWarnGravityBomb:Show()
			yellGravityBomb:Yell()
			PlaySoundFile("Sound\\Creature\\LadyMalande\\BLCKTMPLE_LadyMal_Aggro01.wav")
		end
		if self.Options.RangeFrame then
			DBM.RangeCheck:Show(20)
		end
		if self.Options.SetIconOnGravityBombTarget then
			self:SetIcon(args.destName, 8, 9)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(63018, 65121, 312588, 312941) then --Опаляющий свет
		timerLightBomb:Stop()
	    if args:IsPlayer() and self.Options.RangeFrame then
			DBM.RangeCheck:Show(8)
		end
	    if self.Options.SetIconOnLightBombTarget then
			self:SetIcon(args.destName, 0)
		end
	elseif args:IsSpellID(63024, 64234, 312590, 312943) then --Гравибомба
		timerGravityBomb:Stop()
		if args:IsPlayer() and self.Options.RangeFrame then
			DBM.RangeCheck:Show(8)
		end
		if self.Options.SetIconOnGravityBombTarget then
			self:SetIcon(args.destName, 0)
		end
	end
end

function mod:UNIT_HEALTH(uId)
	if self.vb.phase == 1 and not warned_preP1 and self:GetUnitCreatureId(uId) == 33293 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.80 then
		warned_preP1 = true
		warnPhase2Soon:Show()
	elseif self.vb.phase == 1 and not warned_preP2 and self:GetUnitCreatureId(uId) == 33329 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.01 then
		warned_preP2 = true
		self.vb.phase = 2
		warnPhase2:Show()
	end
end

do 
	local lastConsumption = 0
	function mod:SPELL_DAMAGE(args)
		if args:IsSpellID(64206, 64208, 312596, 312949) and args:IsPlayer() and time() - lastConsumption > 2 then
			specWarnConsumption:Show()
			lastConsumption = time()
		end
	end
end