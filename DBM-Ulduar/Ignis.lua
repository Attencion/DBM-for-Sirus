local mod	= DBM:NewMod("Ignis", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210501002000")


mod:SetCreatureID(33118)
mod:RegisterCombat("yell", L.YellPull)
mod:SetUsedIcons(8)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_REMOVED"
)

local announceSlagPot		   = mod:NewTargetAnnounce(312731, 3)

local warnFlameJetsCast		   = mod:NewSpecialWarningCast(312727, "SpellCaster")

local timerFlameJetsCast	   = mod:NewCastTimer(2.7, 312727, nil, nil, nil, 2, nil)
local timerFlameJetsCooldown   = mod:NewCDTimer(33, 312727, nil, nil, nil, 2, nil, DBM_CORE_INTERRUPT_ICON)
local timerScorchCooldown	   = mod:NewCDTimer(31, 312730, nil, nil, nil, 2, nil, DBM_CORE_HEALER_ICON)
local timerScorchCast		   = mod:NewCastTimer(3, 312730, nil, nil, nil, 2, nil, DBM_CORE_HEALER_ICON)
local timerSlagPot		       = mod:NewTargetTimer(10, 312731, nil, nil, nil, 3, nil)
local timerAchieve		       = mod:NewAchievementTimer(240, 6745, "TimerSpeedKill")

local yellSlagPot		       = mod:NewYell(312731)

mod:AddSetIconOption("SlagPotIcon", 312731, true, false, {8})

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 33118, "Ignis")
	timerAchieve:Start()
	timerScorchCooldown:Start(12-delay)
	timerFlameJetsCooldown:Start(33-delay)
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 33118, "Ignis", wipe)
    DBM.RangeCheck:Hide()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(63472, 62680, 312727, 312374) then --Огненная струя
		timerFlameJetsCast:Start()
		warnFlameJetsCast:Show()
		timerFlameJetsCooldown:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(62548, 312729) then --Ожог
		timerScorchCast:Start()
		timerScorchCooldown:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(62717, 63477, 312378, 312731) then --Ковш
		announceSlagPot:Show(args.destName)
		timerSlagPot:Start(args.destName)
		if args:IsPlayer() and self.Options.SlagPotIcon then
		self:SetIcon(args.destName, 8, 10)
		yellSlagPot:Yell()	
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(62717, 63477, 312378, 312731) then --Ковш
		if self.Options.SlagPotIcon then
			self:SetIcon(args.destName, 0)
		end
	end
end