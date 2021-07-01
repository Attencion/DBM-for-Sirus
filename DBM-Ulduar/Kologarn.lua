local mod	= DBM:NewMod("Kologarn", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 4134 $"):sub(12, -3))
mod:SetCreatureID(32930, 32933, 32934)
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

local warnFocusedEyebeam		= mod:NewTargetAnnounce(312765, 3)
local warnGrip					= mod:NewTargetAnnounce(312760, 2)
local warnCrunchArmor			= mod:NewTargetAnnounce(312748, 2)

local specWarnCrunchArmor2		= mod:NewSpecialWarningStack(312748, false, 2)
local specWarnEyebeam			= mod:NewSpecialWarningYou(312765)

local timerCrunch10             = mod:NewTargetTimer(6, 312748)
local timerCrunchArmor  		= mod:NewCDTimer(15, 312748)
local timerNextShockwave		= mod:NewCDTimer(23, 312752)
local timerFocusedGaze	     	= mod:NewCDTimer(20, 312765)
local timerFocusedGazect        = mod:NewCastTimer(10, 312765)
local timerRespawnLeftArm		= mod:NewTimer(48, "timerLeftArm")
local timerRespawnRightArm		= mod:NewTimer(48, "timerRightArm")
local timerTimeForDisarmed		= mod:NewTimer(10, "achievementDisarmed")	-- 10 HC / 12 nonHC

-- 5/23 00:33:48.648  SPELL_AURA_APPLIED,0x0000000000000000,nil,0x80000000,0x0480000001860FAC,"Hâzzad",0x4000512,63355,"Crunch Armor",0x1,DEBUFF
-- 6/3 21:41:56.140 UNIT_DIED,0x0000000000000000,nil,0x80000000,0xF1500080A60274A0,"Rechter Arm",0xa48 

mod:AddBoolOption("HealthFrame", true)
mod:AddBoolOption("SetIconOnGripTarget", true)
mod:AddBoolOption("PlaySoundOnEyebeam", true)
mod:AddBoolOption("SetIconOnEyebeamTarget", true)
mod:AddBoolOption("YellOnBeam", true, "announce")


function mod:OnCombatStart(delay)
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
    
end


function mod:UNIT_DIED(args)
	if self:GetCIDFromGUID(args.destGUID) == 32934 then 		-- right arm
		timerRespawnRightArm:Start()
		if mod:IsDifficulty("heroic10") then
			timerTimeForDisarmed:Start(12)
		else
			timerTimeForDisarmed:Start()			
		end
	elseif self:GetCIDFromGUID(args.destGUID) == 32933 then		-- left arm
		timerRespawnLeftArm:Start()
		if mod:IsDifficulty("heroic10") then
			timerTimeForDisarmed:Start(12)
		else
			timerTimeForDisarmed:Start()
		end
	end
end

function mod:SPELL_DAMAGE(args)
	if args:IsSpellID(63783, 63982, 312399, 312752) and args:IsPlayer() then	-- Shockwave
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
	end
end

function mod:OnSync(msg, target)
	if msg == "EyeBeamOn" then
		warnFocusedEyebeam:Show(target)
		if target == UnitName("player") then
			specWarnEyebeam:Show()
			if self.Options.PlaySoundOnEyebeam then
				PlaySoundFile("Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav") 
			end
			if self.Options.YellOnBeam then
				SendChatMessage(L.YellBeam, "SAY")
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
	if args:IsSpellID(64290, 64292, 312407, 312760) then
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
	elseif args:IsSpellID(64002, 63355, 312395, 312748) then	-- Crunch Armor
        warnCrunchArmor:Show(args.destName)
		if mod:IsDifficulty("heroic10") then
            timerCrunch10:Start(args.destName)  -- We track duration timer only in 10-man since it's only 6sec and tanks don't switch.
		end
    end
end

function mod:SPELL_AURA_APPLIED_DOSE(args)
	if args:IsSpellID(64002, 63355, 312395, 312748) then		        -- Crunch Armor (25-man only)
		warnCrunchArmor:Show(args.destName)
        if args.amount >= 2 then 
            if args:IsPlayer() then
                specWarnCrunchArmor2:Show(args.amount)
            end
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(64290, 64292, 312407, 312760) then
		self:SetIcon(args.destName, 0)
    end
end