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
local warnFervorCast 				= mod:NewCastAnnounce(312989, 3)
local warnSqueeze					= mod:NewTargetAnnounce(313031, 3)
local warnFervor					= mod:NewTargetAnnounce(312989, 4)
local warnDeafeningRoar				= mod:NewSpellAnnounce(313000, 4)
local warnGuardianSpawned 			= mod:NewAnnounce("WarningGuardianSpawned", 2, 62979)
local warnCrusherTentacleSpawned	= mod:NewAnnounce("WarningCrusherTentacleSpawned", 2)
local warnP2 						= mod:NewPhaseAnnounce(2, 2)
local warnP3 						= mod:NewPhaseAnnounce(3, 2)
local warnSanity 					= mod:NewAnnounce("WarningSanity", 3, 63050)
local warnBrainLink 				= mod:NewTargetAnnounce(312994, 3)
local warnBrainPortalSoon			= mod:NewAnnounce("WarnBrainPortalSoon", 2, 57687)
local warnEmpowerSoon				= mod:NewSoonAnnounce(313014, 4)
local warnDeathCoil 				= mod:NewTargetAnnounce(313029, 3)
local warnBlessing					= mod:NewTargetAnnounce(312990, 3)
local warnApathy					= mod:NewTargetAnnounce(313010, 3)
local warnPlague					= mod:NewTargetAnnounce(313011, 3)
local warnCursedoom					= mod:NewTargetAnnounce(313012, 3)
local warnWithering					= mod:NewTargetAnnounce(313013, 3)

local specWarnBrainLink 			= mod:NewSpecialWarningMoveTo(312994, nil, nil, nil, 2, 2) --Схожее мышление
local specWarnDeathCoil				= mod:NewSpecialWarningYou(313029, nil, nil, nil, 1, 2)   -- Душевная болезнь
local specWarnSanity 				= mod:NewSpecialWarning("SpecWarnSanity")
local specWarnMadnessOutNow			= mod:NewSpecialWarning("SpecWarnMadnessOutNow")
local specWarnLunaricGaze			= mod:NewSpecialWarningLookAway(313001, nil, nil, nil, 1, 2)
local specWarnDeafeningRoar			= mod:NewSpecialWarningCount(313000, nil, nil, nil, 2, 2)
local specWarnMadness				= mod:NewSpecialWarningCount(313003, nil, nil, nil, 1, 2) --Безумие
local specWarnFervor				= mod:NewSpecialWarningYou(312989, nil, nil, nil, 2, 2)
local specWarnBlessing				= mod:NewSpecialWarningYou(312990, nil, nil, nil, 2, 2) --Благословение
local specWarnApathy				= mod:NewSpecialWarningYou(313010, nil, nil, nil, 2, 2) --Апатия
local specWarnPlague				= mod:NewSpecialWarningYou(313011, nil, nil, nil, 2, 2) --Черная чума
local specWarnCursedoom				= mod:NewSpecialWarningYou(313012, nil, nil, nil, 2, 2) --Проклятие рока
local specWarnWithering				= mod:NewSpecialWarningYou(313013, nil, nil, nil, 2, 2) --Иссушающий яд
local specWarnMaladyNear			= mod:NewSpecialWarningClose(313029, nil, nil, nil, 1, 2)

local enrageTimer					= mod:NewBerserkTimer(900)
local timerMaladyCD					= mod:NewCDTimer(22, 313029, nil, nil, nil, 3, nil, DBM_CORE_DEADLY_ICON)
local timerBrainLinkCD				= mod:NewCDTimer(24, 312994, nil, nil, nil, 7, nil, DBM_CORE_DEADLY_ICON)
local timerFervor					= mod:NewTargetTimer(15, 312989, nil, nil, nil, 3, nil, DBM_CORE_HEALER_ICON)
local timerBlessing					= mod:NewTargetTimer(20, 312990, nil, nil, nil, 3, nil, DBM_CORE_HEALER_ICON)
local timerApathy					= mod:NewTargetTimer(20, 313010, nil, nil, nil, 3, nil, DBM_CORE_HEALER_ICON..DBM_CORE_MAGIC_ICON)
local timerPlague					= mod:NewTargetTimer(24, 313011, nil, nil, nil, 3, nil, DBM_CORE_HEALER_ICON..DBM_CORE_DISEASE_ICON)
local timerCursedoom				= mod:NewTargetTimer(12, 313012, nil, nil, nil, 3, nil, DBM_CORE_HEALER_ICON..DBM_CORE_CURSE_ICON)
local timerWithering				= mod:NewTargetTimer(18, 313013, nil, nil, nil, 3, nil, DBM_CORE_HEALER_ICON..DBM_CORE_POISON_ICON)
local brainportal					= mod:NewTimer(20, "NextPortal", 57687, nil, nil, 7)
local brainportal2					= mod:NewCDTimer(60, 64775, nil, nil, nil, 7)
local timerLunaricGaze				= mod:NewCastTimer(4, 313001, nil, nil, nil, 2)
local timerNextLunaricGaze			= mod:NewCDTimer(10, 313001, nil, nil, nil, 2)
local timerEmpower					= mod:NewCDTimer(46, 64465, nil, nil, nil, 3)
local timerEmpowerDuration			= mod:NewBuffActiveTimer(10, 64465, nil, nil, nil, 3)
local timerMadness 					= mod:NewCastTimer(60, 313003, nil, nil, nil, 5, nil, DBM_CORE_DEADLY_ICON, nil, 1, 5)
local timerMadnessCD				= mod:NewCDTimer(90, 313003, nil, nil, nil, 3, nil, DBM_CORE_DEADLY_ICON)
local timerCastDeafeningRoar		= mod:NewCastTimer(2.3, 313000, nil, nil, nil, 2, nil, DBM_CORE_INTERRUPT_ICON)
local timerNextDeafeningRoar		= mod:NewNextTimer(20, 313000, nil, nil, nil, 2, nil, DBM_CORE_INTERRUPT_ICON)
--local timerDeathCoilCD				= mod:NewCDTimer(22, 312993, nil, nil, nil, 3, nil, DBM_CORE_HEROIC_ICON)
local timerAchieve					= mod:NewAchievementTimer(420, 6790, "TimerSpeedKill")

local yellSqueeze					= mod:NewYell(313031)

mod:AddSetIconOption("SetIconOnFearTarget", 313029, true, false, {8})
mod:AddBoolOption("ShowSaraHealth")
mod:AddSetIconOption("SetIconOnFervorTarget", 312989, true, false, {7})
mod:AddSetIconOption("SetIconOnBlessingTarget", 312990, true, false, {6})
mod:AddSetIconOption("SetIconOnWitheringTarget", 313013, true, false, {5})
mod:AddSetIconOption("SetIconOnPlagueTarget", 313011, true, false, {4})
mod:AddSetIconOption("SetIconOnApathyTarget", 313010, true, false, {3})
mod:AddSetIconOption("SetIconOnCursedoomTarget", 313012, true, false, {2})
mod:AddSetIconOption("SetIconOnBrainLinkTarget", 312994, true, false, {7, 8})
mod:AddSetIconOption("SetIconOnBeacon", 64465, true, false, {1, 2, 3, 4, 5, 6, 7, 8})
--mod:AddInfoFrameOption(212647) --???

mod.vb.phase = 1
local brainLinkTargets = {}
local SanityBuff = DBM:GetSpellInfo(63050)
mod.vb.brainLinkIcon = 2
mod.vb.beaconIcon = 8
mod.vb.Guardians = 0
mod.vb.roarCount = 0
mod.vb.madnessCount = 0
--mod.vb.numberOfPlayers = 1

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 33288, "YoggSaron")
	--self.vb.numberOfPlayers = DBM:GetNumRealGroupMembers()
	self.vb.madnessCount = 0
	self.vb.roarCount = 0
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
	if args:IsSpellID(64059, 312650, 313003) then --Доведение до помешательства
		self.vb.madnessCount = self.vb.madnessCount + 1
		specWarnMadness:Show(self.vb.madnessCount)
		timerMadness:Start(60, self.vb.madnessCount)
		warnMadness:Show()
		timerMadnessCD:Start(nil, self.vb.madnessCount+1)
		--brainportal:Start(60)
		--brainportal2:Start(90)
		--warnBrainPortalSoon:Schedule(78)
		--specWarnBrainPortalSoon:Schedule(78)
		specWarnMadnessOutNow:Schedule(55)
	elseif args:IsSpellID(64189, 312647, 313000) then --Оглушающий рёв
		self.vb.roarCount = self.vb.roarCount + 1
		specWarnDeafeningRoar:Show(self.vb.roarCount)
		warnDeafeningRoar:Show()
		timerNextDeafeningRoar:Start(20, self.vb.roarCount+1)
		timerCastDeafeningRoar:Start()
	elseif args:IsSpellID(63138, 312636, 312989) then --Рвение Сары
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
	end
end

function mod:SPELL_SUMMON(args)
	if args:IsSpellID(62979) then
		self.vb.Guardians = self.vb.Guardians + 1
		warnGuardianSpawned:Show(self.vb.Guardians)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(63802, 312641, 312994) then --Схожее мышление
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
	elseif args:IsSpellID(64163, 312648, 313001) then --Взгляд безумца
		specWarnLunaricGaze:Show(args.sourceName)
		timerLunaricGaze:Start()
		timerMadness:Cancel()
		warnBrainPortalSoon:Cancel()
		specWarnBrainPortalSoon:Cancel()
		specWarnMadnessOutNow:Cancel()
		if self.vb.phase == 3 then
			brainportal:Cancel()
			brainportal2:Cancel()
		end
		if self.Options.ShowSaraHealth then --Мозг
			DBM.BossHealth:RemoveBoss(33890)
		end
	elseif args:IsSpellID(63881, 312676, 313029) then --Душевная болезнь
		warnDeathCoil:Show(args.destName)
		timerMaladyCD:Start()
		if self.Options.SetIconOnFearTarget then
			self:SetIcon(args.destName, 8, 10)
		end
		if args:IsPlayer() then
			specwarnDeathCoil:Show()
			specwarnDeathCoil:Play("targetyou")
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
	elseif args:IsSpellID(64126, 64125, 312678, 313031) then --Выдавливание	
		warnSqueeze:Show(args.destName)
		if args:IsPlayer() then
			yellSqueeze:Yell()
		end
	elseif args:IsSpellID(312990, 312637, 63134) then --Благословение
		warnBlessing:Show(args.destName)
		timerBlessing:Start(args.destName)
		if args:IsPlayer() then
			specWarnBlessing:Show()
			specWarnBlessing:Play("targetyou")
		end
		if self.Options.SetIconOnBlessingTarget then
			self:SetIcon(args.destName, 6, 20)
		end
	elseif args:IsSpellID(313013, 312660, 64152) then --Иссушающий яд
		warnWithering:Show(args.destName)
		timerWithering:Start(args.destName)
		if args:IsPlayer() then
			specWarnWithering:Show()
			specWarnWithering:Play("targetyou")
		end
		if self.Options.SetIconOnWitheringTarget then
			self:SetIcon(args.destName, 5, 18)
		end
	elseif args:IsSpellID(313011, 312658, 64153) then --чума
		warnPlague:Show(args.destName)
		timerPlague:Start(args.destName)
		if args:IsPlayer() then
			specWarnPlague:Show()
			specWarnPlague:Play("targetyou")
		end
		if self.Options.SetIconOnPlagueTarget then
			self:SetIcon(args.destName, 4, 24)
		end
	elseif args:IsSpellID(313010, 312657, 64156) then --Апатия
		warnApathy:Show(args.destName)
		timerApathy:Start(args.destName)
		if args:IsPlayer() then
			specWarnApathy:Show()
			specWarnApathy:Play("targetyou")
		end
		if self.Options.SetIconOnApathyTarget then
			self:SetIcon(args.destName, 3, 20)
		end
	elseif args:IsSpellID(313012, 312659, 64157) then --Рок
		warnCursedoom:Show(args.destName)
		timerCursedoom:Start(args.destName)
		if args:IsPlayer() then
			specWarnCursedoom:Show()
			specWarnCursedoom:Play("targetyou")
		end
		if self.Options.SetIconOnCursedoomTarget then
			self:SetIcon(args.destName, 2, 12)
		end
	elseif args:IsSpellID(63138, 312636, 312989) then --Рвение Сары
		warnFervor:Show(args.destName)
		timerFervor:Start(args.destName)
		if self.Options.SetIconOnFervorTarget then
			self:SetIcon(args.destName, 7)
		end
		if args:IsPlayer() and self:AntiSpam(4, 1) then
			specWarnFervor:Show()
			specWarnFervor:Play("targetyou")
		end
	elseif args:IsSpellID(63894, 64775) and self.vb.phase < 2 then --Теневой барьер Йог-Сарона
		self.vb.phase = 2
		warnP2:Show()
		brainportal2:Start(60)
		warnBrainPortalSoon:Schedule(57)
		if self.Options.ShowSaraHealth then --Мозг
			DBM.BossHealth:RemoveBoss(33134)
			DBM.BossHealth:AddBoss(33890,L.Mozg)
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
	if args:IsSpellID(63802, 312641, 312994) and self.Options.SetIconOnBrainLinkTarget then --Схожее мышление
		self:SetIcon(args.destName, 0)
	elseif args:IsSpellID(63138, 312636, 312989) and self.Options.SetIconOnFervorTarget then --Рвение Сары
		self:SetIcon(args.destName, 0)
		timerFervor:Cancel()
	elseif args:IsSpellID(312990, 312637, 63134) and self.Options.SetIconOnBlessingTarget then --Благословение
		self:SetIcon(args.destName, 0)
		timerBlessing:Cancel()
	elseif args:IsSpellID(313013, 312660, 64152) and self.Options.SetIconOnWitheringTarget then --Иссушающий яд
		self:SetIcon(args.destName, 0)
		timerWithering:Cancel()
	elseif args:IsSpellID(313011, 312658, 64153)  and self.Options.SetIconOnPlagueTarget then --чума
		self:SetIcon(args.destName, 0)
		timerPlague:Cancel()
	elseif args:IsSpellID(313010, 312657, 64156)  and self.Options.SetIconOnApathyTarget then --Апатия
		self:SetIcon(args.destName, 0)
		timerApathy:Cancel()
	elseif args:IsSpellID(313012, 312659, 64157)  and self.Options.SetIconOnCursedoomTarget then --Рок
		self:SetIcon(args.destName, 0)
		timerCursedoom:Cancel()
	elseif args:IsSpellID(63894, 64775) then --Теневой барьер Йог-Сарона
		self:SendSync("Phase3")			-- Sync this because you don't get it in your combat log if you are in brain room.
	elseif args:IsSpellID(64163, 312648, 313001) and self:AntiSpam(3, 2) then --Взгляд безумца
		timerNextLunaricGaze:Start()
	elseif args:IsSpellID(63881, 312676, 313029) and self.Options.SetIconOnFearTarget then --Душевная болезнь
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
		timerMadness:Cancel()
		--[[if self.vb.numberOfPlayers == 1 then
			timerMadness:Cancel()
			specWarnMadnessOutNow:Cancel()
		end]]
		warnP3:Show()
		warnEmpowerSoon:Schedule(40)
		timerNextDeafeningRoar:Start(30)
	end
end

