local mod	= DBM:NewMod("Gorelac", "DBM-Serpentshrine")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20201208235000")

mod:SetCreatureID(121217)
mod:RegisterCombat("combat", 121217)
mod:SetUsedIcons(8)

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL",
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"UNIT_DIED",
	"UNIT_TARGET",
	"SPELL_AURA_REMOVED",
	"CHAT_MSG_LOOT",
	"SWING_DAMAGE"
)


local warnStrongBeat			= mod:NewStackAnnounce(310548, 1, nil, "Tank|Healer") --Клешня
local warnPoisonous				= mod:NewSpellAnnounce(310549, 4) --Ядовитая рвота
local warnPowerfulShot			= mod:NewTargetAnnounce(310564, 4) --Мощный выстрел
local warnCallGuardians			= mod:NewSpellAnnounce(310557, 3) --Вызов треша
local warnParalysis				= mod:NewSpellAnnounce(310555, 4) --Паралич
local warnCallGuardiansSoon		= mod:NewPreWarnAnnounce(310557, 5, 3) --Вызов треша
local warnShrillScreech			= mod:NewSpellAnnounce(310566, 3) --Пронзительный визг

local specwarnCallGuardians		= mod:NewSpecialWarningSwitchCount(310557, "Dps", nil, nil, 2, 2) --Треш
local specWarnRippingThorn		= mod:NewSpecialWarningStack(310546, nil, 7, nil, nil, 1, 6) --шип
local specWarnPoisonousBlood	= mod:NewSpecialWarningStack(310547, nil, 7, nil, nil, 1, 6) --кровь
local specWarnPoisonous			= mod:NewSpecialWarningYou(310549, nil, nil, nil, 2, 2) --Рвота
local specWarnStrongBeat		= mod:NewSpecialWarningYou(310548, nil, nil, nil, 2, 2) --Клешня
local specWarnShrillScreech		= mod:NewSpecialWarningYou(310566, nil, nil, nil, 2, 2) --визг
local specwarnParalysis			= mod:NewSpecialWarningYou(310555, nil, nil, nil, 1, 2) --Паралич
 

local timerParalysis			= mod:NewBuffFadesTimer(10, 310555, nil, nil, nil, 2, nil, DBM_CORE_MAGIC_ICON)
local timerParalysisCD			= mod:NewCDTimer(20, 310555, nil, nil, nil, 2, nil, DBM_CORE_MAGIC_ICON)
local timerStrongBeat			= mod:NewBuffFadesTimer(30, 310548, nil, "Tank|Healer", nil, 5, nil)
local timerPoisonous			= mod:NewBuffFadesTimer(30, 310549, nil, "Tank|Healer", nil, 5, nil)
local timerShrillScreech		= mod:NewBuffFadesTimer(6, 310566, nil, nil, nil, 5, nil, DBM_CORE_INTERRUPT_ICON)
local timerPoisonousCD			= mod:NewCDTimer(25, 310549, nil, nil, nil, 3, nil, DBM_CORE_TANK_ICON)
local timerStrongBeatCD			= mod:NewCDTimer(25, 310548, nil, nil, nil, 3, nil, DBM_CORE_DEADLY_ICON) 
local timerCallGuardiansCD		= mod:NewNextTimer(45, 310557, nil, nil, nil, 1, nil, DBM_CORE_DAMAGE_ICON)

local enrageTimer				= mod:NewBerserkTimer(750)

mod:AddSetIconOption("SetIconOnPowerfulShotTarget", 310564, true, false, {8})

mod.vb.guardiansCount = 0

function mod:OnCombatStart(delay)
    DBM:FireCustomEvent("DBM_EncounterStart", 121217, "Gorelac")
	self.vb.guardiansCount = 0
    enrageTimer:Start(-delay)
    timerCallGuardians:Start(45-delay)
    warnCallGuardiansSoon:Schedule(40-delay)
	DBM.RangeCheck:Show(6)
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 121217, "Gorelac", wipe)
    DBM.RangeCheck:Hide()
end


function mod:SPELL_CAST_START(args)
    if args:IsSpellID(310566) then --Пронзительный визг
		warnShrillScreech:Show()
    elseif args:IsSpellID(310549) then --Рвота
        warnPoisonous:Show()
        timerPoisonousCD:Start() 
    elseif args:IsSpellID(310557) then --Призыв охранителей
		self.vb.guardiansCount = self.vb.guardiansCount + 1
        warnCallGuardians:Show()
		specwarnCallGuardians:Show(self.vb.guardiansCount)
        specwarnCallGuardians:Play("killmob")
        timerCallGuardiansCD:Start(nil, self.vb.guardiansCount+1)
        warnCallGuardiansSoon:Schedule(40)
    end
end

function mod:SPELL_AURA_APPLIED(args)
    if args:IsSpellID(310546) then --Шип
		local amount = args.amount or 1
		if amount >= 7 then
            if args:IsPlayer() then
				specWarnRippingThorn:Show(args.amount)
				specWarnRippingThorn:Play("stackhigh")
			end
        end
    elseif args:IsSpellID(310547) then --Кровь
		local amount = args.amount or 1
		if amount >= 7 then
            if args:IsPlayer() then
				specWarnPoisonousBlood:Show(args.amount)
				specWarnPoisonousBlood:Play("stackhigh")
			end
        end
    elseif args:IsSpellID(310548) then --Клешня
        warnStrongBeat:Show(args.destName, args.amount or 1)
		timerStrongBeat:Start(args.destName)
        if args:IsPlayer() then
            specWarnStrongBeat:Show()
        end
    elseif args:IsSpellID(310555) then --Паралич
		timerParalysisCD:Start()
		if args:IsPlayer() then
			specwarnParalysis:Show()
			timerParalysis:Start()
		end	
    elseif args:IsSpellID(310549) then --Рвота
        timerPoisonous:Start(args.destName)
		if args:IsPlayer() then
			specWarnPoisonous:Show()
		end
	elseif args:IsSpellID(310566) then --визг
		timerShrillScreech:Start()
		if args:IsPlayer() then
			specWarnShrillScreech:Show()
		end
    end
end

function mod:SPELL_CAST_SUCCESS(args)
    if args:IsSpellID(310548) then --Клешня
        timerStrongBeatCD:Start()
	elseif args:IsSpellID(310555) then --Паралич
		warnParalysis:Show()
	elseif args:IsSpellID(310564, 310565) then --Мощный выстрел
		warnPowerfulShot:Show(args.destName)
        PlaySoundFile("sound\\creature\\kiljaeden\\kiljaeden02.wav")
        if self.Options.SetIconOnPowerfulShotTarget then
			self:SetIcon(args.destName, 8, 5)
		end
    end
end

function mod:SPELL_AURA_REMOVED(args)
    if args:IsSpellID(310549) then --Рвота
        if args:IsPlayer() then
			timerPoisonous:Cancel()       
		end
    elseif args:IsSpellID(310548) then --Клешня
        if args:IsPlayer() then
			timerStrongBeat:Cancel()       
		end
	elseif args:IsSpellID(310564, 310565) then --Мощный выстрел
		if self.Options.SetIconOnPowerfulShotTarget then
			self:SetIcon(args.destName, 0)
		end
    elseif args:IsSpellID(310555) then --Паралич
        if args:IsPlayer() then
           timerParalysis:Cancel()       
		end
    end
end