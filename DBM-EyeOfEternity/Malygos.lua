local mod	= DBM:NewMod("Malygos", "DBM-EyeOfEternity")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 3726 $"):sub(12, -3))
mod:SetCreatureID(28859)

mod:RegisterCombat("yell", L.YellPull)

mod:RegisterEvents(
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"CHAT_MSG_MONSTER_YELL",
	"SPELL_AURA_APPLIED"
)

local warnSpark			= mod:NewAnnounce("WarningSpark", 2, 59381)
local warnVortex		= mod:NewSpellAnnounce(56105, 3)
local warnBreathInc		= mod:NewAnnounce("WarningBreathSoon", 3, 60072)
local warnBreath		= mod:NewAnnounce("WarningBreath", 4, 60072)
local warnSurge			= mod:NewTargetAnnounce(60936, 3)
local warnStaticField	= mod:NewTargetAnnounce(57430, 3)

local specWarnBreath	= mod:NewSpecialWarningSpell(60072, nil, nil, nil, 2)	--Дыхание чар
local specWarnSurge		= mod:NewSpecialWarningYou(60936, nil, nil, nil, 2)	--Прилив мощи
local specWarnStaticField	= mod:NewSpecialWarningYou(57430)	--Электростатическое поле
local specWarnStaticFieldNear	= mod:NewSpecialWarningClose(57430)	--Электростатическое поле

local enrageTimer		= mod:NewBerserkTimer(615)
local timerSpark		= mod:NewTimer(30, "TimerSpark", 59381, nil, nil, 7, nil)
local timerVortexCD		= mod:NewNextTimer(87, 56105, nil, nil, nil, 2, nil, DBM_CORE_HEALER_ICON)
local timerBreathCD		= mod:NewTimer(59, "timerBreathCD", 60072, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)
local timerBreath		= mod:NewBuffActiveTimer(8, 60072, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)
local timerStaticFieldCD	= mod:NewCDTimer(15.5, 57430, nil, nil, nil, 3)
local timerAchieve      = mod:NewAchievementTimer(360, 1875, "TimerSpeedKill")

local yellStaticField	= mod:NewYell(57430)

local guids = {}
local surgeTargets = {}

local function buildGuidTable()
	for i = 1, GetNumRaidMembers() do
		guids[UnitGUID("raid"..i.."pet") or ""] = UnitName("raid"..i)
	end
end

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 28859, "Malygos")
	timerBreathCD:Start(15-delay)
	timerVortexCD:Start(36-delay)
	timerSpark:Start(-delay)
	enrageTimer:Start(-delay)
	timerAchieve:Start(-delay)
	table.wipe(guids)
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 28859, "Malygos", wipe)
	DBM.RangeCheck:Hide()
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
	if msg == L.EmoteSpark or msg:find(L.EmoteSpark) then
		self:SendSync("Spark")
	elseif msg == L.EmoteBreath or msg:find(L.EmoteBreath) then
		self:SendSync("Breath")
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(60072, 56272) then	--His deep breath
		warnBreath:Show()
		specWarnBreath:Show()
		if event == "Phase2" then
			timerBreathCD:Start(59)
			timerBreath:Start()
		else
			timerBreathCD:Start(20)
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(57430) then
		self:ScheduleMethod(0.1, "StaticFieldTarget")
--		warnStaticField:Show()
		timerStaticFieldCD:Start()
	elseif args:IsSpellID(56105) then
		timerVortexCD:Start()
		warnVortex:Show()
		timerBreathCD:Stop()
		if timerSpark:GetTime() < 11 and timerSpark:IsStarted() then
			timerSpark:Update(18, 30)
		end
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg:sub(0, L.YellPhase2:len()) == L.YellPhase2 then
		self:SendSync("Phase2")
	elseif msg == L.YellBreath or msg:find(L.YellBreath) then
		self:SendSync("BreathSoon")
	elseif msg:sub(0, L.YellPhase3:len()) == L.YellPhase3 then
		self:SendSync("Phase3")
	end
end

local function announceTargets(self)
	warnSurge:Show(table.concat(surgeTargets, "<, >"))
	table.wipe(surgeTargets)
end

function mod:StaticFieldTarget()
	local targetname, uId = self:GetBossTarget(28859)
	if not targetname or not uId then return end
	local targetGuid = UnitGUID(uId)
	local announcetarget = guids[targetGuid]
	warnStaticField:Show(announcetarget)
	if announcetarget == UnitName("player") then
		specWarnStaticField:Show()
		yellStaticField:Yell()
	else
		local uId2 = DBM:GetRaidUnitId(announcetarget)
		if uId2 then
			local inRange = DBM.RangeCheck:GetDistance("player", uId2)
			if inRange and inRange < 13 then
				specWarnStaticFieldNear:Show(announcetarget)
			end
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(60936, 57407) then
		local target = guids[args.destGUID or 0]
		if target then
			surgeTargets[#surgeTargets + 1] = target
			self:Unschedule(announceTargets)
			if #surgeTargets >= 3 then
				announceTargets()
			else
				self:Schedule(0.5, announceTargets, self)
			end
			if target == UnitName("player") then
				specWarnSurge:Show()
			end
		end
	end
end

function mod:OnSync(event, arg)
	if event == "Spark" then
		warnSpark:Show()
		timerSpark:Start()
	elseif event == "Phase2" then
		timerSpark:Cancel()
		timerVortexCD:Cancel()
		timerBreathCD:Start(92)
	elseif event == "Breath" then
		timerBreathCD:Schedule(1)
		warnBreath:Schedule(1)
	elseif event == "BreathSoon" then
		warnBreathInc:Show()
	elseif event == "Phase3" then
		self:Schedule(6, buildGuidTable)
		timerBreathCD:Cancel()
	end
end
