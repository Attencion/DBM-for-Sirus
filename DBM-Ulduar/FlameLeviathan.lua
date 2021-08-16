local mod	= DBM:NewMod("FlameLeviathan", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210501000000")

mod:SetCreatureID(33113)

mod:RegisterCombat("yell", L.YellPull)

mod:RegisterEvents(
	"SPELL_AURA_REMOVED",
	"SPELL_AURA_APPLIED",
	"SPELL_CAST_SUCCESS",
	"SPELL_SUMMON"
)

local warnHodirsFury		= mod:NewTargetAnnounce(312705, 3)
local pursueTargetWarn		= mod:NewAnnounce("PursueWarn", 2, 62374)
local warnNextPursueSoon	= mod:NewAnnounce("warnNextPursueSoon", 3, 62374)

local warnSystemOverload	= mod:NewSpecialWarningSpell(312692)
local pursueSpecWarn		= mod:NewSpecialWarning("SpecialPursueWarnYou")
local warnWardofLife		= mod:NewSpecialWarning("warnWardofLife")

local timerSystemOverload	= mod:NewBuffActiveTimer(20, 312692, nil, nil, nil, 7, nil)
local timerFlameVents		= mod:NewCastTimer(10, 312689, nil, nil, nil, 2, nil, DBM_CORE_INTERRUPT_ICON)
local timerFlameVentsCD		= mod:NewCDTimer(15, 312689, nil, nil, nil, 2, nil, DBM_CORE_INTERRUPT_ICON)
local timerWardoflifeCD		= mod:NewCDTimer(30, 312708, nil, nil, nil, 1, nil, DBM_CORE_TANK_ICON)
local timerPursued			= mod:NewTargetTimer(30, 62374)


local guids = {}
local function buildGuidTable()
	table.wipe(guids)
	for i = 1, GetNumRaidMembers() do
		guids[UnitGUID("raid"..i.."pet") or ""] = UnitName("raid"..i)
	end
end

function mod:OnCombatStart(delay)
        DBM:FireCustomEvent("DBM_EncounterStart", 33113, "FlameLeviathan")
	    buildGuidTable()
end

function mod:OnCombatEnd(wipe)
	    DBM:FireCustomEvent("DBM_EncounterEnd", 33113, "FlameLeviathan", wipe)
        DBM.BossHealth:Hide()
end

function mod:SPELL_SUMMON(args)
	if args:IsSpellID(312355, 312708, 62907, 312363, 312716) then --Защитники жизни
		warnWardofLife:Show()
		timerWardoflifeCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(312689, 62396) then -- Дыхание
		timerFlameVents:Start()
	elseif args:IsSpellID(312692, 62475, 312339) then -- Перезагрузка
		timerSystemOverload:Start()
		warnSystemOverload:Show()
		PlaySoundFile("Sound\\Creature\\FlameLeviathan\\UR_Leviathan_Overload02.wav")
	elseif args:IsSpellID(62374) then -- Преследование
		local player = guids[args.destGUID]
		warnNextPursueSoon:Schedule(25)
		timerPursued:Start(player)
		pursueTargetWarn:Show(player)
		if player == UnitName("player") then
			pursueSpecWarn:Show()
		end
	elseif args:IsSpellID(312705, 62533, 312352) then -- Ярость ходира
		warnHodirsFury:Show(args.destName)
	end

end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(312689, 62396) then
		timerFlameVents:Stop()
		timerFlameVentsCD:Start()
	end
end