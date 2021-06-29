local mod	= DBM:NewMod("Freya_Elders", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210501000000")

-- passive mod to provide information for multiple fight (trash respawn)
mod:SetCreatureID(32914, 32915, 32913)
mod:RegisterCombat("combat", 32914, 32915, 32913)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_AURA_APPLIED",
	"UNIT_DIED"
)

local warnImpale			= mod:NewTargetAnnounce(312859)
local timerImpale			= mod:NewTargetTimer(5, 312859, "Прокол - %s")

local specWarnFistofStone	= mod:NewSpecialWarningDefensive(312853, mod:IsTank())
local specWarnGroundTremor	= mod:NewSpecialWarningCast(312856, "SpellCaster")

local timerStoneCD 		    = mod:NewCDTimer(71, 312853, nil, nil, nil, 3, nil, DBM_CORE_TANK_ICON)
local timerCoreCD 		    = mod:NewCDTimer(39.6, 312842, nil, nil, nil, 2, nil, DBM_CORE_INTERRUPT_ICON)

mod:AddBoolOption("PlaySoundOnFistOfStone", false)
mod:AddBoolOption("TrashRespawnTimer", true, "timer")

--
-- Trash: 33430 Guardian Lasher (flower)
-- 33355 (nymph)
-- 33354 (tree)
--
-- Elder Stonebark (ground tremor / fist of stone)
-- Elder Brightleaf (unstable sunbeam)
--
--Mob IDs:
-- Elder Ironbranch: 32913
-- Elder Brightleaf: 32915
-- Elder Stonebark: 32914
--
function mod:OnCombatStart(delay)
    timerStoneCD:Start(26)
	timerCoreCD:Start()
end


function mod:SPELL_CAST_START(args)
	if args:IsSpellID(62344, 300893, 312500, 312853) then	-- Каменные кулаки
		specWarnFistofStone:Show()
		specWarnFistofStone:Play("defensive")
		timerStoneCD:Start()
		if self.Options.PlaySoundOnFistOfStone then
			PlaySoundFile("Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav")
		end
	elseif args:IsSpellID(62325, 62932, 312489, 312503, 312842, 312856) then	-- Дрожание земли
		specWarnGroundTremor:Show()
	elseif args:IsSpellID(312857, 312504, 62337, 62933) then	-- Окаменевшая кора
        timerCoreCD:Start()	
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(62310, 62928, 312506, 312859) then	-- Прокалывание
		warnImpale:Show(args.destName)
		timerImpale:Start(args.destName)
	end
end

function mod:UNIT_DIED(args)
	if self.Options.TrashRespawnTimer and not DBM.Bars:GetBar(L.TrashRespawnTimer) then
		local guid = tonumber(args.destGUID:sub(9, 12), 16)
		if guid == 33430 or guid == 33355 or guid == 33354 then	-- guardian lasher / nymph / tree
			DBM.Bars:CreateBar(7200, L.TrashRespawnTimer)
		end
	end
end