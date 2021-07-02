﻿local mod	= DBM:NewMod("Fathomlord", "DBM-Serpentshrine")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210130153000")

mod:SetCreatureID(21214)
mod:RegisterCombat("yell", L.YellPull, 21966, 21965, 21964, 21214)
mod:SetUsedIcons(4, 5, 6, 7, 8)

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_EMOTE",
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"CHAT_MSG_MONSTER_YELL",
	"UNIT_DIED",
	"UNIT_HEALTH"
)

mod:AddBoolOption("BossHealthFrame", true)

mod:SetBossHealthInfo(
	21966, L.Sharkkis,
	21965, L.Volniis,
	21964, L.Karibdis,
	21214, L.Karatress)

local canInterrupt
do
	local class = select(2, UnitClass("player"))
	canInterrupt = class == "SHAMAN"
		or class == "WARRIOR"
		or class == "MAGE"
        or class == "DEATHKNIGHT"
end

local warnNovaSoon       = mod:NewSoonAnnounce(38445, 3)   -- Огненная звезда
local specWarnNova       = mod:NewSpecialWarningSpell(38445)  -- Огненная звезда

local timerNovaCD        = mod:NewCDTimer(26, 38445)
local timerSpitfireCD    = mod:NewCDTimer(60, 38236)

local berserkTimer       = mod:NewBerserkTimer(600)

------------------------ХМ-------------------------

local warnPhaseCast	        = mod:NewSpellAnnounce(309292, 4)
local warnP2    	        = mod:NewPhaseAnnounce(2, 2)
local warnStrela            = mod:NewTargetAnnounce(309253, 3) -- Стрела катаклизма
local specWarnCastHeala     = mod:NewSpecialWarning("specWarnCastHeala", canInterrupt) -- Хил
local specWarnStrela	    = mod:NewSpecialWarningYou(309253)
local warnOko	            = mod:NewSpellAnnounce(309258, 2, nil, "Melee")

local timerSvazCD	        = mod:NewCDTimer(25, 309262, nil, nil, nil, 3) -- связь
local timerOkoCD	        = mod:NewCDTimer(16, 309258, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON) -- Око шторма
local timerCastHeala	    = mod:NewCDTimer(29, 309256, nil, nil, nil, 4) -- хил
local timerPhaseCast        = mod:NewCastTimer(60, 309292, nil, nil, nil, 6, nil, DBM_CORE_DEADLY_ICON) -- Скользящий натиск
local timerPhaseCastCD	    = mod:NewCDTimer(150, 309292, nil, nil, nil, 6, nil, DBM_CORE_DEADLY_ICON) -- Скользящий натиск
local timerStrelaCast	    = mod:NewCastTimer(6, 309253) -- Стрела катаклизма
local timerStrelaCD	        = mod:NewCDTimer(43, 309253) -- Стрела катаклизма
-----------Шарккис-----------
local warnSvaz              = mod:NewTargetAnnounce(309262, 3) -- Пламенная связь
local warnPust		        = mod:NewStackAnnounce(309277, 5, nil, "Tank") -- Опустошающее пламя
local specWarnSvaz          = mod:NewSpecialWarningMoveAway(309262, nil, nil, nil, 1, 3) -- Пламенная свзяь

local yellSvaz		        = mod:NewYell(309262)

local berserkTimerhm        = mod:NewBerserkTimer(360)


mod:AddSetIconOption("SetIconOnSvazTargets", 309261, true, true, {5, 6, 7})
mod:AddBoolOption("AnnounceSvaz", false)

local phase							= 1
local SvazTargets = {}
local CastKop = 1
local SvazIcons = 7

do
	local function sort_by_group(v1, v2)
		return DBM:GetRaidSubgroup(UnitName(v1)) < DBM:GetRaidSubgroup(UnitName(v2))
	end
	function mod:SetSvazIcons()
		table.sort(SvazTargets, sort_by_group)
		for i, v in ipairs(SvazTargets) do
			if mod.Options.AnnounceSvaz then
				if DBM:GetRaidRank() > 0 then
					SendChatMessage(L.SvazIcon:format(SvazIcons, UnitName(v)), "RAID_WARNING")
				else
					SendChatMessage(L.SvazIcon:format(SvazIcons, UnitName(v)), "RAID")
				end
			end
			if self.Options.SetIconOnSvazTargets then
				self:SetIcon(UnitName(v), SvazIcons, 10)
			end
			SvazIcons = SvazIcons - 1
		end
		if #SvazTargets >= 3 then
			warnSvaz:Show(table.concat(SvazTargets, "<, >"))
			table.wipe(SvazTargets)
			SvazIcons = 7
		end
	end
end



function mod:OnCombatStart()
	DBM:FireCustomEvent("DBM_EncounterStart", 21214, "Fathom-Lord Karathress")
	phase = 1
	if mod:IsDifficulty("heroic25") then
	berserkTimerhm:Start()
	if self.Options.BossHealthFrame and not self.Options.HealthFrame then
		DBM.BossHealth:Show(L.name)
	end
	if self.Options.BossHealthFrame then
		DBM.BossHealth:AddBoss(21966, L.Sharkkis)
		DBM.BossHealth:AddBoss(21965, L.Volniis)
		DBM.BossHealth:AddBoss(21964, L.Karibdis)
		DBM.BossHealth:AddBoss(21214, L.Karatress)
	end
	else -- Обычка
		berserkTimer:Start()
		timerNovaCD:Start()
		timerSpitfireCD:Start()
		warnNovaSoon:Show(23)
	end
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 21214, "Fathom-Lord Karathress", wipe)
	DBM.RangeCheck:Hide()
    DBM.BossHealth:Clear()
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(309252) then	--барьер
	    phase = 2
	    warnP2:Show()
		berserkTimerhm:Cancel()
		berserkTimerhm:Start()
		timerPhaseCastCD:Start(96)
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(38445) then	-- Обычка
		warnNovaSoon:Show(23)
		specWarnNova:Show()
		timerNovaCD:Start()
	elseif args:IsSpellID(309262) then	-- Связь
		timerSvazCD:Start()
	elseif args:IsSpellID(309256) then	-- Хил
		specWarnCastHeala:Show()
		specWarnCastHeala:Play("kickcast")
		timerCastHeala:Start()
	elseif args:IsSpellID(309292) then	-- натиск
		warnPhaseCast:Show()
		timerPhaseCast:Start()
		timerPhaseCastCD:Start()
	elseif args:IsSpellID(309253) then	-- Стрела катаклизма
		if not targetname then return end
		warnStrela:Show(targetname)
		if targetname == UnitName("player") then
			specWarnStrela:Show()
		        timerStrelaCD:Start()
		        timerStrelaCast:Start()
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(38236) then	-- Обычка
		timerSpitfireCD:Start()
	elseif args:IsSpellID(309258) then	-- Око шторма
		warnOko:Show()
		timerOkoCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(309262) then	-- Пламенная связь
		SvazTargets[#SvazTargets + 1] = args.destName
		if args:IsPlayer() then
			specWarnSvaz:Show()
			yellSvaz:Yell()
		end
		self:ScheduleMethod(0.1, "SetSvazIcons")
	elseif args:IsSpellID(309292) then	--натиск
		warnPhaseCast:Show()
		timerPhaseCast:Start()
		timerPhaseCastCD:Start()
	end
end




mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED