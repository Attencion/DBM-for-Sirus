local mod	= DBM:NewMod("Razorscale", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210501002800")

mod:SetCreatureID(33186)
mod:RegisterCombat("yell", L.YellAir)
mod:SetUsedIcons(8)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_APPLIED_DOSE",
	"SPELL_MISSED",
	"SPELL_DAMAGE",
	"CHAT_MSG_MONSTER_YELL",
	"RAID_BOSS_EMOTE",
	"UNIT_SPELLCAST_SUCCEEDED",
        "SPELL_AURA_REMOVED"
)

local warnArmorfire		        = mod:NewStackAnnounce(312721, 1, nil, "Tank|Healer")

local warnTurretsReadySoon		= mod:NewAnnounce("warnTurretsReadySoon", 1, 48642)
local warnTurretsReady			= mod:NewAnnounce("warnTurretsReady", 3, 48642)
local warnDevouringFlameCast		= mod:NewAnnounce("WarnDevouringFlameCast", 2, 64733, false, "OptionDevouringFlame") -- new option is just a work-around...

local specWarnDevouringFlame		= mod:NewSpecialWarningMove(64733)
local specWarnDevouringFlameCast	= mod:NewSpecialWarning("SpecWarnDevouringFlameCast")
local specWarnArmorfirelf	        = mod:NewSpecialWarningTaunt(312721, "Tank", nil, nil, 1, 2)
local specWarnArmorfire		        = mod:NewSpecialWarningStack(312721, "Tank", 2)

local enrageTimer			= mod:NewBerserkTimer(900)
local timerDeepBreathCooldown		= mod:NewCDTimer(15, 313098, nil, nil, nil, 2, nil)
local timerDeepBreathCast		= mod:NewCastTimer(2.5, 313098, nil, nil, nil, 2, nil)
local timerTurret1			= mod:NewTimer(53, "timerTurret1", 48642)
local timerTurret2			= mod:NewTimer(73, "timerTurret2", 48642)
local timerTurret3			= mod:NewTimer(93, "timerTurret3", 48642)
local timerTurret4			= mod:NewTimer(113, "timerTurret4", 48642)
local timerGrounded                     = mod:NewTimer(36, "timerGrounded")
local timerArmorfire			= mod:NewTargetTimer(20, 312721, nil, "Tank|Healer", nil, 5, nil, DBM_CORE_TANK_ICON)
local timerNextArmorfire                = mod:NewNextTimer(15, 312721, nil, "Tank|Healer", nil, 5, nil, DBM_CORE_TANK_ICON)

mod:AddSetIconOption("DevouringFlameIcon", 64733, true, false, {8})

local castFlames
local combattime = 0

function mod:OnCombatStart(delay)
        DBM:FireCustomEvent("DBM_EncounterStart", 33186, "Razorscale")
	enrageTimer:Start(-delay)
	combattime = GetTime()
	if mod:IsDifficulty("heroic10") then
		warnTurretsReadySoon:Schedule(53-delay)
		warnTurretsReady:Schedule(73-delay)
		timerTurret1:Start(-delay)
		timerTurret2:Start(-delay)
	else
		warnTurretsReadySoon:Schedule(93-delay)
		warnTurretsReady:Schedule(113-delay)
		timerTurret1:Start(-delay) -- 53sec
		timerTurret2:Start(-delay) -- +20
		timerTurret3:Start(-delay) -- +20
		timerTurret4:Start(-delay) -- +20
	end
end

function mod:OnCombatEnd(wipe)
	DBM:FireCustomEvent("DBM_EncounterEnd", 33186, "Razorscale", wipe)
        DBM.BossHealth:Hide()
        DBM.RangeCheck:Hide()
end

function mod:SPELL_DAMAGE(args)
	if args:IsSpellID(64733, 64704) and args:IsPlayer() then  -- Бомба
		specWarnDevouringFlame:Show()		
	end
end


function mod:CHAT_MSG_RAID_BOSS_EMOTE(emote)
	if emote == L.EmotePhase2 or emote:find(L.EmotePhase2) then
		-- phase2
		timerTurret1:Stop()
		timerTurret2:Stop()
		timerTurret3:Stop()
		timerTurret4:Stop()
		timerGrounded:Stop()
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg, mob)
	if (msg == L.YellAir or msg == L.YellAir2) and GetTime() - combattime > 30 then
		if mod:IsDifficulty("heroic10") then -- not sure?
			warnTurretsReadySoon:Schedule(23)
			warnTurretsReady:Schedule(43)
			timerTurret1:Start(23)
			timerTurret2:Start(43)
		else
			warnTurretsReadySoon:Schedule(93)
			warnTurretsReady:Schedule(113)
			timerTurret1:Start()
			timerTurret2:Start()
			timerTurret3:Start()
			timerTurret4:Start()
		end

	elseif msg == L.YellGround then
		timerGrounded:Start()
		timerDeepBreathCooldown:Start(30)
	end
end

--function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(312721, 64771, 312368) then   -- Плавящийся доспех
                        timerArmorfire:Start(args.destName)
                if self:IsTank() then

                        warnArmorfire:Show(args.destName, args.amount or 1)
                        timerNextArmorfire:Start()
                        specWarnArmorfire:Show()
                else
                        specWarnArmorfirelf:Show(args.destName)
                        specWarnArmorfirelf:Play("tauntboss")
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(312721, 64771, 312368) then   -- Плавящийся доспех
                        timerArmorfire:Start(args.destName)
                        timerNextArmorfire:Start()
                if self:IsTanking(uId) then
			if (args.amount) >= 2 then
				if args:IsPlayer() then
					specWarnArmorfire:Show(args.amount)
					specWarnArmorfire:Play("stackhigh")
				else
					if not UnitIsDeadOrGhost("player") and not DBM:UnitDebuff("player", args.spellName) then
						specWarnArmorfirelf:Show(args.destName)
						specWarnArmorfirelf:Play("tauntboss")
					end
				end
                        end
                end
        end
end
 
function mod:SPELL_CAST_START(args)
	if args:IsSpellID(63317, 64021, 313098, 313097) then	-- Огненное дыхание
		timerDeepBreathCast:Start()
		timerDeepBreathCooldown:Start()
	elseif args:IsSpellID(63236) then
		local target = self:GetBossTarget(self.creatureId)
		if target then
			self:CastFlame(target)
		else
			castFlames = GetTime()
		end
	end
end


function mod:UNIT_TARGET(unit)	-- I think this is useless, why would anyone in the raid target razorflame right after the flame stuff?
	if castFlames and GetTime() - castFlames <= 1 and self:GetUnitCreatureId(unit.."target") == self.creatureId then
		local target = UnitName(unit.."targettarget")
		if target then
			self:CastFlame(target)
		else
			self:CastFlame(L.FlamecastUnknown)
		end
		castFlames = false
	end
end 

function mod:CastFlame(target)
	warnDevouringFlameCast:Show(target)
	if target == UnitName("player") then
		specWarnDevouringFlameCast:Show()
	end
	self:SetIcon(target, 8, 9)
end 

function mod:SPELL_AURA_REMOVED(args)
	if args:IsSpellID(312721, 64771, 312368) then		-- Плавящийся доспех
                timerArmorfire:Stop()
	end
end

mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED