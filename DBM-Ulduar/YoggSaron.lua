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


local warnMadness 					= mod:NewCastAnnounce(313003, 2)
local warnSqueeze					= mod:NewTargetAnnounce(313031, 3)
local warnFervor					= mod:NewTargetAnnounce(312989, 4)
local warnDeafeningRoarSoon			= mod:NewPreWarnAnnounce(313000, 5, 3)
local warnGuardianSpawned 			= mod:NewAnnounce("WarningGuardianSpawned", 3, 62979)
local warnCrusherTentacleSpawned	= mod:NewAnnounce("WarningCrusherTentacleSpawned", 2)
local warnP2 						= mod:NewPhaseAnnounce(2, 2)
local warnP3 						= mod:NewPhaseAnnounce(3, 2)
local warnSanity 					= mod:NewAnnounce("WarningSanity", 3, 63050)
local warnBrainLink 				= mod:NewTargetAnnounce(312995, 3)
local warnBrainPortalSoon			= mod:NewAnnounce("WarnBrainPortalSoon", 2, 57687)
local warnEmpowerSoon				= mod:NewSoonAnnounce(313014, 4)

local specWarnBrainLink 			= mod:NewSpecialWarningMoveTo(312995, nil, nil, nil, 1, 2)
local specWarnSanity 				= mod:NewSpecialWarning("SpecWarnSanity")
local specWarnMadnessOutNow			= mod:NewSpecialWarning("SpecWarnMadnessOutNow")
local specWarnLunaricGaze			= mod:NewSpecialWarningLookAway(313002, nil, nil, nil, 1, 2)
local specWarnDeafeningRoar			= mod:NewSpecialWarningSpell(313000, nil, nil, nil, 1, 2)
local specWarnFervor				= mod:NewSpecialWarningYou(312989, nil, nil, nil, 1, 2)
local specWarnMalady				= mod:NewSpecialWarningYou(313029, nil, nil, nil, 1, 2)
local specWarnMaladyNear			= mod:NewSpecialWarningClose(313029, nil, nil, nil, 1, 2)
local yellSqueeze					= mod:NewYell(313031)


local enrageTimer					= mod:NewBerserkTimer(900)
local timerMaladyCD					= mod:NewCDTimer(18.1, 313029, nil, nil, nil, 3)
local timerBrainLinkCD				= mod:NewCDTimer(25.5, 312995, nil, nil, nil, 3)
local timerFervor					= mod:NewTargetTimer(15, 312989, nil, false, 2)
local brainportal					= mod:NewTimer(20, "NextPortal", 57687, nil, nil, 5)
local brainportal2					= mod:NewCDTimer(60, 64775, nil, nil, nil, 3)
local timerLunaricGaze				= mod:NewCastTimer(4, 313002, nil, nil, nil, 2)
local timerNextLunaricGaze			= mod:NewCDTimer(10, 313002, nil, nil, nil, 2)
local timerEmpower					= mod:NewCDTimer(46, 64465, nil, nil, nil, 3)
local timerEmpowerDuration			= mod:NewBuffActiveTimer(10, 64465, nil, nil, nil, 3)
local timerMadness 					= mod:NewCastTimer(60, 313003, nil, nil, nil, 5)
local timerMadnessCD				= mod:NewCDTimer(15, 313003, nil, nil, nil, 3)
local timerCastDeafeningRoar		= mod:NewCastTimer(2.3, 313000, nil, nil, nil, 2)
local timerNextDeafeningRoar		= mod:NewNextTimer(20, 313000, nil, nil, nil, 2)
local timerAchieve					= mod:NewAchievementTimer(420, 3013)

mod:AddSetIconOption("SetIconOnFearTarget", 313029, true, false, {6})
mod:AddBoolOption("ShowSaraHealth")
mod:AddSetIconOption("SetIconOnFervorTarget", 312989, false, false, {7})
mod:AddSetIconOption("SetIconOnBrainLinkTarget", 312995, true, false, {7, 8})
mod:AddSetIconOption("SetIconOnBeacon", 64465, false, false, {1, 2, 3, 4, 5, 6, 7, 8})
--mod:AddInfoFrameOption(212647) --???

mod.vb.phase = 1
local brainLinkTargets = {}
local SanityBuff = DBM:GetSpellInfo(63050)
mod.vb.brainLinkIcon = 2
mod.vb.beaconIcon = 8
mod.vb.Guardians = 0
--mod.vb.numberOfPlayers = 1

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 33288, "YoggSaron")
	--self.vb.numberOfPlayers = DBM:GetNumRealGroupMembers()
	self.vb.brainLinkIcon = 2
	self.vb.beaconIcon = 8
	self.vb.Guardians = 0
	self.vb.phase = 1
	enrageTimer:Start()
	timerAchieve:Start()
	if self.Options.ShowSaraHealth and not self.Options.HealthFrame then
		DBM.BossHealth:Show(L.name)
	end
	if self.Options.ShowSaraHealth then
		DBM.BossHealth:AddBoss(33134, L.Sara)
	end
	table.wipe(brainLinkTargets)
	--[[if self.Options.InfoFrame then
		DBM.InfoFrame:SetHeader(SanityBuff)
		DBM.InfoFrame:Show(30, "playerdebuffstacks", 63050, 2)--Sorted lowest first (highest first is default of arg not given)
	end]]
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 33288, "YoggSaron", wipe)
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
end

--[[function mod:OnTimerRecovery()
	self.vb.numberOfPlayers = DBM:GetNumRealGroupMembers()
end]]

function mod:FervorTarget(targetname, uId)
	if not targetname then return end
	if targetname == UnitName("player") and self:AntiSpam(4, 1) then
		specWarnFervor:Show()
		specWarnFervor:Play("targetyou")
	end
end

local function warnBrainLinkWarning(self)
	warnBrainLink:Show(table.concat(brainLinkTargets, "<, >"))
	timerBrainLinkCD:Start()--VERIFY ME
	table.wipe(brainLinkTargets)
	self.vb.brainLinkIcon = 2
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(312650, 313003, 64059) then	-- Induce Madness
		timerMadness:Start()
		warnMadness:Show()
		--brainportal:Start(60)
		--brainportal2:Start(90)
		--warnBrainPortalSoon:Schedule(78)
		--specWarnBrainPortalSoon:Schedule(78)
		specWarnMadnessOutNow:Schedule(55)
	elseif args:IsSpellID(313000) then		--Deafening Roar
		timerNextDeafeningRoar:Start()
		warnDeafeningRoarSoon:Schedule(15)
		timerCastDeafeningRoar:Start()
		specWarnDeafeningRoar:Show()
		specWarnDeafeningRoar:Play("silencesoon")
	elseif args:IsSpellID(312989) then		--Sara's Fervor
		self:ScheduleMethod(0.1, "FervorTarget")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(64144) and self:GetUnitCreatureId(args.sourceGUID) == 33966 then
		warnCrusherTentacleSpawned:Show()
	elseif args.spellId == 64465 and self:AntiSpam(3, 4) then
		timerEmpower:Start()
		timerEmpowerDuration:Start()
		warnEmpowerSoon:Schedule(40)
	elseif args:IsSpellID(313001, 313002, 313027, 313028) and self:AntiSpam(3, 3) then	-- Lunatic Gaze
		--timerLunaricGaze:Start()
		brainportal:Start(60)
		brainportal2:Start(90)
		--timerMadnessCD:Start(90)
		warnBrainPortalSoon:Schedule(55)
	end
end

function mod:SPELL_SUMMON(args)
	if args:IsSpellID(62979) then
		self.vb.Guardians = self.vb.Guardians + 1
		warnGuardianSpawned:Show(self.vb.Guardians)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(312995, 312994, 312996) then		-- Brain Link
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
	elseif args:IsSpellID(63830, 63881, 312993, 313029) then   -- Душевная болезнь (Death Coil)
		if self.Options.SetIconOnFearTarget then
			self:SetIcon(args.destName, 6)
		end
		if args:IsPlayer() then
			specWarnMalady:Show()
			specWarnMalady:Play("targetyou")
		else
			local uId = DBM:GetRaidUnitId(args.destName)
			if uId then
				local inRange = CheckInteractDistance(uId, 2)
				if inRange then
					specWarnMaladyNear:Show(args.destName)
					specWarnMaladyNear:Play("runaway")
				end
			end
		end
	elseif args:IsSpellID(64126, 313031) then	-- Squeeze
		warnSqueeze:Show(args.destName)
		if args:IsPlayer() then
			yellSqueeze:Yell()
		end
	elseif args:IsSpellID(312989) then	-- Sara's Fervor
		warnFervor:Show(args.destName)
		timerFervor:Start(args.destName)
		if self.Options.SetIconOnFervorTarget then
			self:SetIcon(args.destName, 7)
		end
		if args:IsPlayer() and self:AntiSpam(4, 1) then
			specWarnFervor:Show()
			specWarnFervor:Play("targetyou")
		end
	elseif args:IsSpellID(63894, 64775) and self.vb.phase < 2 then	-- Shadowy Barrier of Yogg-Saron (this is happens when p2 starts)
		self.vb.phase = 2
		warnP2:Show()
		brainportal2:Start(60)
		warnBrainPortalSoon:Schedule(57)
		if self.Options.ShowSaraHealth then --Мозг
			DBM.BossHealth:RemoveBoss(33134)
			DBM.BossHealth:AddBoss(33890,L.Mozg)
		end
	elseif args:IsSpellID(313001, 313002, 313027, 313028) then --Взгляд безумца1
		timerLunaricGaze:Start()
		if args:IsPlayer() then
			specWarnLunaricGaze:Show()
		end
		if self.vb.phase == 3 then
			brainportal:Cancel()
			brainportal2:Cancel()
		end
		if self.Options.ShowSaraHealth then --Мозг
			DBM.BossHealth:RemoveBoss(33890)
		end
	elseif args.spellId == 64465 then
		if self.Options.SetIconOnBeacon then
			self:ScanForMobs(args.destGUID, 2, self.vb.beaconIcon, 1, 0.2, 10, "SetIconOnBeacon")
		end
		self.vb.beaconIcon = self.vb.beaconIcon - 1
		if self.vb.beaconIcon == 0 then
			self.vb.beaconIcon = 8
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 312995 and self.Options.SetIconOnBrainLinkTarget then		-- Brain Link
		self:SetIcon(args.destName, 0)
	elseif args.spellId == 312989 and self.Options.SetIconOnFervorTarget then	-- Sara's Fervor
		self:SetIcon(args.destName, 0)
	elseif args:IsSpellID(63894, 64775) then		-- Shadowy Barrier removed from Yogg-Saron (start p3)
		self:SendSync("Phase3")			-- Sync this because you don't get it in your combat log if you are in brain room.
	elseif args:IsSpellID(313001, 313002, 313027, 313028) and self:AntiSpam(3, 2) then	-- Lunatic Gaze
		timerNextLunaricGaze:Start()
	elseif args:IsSpellID(313029, 312993) and self.Options.SetIconOnFearTarget then   -- Malady of the Mind (Death Coil)
		self:SetIcon(args.destName, 0)
	elseif args.spellId == 64465 then
		if self.Options.SetIconOnBeacon then
			self:ScanForMobs(args.destGUID, 2, 0, 1, 0.2, 12, "SetIconOnBeacon")
		end
	end
end

function mod:SPELL_AURA_REMOVED_DOSE(args)
	if args:IsSpellID(63050) and args.destGUID == UnitGUID("player") then
		if args.amount == 50 then
			warnSanity:Show(args.amount)
		elseif args.amount == 35 or args.amount == 25 or args.amount == 15 then
			specWarnSanity:Show(args.amount)
		end
	end
end



function mod:OnSync(msg)
	if msg == "Phase3" then
		self.vb.phase = 3
		brainportal:Cancel()
		brainportal2:Cancel()
		warnBrainPortalSoon:Cancel()
		timerMaladyCD:Cancel()
		timerBrainLinkCD:Cancel()
		timerMadnessCD:Cancel()
		timerEmpower:Cancel()
		--[[if self.vb.numberOfPlayers == 1 then
			timerMadness:Cancel()
			specWarnMadnessOutNow:Cancel()
		end]]
		warnP3:Show()
		warnEmpowerSoon:Schedule(40)
		timerNextDeafeningRoar:Start(30)
		warnDeafeningRoarSoon:Schedule(25)
	end
end
