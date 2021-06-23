local mod	= DBM:NewMod("Auriaya", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210501000000")

mod:SetCreatureID(33515)
mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"SPELL_DAMAGE",
	"UNIT_DIED"
)

local canInterrupt
do
	local class = select(2, UnitClass("player"))
	canInterrupt = class == "SHAMAN"
		or class == "WARRIOR"
		or class == "ROGUE"
		or class == "MAGE"
                or class == "DEATHKNIGHT"
end

local warnSwarm 	= mod:NewTargetAnnounce(312956, 2)
local warnFear 		= mod:NewSpellAnnounce(312955, 3)
local warnFearSoon	= mod:NewSoonAnnounce(312955, 1)
local warnCatDied 	= mod:NewAnnounce("WarnCatDied", 3, 312972)
local warnCatDiedOne	= mod:NewAnnounce("WarnCatDiedOne", 3, 312972)
local warnSonic		= mod:NewSpellAnnounce(312954, 2)

local specWarnBlast	= mod:NewSpecialWarning("SpecWarnBlast", canInterrupt)
local specWarnVoid 	= mod:NewSpecialWarningMove(312963)

local enrageTimer	= mod:NewBerserkTimer(600)
local timerDefender 	= mod:NewTimer(35, "timerDefender", nil, nil, nil, 1, nil, DBM_CORE_TANK_ICON)
local timerFear		= mod:NewCastTimer(312955, nil, nil, nil, 7, nil)
local timerNextFear 	= mod:NewNextTimer(35.5, 312955, nil, nil, nil, 7, nil)
local timerNextSwarm 	= mod:NewNextTimer(36, 312956, nil, nil, nil, 1, nil)
local timerNextSonic 	= mod:NewNextTimer(30, 312954, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)
local timerSonic	= mod:NewCastTimer(312954, nil, nil, nil, 2, nil)

mod:AddBoolOption("HealthFrame", true)

local isFeared			= false
local catLives = 9

function mod:OnCombatStart(delay)
        DBM:FireCustomEvent("DBM_EncounterStart", 33515, "Auriaya")
	catLives = 9
	enrageTimer:Start(-delay)
	timerNextSwarm:Start()
	warnFearSoon:Schedule(36)
	timerNextFear:Start(38-delay)
	timerNextSonic:Start(60-delay)
	timerDefender:Start(69-delay)
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 33515, "Auriaya", wipe)
        DBM.BossHealth:Hide()
        DBM.RangeCheck:Hide()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(64678, 64389, 312600, 312953) then       -- Удар часового
		specWarnBlast:Show()
	elseif args:IsSpellID(64386, 312602, 312955) then          -- Ужасающий визг
		warnFear:Show()
		timerFear:Start()
		timerNextFear:Schedule(2)
		warnFearSoon:Schedule(34)
	elseif args:IsSpellID(64688, 64422, 312601, 312954) then   -- Ультразвуковой визг
		warnSonic:Show()
		timerSonic:Start()
		timerNextSonic:Start()
                PlaySoundFile("Sound\\Creature\\AlgalonTheObserver\\UR_Algalon_BHole01.wav")
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(64396, 312603, 312956) then -- Крадущиеся стражи
		warnSwarm:Show(args.destName)
		timerNextSwarm:Start()
	elseif args:IsSpellID(64455, 312619, 312972) then -- Дикая сущность
		DBM.BossHealth:AddBoss(34035, L.Defender:format(9))
	elseif args:IsSpellID(64386, 312602, 312955) and args:IsPlayer() then
		isFeared = true		
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(64386, 312602, 312955) and args:IsPlayer() then   -- Ужасающий визг
		isFeared = false	
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 34035 then
		catLives = catLives - 1
		if catLives > 0 then
			if catLives == 1 then
				warnCatDiedOne:Show()
				timerDefender:Start()
			else
				warnCatDied:Show(catLives)
				timerDefender:Start()
         	end
			if self.Options.HealthFrame then
				DBM.BossHealth:RemoveBoss(34035)
				DBM.BossHealth:AddBoss(34035, L.Defender:format(catLives))
			end
		else
			if self.Options.HealthFrame then
				DBM.BossHealth:RemoveBoss(34035)
			end
		end
	end
end

function mod:SPELL_DAMAGE(args)
	if args:IsSpellID(64459, 64675, 312610, 312963) and args:IsPlayer() then -- Feral Defender Void Zone
		specWarnVoid:Show()
	end
end