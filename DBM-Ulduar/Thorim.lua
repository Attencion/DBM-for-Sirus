local mod	= DBM:NewMod("Thorim", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210501000000")
mod:SetCreatureID(32865)
mod:SetUsedIcons(8)

mod:RegisterCombat("yell", L.YellPhase1)
mod:RegisterKill("yell", L.YellKill)

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"CHAT_MSG_MONSTER_YELL",
	"SPELL_CAST_SUCCESS",
    "SPELL_CAST_START",
	"SPELL_DAMAGE"
)

local warnPhase2				= mod:NewPhaseAnnounce(2, 1)
local warnStormhammer			= mod:NewTargetAnnounce(312890, 2) --Оглушительный гром
local warnVolley          		= mod:NewSpellAnnounce(312902, 4) --Залп ледяных стрел
local warnUnbalancingStrike		= mod:NewTargetAnnounce(312898, 3, nil, "Tank|Healer") --Деформирующий удар
local warningBomb				= mod:NewTargetAnnounce(312910, 4) --Взрыв руны

local specWarnOrb				= mod:NewSpecialWarningMove(312892) --Поражение громом
local specWarnLightningCharge	= mod:NewSpecialWarningDodgeCount(312896, nil, nil, nil, 1, 2) --Разряд молнии
local specWarnUnbalancingStrike	= mod:NewSpecialWarningYou(312898, "Tank", nil, nil, 2, 2) --дисбаланс
local specWarnUnbalancingStrikelf = mod:NewSpecialWarningTaunt(312898, "Tank", nil, nil, 1, 2) --дисбаланс
local specWarnNova				= mod:NewSpecialWarningYou(312904, nil, nil, nil, 2, 2) --Нова

mod:AddBoolOption("AnnounceFails", false, "announce")

local enrageTimer			    = mod:NewBerserkTimer(369)
local timerStormhammer			= mod:NewCDTimer(18, 312889, nil, nil, nil, 3)
local timerLightningCharge	 	= mod:NewCDTimer(16, 312896, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON) --Разряд молнии
local timerLightningCharge2	 	= mod:NewCDTimer(12, 312895, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON) --Цепная молния
local timerNova          	 	= mod:NewCDTimer(20, 312904, nil, nil, nil, 2, nil, DBM_CORE_HEALER_ICON..DBM_CORE_MAGIC_ICON) --нова
local timerVolley               = mod:NewCDTimer(20, 312902, nil, nil, nil, 2, nil, DBM_CORE_HEALER_ICON..DBM_CORE_MAGIC_ICON) --залп
local timerUnbalancingStrike	= mod:NewTargetTimer(15, 312898, nil, "Tank|Healer", nil, 3, nil, DBM_CORE_TANK_ICON) --дисбаланс
local timerUnbalancingStrikeCD	= mod:NewCDTimer(20, 312898, nil, "Tank", nil, 3, nil, DBM_CORE_TANK_ICON..DBM_CORE_DEADLY_ICON) --дисбаланс
local timerAchieve				= mod:NewAchievementTimer(175, 6770, "TimerSpeedKill")

local yellBomb		            = mod:NewYell(312910)

mod:AddSetIconOption("SetIconOnBomb", 312910, true, false, {8})
mod:AddBoolOption("RangeFrame", true)

mod.vb.chargeCount = 0

local lastcharge				= {} 

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 32865, "Thorim")
	self.vb.chargeCount = 0
	enrageTimer:Start()
	timerAchieve:Start()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Show(8)
	end
	table.wipe(lastcharge) 
end

local sortedFailsC = {}
local function sortFails1C(e1, e2)
	return (lastcharge[e1] or 0) > (lastcharge[e2] or 0)
end

function mod:OnCombatEnd()
	DBM:FireCustomEvent("DBM_EncounterEnd", 32865, "Thorim", wipe)
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
	if self.Options.AnnounceFails and DBM:GetRaidRank() >= 1 then
		local lcharge = ""
		for k, v in pairs(lastcharge) do
			table.insert(sortedFailsC, k)
		end
		table.sort(sortedFailsC, sortFails1C)
		for i, v in ipairs(sortedFailsC) do
			lcharge = lcharge.." "..v.."("..(lastcharge[v] or "")..")"
		end
		SendChatMessage(L.Charge:format(lcharge), "RAID")
		table.wipe(sortedFailsC)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(62042, 312890, 312536) then --Молот бури
		warnStormhammer:Show(args.destName)
	elseif args:IsSpellID(62130, 300664, 312545, 312898) then --Дисбалансирующий удар
		warnUnbalancingStrike:Show(args.destName)
		timerUnbalancingStrike:Start(args.destName)
		if args:IsPlayer() then
		    specWarnUnbalancingStrike:Show()
		else
		    specWarnUnbalancingStrikelf:Show(args.destName)
			specWarnUnbalancingStrikelf:Play("tauntboss")
		end
	elseif args:IsSpellID(62526, 62527, 312557, 312558, 312910, 312911) then --Детонация руны
		warningBomb:Show(args.destName)
		if self.Options.SetIconOnBomb then
			self:SetIcon(args.destName, 8, 5)
        end
		if args:IsPlayer() then
			yellBomb:Yell()
		end
	elseif args:IsSpellID(312904, 62605, 312551) then --Фростнова
	    timerNova:Start()
		if args:IsPlayer() then
		    specWarnNova:Show()
		end
	end
end

function mod:SPELL_CAST_START(args)
    if args:IsSpellID(62042, 312890, 312536) then --Молот бури
		timerStormhammer:Start()
	elseif args:IsSpellID(312895, 312542, 62131) then --Цепная молния
	    timerLightningCharge2:Start()
	end
end	

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(62130, 300664, 312545, 312898) then --Дисбалансирующий удар
		timerUnbalancingStrikeCD:Start()
    elseif args:IsSpellID(312902, 62604, 312549) then --Залп стрел
	    warnVolley:Show()
        timerVolley:Start()
    elseif args:IsSpellID(312896, 312543, 62279) then --Разряд молнии
		self.vb.chargeCount = self.vb.chargeCount + 1
		specWarnLightningCharge:Show(self.vb.chargeCount)
		timerLightningCharge:Start(16, self.vb.chargeCount+1)
	end
end


function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.YellPhase2 and mod:LatencyCheck() then --Фаза
		self:SendSync("Phase2")
	end
end

local spam = 0
function mod:SPELL_DAMAGE(args)
	if args:IsSpellID(62017, 312539, 312892) then --Поражение громом
		if bit.band(args.destFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) ~= 0
		and bit.band(args.destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) ~= 0
		and GetTime() - spam > 5 then
			spam = GetTime()
			specWarnOrb:Show()
		end
	elseif self.Options.AnnounceFails and args:IsSpellID(62466, 312897, 312544) and DBM:GetRaidRank() >= 1 and DBM:GetRaidUnitId(args.destName) ~= "none" and args.destName then
		lastcharge[args.destName] = (lastcharge[args.destName] or 0) + 1
		SendChatMessage(L.ChargeOn:format(args.destName), "RAID")
	end
end

function mod:OnSync(event, arg)
	if event == "Phase2" then
		warnPhase2:Show()
		enrageTimer:Stop()
		timerAchieve:Stop()
		enrageTimer:Start(300)
		timerLightningCharge:Start(24)
		timerUnbalancingStrike:Start(26)
	end
end