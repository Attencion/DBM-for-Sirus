local mod	= DBM:NewMod("Fathomlord", "DBM-Serpentshrine")
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

local warnNovaSoon		= mod:NewPreWarnAnnounce(38445, 5, 4) --Огненная звезда
local warnWrathSoon		= mod:NewPreWarnAnnounce(38358, 5, 4) --Гнев прилива
local warnSpitfireSoon	= mod:NewPreWarnAnnounce(38236, 5, 2) --тотем
local warnSpitfire		= mod:NewSpellAnnounce(38236, 3) --тотем

local specWarnWrath		= mod:NewSpecialWarningSpell(38358, "Melee", nil, nil, 2, 2) --Гнев прилива
local specWarnNova		= mod:NewSpecialWarningSpell(38445, "Melee", nil, nil, 2, 2) --Огненная звезда

local timerNovaCD		= mod:NewCDTimer(26, 38445, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)
local timerWrathCD		= mod:NewCDTimer(20, 38358, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)
local timerSpitfireCD	= mod:NewCDTimer(60, 38236, nil, nil, nil, 1, nil, DBM_CORE_DAMAGE_ICON)

local berserkTimer       = mod:NewBerserkTimer(600)

------------------------ХМ-------------------------

local warnZemlya            = mod:NewCountAnnounce(309289, 4) --Землетрясение
local warnPhaseCast	        = mod:NewSpellAnnounce(309292, 4)
local warnOko	            = mod:NewSpellAnnounce(309258, 2, nil, "Melee")
local warnP2    	        = mod:NewPhaseAnnounce(2, 2)
local specWarnCastHeala     = mod:NewSpecialWarning("SpecWarnCastHeala", canInterrupt) --Хил
local warnStrela            = mod:NewTargetAnnounce(309253, 1) --Стрела катаклизма
local specWarnZemlya	    = mod:NewSpecialWarningMoveAway(309289, nil, nil, nil, 3, 5) --Землетрясение
local specWarnStrela	    = mod:NewSpecialWarningYou(309253, nil, nil, nil, 3, 2) --стрела

local timerSvazCD	        = mod:NewCDTimer(25, 309262, nil, nil, nil, 3, nil, DBM_CORE_HEALER_ICON) -- связь
local timerOkoCD	        = mod:NewCDTimer(16, 309258, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON) --Око шторма
local timerCastHeala	    = mod:NewCDTimer(29, 309256, nil, nil, nil, 4, nil, DBM_CORE_INTERRUPT_ICON) --хил
local timerPhaseCast        = mod:NewCastTimer(60, 309292, nil, nil, nil, 6, nil, DBM_CORE_DEADLY_ICON) --Скользящий натиск
local timerPhaseCastCD	    = mod:NewCDTimer(150, 309292, nil, nil, nil, 6, nil, DBM_CORE_DEADLY_ICON) --Скользящий натиск
local timerZemlyaCast		= mod:NewCastTimer(5, 309289, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)
local timerStrelaCast	    = mod:NewCastTimer(6, 309253) --Стрела катаклизма
local timerStrelaCD	        = mod:NewCDTimer(43, 309253, nil, nil, nil, 3, nil, DBM_CORE_TANK_ICON) --Стрела катаклизма
-----------Шарккис-----------
local warnSvaz              = mod:NewTargetAnnounce(309262, 3) --Пламенная связь
local warnPust		        = mod:NewStackAnnounce(309277, 5, nil, "Tank") --Опустошающее пламя
local specWarnSvaz          = mod:NewSpecialWarningMoveAway(309262, nil, nil, nil, 4, 3) --Пламенная свзяь

local yellSvaz		        = mod:NewYell(309262)

local berserkTimerhm        = mod:NewBerserkTimer(360)


mod:AddSetIconOption("SetIconOnSvazTargets", 309261, true, true, {5, 6, 7})
mod:AddBoolOption("AnnounceSvaz", false)

local phase							= 1
local SvazTargets = {}
local CastKop = 1
local SvazIcons = 7

mod.vb.zemlyaCount = 0

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
	self.vb.zemlyaCount = 0
	phase = 1
	if mod:IsDifficulty("heroic25") then
		berserkTimerhm:Start()
		timerOkoCD:Start()
		timerSvazCD:Start()
		timerCastHeala:Start()
		timerStrelaCD:Start()
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
		timerWrathCD:Start()
		warnNovaSoon:Schedule(18)
		warnSpitfireSoon:Schedule(55)
		warnWrathSoon:Schedule(15)
	end
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 21214, "Fathom-Lord Karathress", wipe)
	DBM.RangeCheck:Hide()
    DBM.BossHealth:Clear()
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(309252) then --барьер
	    phase = 2
	    warnP2:Show()
		berserkTimerhm:Cancel()
		berserkTimerhm:Start()
		timerPhaseCastCD:Start(95)
		DBM.RangeCheck:Show(7)
	elseif args:IsSpellID(309262) and args:IsPlayer() then --Связь
		if self.Options.SetIconOnSvazTargets then
			self:SetIcon(args.destName, 0)
		end
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(38445) then --Огненная звезда
		warnNovaSoon:Schedule(18)
		specWarnNova:Show()
		timerNovaCD:Start()
	elseif args:IsSpellID(38358) then --Гнев прилива
		specWarnWrath:Show()
		timerWrathCD:Start()
		warnWrathSoon:Schedule(15)
	elseif args:IsSpellID(309256) then --Хил
		specWarnCastHeala:Show()
		specWarnCastHeala:Play("kickcast")
		timerCastHeala:Start()
	elseif args:IsSpellID(309289) then --Землетрясение
		self.vb.zemlyaCount = self.vb.zemlyaCount + 1
		warnZemlya:Show(self.vb.zemlyaCount)
		timerZemlyaCast:Start()
		specWarnZemlya:Show()
		specWarnZemlya:Play("moveaway")
	elseif args:IsSpellID(309292) then --натиск
		warnPhaseCast:Show()
		timerPhaseCast:Start()
		timerPhaseCastCD:Start()
	elseif args:IsSpellID(309253) then --Стрела катаклизма
		if not targetname then return end
		warnStrela:Show(targetname)
		if targetname == UnitName("player") then
			specWarnStrela:Show()
		end
		timerStrelaCD:Start()
		timerStrelaCast:Start()
	end 
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(38236) then --Тотем
		timerSpitfireCD:Start()
		specWarnSpitfire:Show()
		warnSpitfireSoon:Schedule(55)
	elseif args:IsSpellID(309258) then --Око шторма
		warnOko:Show()
		timerOkoCD:Start()
	elseif args:IsSpellID(309262) then --Связь
		timerSvazCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(309262) then --Пламенная связь
		SvazTargets[#SvazTargets + 1] = args.destName
		if args:IsPlayer() then
			specWarnSvaz:Show()
			yellSvaz:Yell()
		end
		self:ScheduleMethod(0.1, "SetSvazIcons")
	elseif args:IsSpellID(309292) then --натиск
		warnPhaseCast:Show()
		timerPhaseCast:Start()
		timerPhaseCastCD:Start()
	end
end




mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED