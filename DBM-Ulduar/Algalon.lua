local mod	= DBM:NewMod("Algalon", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

--[[
--
--  Thanks to  Apathy @ Vek'nilash  who provided us with Informations and Combatlog about Algalon
--
--]]


mod:SetRevision("20210501000000")
mod:SetCreatureID(32871)

mod:RegisterCombat("yell", L.YellPull)
mod:RegisterKill("yell", L.YellKill)
mod:SetWipeTime(20)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"CHAT_MSG_MONSTER_YELL",
        "SPELL_AURA_REMOVED",
	"UNIT_HEALTH"
)

local warnPhasePunch		        = mod:NewStackAnnounce(313033, 1, nil, "Tank|Healer")
local announceBigBang			= mod:NewSpellAnnounce(313034, 3)
local warnPhase2			= mod:NewPhaseAnnounce(2)
local warnPhase2Soon			= mod:NewAnnounce("WarnPhase2Soon", 2)
local announcePreBigBang		= mod:NewPreWarnAnnounce(313034, 5, 3)
local announceBlackHole			= mod:NewSpellAnnounce(313039, 2)
local announceCosmicSmash		= mod:NewAnnounce("WarningCosmicSmash", 3, 313037)

local specwarnStarLow			= mod:NewSpecialWarning("warnStarLow", "Tank|Healer")
local specWarnPhasePunch		= mod:NewSpecialWarningStack(313033, "Tank", 3)
local specWarnBigBang			= mod:NewSpecialWarningDefensive(313034)
local specWarnCosmicSmash		= mod:NewSpecialWarningSpell(312683)
local specPhasePunchlf                  = mod:NewSpecialWarningTaunt(313033, "Tank", nil, nil, 1, 2)

local timerCombatStart		        = mod:NewTimer(8, "TimerCombatStart", 2457)
local enrageTimer			= mod:NewBerserkTimer(360)
local timerNextBigBang			= mod:NewNextTimer(90.5, 313034, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)
local timerBigBangCast			= mod:NewCastTimer(8, 313034, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)
local timerNextCollapsingStar	        = mod:NewTimer(15, "NextCollapsingStar", nil, nil, nil, 2, nil, DBM_CORE_DAMAGE_ICON)
local timerCDCosmicSmash		= mod:NewTimer(25, "PossibleNextCosmicSmash", nil, nil, nil, 2, nil, DBM_CORE_HEALER_ICON)
local timerCastCosmicSmash		= mod:NewCastTimer(4.5, 313037, nil, nil, nil, 2, nil, DBM_CORE_HEALER_ICON)
local timerPhasePunch			= mod:NewBuffActiveTimer(45, 313033, nil, "Tank|Healer", nil, 5, nil, DBM_CORE_TANK_ICON)
local timerNextPhasePunch		= mod:NewNextTimer(16, 313033, nil, "Tank|Healer", nil, 5, nil, DBM_CORE_TANK_ICON)

local warned_preP2 = false
local warned_star = false

function mod:OnCombatStart(delay)
        DBM:FireCustomEvent("DBM_EncounterStart", 32871, "Algalon")
	warned_preP2 = false
	warned_star = false
	local text = select(3, GetWorldStateUIInfo(1)) 
	local _, _, time = string.find(text, L.PullCheck)
	if not time then 
        	time = 60 
    	end
	time = tonumber(time)
	if time == 60 then
		timerCombatStart:Start(26.5-delay)
		self:ScheduleMethod(26.5-delay, "startTimers")	-- 26 seconds roleplaying
	else 
		timerCombatStart:Start(8-delay)
		self:ScheduleMethod(8-delay, "startTimers")	-- 8 seconds roleplaying
	end 
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 32871, "Algalon", wipe)
        DBM.BossHealth:Hide()
        DBM.RangeCheck:Hide()
end

function mod:startTimers()
	enrageTimer:Start()
	timerNextBigBang:Start()
	announcePreBigBang:Schedule(85)
	timerCDCosmicSmash:Start()
	timerNextCollapsingStar:Start()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(64584, 64443, 312681, 313034) then 	-- Суровый удар
		timerBigBangCast:Start()
		timerNextBigBang:Start()
		announceBigBang:Show()
		announcePreBigBang:Schedule(85)
		specWarnBigBang:Show()
                specWarnBigBang:Play("defensive")
                PlaySoundFile("Sound\\Creature\\AlgalonTheObserver\\UR_Algalon_BHole01.wav")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(65108, 64122, 312686, 313039) then 	-- Взрыв чёрной дыры
		announceBlackHole:Show()
		warned_star = false
	elseif args:IsSpellID(64598, 62301, 313036, 312683) then	-- Кара небесная
		timerCastCosmicSmash:Start()
		timerCDCosmicSmash:Start()
		announceCosmicSmash:Show()
		specWarnCosmicSmash:Show()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(64412, 312680, 313033) then   -- Фазовый удар
                warnPhasePunch:Show(args.destName, args.amount or 1)
                timerPhasePunch:Start(args.destName)
                timerNextPhasePunch:Start()
	end
end

mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(64412, 312680, 313033) then		-- фазовый удар
                timerPhasePunch:Stop()
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
	if msg == L.Emote_CollapsingStar or msg:find(L.Emote_CollapsingStar) then
		timerNextCollapsingStar:Start()
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.Phase2 or msg:find(L.Phase2) then
		timerNextCollapsingStar:Cancel()
		warnPhase2:Show()
	end
end

function mod:UNIT_HEALTH(uId)
	if not warned_preP2 and self:GetUnitCreatureId(uId) == 32871 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.23 then
		warned_preP2 = true
		warnPhase2Soon:Show()
	elseif not warned_star and self:GetUnitCreatureId(uId) == 32955 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.25 then
		warned_star = true
		specwarnStarLow:Show()
	end
end