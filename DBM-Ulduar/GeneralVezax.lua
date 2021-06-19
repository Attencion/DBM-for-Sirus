﻿local mod	= DBM:NewMod("GeneralVezax", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("202104251754")
mod:SetCreatureID(33271)
mod:SetUsedIcons(7, 8)

mod:RegisterCombat("combat", 33271)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_INTERRUPT",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"SPELL_CAST_SUCCESS",
	"CHAT_MSG_RAID_BOSS_EMOTE"
)

local canInterrupt
do
	local class = select(2, UnitClass("player"))
	canInterrupt = class == "SHAMAN"
		or class == "WARRIOR"
		or class == "ROGUE"
                or class == "DEATHKNIGHT"
end

local warnShadowCrash		   = mod:NewTargetAnnounce(312625, 1)
local warnLeechLife		   = mod:NewTargetAnnounce(312974, 4)
local warnSurgeDarknessSoon        = mod:NewPreWarnAnnounce(312981, 5, 2)  --Всплеск

local specwarnSearingFlames	   = mod:NewSpecialWarning("SpecWarnSearingFlames", canInterrupt)
local specWarnShadowCrash	   = mod:NewSpecialWarning("SpecialWarningShadowCrash")
local specWarnShadowCrashNear	   = mod:NewSpecialWarning("SpecialWarningShadowCrashNear")
local specWarnSurgeDarkness	   = mod:NewSpecialWarningDefensive(312981, mod:IsTank())
local specWarnLifeLeechYou	   = mod:NewSpecialWarningYou(312974)
local specWarnLifeLeechNear 	   = mod:NewSpecialWarning("SpecialWarningLLNear", true)

local timerEnrage		   = mod:NewBerserkTimer(600)
local timerSearingFlamesCast	   = mod:NewCastTimer(2, 312977, nil, nil, nil, 1, nil, DBM_CORE_INTERRUPT_ICON)
local timerSurgeofDarkness	   = mod:NewBuffActiveTimer(10, 312981, nil, nil, nil, 5, nil)
local timerNextSurgeofDarkness	   = mod:NewCDTimer(62, 312981, nil, nil, nil, 7, nil, DBM_CORE_TANK_ICON)
local timerSaroniteVapors	   = mod:NewNextTimer(30, 312985)
local timerLifeLeech	           = mod:NewTargetTimer(10, 312974, nil, nil, nil, 7, nil, DBM_CORE_DEADLY_ICON)
local timerAchieve		   = mod:NewTimer(210, "TimerHardmode")
local timerLeech		   = mod:NewNextTimer(37, 312974, nil, nil, nil, 7, nil, DBM_CORE_DEADLY_ICON, nil, 1, 5)
local timerSearingFlamesCD         = mod:NewCDTimer(16, 312977, nil, nil, nil, 1, nil, DBM_CORE_INTERRUPT_ICON)

local yellShadowCrash		   = mod:NewYell(312625)

mod:AddBoolOption("YellOnLifeLeech", true)
mod:AddSetIconOption("SetIconOnLifeLeach", 312974, true, false, {8})
mod:AddSetIconOption("SetIconOnShadowCrash", 312625, true, false, {7})
mod:AddBoolOption("CrashArrow", false)
mod:AddBoolOption("BypassLatencyCheck", false)--Use old scan method without syncing or latency check (less reliable but not dependant on other DBM users in raid)


function mod:OnCombatStart(delay)
        DBM:FireCustomEvent("DBM_EncounterStart", 33271, "GeneralVezax")
	timerEnrage:Start(-delay)
	timerAchieve:Start(-delay)
	timerNextSurgeofDarkness:Start(-delay)
        timerLeech:Start(-delay)
        timerSearingFlamesCD:Schedule(11-delay)
        warnSurgeDarknessSoon:Schedule(57-delay)
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 33271, "GeneralVezax", wipe)
        DBM.BossHealth:Hide()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(62661, 312624, 312977) then	-- Жгучее пламя
		timerSearingFlamesCast:Start()
                timerSearingFlamesCD:Start()
                specwarnSearingFlames:Show()
                specwarnSearingFlames:Play("kickcast")
	elseif args:IsSpellID(62662, 312628, 312981) then -- Всплеск тьмы
		specWarnSurgeDarkness:Show()
		timerNextSurgeofDarkness:Start()
                warnSurgeDarknessSoon:Schedule(57)
	end
end

function mod:SPELL_INTERRUPT(args)
	if args:IsSpellID(62661, 312624, 312977) then
		timerSearingFlamesCast:Stop()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(62662, 312628, 312981) then	-- Всплекс тьмы
		timerSurgeofDarkness:Start()
                specWarnSurgeDarkness:Show()
		specWarnSurgeDarkness:Play("defensive")
                PlaySoundFile("\sound\\creature\\kiljaeden\\kiljaeden02.wav")
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(62662, 312628, 312981) then	
		timerSurgeofDarkness:Stop()
        elseif args:IsSpellID(63276, 312621, 312974) then	        -- Метка Безликого
                if self.Options.SetIconOnLifeLeach then
			self:SetIcon(args.destName, 0)
		end
	end
end

function mod:ShadowCrashTarget()
	local target = self:GetBossTarget(33271)
	if not target then return end
	if mod:LatencyCheck() then--Only send sync if you have low latency.
		self:SendSync("CrashOn", target)
	end
end

function mod:OldShadowCrashTarget()
	local targetname = self:GetBossTarget()
	if not targetname then return end
	if self.Options.SetIconOnShadowCrash then
		self:SetIcon(targetname, 7, 10)
	end
	warnShadowCrash:Show(targetname)
	if targetname == UnitName("player") then
		specWarnShadowCrash:Show(targetname)
	elseif targetname then
		local uId = DBM:GetRaidUnitId(targetname)
		if uId then
			local inRange = CheckInteractDistance(uId, 2)
			local x, y = GetPlayerMapPosition(uId)
			if x == 0 and y == 0 then
				SetMapToCurrentZone()
				x, y = GetPlayerMapPosition(uId)
			end
			if inRange then
				specWarnShadowCrashNear:Show()
				if self.Options.CrashArrow then
					DBM.Arrow:ShowRunAway(x, y, 15, 5)
				end
			end
		end
	end
end


function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(62660, 312978, 312625, 312627) then		-- Темное сокрушение
		if self.Options.BypassLatencyCheck then
			self:ScheduleMethod(0.1, "OldShadowCrashTarget")
		else
			self:ScheduleMethod(0.1, "ShadowCrashTarget")
		end
	elseif args:IsSpellID(63276, 312621, 312974) then	        -- Метка Безликого
		if self.Options.SetIconOnLifeLeach then
			self:SetIcon(args.destName, 8, 10)
		end
		warnLeechLife:Show(args.destName)
		timerLifeLeech:Start(args.destName)
                timerLeech:Start()
		if args:IsPlayer() then
			specWarnLifeLeechYou:Show()
                        PlaySoundFile("Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav")
			if self.Options.YellOnLifeLeech then
				SendChatMessage(L.YellLeech, "SAY")
			end
		else
			local uId = DBM:GetRaidUnitId(args.destName)
			if uId then
				local inRange = CheckInteractDistance(uId, 2)
				if inRange then
					specWarnLifeLeechNear:Show(args.destName)
				end
			end
		end
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(emote)
	if emote == L.EmoteSaroniteVapors or emote:find(L.EmoteSaroniteVapors) then
		timerSaroniteVapors:Start()
	end
end

function mod:OnSync(msg, target)
	if msg == "CrashOn" then
		if not self.Options.BypassLatencyCheck then
			warnShadowCrash:Show(target)
			if self.Options.SetIconOnShadowCrash then
				self:SetIcon(target, 8, 10)
			end
			if target == UnitName("player") then
				specWarnShadowCrash:Show()
                                yellShadowCrash:Yell()
			elseif target then
				local uId = DBM:GetRaidUnitId(target)
				if uId then
					local inRange = CheckInteractDistance(uId, 2)
					local x, y = GetPlayerMapPosition(uId)
					if x == 0 and y == 0 then
						SetMapToCurrentZone()
						x, y = GetPlayerMapPosition(uId)
					end
					if inRange then
						specWarnShadowCrashNear:Show()
						if self.Options.CrashArrow then
							DBM.Arrow:ShowRunAway(x, y, 15, 5)
						end
					end
				end
			end
		end
	end
end