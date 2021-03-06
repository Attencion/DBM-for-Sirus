local mod	= DBM:NewMod("PlagueworksTrash", "DBM-Icecrown", 2)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20200405141240")
mod:SetCreatureID(36880)

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_SUMMON",
	"SPELL_AURA_REMOVED",
	"SPELL_CAST_START",
	"UNIT_DIED",
	"CHAT_MSG_MONSTER_YELL"
)
local warnDirectRad     = mod:NewTargetAnnounce(71103, 1)  -- Излучение
local warnZombies		= mod:NewSpellAnnounce(71159, 2)
local warnMortalWound	= mod:NewAnnounce("WarnMortalWound", 2, 71127, false)
local warnDecimateSoon	= mod:NewSoonAnnounce(71123, 3)

local specWarnDecimate		= mod:NewSpecialWarningSpell(71123, nil, nil, nil, 1, 2)
local specWarnMortalWound	= mod:NewSpecialWarningStack(71127, nil, 5)
local specWarnTrap			= mod:NewSpecialWarning("SpecWarnTrap")
local specWarnBlightBomb	= mod:NewSpecialWarningSpell(71088, nil, nil, nil, 1, 2)
local specWarnDirectRad		= mod:NewSpecialWarningYou(71103, nil, nil, nil, 1, 2)  -- Излучение

local timerDirectRad	= mod:NewBuffActiveTimer(20, 71103, nil, nil, nil, 3, nil, DBM_CORE_MAGIC_ICON)
local timerZombies		= mod:NewNextTimer(20, 71159, nil, nil, nil, 1)
local timerMortalWound	= mod:NewTargetTimer(15, 71127, nil, nil, nil, 3)
local timerDecimate		= mod:NewNextTimer(33, 71123, nil, nil, nil, 2)
local timerBlightBomb	= mod:NewCastTimer(5, 71088, nil, nil, nil, 3)

mod:RemoveOption("HealthFrame")

local spamZombies = 0

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(71127) then
		warnMortalWound:Show(args.spellName, args.destName, args.amount or 1)
		timerMortalWound:Start(args.destName)
		if args:IsPlayer() and (args.amount or 1) >= 5 then
			specWarnMortalWound:Show(args.amount)
		end
	elseif args:IsSpellID(71103) then  -- Излучение
		if args:IsPlayer() then
			specWarnDirectRad:Show()
		end
		warnDirectRad:Show(args.destName)
		timerDirectRad:Start(args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(71103) then	-- Излучение
		timerDirectRad:Cancel()
	end
end

mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_SUMMON(args)
	if args:IsSpellID(71159) and GetTime() - spamZombies > 5 then
		warnZombies:Show()
		timerZombies:Start()
		spamZombies = GetTime()
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(71123) then
		specWarnDecimate:Show()
		warnDecimateSoon:Cancel()	-- in case the first 1 is inaccurate, you wont have an invalid soon warning
		warnDecimateSoon:Schedule(28)
		timerDecimate:Start()
	elseif args:IsSpellID(71088) then
		specWarnBlightBomb:Show()
		timerBlightBomb:Start()
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 37025 then
		warnDecimateSoon:Cancel()
		timerDecimate:Cancel()
	elseif cid == 37217 then
		timerZombies:Cancel()
		warnDecimateSoon:Cancel()
		timerDecimate:Cancel()
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if (msg == L.FleshreaperTrap1 or msg == L.FleshreaperTrap2 or msg == L.FleshreaperTrap3) and mod:LatencyCheck() then
		self:SendSync("FleshTrap")
	end
end

function mod:OnSync(msg, arg)
	if msg == "FleshTrap" then
		specWarnTrap:Show()
	end
end