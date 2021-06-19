local mod	= DBM:NewMod("Gorelac", "DBM-Serpentshrine")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20201208235000")

mod:SetCreatureID(55681)
mod:RegisterCombat("combat", 55681)
mod:SetUsedIcons(7, 8)


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

local canInterrupt
do
	local class = select(2, UnitClass("player"))
	canInterrupt = class == "WARRIOR"
		or class == "ROGUE"
                or class == "DEATHKNIGHT"
end

local MagicDispeller
do
	local class = select(2, UnitClass("player"))
	MagicDispeller = class == "PRIEST"
		or class == "PALADIN"
end

local warnStrongBeat	     = mod:NewStackAnnounce(310548, 1, nil, "Tank|Healer") --������
local warnPoisonous	     = mod:NewTargetAnnounce(310549, 1) --�������� �����
local warnMassiveShell	     = mod:NewTargetAnnounce(310560, 1) --�������
local warnPowerfulShot	     = mod:NewSpellAnnounce(310564, 2)  --������ �������
local warnCallGuardians	     = mod:NewSpellAnnounce(310557, 1)  --����� �����
local warnParalysis	     = mod:NewSpellAnnounce(310555, 2)  --�������
local warnCallGuardiansSoon  = mod:NewPreWarnAnnounce(310557, 5, 1)  --����� �����
local warnRippingThorn       = mod:NewCountAnnounce(310546, 2, nil, false)
local warnPoisonousBlood     = mod:NewCountAnnounce(310547, 2, nil, false)

local specwarnCallGuardians = mod:NewSpecialWarningSwitch(310557, "Dps", nil, nil, 1, 2) --����
local specWarnParalysis	    = mod:NewSpecialWarning("specWarnParalysis", MagicDispeller) --�������
local specWarnShrillScreech = mod:NewSpecialWarning("specWarnShrillScreech", canInterrupt)
local specWarnRippingThorn   = mod:NewSpecialWarningStack(310546, nil, 7, nil, nil, 1, 6)
local specWarnPoisonousBlood  = mod:NewSpecialWarningStack(310547, nil, 7, nil, nil, 1, 6)
local specWarnPoisonous	     = mod:NewSpecialWarningYou(310549, "Tank", nil, nil, 1, 2) -- �����
 

local timerParalysis	    = mod:NewBuffFadesTimer(10, 310555, nil, nil, nil, 7, nil, DBM_CORE_MAGIC_ICON)
local timerPoisonous	    = mod:NewBuffFadesTimer(30, 310549, nil, "Tank|Healer", nil, 5, nil)
local timerParalysisCD      = mod:NewCDTimer(20, 310555, nil, nil, nil, 7, nil, DBM_CORE_MAGIC_ICON)
local timerPoisonousCD	    = mod:NewCDTimer(25, 310549, nil, nil, nil, 3, nil, DBM_CORE_TANK_ICON)
local timerStrongBeatCD	    = mod:NewCDTimer(25, 310548, nil, nil, nil, 3, nil, DBM_CORE_TANK_ICON) 
local timerCallGuardiansCD  = mod:NewNextTimer(45, 310557, nil, nil, nil, 1, nil, DBM_CORE_DEADLY_ICON)
local timerStrongBeat       = mod:NewBuffFadesTimer(30, 310548, nil, "Tank|Healer", nil, 5, nil)
local timerRippingThorn     = mod:NewBuffFadesTimer(12, 310546, nil, nil, nil, 5)
local timerPoisonousBlood   = mod:NewBuffFadesTimer(6, 310547, nil, nil, nil, 5)

local enrageTimer	    = mod:NewBerserkTimer(750)


mod:AddSetIconOption("SetIconOnPowerfulShotTarget", 310564, true, false, {8})
mod:AddSetIconOption("SetIconOnMassiveShellTarget", 310560, true, false, {7})
mod:AddBoolOption("YellOnPowerfulShot", true)
mod:AddBoolOption("YellOnMassiveShell", true)

mod.vb.phase = 0


function mod:OnCombatStart(delay)
        DBM:FireCustomEvent("DBM_EncounterStart", 55681, "Gorelac")
        enrageTimer:Start(-delay)
        timerCallGuardians:Start(45-delay)
        warnCallGuardiansSoon:Schedule(40-delay)
        combattime = GetTime()
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 55681, "Gorelac", wipe)
end


function mod:SPELL_CAST_START(args)
         if args:IsSpellID(310566) then                        -- ������������� ����
		specWarnShrillScreech:Show()
                specWarnShrillScreech:Play("kickcast")
         elseif args:IsSpellID(310549) then                    -- �����
                timerPoisonousCD:Start() 
         elseif args:IsSpellID(310564, 310565) then            -- ������ �������
		warnPowerfulShot:Show(args.destName)
                PlaySoundFile("\sound\\creature\\kiljaeden\\kiljaeden02.wav")
                if self.Options.SetIconOnPowerfulShotTarget then
			self:SetIcon(args.destName, 8, 10)
                end
                if self.Options.YellOnPowerfulShot and args:IsPlayer() then
					SendChatMessage(L.YellPowerfulShot, "SAY")
                end
         elseif args:IsSpellID(310560, 310561, 310562, 310563) then         -- �������
		warnMassiveShell:Show()
                if self.Options.SetIconOnMassiveShellTarget then
			self:SetIcon(args.destName, 7, 10)
                end
                if self.Options.YellOnMassiveShell and args:IsPlayer() then
					SendChatMessage(L.YellMassiveShell, "SAY")
                end
         elseif args:IsSpellID(310557, 310558, 310559) then            -- ������ �����������
                warnCallGuardians:Show()
		specwarnCallGuardians:Show()
                specwarnCallGuardians:Play("killmob")
                timerCallGuardiansCD:Start()
                warnCallGuardiansSoon:Schedule(40)
                PlaySoundFile("Sound\\Creature\\illidan\\black_illidan_04.wav")
         end
end

function mod:SPELL_AURA_APPLIED(args)
         if args:IsSpellID(310546) then	 -- ���
		if args:IsPlayer() then
                        WarnRippingThorn:Show(args.amount or 1)
			timerRippingThorn:Start()
			if (args.amount or 1) >= 7 then
				specWarnRippingThorn:Show(args.amount)
				specWarnRippingThorn:Play("stackhigh")
                end
         end

         elseif args:IsSpellID(310547) then	-- �����
		if args:IsPlayer() then
                        warnPoisonousBlood:Show(args.amount or 1)
			timerPoisonousBlood:Start()
			if (args.amount or 1) >= 7 then
				specWarnPoisonousBlood:Show(args.amount)
				specWarnPoisonousBlood:Play("stackhigh")
                end
         end

         elseif args:IsSpellID(310548) then		-- ������
                if args:IsPlayer() then
                        warnStrongBeat:Show(args.destName, args.amount or 1)
                        timerStrongBeat:Start(args.destName)
                end

         elseif args:IsSpellID(310555) then		-- �������
		specwarnParalysis:Show()
                timerParalysis:Start()
                timerParalysisCD:Start()

         elseif args:IsSpellID(310549) then		-- �����
		warnPoisonous:Show(args.destName)
                timerPoisonous:Start(args.destName)
                specWarnPoisonous:Show()
         end
end

function mod:SPELL_CAST_SUCCESS(args)
         if args:IsSpellID(310548) then                 -- ������
                timerStrongBeatCD:Start()
         elseif args:IsSpellID(310555) then             -- �������
                warnParalysis:Show()        
         end
end

function mod:SPELL_AURA_REMOVED(args)
         if args:IsSpellID(310564) then     -- ������ �������
                if self.Options.SetIconOnPowerfulShotTarget then
			self:SetIcon(args.destName, 0)
		end
         elseif args:IsSpellID(310549) then     -- �����
                if args:IsPlayer() then
                        timerPoisonous:Cancel()       
		end
         elseif args:IsSpellID(310548) then     -- ������
                if args:IsPlayer() then
                        timerStrongBeat:Cancel()       
		end
         elseif args:IsSpellID(310555) then     -- �������
                if args:IsPlayer() then
                        timerParalysis:Cancel()       
		end
         elseif args:IsSpellID(310560) then     -- �������
                if self.Options.SetIconOnMassiveShellTarget then
			self:SetIcon(args.destName, 0)
		end
         elseif args:IsSpellID(310547) then	-- �����
		if args:IsPlayer() then
			timerPoisonousBlood:Cancel()
                end
         elseif args:IsSpellID(310546) then	-- ���
		if args:IsPlayer() then
			timerRippingThorn:Cancel()
		end
         end
end