local mod	= DBM:NewMod("Hydross", "DBM-Serpentshrine")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20201011233000")

mod:SetCreatureID(21216)
mod:RegisterCombat("combat")
mod:RegisterCombat("yell", L.YellPull)
mod:SetUsedIcons(3, 4, 5, 6, 7, 8)


mod:RegisterEvents(
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED",
	"CHAT_MSG_MONSTER_YELL",
	"SPELL_CAST_START",
	"UNIT_HEALTH",
	"CHAT_MSG_MONSTER_YELL"
)

local warnMarkOfHydross     = mod:NewAnnounce("WarnMarkOfHydross", 3, 38215)
local warnMarkOfCorruption  = mod:NewAnnounce("WarnMarkOfCorruption", 3, 38219)
local warnWaterTomb         = mod:NewTargetAnnounce(38235, 3)
local warnVileSludge        = mod:NewTargetAnnounce(38246, 3)

local specWarnThreatReset   = mod:NewSpecialWarning("SpecWarnThreatReset", "-Tank|-Healer")

local timerMarkOfHydross    = mod:NewTimer(15, "TimerMarkOfHydross", 38215, nil, nil, 7)
local timerMarkOfCorruption = mod:NewTimer(15, "TimerMarkOfCorruption", 38219, nil, nil, 7)

local berserkTimer          = mod:NewBerserkTimer(600)

----------хм-------------------

local warnYad			= mod:NewCountAnnounce(309072, 4) -- яд
local warnChis			= mod:NewCountAnnounce(309055, 4) -- цунами
local warnSklep         = mod:NewTargetAnnounce(309046, 3) -- лужа
local warnKor           = mod:NewTargetAnnounce(309065, 3) -- коррозия
local warnArrow         = mod:NewSpellAnnounce(309052, 3, nil, "Melee") -- залп вод
local warnAya			= mod:NewSpellAnnounce(309069, 3, nil, "Melee") -- залп яда

local specWarnArrow     = mod:NewSpecialWarningMove(309052, "SpellCaster", nil, nil, 2, 3) -- залп вод
local specWarnAya       = mod:NewSpecialWarningMove(309069, "SpellCaster", nil, nil, 2, 3) -- залп яда
local specWarnYad       = mod:NewSpecialWarning("Yad", 309072, nil, nil, 1, 6) -- Перефаза яда
local specWarnChis      = mod:NewSpecialWarning("Chis", 309055, nil, nil, 1, 6) -- Перефаза чист

local specWarnSklep     = mod:NewSpecialWarningRun(309046, nil, nil, nil, 1, 4) -- лужа
local specWarnKor       = mod:NewSpecialWarningRun(309065, nil, nil, nil, 1, 4) -- коррозия

local timerSklepCD	= mod:NewCDTimer(32, 309046, nil, nil, nil, 3, nil, DBM_CORE_MAGIC_ICON) -- лужа
local timerKorCD	= mod:NewCDTimer(32, 309065, nil, nil, nil, 3, nil, DBM_CORE_POISON_ICON) -- коррозия
local timerArrowCD	= mod:NewCDTimer(25, 309052, nil, nil, nil, 3, nil, DBM_CORE_HEALER_ICON) -- залп вод
local timerAyaCD	= mod:NewCDTimer(25, 309069, nil, nil, nil, 3, nil, DBM_CORE_HEALER_ICON) -- залп яда
local timerArrowCast	= mod:NewCastTimer(1.5, 309052, nil, nil, nil, 3, nil, DBM_CORE_HEALER_ICON) -- залп  вод каст
local timerAyaCast  	= mod:NewCastTimer(1.5, 309069, nil, nil, nil, 3, nil, DBM_CORE_HEALER_ICON) -- залп  яда каст
local timerYadCast	= mod:NewCastTimer(25, 309072, nil, nil, nil, 6, nil, DBM_CORE_DEADLY_ICON) -- яд
local timerChisCast	= mod:NewCastTimer(20, 309055, nil, nil, nil, 6, nil, DBM_CORE_DEADLY_ICON) -- чистота

local yellSklep		= mod:NewYell(309046)
local yellKor		= mod:NewYell(309065)

mod:AddSetIconOption("SetIconOnSklepTargets", 309046, true, true, {6, 7, 8})
mod:AddSetIconOption("SetIconOnKorTargets", 309065, true, true, {6, 7, 8})
mod:AddBoolOption("RangeFrame", true)
mod:AddBoolOption("AnnounceSklep", false)
mod:AddBoolOption("AnnounceKor", false)

mod.vb.phase = 0
mod.vb.yadCount = 0
mod.vb.chisCount = 0
mod.vb.SklepIcon = 8
mod.vb.KorlIcon = 8

local SklepTargets = {}
local KorTargets = {}

do
	local function sort_by_group(v1, v2)
		return DBM:GetRaidSubgroup(UnitName(v1)) < DBM:GetRaidSubgroup(UnitName(v2))
	end
	function mod:SetSklepIcons()
		table.sort(SklepTargets, sort_by_group)
		for i, v in ipairs(SklepTargets) do
			if mod.Options.AnnounceSklep then
				if DBM:GetRaidRank() > 0 then
					SendChatMessage(L.SklepIcon:format(self.vb.SklepIcons, UnitName(v)), "RAID_WARNING")
				else
					SendChatMessage(L.SklepIcon:format(self.vb.SklepIcons, UnitName(v)), "RAID")
				end
			end
			if self.Options.SetIconOnSklepTargets then
				self:SetIcon(UnitName(v), self.vb.SklepIcons, 10)
			end
			self.vb.SklepIcons = self.vb.SklepIcons - 1
		end
		if #SklepTargets >= 3 then
			warnSklep:Show(table.concat(SklepTargets, "<, >"))
			table.wipe(SklepTargets)
			self.vb.SklepIcons = 8
		end
	end
	function mod:SetKorIcons()
		table.sort(KorTargets, sort_by_group)
		for i, v in ipairs(KorTargets) do
			if mod.Options.AnnounceKor then
				if DBM:GetRaidRank() > 0 then
					SendChatMessage(L.KorIcon:format(self.vb.KorIcon, UnitName(v)), "RAID_WARNING")
				else
					SendChatMessage(L.KorIcon:format(self.vb.KorIcon, UnitName(v)), "RAID")
				end
			end
			if self.Options.SetIconOnKorTargets then
				self:SetIcon(UnitName(v), self.vb.KorIcon)
			end
			self.vb.KorIcon = self.vb.KorIcon - 1
		end
		if #KorTargets >= 3 then
			warnKor:Show(table.concat(KorTargets, "<, >"))
			table.wipe(KorTargets)
			self.vb.KorIcon = 8
		end
	end
end


function mod:OnCombatStart()
	berserkTimer:Start()
	self.vb.chisCount = 0
	self.vb.yadCount = 0
	self.vb.phase = 1
	self.vb.SklepIcons = 8
	self.vb.KorIcon = 8
	if mod:IsDifficulty("heroic25") then
	timerArrowCD:Start()
	timerSklepCD:Start()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Show(5)
	end
	else
	timerMarkOfHydross:Start("10")
	DBM:FireCustomEvent("DBM_EncounterStart", 21216, "Hydross the Unstable")
	end
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 21216, "Hydross the Unstable", wipe)
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end


function mod:SPELL_CAST_START(args)
	if args:IsSpellID(309052) then --залп вод
		timerArrowCD:Start()
		timerArrowCast:Start()
		specWarnArrow:Show()
		warnArrow:Show()
	elseif args:IsSpellID(309069) then --залп яда
		timerAyaCD:Start()
		timerAyaCast:Start()
		specWarnAya:Show()
		warnAya:Show()
	elseif args:IsSpellID(309072) then  --грязная фаза
		self.vb.yadCount = self.vb.yadCount + 1
		warnYad:Show(self.vb.yadCount)
		timerYadCast:Start(25, self.vb.yadCount)
		timerKorCD:Start(56)
		timerAyaCD:Start(50)
		specWarnYad:Show()
		timerArrowCD:Cancel()
		timerSklepCD:Cancel()
	end
end

function mod:SPELL_AURA_APPLIED(args) -- все хм --
	if args:IsSpellID(309046) then
		SklepTargets[#SklepTargets + 1] = args.destName
		if args:IsPlayer() then
			specWarnSklep:Show()
			yellSklep:Yell()
		end
		self:ScheduleMethod(0.1, "SetSklepIcons")
		timerSklepCD:Start()
	elseif args:IsSpellID(309065) then
		KorTargets[#KorTargets + 1] = args.destName
		if args:IsPlayer() then
			specWarnKor:Show()
			yellKor:Yell()
		end
		self:ScheduleMethod(0.1, "SetKorIcons")
		timerKorCD:Start()
	end
end



function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(38215) then
		warnMarkOfHydross:Show("10")
		timerMarkOfHydross:Start("25")
	elseif args:IsSpellID(38216) then
		warnMarkOfHydross:Show("25")
		timerMarkOfHydross:Start("50")
	elseif args:IsSpellID(38217) then
		warnMarkOfHydross:Show("50")
		timerMarkOfHydross:Start("100")
	elseif args:IsSpellID(38218) then
		warnMarkOfHydross:Show("100")
		timerMarkOfHydross:Start("250")
	elseif args:IsSpellID(38231) then
		warnMarkOfHydross:Show("250")
		timerMarkOfHydross:Start("500")
	elseif args:IsSpellID(40584) then
		warnMarkOfHydross:Show("500")
		timerMarkOfHydross:Start("500")
	elseif args:IsSpellID(38219) then
		warnMarkOfCorruption:Show("10")
		timerMarkOfCorruption:Start("25")
	elseif args:IsSpellID(38220) then
		warnMarkOfCorruption:Show("25")
		timerMarkOfCorruption:Start("50")
	elseif args:IsSpellID(38221) then
		warnMarkOfCorruption:Show("50")
		timerMarkOfCorruption:Start("100")
	elseif args:IsSpellID(38222) then
		warnMarkOfCorruption:Show("100")
		timerMarkOfCorruption:Start("250")
	elseif args:IsSpellID(38230) then
		warnMarkOfCorruption:Show("250")
		timerMarkOfCorruption:Start("500")
	elseif args:IsSpellID(40583) then
		warnMarkOfCorruption:Show("500")
		timerMarkOfCorruption:Start("500")
	elseif args:IsSpellID(38235) then
		warnWaterTomb:Show(args.destName)
	elseif args:IsSpellID(38246) then
		warnVileSludge:Show(args.destName)
	-------------- хм-------------------
    elseif  args:IsSpellID(309055) then -- чистая фаза
		self.vb.chisCount = self.vb.chisCount + 1
		warnChis:Show(self.vb.chisCount)
        timerChisCast:Start(nil, self.vb.chisCount)
	    specWarnChis:Show()
	    timerKorCD:Cancel()
	    timerAyaCD:Cancel()
	    timerArrowCD:Start()
	    timerSklepCD:Start()
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if mod:IsDifficulty("heroic25") then
	else
	    if msg == L.YellPoison then
		timerMarkOfHydross:Cancel()
		timerMarkOfCorruption:Start("10")
		specWarnThreatReset:Show()
	    elseif msg == L.YellWater then
		timerMarkOfCorruption:Cancel()
		timerMarkOfHydross:Start("10")
		specWarnThreatReset:Show()
	end
	end
end

function mod:SPELL_AURA_REMOVED(args)
         if args:IsSpellID(309046) then     -- знак вод
                if self.Options.SetSklepIcons then
			self:SetIcon(args.destName, 0)
		end
         elseif args:IsSpellID(309065) then     -- коррозия
                if self.Options.SetKorIcons then
			self:SetIcon(args.destName, 0)       
		end
	end
end

mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED