local mod	= DBM:NewMod("IronCouncil", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210501003000")

mod:SetCreatureID(32927)
mod:RegisterCombat("combat", 32867, 32927, 32857)
mod:SetUsedIcons(1, 2, 3, 4, 5, 6, 7, 8)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"UNIT_DIED",
	"SPELL_AURA_REMOVED",
	"SPELL_CAST_SUCCESS"
)

mod:AddBoolOption("HealthFrame", true)

mod:SetBossHealthInfo(
	32867, L.Steelbreaker,
	32927, L.RunemasterMolgeim,
	32857, L.StormcallerBrundir
)

local warnSupercharge			= mod:NewSpellAnnounce(312766, 4)

--Брундир
-- High Voltage ... 63498
local warnChainlight			= mod:NewSpellAnnounce(312780, 2, nil, false, 2)
local timerOverload				= mod:NewCastTimer(6, 312782, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON) --перезагрузка
local timerLightningWhirl		= mod:NewCastTimer(5, 312783, nil, nil, nil, 4, nil, DBM_CORE_INTERRUPT_ICON) --вихрь молний
local specwarnLightningTendrils	= mod:NewSpecialWarningRun(312786, nil, nil, nil, 1, 2) --придатки
local timerLightningTendrils	= mod:NewBuffActiveTimer(27, 312786, nil, nil, nil, 6) --придатки
local specwarnOverload			= mod:NewSpecialWarningRun(312781, nil, nil, nil, 1, 2) --перезагрузка
local specWarnLightningWhirl	= mod:NewSpecialWarningInterrupt(63483, "HasInterrupt", nil, nil, 1, 2)
mod:AddBoolOption("AlwaysWarnOnOverload", false, "announce")
--local specwarnStaticDisruption		= mod:NewSpecialWarningMoveAway(312770)
mod:AddBoolOption("PlaySoundOnOverload", true)
mod:AddBoolOption("PlaySoundLightningTendrils", true)

--Сталелом
-- High Voltage ... don't know what to show here - 63498
local warnFusionPunch			= mod:NewSpellAnnounce(312769, 4)
local timerFusionPunchCast		= mod:NewCastTimer(3, 312769, nil, nil, nil, 5, nil, DBM_CORE_TANK_ICON)
local timerFusionPunchActive	= mod:NewTargetTimer(4,312769, nil, nil, nil, 5, nil, DBM_CORE_MAGIC_ICON)
local warnOverwhelmingPower		= mod:NewTargetAnnounce(312772, 2)
local timerOverwhelmingPower	= mod:NewTargetTimer(25, 312772, nil, nil, nil, 5, nil, DBM_CORE_DEADLY_ICON)
local warnStaticDisruption		= mod:NewTargetAnnounce(312770, 3)
local timerStaticDisruption		= mod:NewCDTimer(30, 312770, nil, nil, nil, 5, nil, DBM_CORE_HEALER_ICON)
local specwarnFusionPunch       = mod:NewSpecialWarningDefensive(312769, "Tank", nil, nil, 2, 2)
mod:AddSetIconOption("SetIconOnOverwhelmingPower", 312772, true, true, {8})
mod:AddSetIconOption("SetIconOnStaticDisruption", 312770, true, true, {7, 6, 5, 4, 3, 2, 1})

--Молгейм
-- Lightning Blast ... don't know, maybe 63491
local timerShieldofRunes		= mod:NewBuffActiveTimer(15, 312775)
local timerShieldofRunesCD		= mod:NewCDTimer(30, 312775, nil, nil, nil, 3, nil, DBM_CORE_DEADLY_ICON)
local warnRuneofPower			= mod:NewTargetAnnounce(61973, 2) -- Руна мощи
local warnRuneofDeath			= mod:NewSpellAnnounce(312777, 4) -- Руна смерти
local warnShieldofRunes			= mod:NewSpellAnnounce(312774, 3) -- Руна щита
local warnRuneofSummoning		= mod:NewSpellAnnounce(312779, 3) --Руна призыва
local specwarnRuneofDeath		= mod:NewSpecialWarningMove(312777, nil, nil, nil, 1, 2) --руна смерти
local specWarnRuneofShields		= mod:NewSpecialWarningDispel(312774, "MagicDispeller", nil, nil, 1, 2)
local timerRuneofDeathDura		= mod:NewNextTimer(30, 312777, nil, nil, nil, 3, nil, DBM_CORE_DEADLY_ICON) --руна смерти
local timerRuneofPower			= mod:NewCDTimer(30, 61973, nil, nil, nil, 5, nil, DBM_CORE_TANK_ICON)
local timerRuneofSummoning		= mod:NewCDTimer(24.1, 62273, nil, nil, nil, 1)

local yellStaticDisruption		= mod:NewYell(312770)

--[[local timerRuneofDeath			= mod:NewCDTimer(30, 312777)
local yellOverwhelmingPowerFades	= mod:NewFadesYell(312772)
local yellStaticDisruptionFades		= mod:NewFadesYell(312770)]]

mod:AddBoolOption("PlaySoundDeathRune", true, "announce")
mod:AddBoolOption("YellOnOverwhelmingPower", true)


local enrageTimer				= mod:NewBerserkTimer(900)

local disruptTargets = {}
mod.vb.disruptIcon = 7

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 32927, "IronCouncil")
	enrageTimer:Start(-delay)
	table.wipe(disruptTargets)
	mod.vb.disruptIcon = 7
	timerRuneofPower:Start(20-delay)
	timerShieldofRunesCD:Start(-delay)
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 32927, "IronCouncil", wipe)
	DBM.RangeCheck:Hide()
	DBM.BossHealth:Hide()
end

function mod:RuneTarget(targetname, uId)
	if not targetname then return end
		warnRuneofPower:Show(targetname)
end

local function warnStaticDisruptionTargets()
	warnStaticDisruption:Show(table.concat(disruptTargets, "<, >"))
	table.wipe(disruptTargets)
	mod.vb.disruptIcon = 7
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(61920, 312766, 312413) then --Суперзаряд
		warnSupercharge:Show()
	elseif args:IsSpellID(63479, 61879, 312427, 312780) then --Цепная молния
		warnChainlight:Show()
	elseif args:IsSpellID(63483, 61915, 312783, 312430) then --Вихрь молний
		timerLightningWhirl:Start()
	elseif args:IsSpellID(61903, 63493, 312416, 312769) then --Энергетический удар
		warnFusionPunch:Show()
		timerFusionPunchCast:Start()
	elseif args:IsSpellID(62274, 63489, 312421, 312774) then --Рунический щит
		warnShieldofRunes:Show()
		timerShieldofRunesCD:Start()
	elseif args:IsSpellID(64320, 61974, 312423, 312776) then --руна мощи
		timerRuneofPower:Start()
		warnRuneofPower:Show()
	elseif args:IsSpellID(312779, 312778, 312425, 312426) then --Руна призыва
		warnRuneofSummoning:Show()
	elseif args:IsSpellID(61869, 63481, 312428, 312781) then --Перегрузка
		specwarnOverload:Show()
		if self.Options.PlaySoundOnOverload then
			PlaySoundFile("Sound\\Creature\\LadyMalande\\BLCKTMPLE_LadyMal_Aggro01.wav")
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(63490, 62269, 312424, 312777) then --Руна смерти
		warnRuneofDeath:Show()
		timerRuneofDeathDura:Start()
	elseif args:IsSpellID(61973, 61974, 64320) then --Руна мощи
		self:ScheduleMethod(0.1, "RuneTarget", 0.1, 16, true, true)
		timerRuneofPower:Start()
	elseif args:IsSpellID(61912, 63494, 312417, 312770) then --Статический сбой
		timerStaticDisruption:Start()
	elseif args:IsSpellID(61869, 63481, 312428, 312781) then --Перегрузка
		timerOverload:Start()
		if self.Options.AlwaysWarnOnOverload or UnitName("target") == L.StormcallerBrundir then
			specwarnOverload:Show()
			specwarnOverload:Play("justrun")
			if self.Options.PlaySoundOnOverload then
				PlaySoundFile("Sound\\Creature\\LadyMalande\\BLCKTMPLE_LadyMal_Aggro01.wav")
			end
		end
	end
end
--Продолжить с этого момента
function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 32867 then --Сталелом
        timerStaticDisruption:Cancel()
	elseif cid == 32927 then --Молгейм
        timerRuneofPower:Cancel()
        timerRuneofDeathDura:Cancel()
		timerShieldofRunesCD:Cancel()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(61903, 63493, 312416, 312769) then --Энергетический удар
		timerFusionPunchActive:Cancel()
	elseif args:IsSpellID(312418, 312419, 312771, 312772) then --Переполняющая мощь
		timerOverwhelmingPower:Cancel()
	elseif args:IsSpellID(62274, 63489, 312421, 312774) and not args:IsDestTypePlayer() then --Рунический щит
		timerShieldofRunes:Cancel()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(312769, 312416) then --Энергетический удар
		timerFusionPunchActive:Start(args.destName)
	elseif args:IsSpellID(312424, 312777) then --Руна смерти
		if args:IsPlayer() then
			specwarnRuneofDeath:Show()
			specwarnRuneofDeath:Play("runaway")
			if self.Options.PlaySoundDeathRune then
				PlaySoundFile("Sound\\Creature\\LadyMalande\\BLCKTMPLE_LadyMal_Aggro01.wav")
			end
		end
	elseif args:IsSpellID(62274, 63489, 312421, 312774) and not args:IsDestTypePlayer() then --Рунический щит
		timerShieldofRunes:Start()
		specWarnRuneofShields:Show(args.destName)
		specWarnRuneofShields:Play("dispelboss")
	elseif args:IsSpellID(312771, 312772, 312418, 312419) then --Переполняющая энергия
		warnOverwhelmingPower:Show(args.destName)
		if mod:IsDifficulty("heroic10") then
			timerOverwhelmingPower:Start(60, args.destName)
		else
			timerOverwhelmingPower:Start(35, args.destName)
		end

		if self.Options.SetIconOnOverwhelmingPower then
			if mod:IsDifficulty("heroic10") then
				self:SetIcon(args.destName, 8, 60) -- skull for 60 seconds (until meltdown)
			else
				self:SetIcon(args.destName, 8, 35) -- skull for 35 seconds (until meltdown)
			end
		end
	elseif args:IsSpellID(312786, 312785, 312432, 312433) then --Светящиеся придатки
		timerLightningTendrils:Start()
		specwarnLightningTendrils:Show()
		specwarnLightningTendrils:Play("justrun")
		if self.Options.PlaySoundLightningTendrils then
			PlaySoundFile("Sound\\Creature\\LadyMalande\\BLCKTMPLE_LadyMal_Aggro01.wav")
		end
	elseif args:IsSpellID(312770, 312417, 63495) then --Статический сбой
		disruptTargets[#disruptTargets + 1] = args.destName
		if self.Options.SetIconOnStaticDisruption and self.vb.disruptIcon > 0 then
			self:SetIcon(args.destName, self.vb.disruptIcon, 20)
			self.vb.disruptIcon = self.vb.disruptIcon - 1
		end
		self:Unschedule(warnStaticDisruptionTargets)
		self:Schedule(0.3, warnStaticDisruptionTargets)
	elseif args:IsSpellID(63483, 61915) then	-- LightningWhirl
		timerLightningWhirl:Start()
		if self:CheckInterruptFilter(args.destGUID, false, true) then
			specWarnLightningWhirl:Show(args.destName)
			specWarnLightningWhirl:Play("kickcast")
		end
	end
end