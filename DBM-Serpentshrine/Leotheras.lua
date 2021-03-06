local mod	= DBM:NewMod("Leotheras", "DBM-Serpentshrine")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20201004021400")

mod:SetCreatureID(21215)
mod:RegisterCombat("combat", 21215)
mod:SetUsedIcons(4, 5, 6, 7, 8)

mod:RegisterEvents(
	"SPELL_CAST_SUCCESS",
	"CHAT_MSG_MONSTER_YELL",
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"UNIT_HEALTH",
	"SPELL_AURA_REMOVED"
)

-- local warnDemonSoon         = mod:NewAnnounce("WarnDemonSoon", 3, "Interface\\Icons\\Spell_Shadow_Metamorphosis")
-- local warnNormalSoon        = mod:NewAnnounce("WarnNormalSoon", 3, "Interface\\Icons\\INV_Weapon_ShortBlade_07")
local warnDemons            = mod:NewTargetAnnounce(37676, 4)

local specWarnDemon         = mod:NewSpecialWarningYou(37676)

local timerDemon            = mod:NewTimer(45, "TimerDemon", "Interface\\Icons\\Spell_Shadow_Metamorphosis")
local timerNormal           = mod:NewTimer(60, "TimerNormal", "Interface\\Icons\\INV_Weapon_ShortBlade_07")
local timerInnerDemons      = mod:NewTimer(32.5, "TimerInnerDemons", 11446)
local timerWhirlwind        = mod:NewCastTimer(12, 37640)
local timerWhirlwindCD      = mod:NewCDTimer(19, 37640)

local berserkTimer          = mod:NewBerserkTimer(600)


---------------------------------хм---------------------------------

local warnRass	           	= mod:NewStackAnnounce(310480, 5, nil, "Tank|Healer") --Рассеченая душа
local warnKogti		        = mod:NewStackAnnounce(310502, 5, nil, "Tank|Healer") --Когти
local warnNat    	        = mod:NewTargetAnnounce(310478, 2) --Натиск
local warnChardg	     	= mod:NewTargetAnnounce(310481, 3) --Рывок
local warnPepels  	     	= mod:NewTargetAnnounce(310514, 3) --Испепеление
local warnKlei				= mod:NewTargetAnnounce(310496, 4) --Клеймо
local warnMeta		        = mod:NewSpellAnnounce(310484, 3) --Метаморфоза
local warnMeta2		        = mod:NewSpellAnnounce(310518, 2) --Мета2
local warnElf		        = mod:NewSpellAnnounce(310506, 2) --Эльф
local warnPepel		        = mod:NewSpellAnnounce(310514, 3) --пепел
local warnVsp		        = mod:NewStackAnnounce(310521, 1, nil, "Tank|Healer") --Вспышка
local warnPhase2Soon   		= mod:NewPrePhaseAnnounce(2)
local warnPhase2     		= mod:NewPhaseAnnounce(2)


local specWarnKogti			= mod:NewSpecialWarningStack(310502, nil, 5, nil, nil, 1, 6) --когти
local specWarnRass			= mod:NewSpecialWarningStack(310480, nil, 2, nil, nil, 1, 6) --рассечение
local specWarnVsp			= mod:NewSpecialWarningStack(310521, nil, 7, nil, nil, 1, 6) --Вспышка
local specWarnKogtilf		= mod:NewSpecialWarningTaunt(310502, "Tank", nil, nil, 1, 2) --когти
local specWarnRasslf		= mod:NewSpecialWarningTaunt(310480, "Tank", nil, nil, 1, 2) --рассечение
local specWarnChardg        = mod:NewSpecialWarningYou(310481, nil, nil, nil, 1, 2)
local specWarnKlei          = mod:NewSpecialWarningYou(310496, nil, nil, nil, 1, 2)
local specWarnObstrel       = mod:NewSpecialWarningRun(310510, nil, nil, nil, 2, 2)
local specWarnChardg2		= mod:NewSpecialWarningDodge(310481, "Melee", nil, nil, 2, 2)
local specWarnAnig          = mod:NewSpecialWarningDodge(310508, nil, nil, nil, 2, 2)
local specWarnVzg           = mod:NewSpecialWarningDodge(310516, nil, nil, nil, 2, 2)
local specWarnVost          = mod:NewSpecialWarningSoak(310503, nil, nil, nil, 1, 2)
local specWarnPechat        = mod:NewSpecialWarningSoak(310487, nil, nil, nil, 1, 2)
local specWarnPepel         = mod:NewSpecialWarningYou(310514, nil, nil, nil, 1, 4)

local timerRass				= mod:NewTargetTimer(40, 310480, nil, "Tank|Healer", nil, 5, nil, DBM_CORE_TANK_ICON) --Рассеченая душа
local timerKogti			= mod:NewTargetTimer(40, 310502, nil, "Tank|Healer", nil, 5, nil, DBM_CORE_TANK_ICON) --Когти
local timerKlei				= mod:NewTargetTimer(30, 310496, nil, nil, nil, 3, nil, DBM_CORE_DEADLY_ICON) --Клеймо
local timerAnigCast			= mod:NewCastTimer(10, 310508, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON) --Анигиляция
local timerVzgCast			= mod:NewCastTimer(5, 310516, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON) --Взгляд
local timerChardgCast		= mod:NewCastTimer(3, 310481, nil, nil, nil, 3) --Рывок
local timerMetaCast			= mod:NewCastTimer(3, 310484, nil, nil, nil, 3) --Мета
local timerElfCast			= mod:NewCastTimer(3, 310506, nil, nil, nil, 3) --Эльф
local timerMeta2			= mod:NewCastTimer(5, 310518, nil, nil, nil, 7) --Мета2
local timerNatCast			= mod:NewCastTimer(3, 310478, nil, nil, nil, 3) --Натиск
local timerPepelCast		= mod:NewCastTimer(3, 310514, nil, nil, nil, 3) --Испепел

local yellKlei		    = mod:NewYell(310496)
local yellPepels	    = mod:NewYell(310514)

mod:AddSetIconOption("SetIconOnDemonTargets", 37676, true, true, {5, 6, 7, 8})
mod:AddSetIconOption("SetIconOnPepelTargets", 310514, true, true, {4, 5, 6, 7})
mod:AddSetIconOption("KleiIcon", 310496, true, true, {8})
mod:AddBoolOption("AnnounceKlei", false)
mod:AddBoolOption("AnnouncePepel", false)
mod:AddBoolOption("RangeFrame", true)
mod:AddBoolOption("PlaySoundOnSpell", true)

mod.vb.phase = 0
local demonTargets = {}
local warned_preP1 = false
local warned_preP2 = false
local PepelTargets = {}
local KleiIcons = 8
local combattime = 0

do
	local function sort_by_group(v1, v2)
		return DBM:GetRaidSubgroup(UnitName(v1)) < DBM:GetRaidSubgroup(UnitName(v2))
	end
	function mod:SetPepelIcons()
		if DBM:GetRaidRank() >= 0 then
			table.sort(PepelTargets, sort_by_group)
			local PepelIcons = 7
			for i, v in ipairs(PepelTargets) do
				if mod.Options.AnnouncePepel then
					if DBM:GetRaidRank() > 0 then
						SendChatMessage(L.PepelIcon:format(PepelIcons, UnitName(v)), "RAID_WARNING")
					else
						SendChatMessage(L.PepelIcon:format(PepelIcons, UnitName(v)), "RAID")
					end
				end
				if self.Options.SetIconOnPepelTargets then
					self:SetIcon(UnitName(v), PepelIcons)
				end
				PepelIcons = PepelIcons - 1
			end
			if #PepelTargets >= 4 then
				warnPepels:Show(table.concat(PepelTargets, "<, >"))
				table.wipe(PepelTargets)
				PepelIcons = 7
			end
		end
	end
end

function mod:WarnDemons()
	warnDemons:Show(table.concat(demonTargets, "<, >"))
	if self.Options.SetIconOnDemonTargets then
		table.sort(demonTargets, function(v1,v2) return DBM:GetRaidSubgroup(v1) < DBM:GetRaidSubgroup(v2) end)
		local k = 8
		for i, v in ipairs(demonTargets) do
			self:SetIcon(v, k)
			k = k - 1
		end
	end
	table.wipe(demonTargets)
end

function mod:OnCombatStart()
	DBM:FireCustomEvent("DBM_EncounterStart", 21215, "Leotheras the Blind")
	table.wipe(demonTargets)
	self.vb.phase = 1
	combattime = GetTime()
	if mod:IsDifficulty("heroic25") then
	else
		berserkTimer:Start()
		timerDemon:Start(60)
		timerWhirlwindCD:Start(18)
	end
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 21215, "Leotheras the Blind", wipe)
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end



function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(310481) then --рывок
	timerChardgCast:Start()
	warnChardg:Show(args.destName)
	specWarnChardg2:Show()
	if args:IsPlayer() then
		specWarnChardg:Show()
	end
	elseif args:IsSpellID(310484) then --демон
	warnMeta:Show()
	timerMetaCast:Start()
	if self.Options.PlaySoundOnSpell then
		PlaySoundFile("Sound\\Creature\\illidan\\black_illidan_13.wav")
	end
	elseif args:IsSpellID(310506) then --эльф
	warnElf:Show()
	timerElfCast:Start()
	if self.Options.PlaySoundOnSpell then
		PlaySoundFile("Sound\\Creature\\illidan\\black_illidan_07.wav")
	end
	elseif args:IsSpellID(310496) then --клеймо
	if self.Options.PlaySoundOnSpell then
		PlaySoundFile("Sound\\Creature\\illidan\\black_illidan_09.wav")
	end
	elseif args:IsSpellID(310518) then --мета2
	warnMeta2:Show()
	timerMeta2:Start()
	if self.Options.PlaySoundOnSpell then
		PlaySoundFile("Sound\\Creature\\illidan\\black_illidan_08.wav")
	end
	elseif args:IsSpellID(310478) then --Натиск
	warnNat:Show(args.destName)
	timerNatCast:Start()
	elseif args:IsSpellID(310516) then --Пронзающий взгляд
	specWarnVzg:Show()
	timerVzgCast:Start()
	if self.Options.PlaySoundOnSpell then
		PlaySoundFile("Sound\\Creature\\illidan\\black_illidan_19.wav")
		end
	end
end


function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(37640) then
		timerWhirlwind:Start()
		timerWhirlwindCD:Schedule(12)
	elseif args:IsSpellID(37676) then
		demonTargets[#demonTargets + 1] = args.destName
		if args:IsPlayer() then
			specWarnDemon:Show()
		end
		self:UnscheduleMethod("WarnDemons")
		self:ScheduleMethod(0.1, "WarnDemons")
	elseif args:IsSpellID(310480) then --хм Рассеченая душа
		local amount = args.amount or 1
        if amount >= 2 then
            if args:IsPlayer() then
                specWarnRass:Show(args.amount)
                specWarnRass:Play("stackhigh")
            else
				local _, _, _, _, _, expireTime = DBM:UnitDebuff("player", args.spellName)
				local remaining
				if expireTime then
					remaining = expireTime-GetTime()
				end
				if not UnitIsDeadOrGhost("player") and (not remaining or remaining and remaining < 40) then
					specWarnRasslf:Show(args.destName)
					specWarnRasslf:Play("tauntboss")
				else
					warnRass:Show(args.destName, amount)
				end
			end
		else
			warnRass:Show(args.destName, amount)
			timerRass:Start(args.destName)
		end
	elseif args:IsSpellID(310502) then --хм Когти скверны
		local amount = args.amount or 1
        if amount >= 5 then
            if args:IsPlayer() then
                specWarnKogti:Show(args.amount)
                specWarnKogti:Play("stackhigh")
            else
				local _, _, _, _, _, expireTime = DBM:UnitDebuff("player", args.spellName)
				local remaining
				if expireTime then
					remaining = expireTime-GetTime()
				end
				if not UnitIsDeadOrGhost("player") and (not remaining or remaining and remaining < 40) then
					specWarnKogtilf:Show(args.destName)
					specWarnKogtilf:Play("tauntboss")
				else
					warnKogti:Show(args.destName, amount)
				end
			end
		else
			warnKogti:Show(args.destName, amount)
			timerKogti:Start(args.destName)
		end
	elseif args:IsSpellID(310521) then --хм Вспышка
		local amount = args.amount or 1
		if amount >= 7 then
			if args:IsPlayer() then
				specWarnVsp:Show(args.amount)
				specWarnVsp:Play("stackhigh")
			end
		else
			if self:IsTank() then
				specWarnVsp:Show(args.amount)
				specWarnVsp:Play("stackhigh")
				warnVsp:Show(args.destName, amount)
			end
		end
	elseif args:IsSpellID(310496) then --хм Клеймо
		warnKlei:Show(args.destName)
		timerKlei:Start(args.destName)
		if self.Options.KleiIcon then
			self:SetIcon(args.destName, 8, 30)
		end
		if args:IsPlayer() then
			specWarnKlei:Show()
			yellKlei:Yell()
		end
		if self.Options.PlaySoundOnSpell then
			PlaySoundFile("Sound\\Creature\\illidan\\black_illidan_09.wav")
		end
		if mod.Options.AnnounceKlei then
			if DBM:GetRaidRank() > 0 then
				SendChatMessage(L.Klei:format(KleiIcons, args.destName), "RAID_WARNING")
			else
				SendChatMessage(L.Klei:format(KleiIcons, args.destName), "RAID")
			end
		end
	elseif args:IsSpellID(310514) then
		PepelTargets[#PepelTargets + 1] = args.destName
		if args:IsPlayer() then
			specWarnPepel:Show()
			yellPepels:Yell()
		end
		self:ScheduleMethod(0.1, "SetPepelIcons")
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(37676) then --демоны
		if self.Options.SetIconOnDemonTargets then
		self:SetIcon(args.destName, 0)
		end
	elseif args:IsSpellID(310514) then --Испепеление
		if self.Options.SetIconOnPepelTargets then
		self:SetIcon(args.destName, 0)
		end
	elseif args:IsSpellID(310496) then --Клеймо
		timerKlei:Stop()
		if self.Options.KleiIcon then
		self:SetIcon(args.destName, 0)
		end
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(37676) then --демоны
		timerInnerDemons:Start()
	elseif args:IsSpellID(310510) then --обстрел
		specWarnObstrel:Show()
	if self.Options.PlaySoundOnSpell then
		PlaySoundFile("Sound\\Creature\\illidan\\black_illidan_12.wav")
	end	
	elseif args:IsSpellID(310508) then --аннигиляция
		specWarnAnig:Show()
		timerAnigCast:Start()
	if self.Options.PlaySoundOnSpell then
		PlaySoundFile("Sound\\Creature\\illidan\\black_illidan_19.wav")
	end
	elseif args:IsSpellID(310514) then --испепеление
	if self.Options.PlaySoundOnSpell then
		PlaySoundFile("Sound\\Creature\\illidan\\black_illidan_18.wav")
	end
	elseif args:IsSpellID(310503) then
		specWarnVost:Show()
	elseif args:IsSpellID(310487) then --печати
		specWarnPechat:Show()
	if self.Options.PlaySoundOnSpell then
		PlaySoundFile("Sound\\Creature\\illidan\\black_illidan_04.wav")
	end	
	elseif args:IsSpellID(310514) then
		timerPepelCast:Start(2)
		warnPepel:Show()
	end
end

function mod:UNIT_HEALTH(uId)
	if self.vb.phase == 1 and not warned_preP1 and self:GetUnitCreatureId(uId) == 21215 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.37 then
		warned_preP1 = true
		warnPhase2Soon:Show()
	end
	if self.vb.phase == 1 and not warned_preP2 and self:GetUnitCreatureId(uId) == 21215 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.35 then
		warned_preP2 = true
		self.vb.phase = 2
		warnPhase2:Show()
	end
end


function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.YellDemon then
		timerDemon:Cancel()
		timerWhirlwindCD:Cancel()
		timerDemon:Schedule(60)
		timerWhirlwindCD:Schedule(60)
		timerNormal:Start()
	elseif msg == L.YellShadow then
		timerDemon:Cancel()
		timerNormal:Cancel()
		timerWhirlwindCD:Start(22.5)
	end
end


mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED