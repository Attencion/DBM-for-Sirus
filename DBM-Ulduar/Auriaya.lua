local mod	= DBM:NewMod("Auriaya", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 4133 $"):sub(12, -3))

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
end

local warnSwarm 		= mod:NewTargetAnnounce(312956, 2)
local warnFear 			= mod:NewSpellAnnounce(312955, 3)
local warnFearSoon	 	= mod:NewSoonAnnounce(312955, 1)
local warnCatDied 		= mod:NewAnnounce("WarnCatDied", 3, 312972)
local warnCatDiedOne	= mod:NewAnnounce("WarnCatDiedOne", 3, 312972)
local warnSonic			= mod:NewSpellAnnounce(312954, 2)

local specWarnBlast		= mod:NewSpecialWarning("SpecWarnBlast", canInterrupt)
local specWarnVoid 		= mod:NewSpecialWarningMove(312963)

local enrageTimer		= mod:NewBerserkTimer(600)
local timerDefender 	= mod:NewTimer(35, "timerDefender")
local timerFear			= mod:NewCastTimer(312955)
local timerNextFear 	= mod:NewNextTimer(35.5, 312955)
local timerNextSwarm 	= mod:NewNextTimer(36, 312956)
local timerNextSonic 	= mod:NewNextTimer(27, 312954)
local timerSonic		= mod:NewCastTimer(312954)

mod:AddBoolOption("HealthFrame", true)

local isFeared			= false
local catLives = 9

function mod:OnCombatStart(delay)
	catLives = 9
	enrageTimer:Start(-delay)
	timerNextSwarm:Start()
	warnFearSoon:Schedule(36)
	timerNextFear:Start(38-delay)
	timerNextSonic:Start(60-delay)
	timerDefender:Start(69-delay)
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(64678, 64389, 312600, 312953) then -- Sentinel Blast
		specWarnBlast:Show()
	elseif args:IsSpellID(64386, 312602, 312955) then -- Terrifying Screech
		warnFear:Show()
		timerFear:Start()
		timerNextFear:Schedule(2)
		warnFearSoon:Schedule(34)
	elseif args:IsSpellID(64688, 64422, 312601, 312954) then --Sonic Screech
		warnSonic:Show()
		timerSonic:Start()
		timerNextSonic:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(64396, 312603, 312956) then -- Guardian Swarm
		warnSwarm:Show(args.destName)
		timerNextSwarm:Start()
	elseif args:IsSpellID(64455, 312619, 312972) then -- Feral Essence
		DBM.BossHealth:AddBoss(34035, L.Defender:format(9))
	elseif args:IsSpellID(64386, 312602, 312955) and args:IsPlayer() then
		isFeared = true		
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(64386, 312602, 312955) and args:IsPlayer() then
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