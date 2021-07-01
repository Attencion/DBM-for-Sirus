local mod	= DBM:NewMod("IronCouncil", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 4154 $"):sub(12, -3))
mod:SetCreatureID(32927)
mod:SetUsedIcons(1, 2, 3, 4, 5, 6, 7, 8)

mod:RegisterCombat("combat", 32867, 32927, 32857)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_CAST_SUCCESS",
	"UNIT_DIED"	
)

mod:AddBoolOption("HealthFrame", true)

mod:SetBossHealthInfo(
	32867, L.Steelbreaker,
	32927, L.RunemasterMolgeim,
	32857, L.StormcallerBrundir
)


-- Stormcaller Brundir
-- High Voltage ... 63498
local warnChainlight			= mod:NewSpellAnnounce(64215, 1)
local timerOverload				= mod:NewCastTimer(6, 312781)
local timerLightningWhirl		= mod:NewCastTimer(5, 312783)
local specwarnLightningTendrils	= mod:NewSpecialWarningRun(312786)
local timerLightningTendrils	= mod:NewBuffActiveTimer(27, 312786)
local specwarnOverload			= mod:NewSpecialWarningRun(312781) 
mod:AddBoolOption("AlwaysWarnOnOverload", false, "announce")
mod:AddBoolOption("PlaySoundOnOverload", true)
mod:AddBoolOption("PlaySoundLightningTendrils", true)

-- Steelbreaker
-- High Voltage ... don't know what to show here - 63498
local warnFusionPunch			= mod:NewSpellAnnounce(312769, 4)
local timerFusionPunchCast		= mod:NewCastTimer(3, 312769)
local timerFusionPunchActive	= mod:NewTargetTimer(4, 312769, "Удар - %s")
local warnOverwhelmingPower		= mod:NewTargetAnnounce(312772, 2)
local timerOverwhelmingPower	= mod:NewTargetTimer(35, 312772, "Энергия - %s")
local warnStaticDisruption		= mod:NewTargetAnnounce(312770, 3) 
mod:AddBoolOption("SetIconOnOverwhelmingPower")
mod:AddBoolOption("SetIconOnStaticDisruption")

-- Runemaster Molgeim
-- Lightning Blast ... don't know, maybe 63491
local timerShieldofRunesCD		= mod:NewCDTimer(30, 312775)
local warnRuneofPower			= mod:NewTargetAnnounce(64320, 2)
local warnRuneofDeath			= mod:NewSpellAnnounce(312777, 2)
local warnShieldofRunes			= mod:NewSpellAnnounce(312774, 2)
local warnRuneofSummoning		= mod:NewSpellAnnounce(312778, 3)
local specwarnRuneofDeath		= mod:NewSpecialWarningMove(312777)
local timerRuneofPower			= mod:NewCDTimer(30, 64320)
local timerRuneofDeath			= mod:NewCDTimer(30, 312777)
mod:AddBoolOption("PlaySoundDeathRune", true, "announce")

local enrageTimer				= mod:NewBerserkTimer(900)

local disruptTargets = {}
local disruptIcon = 7

function mod:OnCombatStart(delay)
	enrageTimer:Start(-delay)
	table.wipe(disruptTargets)
	disruptIcon = 7
	timerRuneofPower:Start(20-delay)
	timerShieldofRunesCD:Start(-delay)
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
	if args:IsSpellID(63479, 61879, 312427, 312780) then	-- Chain light
		warnChainlight:Show()
	elseif args:IsSpellID(63483, 61915, 312783, 312430) then	-- LightningWhirl
		timerLightningWhirl:Start()
	elseif args:IsSpellID(61903, 63493, 312416, 312769) then	-- Fusion Punch
		warnFusionPunch:Show()
		timerFusionPunchCast:Start()
	elseif args:IsSpellID(62274, 63489, 312421, 312774) then		-- Shield of Runes
		warnShieldofRunes:Show()
		timerShieldofRunesCD:Start()
	elseif args:IsSpellID(62273, 312425, 312778) then				-- Rune of Summoning
		warnRuneofSummoning:Show()
	end
end

function mod:UNIT_DIED(args)
	if args.destName == L.StormcallerBrundir then
        timerRuneofPower:Start(25)
        timerRuneofDeath:Start()
        timerShieldofRunesCD:Start(27)		
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(63490, 62269, 312424, 312777) then		-- Rune of Death
		warnRuneofDeath:Show()
		timerRuneofDeath:Start()
	elseif args:IsSpellID(64321, 61974, 312423, 312776) then	-- Rune of Power
		self:ScheduleMethod(0.1, "RuneTarget")
		timerRuneofPower:Start()
	elseif args:IsSpellID(61869, 63481, 312428, 312781) then	-- Overload
		timerOverload:Start()
		if self.Options.AlwaysWarnOnOverload or UnitName("target") == L.StormcallerBrundir then
			specwarnOverload:Show()
			if self.Options.PlaySoundOnOverload then
				PlaySoundFile("Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav")
			end
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(61903, 63493, 312416, 312769) then		-- Fusion Punch
		timerFusionPunchActive:Start(args.destName)
	elseif args:IsSpellID(62269, 63490, 312424, 312777) then	-- Rune of Death - move away from it
		if args:IsPlayer() then
			specwarnRuneofDeath:Show()
			if self.Options.PlaySoundDeathRune then
				PlaySoundFile("Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav")
			end
		end		
	elseif args:IsSpellID(312418, 312419, 312771, 312772) then	-- Overwhelming Power
		warnOverwhelmingPower:Show(args.destName)
		if mod:IsDifficulty("heroic10") or mod:IsDifficulty("heroic25") then
			timerOverwhelmingPower:Start(60, args.destName)
		else
			timerOverwhelmingPower:Start(35, args.destName)
		end
		if self.Options.SetIconOnOverwhelmingPower then
			if mod:IsDifficulty("heroic10") or mod:IsDifficulty("heroic25") then
				self:SetIcon(args.destName, 8, 60) -- skull for 60 seconds (until meltdown)
			else
				self:SetIcon(args.destName, 8, 35) -- skull for 35 seconds (until meltdown)
			end
		end
	elseif args:IsSpellID(63486, 61887, 312432, 312433, 312785, 312786) then	-- Lightning Tendrils
		timerLightningTendrils:Start()
		specwarnLightningTendrils:Show()
		if self.Options.PlaySoundLightningTendrils then
			PlaySoundFile("Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav")
		end
	elseif args:IsSpellID(61912, 63494, 312417, 312770) then	-- Static Disruption (Hard Mode)
		disruptTargets[#disruptTargets + 1] = args.destName
		if self.Options.SetIconOnStaticDisruption then 
			self:SetIcon(args.destName, disruptIcon, 20)
			disruptIcon = disruptIcon - 1
		end
		self:Unschedule(warnStaticDisruptionTargets)
		self:Schedule(0.3, warnStaticDisruptionTargets)
	end
end


