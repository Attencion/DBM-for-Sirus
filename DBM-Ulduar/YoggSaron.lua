local mod	= DBM:NewMod("YoggSaron", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210425232323")

mod:SetCreatureID(33288)
mod:RegisterCombat("yell", L.YellPull)
mod:SetUsedIcons(8, 7, 6, 2, 1)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_SUMMON",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"SPELL_AURA_REMOVED_DOSE",
	"UNIT_HEALTH"
)

mod:SetBossHealthInfo(
	33134, L.Sara,
	33890, L.Mozg,
	33288, L.Saron
)

local warnMadness 				= mod:NewCastAnnounce(313003, 2)
local warnFervorCast 				= mod:NewCastAnnounce(312989, 3)
local warnSqueeze				= mod:NewTargetAnnounce(313031, 3)
local warnFervor				= mod:NewTargetAnnounce(312989, 4)
local warnDeafeningRoarSoon			= mod:NewPreWarnAnnounce(313000, 5, 3)
local warnGuardianSpawned 			= mod:NewAnnounce("WarningGuardianSpawned", 3, 62979)
local warnCrusherTentacleSpawned	        = mod:NewAnnounce("WarningCrusherTentacleSpawned", 2)
local warnP2 					= mod:NewPhaseAnnounce(2, 2)
local warnP3 					= mod:NewPhaseAnnounce(3, 2)
local warnPhase2Soon			        = mod:NewAnnounce("WarnPhase2Soon", 2)
local warnPhase3Soon			        = mod:NewAnnounce("WarnPhase3Soon", 2)
local warnSanity 				= mod:NewAnnounce("WarningSanity", 3, 63050)
local warnBrainLink 				= mod:NewTargetAnnounce(312994, 3)
local warnBrainPortalSoon			= mod:NewAnnounce("WarnBrainPortalSoon", 2)
local warnEmpowerSoon				= mod:NewSoonAnnounce(313014, 4)
local warnDeathCoil 				= mod:NewTargetAnnounce(312993, 3)
local warnLunaricGaze	                        = mod:NewSpellAnnounce(313001, 3)  --Взгляд


local specWarnGuardianLow 			= mod:NewSpecialWarning("SpecWarnGuardianLow", false)
local specWarnBrainLink 			= mod:NewSpecialWarningYou(312994)
local specWarnDeathCoil			        = mod:NewSpecialWarningYou(312993)   -- Душевная болезнь
local specWarnSanity 				= mod:NewSpecialWarning("SpecWarnSanity")
local specWarnMadnessOutNow			= mod:NewSpecialWarning("SpecWarnMadnessOutNow")
local specWarnBrainPortalSoon		        = mod:NewSpecialWarning("specWarnBrainPortalSoon", true)
local specWarnDeafeningRoar			= mod:NewSpecialWarningCast(313000, "SpellCaster")
local specWarnFervor				= mod:NewSpecialWarningYou(312989)
local specWarnFervorCast			= mod:NewSpecialWarning("SpecWarnFervorCast", mod:IsMelee())
local specWarnMaladyNear			= mod:NewSpecialWarning("SpecWarnMaladyNear", true)
local specWarnLunaricGaze		        = mod:NewSpecialWarningLookAway(313001)


local enrageTimer			= mod:NewBerserkTimer(900)
local timerFervor			= mod:NewTargetTimer(15, 312989, nil, nil, nil, 3, nil, DBM_CORE_HEALER_ICON)
local brainportal			= mod:NewTimer(30, "NextPortal")
local timerLunaricGaze			= mod:NewCastTimer(4, 313001, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)
local timerNextLunaricGaze		= mod:NewCDTimer(8.5, 313001, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)
local timerEmpower			= mod:NewCDTimer(46, 64465, nil, nil, nil, 5, nil, DBM_CORE_TANK_ICON)
local timerEmpowerDuration		= mod:NewBuffActiveTimer(10, 64465)
local timerMadness 			= mod:NewCastTimer(60, 313003, nil, nil, nil, 6, nil, DBM_CORE_DAMAGE_ICON)
local timerCastDeafeningRoar		= mod:NewCastTimer(2.3, 313000, nil, nil, nil, 7, nil)
local timerNextDeafeningRoar		= mod:NewNextTimer(30, 313000, nil, nil, nil, 7, nil)
local timerAchieve			= mod:NewAchievementTimer(420, 6790, "TimerSpeedKill")
local timerBrainLinkCD			= mod:NewCDTimer(24, 312994, nil, nil, nil, 3, nil, DBM_CORE_HEROIC_ICON)
local timerDeathCoilCD			= mod:NewCDTimer(22, 312993, nil, nil, nil, 3, nil, DBM_CORE_HEROIC_ICON)

mod:AddBoolOption("ShowSaraHealth")
mod:AddSetIconOption("SetIconOnFearTarget", 312993, true, false, {8})
mod:AddSetIconOption("SetIconOnFervorTarget", 312989, true, false, {7})
mod:AddSetIconOption("SetIconOnBrainLinkTarget", 312994, true, false, {7, 6})
mod:AddSetIconOption("SetIconOnBeacon", 64465, true, false, {8, 7, 6, 2, 1})
mod:AddBoolOption("MaladyArrow")
mod:AddBoolOption("YellOnDeathCoil", true)
mod:AddBoolOption("WarningSqueeze", true)
mod:AddBoolOption("RangeFrame")


local targetWarningsShown			= {}
local brainLinkTargets = {}
local brainLinkIcon = 7
local Guardians = 0

mod.vb.phase = 0
mod.vb.brainLinkIcon = 2
mod.vb.beaconIcon = 8
mod.vb.Guardians = 0

local warned_preP1 = false
local warned_preP2 = false
local warned_preP3 = false

function mod:OnCombatStart(delay)
        DBM:FireCustomEvent("DBM_EncounterStart", 33288, "YoggSaron")
        self.vb.brainLinkIcon = 2
        self.vb.beaconIcon = 8
	self.vb.Guardians = 0
	self.vb.phase = 1
        warned_preP1 = false
        warned_preP2 = false
	enrageTimer:Start()
	timerAchieve:Start()
	if self.Options.ShowSaraHealth and not self.Options.HealthFrame then
		DBM.BossHealth:Show(L.name)
	end
	if self.Options.ShowSaraHealth then
		DBM.BossHealth:AddBoss(33134, L.Sara)
	end
        if self.Options.RangeFrame then
                DBM.RangeCheck:Show(12)
        end
	table.wipe(targetWarningsShown)
	table.wipe(brainLinkTargets)
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 33288, "YoggSaron", wipe)
        DBM.BossHealth:Hide()
        DBM.RangeCheck:Hide()
end

function mod:FervorTarget()
	local targetname = self:GetBossTarget(33134)
	if not targetname then return end
	if targetname == UnitName("player") then
		specWarnFervorCast:Show()
	end
end

local function warnBrainLinkWarning(self)
	warnBrainLink:Show(table.concat(brainLinkTargets, "<, >"))
	timerBrainLinkCD:Start()--VERIFY ME
	table.wipe(brainLinkTargets)
	self.vb.brainLinkIcon = 2
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(64059, 312650, 313003) then	    -- Доведение до помешательства
		timerMadness:Start()
		warnMadness:Show()
		brainportal:Schedule(60)
		warnBrainPortalSoon:Schedule(85)
		specWarnBrainPortalSoon:Schedule(85)
		specWarnMadnessOutNow:Schedule(55)
	elseif args:IsSpellID(64189, 312647, 313000) then   -- Оглушающий рёв
		timerNextDeafeningRoar:Start()
		warnDeafeningRoarSoon:Schedule(55)
		timerCastDeafeningRoar:Start()
		specWarnDeafeningRoar:Show()
        elseif args:IsSpellID(64163, 312648, 313001) then   -- Взгляд безумца
                warnLunaricGaze:Show()
                timerMadness:Cancel()
                brainportal:Cancel()
                warnBrainPortalSoon:Cancel()
                specWarnBrainPortalSoon:Cancel()
                specWarnMadnessOutNow:Cancel()
	elseif args:IsSpellID(63138, 312636, 312989) then   -- Рвение Сары
		self:ScheduleMethod(0.1, "FervorTarget")
		warnFervorCast:Show()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(64144) and self:GetUnitCreatureId(args.sourceGUID) == 33966 then 
		warnCrusherTentacleSpawned:Show()
	end
end

function mod:SPELL_SUMMON(args)
	if args:IsSpellID(62979) then
		self.vb.Guardians = self.vb.Guardians + 1
		warnGuardianSpawned:Show(self.vb.Guardians)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(63802, 312641, 312994) then		-- Схожее мышление
                timerBrainLinkCD:Start()
		self:Unschedule(warnBrainLinkWarning)
		brainLinkTargets[#brainLinkTargets + 1] = args.destName
		if self.Options.SetIconOnBrainLinkTarget then
			self:SetIcon(args.destName, self.vb.brainLinkIcon)
		end
		self.vb.brainLinkIcon = self.vb.brainLinkIcon - 1
		if args:IsPlayer() then
			specWarnBrainLink:Show()
			specWarnBrainLink:Play("linegather")
		end
		if #brainLinkTargets == 2 then
			warnBrainLinkWarning(self)
		else
			self:Schedule(0.5, warnBrainLinkWarning, self)
		end
	elseif args:IsSpellID(63830, 63881, 312640, 312993, 312676, 313029) then   -- Душевная болезнь
                warnDeathCoil:Show(args.destName)
                timerDeathCoilCD:Start()
		if self.Options.SetIconOnFearTarget then
			self:SetIcon(args.destName, 8, 10) 
		end
                if self.Options.YellOnDeathCoil and args:IsPlayer() then
				SendChatMessage(L.YellDeathCoil, "SAY")
		end
                if args:IsPlayer() then
			specwarnDeathCoil:Show()
		end
		local uId = DBM:GetRaidUnitId(args.destName) 
		if uId then 
			local inRange = CheckInteractDistance(uId, 2)
			local x, y = GetPlayerMapPosition(uId)
			if x == 0 and y == 0 then
				SetMapToCurrentZone()
				x, y = GetPlayerMapPosition(uId)
			end
			if inRange then 
				specWarnMaladyNear:Show(args.destName)
				if self.Options.MaladyArrow then
					DBM.Arrow:ShowRunAway(x, y, 12, 5)
				end
			end 
		end 
	elseif args:IsSpellID(64126, 64125, 312678, 313031) then	-- Выдавливание		
		warnSqueeze:Show(args.destName)
		if args:IsPlayer() and self.Options.WarningSqueeze then			
			SendChatMessage(L.WarningYellSqueeze, "SAY")			
		end	
	elseif args:IsSpellID(63138, 312636, 312989) then	-- Рвение Сары
		warnFervor:Show(args.destName)
		timerFervor:Start(args.destName)
		if self.Options.SetIconOnFervorTarget then
			self:SetIcon(args.destName, 7, 15)
		end
		if args:IsPlayer() then 
			specWarnFervor:Show()
		end
	elseif args:IsSpellID(63894) then	-- Теневой барьер Йог-Сарона (this is happens when p2 starts)
                warned_preP2 = true
                self.vb.phase = 2
		warnP2:Show()
		brainportal:Start(60)
		warnBrainPortalSoon:Schedule(55)
		specWarnBrainPortalSoon:Schedule(55)
		warnP2:Show()
		if self.Options.ShowSaraHealth then
			DBM.BossHealth:RemoveBoss(33134)
                        DBM.BossHealth:AddBoss(33890, L.Mozg)
		end
	elseif args:IsSpellID(64163, 312648, 313001) and args:IsPlayer() then	-- Взгляд2
		timerLunaricGaze:Start()
                specWarnLunaricGaze:Show()
                brainportal:Cancel()
                PlaySoundFile("Sound\\Creature\\AlgalonTheObserver\\UR_Algalon_BHole01.wav")
        elseif args:IsSpellID(64167, 312674, 313027, 64168, 313028) and args:IsPlayer() then	-- Взгляд2
                timerLunaricGaze:Start()
                specWarnLunaricGaze:Show()
	elseif args:IsSpellID(313014, 312661, 64486, 64468) then
		if self.Options.SetIconOnBeacon then
			self:ScanForMobs(args.destGUID, 2, self.vb.beaconIcon, 1, 0.2, 10, "SetIconOnBeacon")
		end
		self.vb.beaconIcon = self.vb.beaconIcon - 1
		if self.vb.beaconIcon == 0 then
			self.vb.beaconIcon = 8
		end
		timerEmpower:Start()
		timerEmpowerDuration:Start()
		warnEmpowerSoon:Schedule(40)
	end
end

function mod:SPELL_AURA_REMOVED(args)
        if args:IsSpellID(63802, 312641, 312994) and self.Options.SetIconOnBrainLinkTarget then
		self:SetIcon(args.destName, 0)
        elseif args:IsSpellID(63830, 63881, 312640, 312993, 312676, 313029) and self.Options.SetIconOnFearTarget then
		self:SetIcon(args.destName, 0)
	elseif args:IsSpellID(63138, 312636, 312989) and self.Options.SetIconOnFervorTarget then
		self:SetIcon(args.destName, 0)
	elseif args:IsSpellID(63894) then		-- Теневой барьер removed from Yogg-Saron (start p3)
		if mod:LatencyCheck() then
			self:SendSync("Phase3")			-- Sync this because you don't get it in your combat log if you are in brain room.
		end
        elseif args:IsSpellID(313014, 312661, 64486, 64468) then
		if self.Options.SetIconOnBeacon then
			self:ScanForMobs(args.destGUID, 2, 0, 1, 0.2, 12, "SetIconOnBeacon")
                end
	end
end

function mod:SPELL_AURA_REMOVED_DOSE(args)
	if args:IsSpellID(63050) and args.destGUID == UnitGUID("player") then
		if args.amount == 50 then
			warnSanity:Show(args.amount)
		elseif args.amount == 25 or args.amount == 15 or args.amount == 5 then
			warnSanity:Show(args.amount)
			specWarnSanity:Show(args.amount)
		end
	end
end

function mod:UNIT_HEALTH(uId)
	if phase == 1 and uId == "target" and self:GetUnitCreatureId(uId) == 33136 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.3 and not targetWarningsShown[UnitGUID(uId)] then
		targetWarningsShown[UnitGUID(uId)] = true
		specWarnGuardianLow:Show()
        elseif self.vb.phase == 2 and self:GetUnitCreatureId(uId) == 33288 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.30 then  --мозг 30хп
		self.vb.phase = 3
		warnP3:Show()
                brainportal:Cancel()
                timerEmpower:Start()
                warnEmpowerSoon:Schedule(41)	
		warnBrainPortalSoon:Cancel()
		timerNextDeafeningRoar:Start()
		warnDeafeningRoarSoon:Schedule(25)
                timerNextLunaricGaze:Start()
                if self.Options.ShowSaraHealth then
			DBM.BossHealth:RemoveBoss(33890)
                        DBM.BossHealth:AddBoss(33288, L.Saron)
                end
        elseif self.vb.phase == 1 and not warned_preP1 and self:GetUnitCreatureId(uId) == 33134 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.07 then  --сара 2 фаза некст
                warned_preP1 = true
		warnPhase2Soon:Show()
        elseif self.vb.phase == 2 and not warned_preP3 and self:GetUnitCreatureId(uId) == 33890 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.35 then  --мозг 2 фаза
                warned_preP3 = true
		warnPhase3Soon:Show()
	end
end

