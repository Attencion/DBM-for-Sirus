﻿local mod	= DBM:NewMod("Algalon", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210501000000")
mod:SetCreatureID(32871)

mod:RegisterCombat("combat", "yell", L.YellPull)
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

local warnPhasePunch		    = mod:NewStackAnnounce(313033, 1, nil, "Tank|Healer")
local announceBigBang			= mod:NewSpellAnnounce(313034, 4)
local warnPhase2				= mod:NewPhaseAnnounce(2)
local warnPhase2Soon			= mod:NewAnnounce("WarnPhase2Soon", 2)
local announcePreBigBang		= mod:NewPreWarnAnnounce(313034, 5, 3)
local announceBlackHole			= mod:NewSpellAnnounce(313039, 3)
local announceCosmicSmash		= mod:NewAnnounce("WarningCosmicSmash", 3, 313036)

local specwarnStarLow			= mod:NewSpecialWarning("warnStarLow", "Tank|Healer", nil, nil, 1, 2)
local specWarnPhasePunch		= mod:NewSpecialWarningStack(313033, nil, 3, nil, nil, 1, 6)
local specWarnPhasePunchlf		= mod:NewSpecialWarningTaunt(313033, "Tank", nil, nil, 1, 2)
local specWarnBigBang			= mod:NewSpecialWarningDefensive(313034, nil, nil, nil, 3, 2)
local specWarnCosmicSmash		= mod:NewSpecialWarningDodge(313036, nil, nil, nil, 2, 2)

local timerCombatStart		    = mod:NewTimer(7, "TimerCombatStart", 2457)
local enrageTimer				= mod:NewBerserkTimer(360)
local timerNextBigBang			= mod:NewNextTimer(90.5, 313034, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)
local timerBigBangCast			= mod:NewCastTimer(8, 313034, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)
local timerNextCollapsingStar	= mod:NewTimer(15, "NextCollapsingStar", nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)
local timerCDCosmicSmash		= mod:NewCDTimer(25, 64598, nil, nil, nil, 2, nil, DBM_CORE_HEALER_ICON)
local timerCastCosmicSmash		= mod:NewCastTimer(4.5, 64598, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)
local timerPhasePunch			= mod:NewBuffActiveTimer(45, 313033, nil, "Tank", nil, 5, nil)
local timerNextPhasePunch		= mod:NewNextTimer(16, 313033, nil, "Tank", nil, 5, nil)


local warned_preP2 = false
local warned_star = false
local combattime = 0

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 32871, "Algalon")
	warned_preP2 = false
	warned_star = false
	combattime = GetTime()
	local text = select(3, GetWorldStateUIInfo(1))
	local _, _, time = string.find(text, L.PullCheck)
	if not time then
		time = 60
	end
	time = tonumber(time)
	if time == 60 then
		timerCombatStart:Start(26.5-delay)
		self:ScheduleMethod(26.5-delay, "startTimers")
	else
		timerCombatStart:Start(-delay)
		self:ScheduleMethod(8-delay, "startTimers")
	end
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 32871, "Algalon", wipe)
end

function mod:startTimers()
	enrageTimer:Start()
	timerNextBigBang:Start()
	announcePreBigBang:Schedule(85)
	timerCDCosmicSmash:Start()
	timerNextCollapsingStar:Start()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(64584, 64443, 312681, 313034) then --Суровый удар
		timerBigBangCast:Start()
		timerNextBigBang:Start()
		announceBigBang:Show()
		announcePreBigBang:Schedule(85)
		specWarnBigBang:Show()
		specWarnBigBang:Play("defensive")
		PlaySoundFile("Sound\\Creature\\illidan\\black_illidan_04.wav")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(313039, 64122, 65108, 312686) then --Взрыв чёрной дыры
		announceBlackHole:Show()
		warned_star = false
	elseif args:IsSpellID(64598, 62301, 313036, 312683, 62304, 64597) then	--Кара небесная
		timerCastCosmicSmash:Start()
		timerCDCosmicSmash:Start()
		announceCosmicSmash:Show()
		specWarnCosmicSmash:Show()
	elseif args:IsSpellID(313033, 312680, 64412) then --Фазовый удар
		timerNextPhasePunch:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(313033, 312680, 64412) then --Фазовый удар
		local amount = args.amount or 1
        if amount >= 3 then
            if args:IsPlayer() then
                specWarnPhasePunch:Show(args.amount)
                specWarnPhasePunch:Play("stackhigh")
            else
				local _, _, _, _, _, expireTime = DBM:UnitDebuff("player", args.spellName)
				local remaining
				if expireTime then
					remaining = expireTime-GetTime()
				end
				if not UnitIsDeadOrGhost("player") and (not remaining or remaining and remaining < 12) then
					specWarnPhasePunchlf:Show(args.destName)
					specWarnPhasePunchlf:Play("tauntboss")
				else
					warnPhasePunch:Show(args.destName, amount)
				end
			end
		else
			warnPhasePunch:Show(args.destName, amount)
			timerPhasePunch:Start(args.destName)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(313033, 312680, 64412) then --Фазовый удар
		timerPhasePunch:Stop(args.destName)
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

mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED