local mod	= DBM:NewMod("Alar", "DBM-TheEye", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210130153000")

mod:SetCreatureID(19514)
mod:RegisterCombat("combat", 19514)
mod:SetUsedIcons(3, 4, 5, 6, 7, 8)

mod:RegisterEvents(
	"SPELL_CAST_SUCCESS",
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED",
	"SPELL_DISPEL",
	"SPELL_SUMMON",
	"SPELL_DAMAGE",
	"UNIT_TARGET",
	"UNIT_HEALTH",
	"CHAT_MSG_MONSTER_YELL",
	"CHAT_MSG_RAID_BOSS_WHISPER",
	"CHAT_MSG_RAID_BOSS_EMOTE",
	"SWING_DAMAGE",
	"SWING_MISSED"
)

-- Normal
local warnPlatSoon			= mod:NewAnnounce("WarnPlatSoon", 3, 46599)
local warnFeatherSoon			= mod:NewSoonAnnounce(34229, 4)
local warnBombSoon			= mod:NewSoonAnnounce(35181, 3)
local warnBomb				= mod:NewTargetAnnounce(35181, 3)

--local specWarnFeather			= mod:NewSpecialWarningSpell(34229, not mod:IsRanged())
local specWarnBomb			= mod:NewSpecialWarningYou(35181, nil, nil, nil, 2, 2)
local specWarnPatch			= mod:NewSpecialWarningMove(35383)

local timerNextPlat			= mod:NewTimer(33, "TimerNextPlat", 46599)
local timerFeather			= mod:NewCastTimer(10, 34229)
local timerNextFeather			= mod:NewCDTimer(180, 34229)
local timerNextCharge			= mod:NewCDTimer(22, 35412)
local timerNextBomb			= mod:NewCDTimer(46, 35181)

local berserkTimerN			= mod:NewBerserkTimer(1200)

-- Heroic
local warnFlameBlow		        = mod:NewStackAnnounce(308628, 1, nil, "Tank|Healer")
local specWarnPhase2Soon		= mod:NewSpecialWarning("WarnPhase2Soon", 1) -- ������ ����
local specWarnPhase2			= mod:NewSpecialWarning("WarnPhase2", 1) -- ������ ����
local specWarnFlamefall			= mod:NewSpecialWarningSpell(308987, nil, nil, nil, 1, 2) -- ������� �������
local specWarnAnimated			= mod:NewSpecialWarningSpell(308633, nil, nil, nil, 1, 2) -- ������� �����
local specWarnFireSign			= mod:NewSpecialWarningSpell(308638, nil, nil, nil, 1, 2) -- ���� ����
local specWarnPhoenixScream             = mod:NewSpecialWarningSpell(308671, nil, nil, nil, 1, 2)  -- ���� �������
local specWarnFireSign2                 = mod:NewSpecialWarningYou(308638, nil, nil, nil, 1, 2)

local timerAnimatedCD			= mod:NewCDTimer(70, 308633, nil, "Healer", nil, 5, nil, DBM_CORE_HEALER_ICON) -- ������� �����
local timerFireSignCD			= mod:NewCDTimer(37, 308638, nil, nil, nil, 7, nil, DBM_CORE_MAGIC_ICON) -- ���� ����
local timerFlamefallCD			= mod:NewCDTimer(31, 308987, nil, nil, nil, 1, nil, DBM_CORE_DEADLY_ICON) -- ����������� ������
local timerPhoenixScreamCD		= mod:NewCDTimer(20, 308671, nil, nil, nil, 1, nil, DBM_CORE_HEROIC_ICON) -- ���� �������


local timerAnimatedCast			= mod:NewCastTimer(2, 308633, nil, nil, nil, 2) -- ������� �����
local timerFireSignCast			= mod:NewCastTimer(1, 308638, nil, nil, nil, 2) -- ���� ����
local timerFlamefallCast		= mod:NewCastTimer(5, 308987, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON, nil, 1, 5) -- ���� ������
local timerPhase2Cast			= mod:NewCastTimer(20, 308640, nil, nil, nil, 1, nil, DBM_CORE_DEADLY_ICON) -- ��������
-- 2 phase --
local timerPhoenixScreamCast	        = mod:NewCastTimer(2, 308671, nil, nil, nil, 6, nil, DBM_CORE_HEROIC_ICON) -- ���� �������
local timerScatteringCast		= mod:NewCastTimer(20, 308663) -- ���� �������: �����������
local timerWeaknessCast			= mod:NewCastTimer(20, 308664) -- ���� �������: ��������
local timerFuryCast			= mod:NewCastTimer(20, 308665) -- ���� �������: ������
local timerFatigueCast			= mod:NewCastTimer(20, 308667) -- ���� �������: ���������

local berserkTimerH			= mod:NewBerserkTimer(444)
local berserkTimerH2			= mod:NewBerserkTimer(500)


mod:AddBoolOption("FeatherIcon")
mod:AddBoolOption("YellOnFeather", true, "announce")
mod:AddBoolOption("FeatherArrow")

mod.vb.phase = 0

local warned_preP1 = false
local LKTank

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 19514, "Al'ar")

	self.vb.phase = 1
	if mod:IsDifficulty("heroic25") then
		timerAnimatedCD:Start()
		timerFireSignCD:Start()
		timerFlamefallCD:Start()
	    berserkTimerH:Start()
	    warned_preP1 = false
	else
		berserkTimerN:Start()
		timerNextPlat:Start(39)
		timerNextFeather:Start()
		warnPlatSoon:Schedule(36)
		warnFeatherSoon:Schedule(169)
	end
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 19514, "Al'ar", wipe)
end

function mod:Platform()
	timerNextPlat:Start()
	warnPlatSoon:Schedule(33)
	self:UnscheduleMethod("Platform")
	self:ScheduleMethod(36, "Platform")
end


function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(34229) then
		timerFeather:Start()
		timerNextFeather:Start()
		timerNextPlat:Cancel()
		timerNextPlat:Schedule(10)
		self:UnscheduleMethod("Platform")
		self:ScheduleMethod(46, "Platform")
	elseif args:IsSpellID(35181) then
		warnBomb:Show(args.destName)
		timerNextBomb:Start()
		if args:IsPlayer() then
			specWarnBomb:Show()
		end
	elseif args:IsSpellID(308640) then  -- Phase 2
		timerPhase2Cast:Start()
		specWarnPhase2:Show()
		berserkTimerH:Cancel()
		berserkTimerH2:Start()
		self.vb.phase = 2
	end
end

function mod:SPELL_AURA_APPLIED(args)
        if args:IsSpellID(308638) then	 -- ���� ����
		specWarnFireSign2:Show()
	elseif args:IsSpellID(308628) then
		warnFlameBlow:Show(args.destName, args.amount or 1)
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(34342) then
		timerFeather:Cancel()
		timerNextFeather:Cancel()
		timerNextPlat:Cancel()
		self:UnscheduleMethod("Platform")
		warnPlatSoon:Cancel()
		warnFeatherSoon:Cancel()
		timerNextCharge:Start()
		timerNextBomb:Start()
		warnBombSoon:Schedule(43)
	elseif args:IsSpellID(46599) then -- ���� ����
		timerNextPlat:Start(33)
	elseif args:IsSpellID(308638) then -- ���� ����
		specWarnFireSign:Show()
		timerFireSignCD:Start()
		timerFireSignCast:Start()
	elseif args:IsSpellID(308987) then -- ������� �������
		specWarnFlamefall:Show()
		timerFlamefallCD:Start()
	    timerFlamefallCast:Start()
	elseif args:IsSpellID(308633) then -- ������� �����
		specWarnAnimated:Show()
		timerAnimatedCD:Start()
		timerAnimatedCast:Start()
	------- 2 Phase ---------
	elseif args:IsSpellID(308671) then -- ���� �������
	    timerPhoenixScreamCast:Start()
		timerPhoenixScreamCD:Start()
		specWarnPhoenixScream:Show()
	elseif args:IsSpellID(308663) then -- ���� �������: �����������
		timerScatteringCast:Start()
	elseif args:IsSpellID(308664) then -- ���� �������: ��������
		timerWeaknessCast:Start()
	elseif args:IsSpellID(308665) then -- ���� �������: ������
		timerFuryCast:Start()
	elseif args:IsSpellID(308667) then -- ���� �������: ���������
		timerFatigueCast:Start()
	end
end


function mod:UNIT_HEALTH(uId)
	if not warned_preP1 and self:GetUnitCreatureId(uId) == 19514 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.07 then
		warned_preP1 = true
		specWarnPhase2Soon:Show()
	end
end

mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED