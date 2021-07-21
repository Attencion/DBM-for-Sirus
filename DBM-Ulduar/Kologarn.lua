local mod	= DBM:NewMod("Kologarn", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210501000000")

mod:SetCreatureID(32930)
mod:RegisterCombat("yell",L.YellPull)
mod:SetUsedIcons(5, 6, 7, 8)


mod:RegisterEvents(
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED",
	"SPELL_DAMAGE",
	"SPELL_MISSED",
	"CHAT_MSG_RAID_BOSS_WHISPER",
	"UNIT_DIED"
)

mod:SetBossHealthInfo(
	32930, L.Health_Body,
	32934, L.Health_Right_Arm,
	32933, L.Health_Left_Arm
)

local warnFocusedEyebeam		= mod:NewTargetAnnounce(312765, 3)
local warnGrip					= mod:NewTargetAnnounce(312757, 1)
local warnCrunchArmor			= mod:NewStackAnnounce(312748, 2, nil, "Tank|Healer")

local specWarnCrunchArmor2		= mod:NewSpecialWarningStack(312748, nil, 2, nil, 2, 1, 6)
local specWarnEyebeam			= mod:NewSpecialWarningYou(312765, nil, nil, nil, 4, 2)
local specWarnCrunchArmorlf		= mod:NewSpecialWarningTaunt(312748, "Tank", nil, nil, 1, 2)

local timerCrunch10             = mod:NewTargetTimer(45, 312395, nil, "Tank|Healer", nil, 5, nil, DBM_CORE_TANK_ICON)
local timerNextSmash			= mod:NewCDTimer(20.4, 312750, nil, "Tank", nil, 5, nil, DBM_CORE_TANK_ICON)
local timerNextShockwave		= mod:NewCDTimer(18, 312752, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)
local timerNextEyebeam			= mod:NewCDTimer(18.2, 312765, nil, nil, nil, 3)
local timerEyebeam              = mod:NewCastTimer(10, 312765, nil, nil, nil, 3, nil, DBM_CORE_DEADLY_ICON)
local timerNextGrip				= mod:NewCDTimer(20, 64292, nil, nil, nil, 3)
local timerRespawnLeftArm		= mod:NewTimer(48, "timerLeftArm", nil, nil, nil, 1)
local timerRespawnRightArm		= mod:NewTimer(48, "timerRightArm", nil, nil, nil, 1)
local timerTimeForDisarmed		= mod:NewTimer(10, "achievementDisarmed")	-- 10 HC / 12 nonHC

local yellBeam					= mod:NewYell(63346)

local combattime = 0

mod:AddBoolOption("HealthFrame", true)
mod:AddSetIconOption("SetIconOnGripTarget", 312757, true, false, {7, 6, 5})
mod:AddSetIconOption("SetIconOnEyebeamTarget", 312765, true, false, {8})
mod:AddBoolOption("YellOnGrip", true)

mod.vb.disarmActive = false
--local gripTargets = {}

local function armReset(self)
	self.vb.disarmActive = false
end

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 32930, "Kologarn")
	combattime = GetTime()
	timerNextSmash:Start(10-delay)
	timerNextEyebeam:Start(11-delay)
	timerNextShockwave:Start(15.7-delay)
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 32930, "Kologarn", wipe)
	DBM.BossHealth:Hide()
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(64003, 312750, 312397, 64006, 63573) then --подзатыльник
		timerNextSmash:Start()
	end
end

function mod:UNIT_DIED(args)
	if self:GetCIDFromGUID(args.destGUID) == 32934 then --Правая рука
		timerRespawnRightArm:Start()
		timerNextGrip:Cancel()
		if not self.vb.disarmActive then
			self.vb.disarmActive = true
			timerTimeForDisarmed:Start(12)
			self:Schedule(12, armReset, self)
		end
	elseif self:GetCIDFromGUID(args.destGUID) == 32933 then --Левая рука
		timerRespawnLeftArm:Start()
		timerNextShockwave:Cancel()
		if not self.vb.disarmActive then
			self.vb.disarmActive = true
			timerTimeForDisarmed:Start(12)
			self:Schedule(12, armReset, self)
		end
	end
end

function mod:SPELL_DAMAGE(args)
	if args:IsSpellID(312399, 312752, 63982, 63783) and args:IsPlayer() then --Ударная волна
		timerNextShockwave:Start()
	elseif args:IsSpellID(63346, 63976, 312412, 312765) and args:IsPlayer() then --Сосредоточенный взгляд
		specWarnEyebeam:Show()
	end
end

function mod:CHAT_MSG_RAID_BOSS_WHISPER(msg)
	if msg:find(L.FocusedEyebeam) then
		specWarnEyebeam:Show()
		specWarnEyebeam:Play("justrun")
		timerNextEyebeam:Start()
		yellBeam:Yell()
	end
end

function mod:OnSync(msg, target)
	if msg == "EyeBeamOn" then
		warnFocusedEyebeam:Show(target)
		if target == UnitName("player") then
			specWarnEyebeam:Show()
			if self.Options.PlaySoundOnEyebeam then
				PlaySoundFile("Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav")
			end
		end
		if self.Options.SetIconOnEyebeamTarget then
			self:SetIcon(target, 8, 8)
		end
	end
end

local gripTargets = {}
function mod:GripAnnounce()
	warnGrip:Show(table.concat(gripTargets, "<, >"))
	table.wipe(gripTargets)
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(64290, 64292, 312407, 312760) then --Каменная хватка
		if self.Options.SetIconOnGripTarget then
			self:SetIcon(args.destName, 8 - #gripTargets, 10)
		end
		table.insert(gripTargets, args.destName)
		self:UnscheduleMethod("GripAnnounce")
		if #gripTargets >= 3 then
			self:GripAnnounce()
		else
			self:ScheduleMethod(0.2, "GripAnnounce")
		end
		if self.Options.YellOnGrip  and args:IsPlayer() then
			SendChatMessage(L.YellGrip , "SAY")
		end
	elseif args:IsSpellID(64002, 63355, 312395, 312748) then --Хруст доспеха
		local amount = args.amount or 1
		if amount >= 2 then
			if args:IsPlayer() then
				specWarnCrunchArmor2:Show(args.amount)
				specWarnCrunchArmor2:Play("stackhigh")
            else
				local _, _, _, _, _, expireTime = DBM:UnitDebuff("player", args.spellName)
				local remaining
				if expireTime then
					remaining = expireTime-GetTime()
				end
				if not UnitIsDeadOrGhost("player") and (not remaining or remaining and remaining < 45) then
					specWarnCrunchArmorlf:Show(args.destName)
					specWarnCrunchArmorlf:Play("tauntboss")
				else
					warnCrunchArmor:Show(args.destName, amount)
				end
			end
		else
			warnCrunchArmor:Show(args.destName, amount)
			timerCrunch10:Start(args.destName)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(64290, 64292, 312407, 312760) then --хватка
		self:SetIcon(args.destName, 0)
    end
end

mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED