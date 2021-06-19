local mod	= DBM:NewMod("Kologarn", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210501000000")

mod:SetCreatureID(32930, 32933, 32934)
mod:RegisterCombat("yell",L.YellPull)
mod:SetUsedIcons(5, 6, 7, 8)

mod:RegisterCombat("combat", 32930, 32933, 32934)

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_AURA_REMOVED",
	"SPELL_DAMAGE",
	"CHAT_MSG_RAID_BOSS_WHISPER",
	"UNIT_DIED"
)

mod:SetBossHealthInfo(
	32930, L.Health_Body,
	32934, L.Health_Right_Arm,
	32933, L.Health_Left_Arm
)

local warnCrunchArmor		        = mod:NewStackAnnounce(312748, 1, nil, "Tank|Healer")
local warnFocusedEyebeam		= mod:NewTargetAnnounce(312765, 3)
local warnGrip				= mod:NewTargetAnnounce(312757, 1)

local specWarnCrunchArmor2		= mod:NewSpecialWarningStack(312748, "Tank", 2)
local specWarnEyebeam			= mod:NewSpecialWarningYou(312765)
local specWarnCrunchArmorlf             = mod:NewSpecialWarningTaunt(312748, "Tank", nil, nil, 1, 2)

local timerCrunch10                     = mod:NewTargetTimer(45, 312748, nil, "Tank|Healer", nil, 5, nil, DBM_CORE_TANK_ICON)
local timerCrunchArmor  		= mod:NewNextTimer(40, 312748, nil, "Tank|Healer", nil, 5, nil, DBM_CORE_TANK_ICON)
local timerNextShockwave		= mod:NewCDTimer(23, 312752)
local timerFocusedGaze	     	        = mod:NewCDTimer(20, 312765)
local timerFocusedGazect                = mod:NewCastTimer(10, 312765)
local timerRespawnLeftArm		= mod:NewTimer(48, "timerLeftArm")
local timerRespawnRightArm		= mod:NewTimer(48, "timerRightArm")
local timerTimeForDisarmed		= mod:NewTimer(10, "achievementDisarmed")	-- 10 HC / 12 nonHC

local yellFocusedEyebeam		= mod:NewYell(312765)


mod:AddBoolOption("HealthFrame", true)
mod:AddSetIconOption("SetIconOnGripTarget", 312757, true, false, {7, 6, 5})
mod:AddBoolOption("PlaySoundOnEyebeam", true)
mod:AddSetIconOption("SetIconOnEyebeamTarget", 312765, true, false, {8})
mod:AddBoolOption("YellOnGrip", true)


function mod:OnCombatStart(delay)
    DBM:FireCustomEvent("DBM_EncounterStart", 32930, "Kologarn")
    timerCrunchArmor:Start(5-delay)
    timerCrunchArmor:Schedule(7-delay)
    timerCrunchArmor:Schedule(31-delay)
    timerCrunchArmor:Schedule(60-delay)
    timerCrunchArmor:Schedule(83-delay)
    timerCrunchArmor:Schedule(104.5-delay)
    timerCrunchArmor:Schedule(126.7-delay)
    timerCrunchArmor:Schedule(143.7-delay)
    timerCrunchArmor:Schedule(168-delay)
    timerCrunchArmor:Schedule(227-delay)
    timerCrunchArmor:Schedule(243.6-delay)
    timerCrunchArmor:Schedule(268.9-delay)	
	timerFocusedGaze:Start(-delay)
	timerFocusedGazect:Schedule(20-delay)
	timerNextShockwave:Start(10-delay)	
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 32930, "Kologarn", wipe)
        DBM.BossHealth:Hide()
end

function mod:UNIT_DIED(args)
	if self:GetCIDFromGUID(args.destGUID) == 32934 then 		-- правая рука
		timerRespawnRightArm:Start()
		if mod:IsDifficulty("heroic10") or mod:IsDifficulty("heroic25") then
			timerTimeForDisarmed:Start(12)
		else
			timerTimeForDisarmed:Start()			
		end
	elseif self:GetCIDFromGUID(args.destGUID) == 32933 then		-- левая рука
		timerRespawnLeftArm:Start()
		if mod:IsDifficulty("heroic10") or mod:IsDifficulty("heroic25") then
			timerTimeForDisarmed:Start(12)
		else
			timerTimeForDisarmed:Start()
		end
	end
end

function mod:SPELL_DAMAGE(args)
	if args:IsSpellID(63783, 63982, 312399, 312752) and args:IsPlayer() then	-- Ударная волна
		timerNextShockwave:Start()
	elseif args:IsSpellID(63346, 63976, 312412, 312765) and args:IsPlayer() then
		specWarnEyebeam:Show()
	end
end

function mod:CHAT_MSG_RAID_BOSS_WHISPER(msg)
	if msg:find(L.FocusedEyebeam) then
		self:SendSync("EyeBeamOn", UnitName("player"))
		timerFocusedGaze:Start()
		timerFocusedGazect:Start()
                warnFocusedEyebeam:Show()
	end
end

function mod:OnSync(msg, target)
	if msg == "EyeBeamOn" then
		warnFocusedEyebeam:Show(target)
		if target == UnitName("player") then
			specWarnEyebeam:Show()
                        yellFocusedEyebeam:Yell()
			if self.Options.PlaySoundOnEyebeam then
				PlaySoundFile("Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav") 
			end
		end 
		if self.Options.SetIconOnEyebeamTarget then
			self:SetIcon(target, 5, 8) 
		end
	end
end

local gripTargets = {}
function mod:GripAnnounce()
	warnGrip:Show(table.concat(gripTargets, "<, >"))
	table.wipe(gripTargets)
end
function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(64290, 64292, 312407, 312760) then        -- Каменная хватка
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
	elseif args:IsSpellID(64002, 63355, 312395, 312748) then	-- Хруст доспеха
                warnCrunchArmor:Show(args.destName, args.amount or 1)
                timerCrunch10:Start(args.destName)
                timerCrunchArmor:Start()
        end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(64290, 64292, 312407, 312760) then  --Хватка
		self:SetIcon(args.destName, 0)
        elseif args:IsSpellID(64002, 63355, 312395, 312748) then		-- Хруст доспеха
                timerCrunch10:Stop()
        end
end