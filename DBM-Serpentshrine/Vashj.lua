local mod	= DBM:NewMod("Vashj", "DBM-Serpentshrine")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20201229013800")

mod:SetCreatureID(21212)
mod:RegisterCombat("combat", 21212)
mod:SetUsedIcons(7, 8)

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL",
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"UNIT_DIED",
	"UNIT_TARGET",
	"UNIT_HEALTH",
	"SPELL_AURA_REMOVED",
	"CHAT_MSG_LOOT",
	"SWING_DAMAGE",
	"SPELL_SUMMON"
)

local warnCore           = mod:NewAnnounce("WarnCore", 3, 38132)
local warnCharge         = mod:NewTargetAnnounce(38280, 4)
local warnPhase          = mod:NewAnnounce("WarnPhase", 1)
local warnElemental      = mod:NewAnnounce("WarnElemental", 4)

local specWarnCore       = mod:NewSpecialWarningYou(38132)
local specWarnCharge     = mod:NewSpecialWarningRun(38280)

local timerStrider       = mod:NewTimer(66, "Strider", "Interface\\Icons\\INV_Misc_Fish_13", nil, nil, 1)
local timerElemental     = mod:NewTimer(40, "TaintedElemental", "Interface\\Icons\\Spell_Nature_ElementalShields", nil, nil, 1)
local timerNaga          = mod:NewTimer(47.5, "Naga", "Interface\\Icons\\INV_Misc_MonsterHead_02", nil, nil, 1)
local timerCharge        = mod:NewTargetTimer(20, 38280, nil, nil, nil, 4)

--------------------------------Героик--------------------------------


local warnStaticAnger			= mod:NewTargetAnnounce(310636, 4) -- Статический заряд
local warnStaticAnger2			= mod:NewTargetAnnounce(310659, 4) -- Статический заряд2
local warnElemAnonce			= mod:NewSoonAnnounce(310635, 1) -- Скоро призыв элементалей хм
local warnStartElem				= mod:NewSpellAnnounce(310635, 1) -- Призыв элемов хм
local warnScat					= mod:NewSpellAnnounce(310657, 1) -- Призыв скатов хм
local warnPhase2Soon			= mod:NewPrePhaseAnnounce(2)
local warnPhase3Soon			= mod:NewPrePhaseAnnounce(3)
local warnPhase2				= mod:NewPhaseAnnounce(2)
local warnPhase3				= mod:NewPhaseAnnounce(3)

local specWarnStaticAnger		= mod:NewSpecialWarningMove(310636, nil, nil, nil, 4, 5) -- Статический заряд на игроке
local specWarnStaticAnger2		= mod:NewSpecialWarningMove(310659, nil, nil, nil, 4, 5) -- Статический заряд на игроке
local specWarnStaticAngerNear	= mod:NewSpecialWarning("SpecWarnStaticAngerNear", 310636, nil, nil, 1, 2) -- Статический заряд около игрока
local specWarnStaticAngerNear2	= mod:NewSpecialWarning("SpecWarnStaticAngerNear2", 310659, nil, nil, 1, 2) -- Статический заряд около игрока

local timerStaticAngerCD		= mod:NewCDTimer(15, 310636, nil, nil, nil, 3, nil, DBM_CORE_DEADLY_ICON) -- Статический заряд
local timerStaticAnger2CD		= mod:NewCDTimer(15, 310659, nil, nil, nil, 3, nil, DBM_CORE_DEADLY_ICON) -- Статический заряд
local timerElemCD				= mod:NewCDTimer(60, 310635, nil, nil, nil, 1, nil, DBM_CORE_HEALER_ICON) -- Элементали
local timerStaticAnger			= mod:NewTargetTimer(8, 310636, nil, nil, nil, 3, nil, DBM_CORE_DEADLY_ICON) -- Статический заряд на игроке
local timerStaticAnger2			= mod:NewTargetTimer(8, 310659, nil, nil, nil, 3, nil, DBM_CORE_DEADLY_ICON) -- Статический заряд на игроке

local yellStaticAnger			= mod:NewYell(310636)
local yellStaticAnger2			= mod:NewYell(310659)

mod:AddBoolOption("Elem")
mod:AddBoolOption("AutoChangeLootToFFA", true)
mod:AddSetIconOption("SetIconOnStaticTargets", 310636, true, true, {7, 8})
mod:AddSetIconOption("SetIconOnStaticTargets2", 310659, true, true, {7, 8})
mod:AddBoolOption("AnnounceStatic", false)
mod:AddBoolOption("AnnounceStatic2", false)

mod.vb.phase = 0
local ti = true
local warned_elem = false
local warned_preP1 = false
local warned_preP2 = false
local warned_preP3 = false
local warned_preP4 = false
local StaticTargets = {}
local StaticTargets2 = {}
local StaticIcons = 8
local StaticIcons2 = 8
local lootmethod, masterlooterRaidID
mod.vb.StaticIcons = 8
mod.vb.StaticIcons2 = 8

do
	local function sort_by_group(v1, v2)
		return DBM:GetRaidSubgroup(UnitName(v1)) < DBM:GetRaidSubgroup(UnitName(v2))
	end
	function mod:StaticAngerIcons() -- метки и анонс целей статического заряда
		table.sort(StaticTargets, sort_by_group)
		for i, v in ipairs(StaticTargets) do
			if mod.Options.AnnounceStatic then
				if DBM:GetRaidRank() > 0 then
					SendChatMessage(L.StaticIcon:format(self.vb.StaticIcons, UnitName(v)), "RAID_WARNING")
				else
					SendChatMessage(L.StaticIcon:format(self.vb.StaticIcons, UnitName(v)), "RAID")
				end
			end
			if self.Options.SetIconOnStaticTargets then
				self:SetIcon(UnitName(v), self.vb.StaticIcons, 8)
			end
			self.vb.StaticIcons = self.vb.StaticIcons - 1
		end
		if #StaticTargets >= 2 then
			warnStaticAnger:Show(table.concat(StaticTargets, "<, >"))
			table.wipe(StaticTargets)
			self.vb.StaticIcons = 8
		end
	end
	function mod:StaticAngerIcons2() -- метки и анонс целей статического заряда
		table.sort(StaticTargets2, sort_by_group)
		for i, v in ipairs(StaticTargets2) do
			if mod.Options.AnnounceStatic2 then
				if DBM:GetRaidRank() > 0 then
					SendChatMessage(L.StaticIcon2:format(self.vb.StaticIcons2, UnitName(v)), "RAID_WARNING")
				else
					SendChatMessage(L.StaticIcon2:format(self.vb.StaticIcons2, UnitName(v)), "RAID")
				end
			end
			if self.Options.SetIconOnStaticTargets2 then
				self:SetIcon(UnitName(v), self.vb.StaticIcons2, 8)
			end
			self.vb.StaticIcons2 = self.vb.StaticIcons2 - 1
		end
		if #StaticTargets2 >= 2 then
			warnStaticAnger2:Show(table.concat(StaticTargets2, "<, >"))
			table.wipe(StaticTargets2)
			self.vb.StaticIcons2 = 8
		end
	end
end

function mod:NextStrider()
	timerStrider:Start()
	self:UnscheduleMethod("NextStrider")
	self:ScheduleMethod(66, "NextStrider")
end

function mod:NextNaga()
	timerNaga:Start()
	self:UnscheduleMethod("NextNaga")
	self:ScheduleMethod(47.5, "NextNaga")
end

function mod:NextElem()
	timerElemCD:Start()
	self:ScheduleMethod(50, "NextElemAnonce")
end

function mod:NextElemAnonce()
	warnElemAnonce:Show()
	warned_elem = false
end

function mod:ElementalSoon()
	ti = true
	warnElemental:Show()
end

function mod:SWING_DAMAGE(args)
	if args:GetDestCreatureID() == 22009  and args:IsSrcTypePlayer() then
		if args.sourceName ~= UnitName("player") then
			if self.Options.Elem then
				DBM.Arrow:ShowRunTo(args.sourceName, 0, 0)
			end
		end
	end
end

function mod:TaintedIcon()
	if DBM:GetRaidRank() >= 1 then
		for i = 1, GetNumRaidMembers() do
			if UnitName("raid"..i.."target") == L.TaintedElemental then
				ti = false
				SetRaidTarget("raid"..i.."target", 8)
				break
			end
		end
	end
end

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 21212, "Lady Vashj")
	ti = true
	self.vb.phase = 1
	self.vb.StaticIcons = 8
	self.vb.StaticIcons2 = 8
	if mod:IsDifficulty("heroic25") then
		DBM.RangeCheck:Show(20)
		timerElemCD:Start(10)
		timerStaticAngerCD:Start()
	else	-- Обычка
		if DBM:GetRaidRank() == 2 then
		lootmethod, _, masterlooterRaidID = GetLootMethod()
		end
	end
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 21212, "Lady Vashj", wipe)
	warned_elem = false
	warned_preP1 = false
	warned_preP2 = false
	warned_preP3 = false
	warned_preP4 = false
	DBM.RangeCheck:Hide()
	if self.Options.AutoChangeLootToFFA and DBM:GetRaidRank() == 2 then
		if masterlooterRaidID then
			SetLootMethod(lootmethod, "raid"..masterlooterRaidID)
		else
			SetLootMethod(lootmethod)
		end
	end
end



function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 38132 then
		warnCore:Show(args.destName)
		if args:IsPlayer() then
			specWarnCore:Show()
		end
	elseif spellId == 310636 then	-- хм заряд
		if args:IsPlayer() then
			specWarnStaticAnger:Show()
			yellStaticAnger:Yell()
		else
			local uId = DBM:GetRaidUnitId(args.destName)
			if uId and self.vb.phase == 1 then
				local inRange = CheckInteractDistance(uId, 3)
				local x, y = GetPlayerMapPosition(uId)
				if x == 0 and y == 0 then
					SetMapToCurrentZone()
					x, y = GetPlayerMapPosition(uId)
				end
				if inRange then
					specWarnStaticAngerNear:Show()
				end
			end
		end
		timerStaticAnger:Start(args.destName)
		StaticTargets[#StaticTargets + 1] = args.destName
		self:UnscheduleMethod("StaticAngerIcons")
		self:ScheduleMethod(0.1, "StaticAngerIcons")
	elseif spellId == 310659 then	-- хм заряд
		if args:IsPlayer() then
			specWarnStaticAnger2:Show()
			yellStaticAnger2:Yell()
		else
			local uId = DBM:GetRaidUnitId(args.destName)
			if uId and self.vb.phase == 2 or self.vb.phase == 3 then
				local inRange = CheckInteractDistance(uId, 3)
				local x, y = GetPlayerMapPosition(uId)
				if x == 0 and y == 0 then
					SetMapToCurrentZone()
					x, y = GetPlayerMapPosition(uId)
				end
				if inRange then
					specWarnStaticAngerNear2:Show()
				end
			end
		end
		timerStaticAnger2:Start(args.destName)
		StaticTargets2[#StaticTargets2 + 1] = args.destName
		self:UnscheduleMethod("StaticAngerIcons2")
		self:ScheduleMethod(0.1, "StaticAngerIcons2")
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(310636) then	-- Заряд 1 фаза
		if self.Options.StaticAngerIcons then
			self:SetIcon(args.destName, 0)
                end
	elseif args:IsSpellID(310659) then	-- заряд 2 фаза
		if self.Options.StaticAngerIcons2 then
			self:SetIcon(args.destName, 0)
		end
	end
end

function mod:SPELL_SUMMON(args)
	local spellId = args.spellId
	if spellId == 310635 and warned_elem == false then
		warnStartElem:Show()
		self:ScheduleMethod(0, "NextElem")
		warned_elem = true
	elseif spellId == 310657 then
		warnScat:Show()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(38280) then
		warnCharge:Show(args.destName)
		timerCharge:Start(args.destName)
		if args:IsPlayer() then
			specWarnCharge:Show()
		end
	elseif spellId == 310636 then	-- хм заряд1
		timerStaticAngerCD:Start()
	elseif spellId == 310659 then	-- хм заряд2
		timerStaticAnger2CD:Start()
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.YellPhase2 then
		warnPhase:Show(2)
		timerStrider:Start()
		timerElemental:Start(40)
		timerNaga:Start()
		self:ScheduleMethod(66, "NextStrider")
		self:ScheduleMethod(47.5, "NextNaga")
		self:ScheduleMethod(35, "ElementalSoon")
	elseif msg == L.YellPhase3 then
		warnPhase:Show(3)
		timerStrider:Cancel()
		timerElemental:Cancel()
		timerNaga:Cancel()
		self:UnscheduleMethod("NextStrider")
		self:UnscheduleMethod("NextNaga")
	end
end

function mod:UNIT_DIED(args)
	if args.destName == L.TaintedElemental then
		timerElemental:Start()
		self:ScheduleMethod(35, "ElementalSoon")
	end
end

function mod:UNIT_HEALTH(uId)
	if self.vb.phase == 1 and not warned_preP1 and self:GetUnitCreatureId(uId) == 21212 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.72 then  --обе
		warned_preP1 = true
		warnPhase2Soon:Show()
	end
	if self.vb.phase == 1 and not warned_preP2 and self:GetUnitCreatureId(uId) == 21212 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.70 then  --обычка
		warned_preP2 = true
		self.vb.phase = 2
		warnPhase2:Show()
		if self.Options.AutoChangeLootToFFA and DBM:GetRaidRank() == 2 then
			SetLootMethod("freeforall")
		end
	end
	if mod:IsDifficulty("heroic25") then
		if self.vb.phase == 1 and not warned_preP2 and self:GetUnitCreatureId(uId) == 21212 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.70 then
			warned_preP2 = true
			self.vb.phase = 2
			warnPhase2:Show()
			timerStaticAnger2CD:Start()
		end	
	end 
	if mod:IsDifficulty("heroic25") then
		if self.vb.phase == 2 and not warned_preP3 and self:GetUnitCreatureId(uId) == 21212 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.42 then  --гера
			warned_preP3 = true
			warnPhase3Soon:Show()
		end
		if self.vb.phase == 2 and not warned_preP4 and self:GetUnitCreatureId(uId) == 21212 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.40 then  --гера
			warned_preP4 = true
			self.vb.phase = 3
			warnPhase3:Show()
			timerElemCD:Cancel()
			timerStaticAnger2CD:Start()
		end
	else
		if self.vb.phase == 2 and not warned_preP4 and self:GetUnitCreatureId(uId) == 21212 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.50 then  --Обычка
			if self.Options.AutoChangeLootToFFA and DBM:GetRaidRank() == 2 then
			if masterlooterRaidID then
				SetLootMethod(lootmethod, "raid"..masterlooterRaidID)
			else
				SetLootMethod(lootmethod)
			end
		end
			warned_preP4 = true
			self.vb.phase = 3
			warnPhase3:Show()
		end
	end
end

function mod:UNIT_TARGET()
	if ti then
		self:TaintedIcon()
	end
end

function mod:OnCombatEnd()
	self:UnscheduleMethod("NextStrider")
	self:UnscheduleMethod("NextNaga")
	self:UnscheduleMethod("ElementalSoon")
end
