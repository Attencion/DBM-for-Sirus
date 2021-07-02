local mod	= DBM:NewMod("Hodir", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210501000000")
mod:SetCreatureID(32845)
mod:SetUsedIcons(7, 8)

mod:RegisterCombat("combat")
mod:RegisterKill("yell", L.YellKill)

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_DAMAGE",
    "SPELL_AURA_REMOVED"
)

local warnStormCloud		= mod:NewTargetAnnounce(312831, 1) --грозовая туча
local warnFrozenBlows		= mod:NewSpellAnnounce(312462, 1, nil, "Tank|Healer") --Ледяные дуновения

local warnFlashFreeze		= mod:NewSpecialWarningSpell(312818) --вспышка
local specWarnStormCloud	= mod:NewSpecialWarningYou(312831, nil, nil, nil, 1, 2)
local specWarnBitingCold	= mod:NewSpecialWarningMove(312819, true) --трескучий мороз

local enrageTimer			= mod:NewBerserkTimer(475)
local timerFlashFreeze		= mod:NewCastTimer(9, 312818, nil, nil, nil, 6, nil)
local timerFrozenBlows		= mod:NewBuffActiveTimer(20, 312462, nil, "Tank|Healer", nil, 5, nil, DBM_CORE_TANK_ICON)
local timerFlashFrCD		= mod:NewCDTimer(60, 312818, nil, nil, nil, 6, nil)
local timerAchieve			= mod:NewAchievementTimer(179, 6766, "TimerSpeedKill")

mod:AddBoolOption("PlaySoundOnFlashFreeze", true)
mod:AddSetIconOption("SetIconOnStormCloud", 312831, true, false, {8, 7})
mod:AddBoolOption("YellOnStormCloud", true)

mod.vb.stormCloudIcon = 8

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 32845, "Hodir")
	enrageTimer:Start(-delay)
	timerAchieve:Start()
	timerFlashFrCD:Start(70-delay)
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 32845, "Hodir", wipe)
	DBM.RangeCheck:Hide()
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(61968, 312465, 312818) then --Ледяная вспышка
		timerFlashFreeze:Start()
		warnFlashFreeze:Show()
		timerFlashFrCD:Start()
		if self.Options.PlaySoundOnFlashFreeze then
			PlaySoundFile("Sound\\Creature\\AlgalonTheObserver\\UR_Algalon_BHole01.wav")
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(62478, 63512, 312815, 312462) then --Ледяные дуновения
		warnFrozenBlows:Show()
		timerFrozenBlows:Start()
	elseif args:IsSpellID(65123, 65133, 312478, 312831) then --Грозовая туча
		if args:IsPlayer() then
			specWarnStormCloud:Show()
		else
			warnStormCloud:Show(args.destName)
		end
		if self.Options.SetIconOnStormCloud then
			self:SetIcon(args.destName, self.vb.stormCloudIcon)
		end
		if self.vb.stormCloudIcon == 8 then --2 игрока
			self.vb.stormCloudIcon = 7
		else
			self.vb.stormCloudIcon = 8
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(65123, 65133, 312478, 312831) then --Грозовая туча
		if self.Options.SetIconOnStormCloud then
			self:SetIcon(args.destName, 0)
		end
	end
end

do 
	local lastbitingcold = 0
	function mod:SPELL_DAMAGE(args)
		if args:IsSpellID(62038, 62188, 312466, 312819) and args:IsPlayer() and time() - lastbitingcold > 2 then --Трескучий мороз
			specWarnBitingCold:Show()
			lastbitingcold = time()
		end
	end
end