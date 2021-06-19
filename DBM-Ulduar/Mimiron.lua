local mod	= DBM:NewMod("Mimiron", "DBM-Ulduar")
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20210501000000")

mod:SetCreatureID(33432)
mod:SetUsedIcons(1, 2, 3, 4, 5, 6, 7, 8)

mod:RegisterCombat("yell", L.YellPull)
mod:RegisterCombat("yell", L.YellHardPull)

mod:RegisterEvents(
	"SPELL_CAST_START",
	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"CHAT_MSG_MONSTER_YELL",
	"SPELL_AURA_REMOVED",
	"UNIT_SPELLCAST_CHANNEL_STOP",
	"UNIT_SPELLCAST_SUCCEEDED",
	"CHAT_MSG_LOOT",
	"SPELL_SUMMON"
)

local blastWarn				= mod:NewTargetAnnounce(312790, 4)
local shellWarn				= mod:NewTargetAnnounce(312435, 2)
local lootannounce			= mod:NewAnnounce("MagneticCore", 1)
local warnBombSpawn			= mod:NewAnnounce("WarnBombSpawn", 3)
local warnFrostBomb			= mod:NewSpellAnnounce(64623, 3)
local warnRockets			= mod:NewSpellAnnounce(63041, 2)
local warnFlames			= mod:NewSpellAnnounce(312450, 2)
local warnShockBlast2			= mod:NewSpellAnnounce(312792, 4)

local warnShockBlast			= mod:NewSpecialWarning("WarningShockBlast", nil, false)
local warnDarkGlare			= mod:NewSpecialWarningSpell(63293)

mod:AddBoolOption("ShockBlastWarningInP1", mod:IsMelee(), "announce")
mod:AddBoolOption("ShockBlastWarningInP4", true, "announce")

local enrage 				= mod:NewBerserkTimer(900)
local timerHardmode			= mod:NewTimer(610, "TimerHardmode", 312811)
local timerP1toP2			= mod:NewTimer(48, "TimeToPhase2")
local timerP2toP3			= mod:NewTimer(27, "TimeToPhase3")
local timerP3toP4			= mod:NewTimer(30, "TimeToPhase4")
local timerProximityMines		= mod:NewNextTimer(35, 63027, nil, nil, nil, 7, nil)
local timerShockBlast			= mod:NewCastTimer(4, 312792, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)
local timerSpinUp			= mod:NewCastTimer(4, 312794, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)
local timerDarkGlareCast		= mod:NewCastTimer(10, 63274, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)
local timerNextDarkGlare		= mod:NewNextTimer(40, 63274, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)
local timerNextShockblast		= mod:NewNextTimer(35, 312792, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)
local timerPlasmaBlastCD		= mod:NewCDTimer(30, 312790, nil, nil, nil, 3, nil, DBM_CORE_HEALER_ICON)
local timerShell			= mod:NewBuffActiveTimer(6, 312435, nil, "Healer", nil, 3, nil, DBM_CORE_HEALER_ICON)
local timerShellCD		        = mod:NewCDTimer(10, 312435, nil, nil, nil, 5, nil, DBM_CORE_HEALER_ICON)
local timerFlameSuppressant		= mod:NewBuffActiveTimer(10, 312793)
local timerNextFlameSuppressant	        = mod:NewNextTimer(80, 312793)
local timerNextFlames			= mod:NewNextTimer(27.5, 312450, nil, nil, nil, 2, nil, DBM_CORE_HEROIC_ICON)
local timerNextFrostBomb                = mod:NewNextTimer(60, 64623, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)
local timerBombExplosion		= mod:NewCastTimer(15, 65333) 
local timerNextRockets		        = mod:NewCDTimer(20, 63041)

mod:AddBoolOption("HealthFramePhase4", true)
mod:AddBoolOption("AutoChangeLootToFFA", true)
mod:AddSetIconOption("SetIconOnPlasmaBlast", 312790, true, false, {8})
mod:AddSetIconOption("SetIconOnNapalm", 312435, true, false, {7, 6, 5, 4, 3, 2, 1})
mod:AddBoolOption("RangeFrame")
mod:AddBoolOption("YellOnshellWarn", true)

local hardmode = false
local phase						= 0 
local lootmethod, masterlooterRaidID
local spinningUp				= GetSpellInfo(312794)
local lastSpinUp				= 0
local is_spinningUp				= false
local napalmShellTargets = {}
local napalmShellIcon 	= 7

local function warnNapalmShellTargets()
	shellWarn:Show(table.concat(napalmShellTargets, "<, >"))
	table.wipe(napalmShellTargets)
	napalmShellIcon = 7
end

function mod:OnCombatStart(delay)
        DBM:FireCustomEvent("DBM_EncounterStart", 33432, "Mimiron")
    hardmode = false
	enrage:Start(-delay)
	phase = 0
	is_spinningUp = false
	napalmShellIcon = 7
	table.wipe(napalmShellTargets)
	self:NextPhase()
	timerPlasmaBlastCD:Start(-delay)
	timerNextShockblast:Start(28-delay)
	if DBM:GetRaidRank() == 2 then
		lootmethod, _, masterlooterRaidID = GetLootMethod()
	end
	if self.Options.RangeFrame then
		DBM.RangeCheck:Show(6)
	end
end

function mod:OnCombatEnd()
        DBM:FireCustomEvent("DBM_EncounterEnd", 33432, "Mimiron", wipe)
	DBM.BossHealth:Hide()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
	if self.Options.AutoChangeLootToFFA and DBM:GetRaidRank() == 2 then
		if masterlooterRaidID then
			SetLootMethod(lootmethod, "raid"..masterlooterRaidID)
		else
			SetLootMethod(lootmethod)
		end
	end
end

function mod:Flames()
	if phase == 4 then
		timerNextFlames:Start(18)
		self:ScheduleMethod(18, "Flames")
	else
		timerNextFlames:Start()
		self:ScheduleMethod(27.5, "Flames")
	end
end

function mod:SPELL_SUMMON(args)
	if args:IsSpellID(63811, 63801, 312807) then -- Бомбот
		warnBombSpawn:Show()
	end
end


function mod:UNIT_SPELLCAST_CHANNEL_STOP(unit, spell)
	if spell == spinningUp and GetTime() - lastSpinUp < 3.9 then
		is_spinningUp = false
		self:SendSync("SpinUpFail")	
	end
end

function mod:CHAT_MSG_LOOT(msg)
	-- DBM:AddMsg(msg) --> Meridium receives loot: [Magnetic Core]
	local player, itemID = msg:match(L.LootMsg)
	if player and itemID and tonumber(itemID) == 46029 then
		lootannounce:Show(player)
	end
end

function mod:SPELL_CAST_START(args)
	if args:IsSpellID(63631, 312439, 312792) then   -- Шоковый удар
		if phase == 1 and self.Options.ShockBlastWarningInP1 or phase == 4 and self.Options.ShockBlastWarningInP4 then
			warnShockBlast:Show()
		end
                warnShockBlast2:Show()
		timerShockBlast:Start()
		timerNextShockblast:Start()
		PlaySoundFile("Sound\\Creature\\HoodWolf\\HoodWolfTransformPlayer01.wav")
	end
	if args:IsSpellID(64529, 62997, 312437, 312790) then    -- Взрыв плазмы
		timerPlasmaBlastCD:Start()
	end
	if args:IsSpellID(64570, 312434, 312787, 312793) then   -- Подавитель пламени
		timerNextFlameSuppressant:Start()
	end
	if args:IsSpellID(64623) then                           -- Фростбомба
		warnFrostBomb:Show()
		timerBombExplosion:Start()
		timerNextFrostBomb:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(63666, 65026, 312347, 312435, 312700, 312788) and args:IsDestTypePlayer() then -- Заряд напалма
		napalmShellTargets[#napalmShellTargets + 1] = args.destName
		timerShell:Start(args.destName)
                timerShellCD:Start()
		if self.Options.SetIconOnNapalm then
			self:SetIcon(args.destName, napalmShellIcon, 6)
			napalmShellIcon = napalmShellIcon - 1
		end
                if self.Options.YellOnshellWarn and args:IsPlayer() then
				SendChatMessage(L.YellshellWarn, "SAY")
		end
		self:Unschedule(warnNapalmShellTargets)
		self:Schedule(0.3, warnNapalmShellTargets)
	elseif args:IsSpellID(64529, 62997, 312437, 312790) then -- Взрыв плазмы
		blastWarn:Show(args.destName)
		if self.Options.SetIconOnPlasmaBlast then
			self:SetIcon(args.destName, 8, 6)
		end
	end
end

local function show_warning_for_spinup()
	if is_spinningUp then
		warnDarkGlare:Show()
                timerNextDarkGlare:Start()
		PlaySoundFile("Sound\\Creature\\AlgalonTheObserver\\UR_Algalon_BHole01.wav")
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(63027, 63667, 312436, 312789) then				-- Мины
		timerProximityMines:Start()

        elseif args:IsSpellID(312450, 312803, 64566) then  -- Пламя
                warnFlames:Show()
                timerNextFlames:Start()

        elseif args:IsSpellID(63041, 63036, 64064, 64402) then  -- Ракетный залп
                warnRockets:Show()
                timerNextRockets:Start()

	elseif args:IsSpellID(63414, 312441, 312794) then			-- Вращение
		is_spinningUp = true
		timerSpinUp:Start()
		timerDarkGlareCast:Schedule(4)
		timerNextDarkGlare:Schedule(19)			-- 4 (cast spinup) + 15 sec (cast dark glare)
		DBM:Schedule(0.15, show_warning_for_spinup)	-- wait 0.15 and then announce it, otherwise it will sometimes fail
		lastSpinUp = GetTime()
	
	elseif args:IsSpellID(65192, 312440, 312793) then
		timerNextFlameSuppressant:Start()
	end
end

function mod:NextPhase()
	phase = phase + 1
	if phase == 1 then
		if self.Options.HealthFrame then
			DBM.BossHealth:Clear()
			DBM.BossHealth:AddBoss(33432, L.MobPhase1)
		end

	elseif phase == 2 then
                timerNextFlames:Stop()
                timerPlasmaBlastCD:Stop()
		timerNextShockblast:Stop()
		timerProximityMines:Stop()
		timerNextFlameSuppressant:Stop()
		timerP1toP2:Start()
                timerNextFlames:Start(10)
                timerNextRockets:Schedule(48)		
		timerNextDarkGlare:Schedule(38)
		if self.Options.HealthFrame then
			DBM.BossHealth:Clear()
			DBM.BossHealth:AddBoss(33651, L.MobPhase2)
		end
		if self.Options.RangeFrame then
			DBM.RangeCheck:Hide()
		end
		if hardmode then
            timerNextFrostBomb:Start(114)
        end

	elseif phase == 3 then
		if self.Options.AutoChangeLootToFFA and DBM:GetRaidRank() == 2 then
			SetLootMethod("freeforall")
		end
                timerNextFlames:Stop()
                timerNextRockets:Stop()
		timerDarkGlareCast:Cancel()
		timerNextDarkGlare:Cancel()
		timerNextFrostBomb:Cancel()
		timerP2toP3:Start()
                timerNextFlames:Start(35)
		if self.Options.HealthFrame then
			DBM.BossHealth:Clear()
			DBM.BossHealth:AddBoss(33670, L.MobPhase3)
		end

	elseif phase == 4 then
		if self.Options.AutoChangeLootToFFA and DBM:GetRaidRank() == 2 then
			if masterlooterRaidID then
				SetLootMethod(lootmethod, "raid"..masterlooterRaidID)
			else
				SetLootMethod(lootmethod)
			end
		end
                timerNextFlames:Stop()
		timerP3toP4:Start()
                timerNextRockets:Schedule(30)
		timerDarkGlareCast:Schedule(52)
                timerNextShockblast:Schedule(55)
                timerNextFlames:Start(28)
		if self.Options.HealthFramePhase4 or self.Options.HealthFrame then
			DBM.BossHealth:Show(L.name)
			DBM.BossHealth:AddBoss(33670, L.MobPhase3)
			DBM.BossHealth:AddBoss(33651, L.MobPhase2)
			DBM.BossHealth:AddBoss(33432, L.MobPhase1)
		end
		if hardmode then
			self:UnscheduleMethod("Flames")
			self:Flames()
            timerNextFrostBomb:Start(73)
        end
	end
end

do 
	local count = 0
	local last = 0
	local lastPhaseChange = 0
	function mod:SPELL_AURA_REMOVED(args)
		local cid = self:GetCIDFromGUID(args.destGUID)
		if GetTime() - lastPhaseChange > 30 and (cid == 33432 or cid == 33651 or cid == 33670) then
			if args.timestamp == last then	-- all events in the same tick to detect the phases earlier (than the yell) and localization-independent
				count = count + 1
				if (mod:IsDifficulty("heroic10") and count > 4) or (mod:IsDifficulty("heroic25") and count > 9) then
					lastPhaseChange = GetTime()
					self:NextPhase()
				end
			else
				count = 1
			end
			last = args.timestamp
		elseif args:IsSpellID(63666, 65026, 312347, 312435, 312700, 312788) then   -- Заряд напалма
			if self.Options.SetIconOnNapalm then
				self:SetIcon(args.destName, 0)
			end
                elseif args:IsSpellID(64529, 62997, 312437, 312790) then   -- заряд плазмы
			if self.Options.SetIconOnPlasmaBlast then
				self:SetIcon(args.destName, 0)
                        end
		end
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if (msg == L.YellPhase2 or msg:find(L.YellPhase2)) and mod:LatencyCheck() then
		--DBM:AddMsg("ALPHA: yell detect phase2, syncing to clients")
		self:SendSync("Phase2")	-- untested alpha! (this will result in a wrong timer)

	elseif (msg == L.YellPhase3 or msg:find(L.YellPhase3)) and mod:LatencyCheck() then
		--DBM:AddMsg("ALPHA: yell detect phase3, syncing to clients")
		self:SendSync("Phase3")	-- untested alpha! (this will result in a wrong timer)

	elseif (msg == L.YellPhase4 or msg:find(L.YellPhase4)) and mod:LatencyCheck() then
		--DBM:AddMsg("ALPHA: yell detect phase3, syncing to clients")
		self:SendSync("Phase4") -- SPELL_AURA_REMOVED detection might fail in phase 3...there are simply not enough debuffs on him

	elseif msg:find(L.YellHardPull) then
		timerHardmode:Start()
		timerNextFlameSuppressant:Start()
		enrage:Stop()
		hardmode = true
		timerNextFlames:Start(6.5)
		self:ScheduleMethod(6.5, "Flames")
	end
end


function mod:OnSync(event, args)
	if event == "SpinUpFail" then
		is_spinningUp = false
		timerSpinUp:Cancel()
		timerDarkGlareCast:Cancel()
		timerNextDarkGlare:Cancel()
		warnDarkGlare:Cancel()
	elseif event == "Phase2" and phase == 1 then -- alternate localized-dependent detection
		self:NextPhase()
	elseif event == "Phase3" and phase == 2 then
		self:NextPhase()
	elseif event == "Phase4" and phase == 3 then
		self:NextPhase()
	end
end