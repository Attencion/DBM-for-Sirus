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
	"SPELL_CAST_SUCCESS",
        "SPELL_AURA_REMOVED"
)

mod:AddBoolOption("HealthFrame", true)

mod:SetBossHealthInfo(
	32867, L.Steelbreaker,
	32927, L.RunemasterMolgeim,
	32857, L.StormcallerBrundir
)


-- Stormcaller Brundir
-- High Voltage ... 63498
local warnChainlight			= mod:NewSpellAnnounce(312780, 1)
local timerOverload			= mod:NewCastTimer(6, 312781, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)
local timerLightningWhirl		= mod:NewCastTimer(5, 312783)
local specwarnLightningTendrils	        = mod:NewSpecialWarningRun(312786)
local timerLightningTendrils	        = mod:NewBuffActiveTimer(27, 312786, nil, nil, nil, 7, nil, DBM_CORE_DEADLY_ICON)
local specwarnOverload			= mod:NewSpecialWarningRun(312781)
local specwarnStaticDisruption		= mod:NewSpecialWarningMoveAway(312770, 3) 
mod:AddBoolOption("AlwaysWarnOnOverload", false, "announce")
mod:AddBoolOption("PlaySoundLightningTendrils", true)

-- Steelbreaker
-- High Voltage ... don't know what to show here - 63498
local warnFusionPunch			= mod:NewSpellAnnounce(312769, 4)
local timerFusionPunchCast		= mod:NewCastTimer(3, 312769, nil, nil, nil, 7, nil, DBM_CORE_DEADLY_ICON)
local timerFusionPunchActive	        = mod:NewTargetTimer(4, 312769, nil, nil, nil, 7, nil, DBM_CORE_HEALER_ICON)
local warnOverwhelmingPower		= mod:NewTargetAnnounce(312772, 2)
local timerOverwhelmingPower	        = mod:NewTargetTimer(35, 312772, nil, nil, nil, 2, nil, DBM_CORE_INTERRUPT_ICON)
local warnStaticDisruption		= mod:NewTargetAnnounce(312770, 3)
local specwarnFusionPunch               = mod:NewSpecialWarningDefensive(312769, "Tank", 2) 
mod:AddSetIconOption("SetIconOnOverwhelmingPower", 312772, true, false, {8})
mod:AddSetIconOption("SetIconOnStaticDisruption", 312770, true, false, {7, 6, 5, 4, 3, 2, 1})

-- Runemaster Molgeim
-- Lightning Blast ... don't know, maybe 63491
local timerShieldofRunesCD		= mod:NewCDTimer(30, 312775, nil, nil, nil, 7, nil, DBM_CORE_DEADLY_ICON)
local warnRuneofPower			= mod:NewTargetAnnounce(312776, 2)
local warnRuneofDeath			= mod:NewSpellAnnounce(312777, 2)
local warnShieldofRunes			= mod:NewSpellAnnounce(312774, 2)
local warnRuneofSummoning		= mod:NewSpellAnnounce(312778, 3)
local specwarnRuneofDeath		= mod:NewSpecialWarningMove(312777)
local timerRuneofPower			= mod:NewCDTimer(30, 312776, nil, nil, nil, 7, nil, DBM_CORE_DAMAGE_ICON)
local timerRuneofDeath			= mod:NewCDTimer(30, 312777, nil, nil, nil, 7, nil, DBM_CORE_DEADLY_ICON)

local yellStaticDisruption		= mod:NewYell(312770)

mod:AddBoolOption("PlaySoundDeathRune", true, "announce")
mod:AddBoolOption("YellOnOverwhelmingPower", true)

local enrageTimer			= mod:NewBerserkTimer(900)

local disruptTargets = {}
local disruptIcon = 7

function mod:OnCombatStart(delay)
        DBM:FireCustomEvent("DBM_EncounterStart", 32927, "IronCouncil")
	enrageTimer:Start(-delay)
	table.wipe(disruptTargets)
	disruptIcon = 7
	timerRuneofPower:Start(20-delay)
	timerShieldofRunesCD:Start(-delay)
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 32927, "IronCouncil", wipe)
	DBM.RangeCheck:Hide()
        DBM.BossHealth:Hide()
end

function mod:RuneTarget()
	local targetname = self:GetBossTarget(32927)
	if not targetname then return end
		warnRuneofPower:Show(targetname)
end

local function warnStaticDisruptionTargets()
	warnStaticDisruption:Show(table.concat(disruptTargets, "<, >"))
	table.wipe(disruptTargets)
	disruptIcon = 7
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(63479, 61879, 312427, 312780) then	        -- Цепная молния
		warnChainlight:Show()
	elseif args:IsSpellID(63483, 61915, 312783, 312430) then	-- Вихрь молний
		timerLightningWhirl:Start()
	elseif args:IsSpellID(61903, 63493, 312416, 312769) then	-- Энергетический удар
		warnFusionPunch:Show()
		timerFusionPunchCast:Start()
                if args:IsPlayer() then
			specwarnFusionPunch:Show()
			specwarnFusionPunch:Play("defensive")
                        PlaySoundFile("Sound\\Creature\\AlgalonTheObserver\\UR_Algalon_BHole01.wav")
		end
	elseif args:IsSpellID(62274, 63489, 312421, 312774) then	-- Рунический щит
		warnShieldofRunes:Show()
		timerShieldofRunesCD:Start()
                PlaySoundFile("Sound\\Creature\\AlgalonTheObserver\\UR_Algalon_BHole01.wav")
        elseif args:IsSpellID(64320, 61974, 312423, 312776) then        -- руна мощи
                timerRuneofPower:Start()
                warnRuneofPower:Show()
	elseif args:IsSpellID(62273, 312425, 312778) then		-- Руна призыва
		warnRuneofSummoning:Show()
        elseif args:IsSpellID(61869, 63481, 312428, 312781) then	-- Перегрузка
                specwarnOverload:Show()
                PlaySoundFile("Sound\\Creature\\illidan\\black_illidan_04.wav")
	end
end

function mod:UNIT_DIED(args)
	if args.destName == L.StormcallerBrundir then
        timerRuneofPower:Start(25)
        timerRuneofDeath:Start()
        timerShieldofRunesCD:Start(27)
        elseif args.destName == L.RunemasterMolgeim then
        timerRuneofPower:Cancel()
        timerRuneofDeath:Cancel()		
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(61903, 63493, 312416, 312769) then            -- Энергетический удар
		timerFusionPunchActive:Cancel()
        elseif args:IsSpellID(312418, 312419, 312771, 312772) then
                timerOverwhelmingPower:Cancel()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(63490, 62269, 312424, 312777) then		-- Руна смерти
		warnRuneofDeath:Show()
		timerRuneofDeath:Start()
	elseif args:IsSpellID(64320, 61974, 312423, 312776) then	-- Руна мощи
		self:ScheduleMethod(0.1, "RuneTarget")
		timerRuneofPower:Start()
	elseif args:IsSpellID(61869, 63481, 312428, 312781) then	-- Перегрузка
		timerOverload:Start()
		if self.Options.AlwaysWarnOnOverload or UnitName("target") == L.StormcallerBrundir then
			specwarnOverload:Show()
                        specwarnOverload:Play("justrun")
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(61903, 63493, 312416, 312769) then		-- Энергетический удар
		timerFusionPunchActive:Start(args.destName)
                specwarnFusionPunch:Show()
	elseif args:IsSpellID(62269, 63490, 312424, 312777) then	-- Руна смерти
		if args:IsPlayer() then
			specwarnRuneofDeath:Show()
                        specwarnRuneofDeath:Play("runaway")
			if self.Options.PlaySoundDeathRune then
				PlaySoundFile("Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav")
			end
		end		
	elseif args:IsSpellID(312418, 312419, 312771, 312772) then	-- Переполняющая энергия
		warnOverwhelmingPower:Show(args.destName)
		if mod:IsDifficulty("heroic10") then
			timerOverwhelmingPower:Start(35, args.destName)
		else
			timerOverwhelmingPower:Start(35, args.destName)
		end
		if self.Options.SetIconOnOverwhelmingPower then
			if mod:IsDifficulty("heroic10") then
				self:SetIcon(args.destName, 8, 35) -- skull for 60 seconds (until meltdown)
			else
				self:SetIcon(args.destName, 8, 35) -- skull for 35 seconds (until meltdown)
			end
		end
                if self.Options.YellOnOverwhelmingPower and args:IsPlayer() then
				SendChatMessage(L.YellOverwhelmingPower, "SAY")
                                DBM.RangeCheck:Show(15)
                end
	elseif args:IsSpellID(63486, 61887, 312432, 312433, 312785, 312786) then	-- Светящиеся придатки
		timerLightningTendrils:Start()
		specwarnLightningTendrils:Show()
		if self.Options.PlaySoundLightningTendrils then
			PlaySoundFile("Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav")
		end
	elseif args:IsSpellID(61912, 63494, 312417, 312770) then	-- Статический сбой (Hard Mode)
		disruptTargets[#disruptTargets + 1] = args.destName
		if self.Options.SetIconOnStaticDisruption then 
			self:SetIcon(args.destName, disruptIcon, 20)
			disruptIcon = disruptIcon - 1
		end
                if args:IsPlayer() then
                        yellStaticDisruption:Yell()
                end
		self:Unschedule(warnStaticDisruptionTargets)
		self:Schedule(0.3, warnStaticDisruptionTargets)
	end
end


