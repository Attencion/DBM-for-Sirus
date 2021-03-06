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


local blastWarn					= mod:NewTargetAnnounce(312790, 4)
local shellWarn					= mod:NewTargetAnnounce(312435, 2)
local lootannounce				= mod:NewAnnounce("MagneticCore", 1)
local warnBombSpawn				= mod:NewAnnounce("WarnBombSpawn", 3)
local warnFrostBomb				= mod:NewSpellAnnounce(64623, 4)
local warnFlames				= mod:NewSpellAnnounce(312803, 2)
local warnDarkGlare				= mod:NewSpellAnnounce(63293, 4)

local warnShockBlast			= mod:NewSpecialWarningDodgeCount(312792, nil, nil, nil, 4, 2)
local specwarnDarkGlare			= mod:NewSpecialWarningCount(63293, nil, nil, nil, 3, 5)
local specwarnFrostBomb			= mod:NewSpecialWarningDodgeCount(64623, nil, nil, nil, 2, 2)
local warnPlasmaBlast			= mod:NewSpecialWarningDefensive(312790, nil, nil, nil, 2, 2)

local enrage 					= mod:NewBerserkTimer(900)
local timerHardmode				= mod:NewTimer(610, "TimerHardmode", 312812)
local timerP1toP2				= mod:NewTimer(48, "TimeToPhase2", nil, nil, nil, 6)
local timerP2toP3				= mod:NewTimer(27, "TimeToPhase3", nil, nil, nil, 6)
local timerP3toP4				= mod:NewTimer(30, "TimeToPhase4", nil, nil, nil, 6)
local timerProximityMines		= mod:NewNextTimer(35, 312789, nil, nil, nil, 3)
local timerShockBlast			= mod:NewCastTimer(4, 312792, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)
local timerShockBlastCD			= mod:NewCDTimer(40, 312792, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)
local timerSpinUp				= mod:NewCastTimer(4, 312794, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)
local timerDarkGlareCast		= mod:NewCastTimer(10, 63274, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)
local timerNextDarkGlare		= mod:NewNextTimer(40, 63274, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON) -- ???????????????? ?????????????? P3Wx2
local timerNextShockblast		= mod:NewNextTimer(35, 312792, nil, nil, nil, 2, nil, DBM_CORE_DEADLY_ICON)
local timerPlasmaBlastCD		= mod:NewCDTimer(30, 312790, nil, "Tank|Healer", 2, 5)
local timerShell				= mod:NewTargetTimer(6, 312435, nil, "Tank|Healer", 2, 5, nil, DBM_CORE_HEALER_ICON)
local timerShellCD		        = mod:NewCDTimer(10, 312435, nil, nil, 2, 5, nil, DBM_CORE_HEALER_ICON)
local timerFlameSuppressant		= mod:NewNextTimer(70, 312793, nil, nil, nil, 7)
local timerNextFlames			= mod:NewNextTimer(27.5, 312803, nil, nil, nil, 3)
local timerNextFrostBomb        = mod:NewNextTimer(60, 64623, nil, nil, nil, 3, nil, DBM_CORE_DEADLY_ICON) --?????????????? ??????????
local timerBombExplosion		= mod:NewCastTimer(15, 312804, nil, nil, nil, 3, nil, DBM_CORE_DEADLY_ICON)
--local timerVolleyCD		        = mod:NewCDTimer(20, 63041)

mod:AddSetIconOption("SetIconOnNapalm", 312435, true, false, {7, 6, 5, 4, 3, 2, 1})
mod:AddSetIconOption("SetIconOnPlasmaBlast", 312790, true, false, {8})
mod:AddBoolOption("HealthFramePhase4", true)
mod:AddBoolOption("AutoChangeLootToFFA", true)
mod:AddBoolOption("RangeFrame", true)


mod.vb.hardmode = false
mod.vb.phase = 0
mod.vb.napalmShellIcon = 7
mod.vb.glareCount = 0
mod.vb.shockblastCount = 0
mod.vb.frostbombCount = 0

local lootmethod, masterlooterRaidID
local spinningUp = DBM:GetSpellInfo(312794)
local lastSpinUp = 0
local is_spinningUp = false
local napalmShellTargets = {}
local napalmShellIcon 	= 7

local function warnNapalmShellTargets()
	shellWarn:Show(table.concat(napalmShellTargets, "<, >"))
	table.wipe(napalmShellTargets)
	napalmShellIcon = 7
end

function mod:OnCombatStart(delay)
	DBM:FireCustomEvent("DBM_EncounterStart", 33432, "Mimiron")
	self.vb.hardmode = false
	self.vb.glareCount = 0
	self.vb.shockblastCount = 0
	self.vb.frostbombCount = 0
	enrage:Start(-delay)
	self.vb.phase = 0
	is_spinningUp = false
	napalmShellIcon = 7
	table.wipe(napalmShellTargets)
	self:NextPhase()
	timerPlasmaBlastCD:Start(-delay)
	timerShockBlastCD:Start(28-delay)
	if DBM:GetRaidRank() == 2 then
		lootmethod, masterlooterRaidID = GetLootMethod()
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
	if self.vb.phase == 4 then
		timerNextFlames:Start(18)
		self:ScheduleMethod(18, "Flames")
	else
		timerNextFlames:Start()
		self:ScheduleMethod(27.5, "Flames")
	end
end

function mod:SPELL_SUMMON(args)
	if args:IsSpellID(63811, 63801, 312807) then --????????????
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
	if args:IsSpellID(63631, 312439, 312792) then --?????????????? ????????
		self.vb.shockblastCount = self.vb.shockblastCount + 1
		warnShockBlast:Show(self.vb.shockblastCount)
		warnShockBlast:Play("runout")
		timerShockBlast:Start()
		timerNextShockblast:Start(35, self.vb.shockblastCount+1)
	elseif args:IsSpellID(64529, 62997, 312437, 312790) then --?????????? ????????????
		timerPlasmaBlastCD:Start()
		local tanking, status = UnitDetailedThreatSituation("player", "boss1")--Change boss unitID if it's not boss 1
		if tanking or (status == 3) then
			warnPlasmaBlast:Show()
			warnPlasmaBlast:Play("defensive")
		end
	elseif args:IsSpellID(64623) then --????????????????????
		self.vb.frostbombCount = self.vb.frostbombCount + 1
		warnFrostBomb:Show()
		specwarnFrostBomb:Show(self.vb.frostbombCount)
		timerBombExplosion:Start()
		timerNextFrostBomb:Start(60, self.vb.frostbombCount+1)
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args:IsSpellID(63666, 65026, 312347, 312435, 312700, 312788) and args:IsDestTypePlayer() then -- ?????????? ??????????????
		napalmShellTargets[#napalmShellTargets + 1] = args.destName
		timerShell:Start()
		timerShellCD:Start()
		if self.Options.SetIconOnNapalm then
			self:SetIcon(args.destName, napalmShellIcon, 6)
			napalmShellIcon = napalmShellIcon - 1
		end
		self:Unschedule(warnNapalmShellTargets)
		self:Schedule(0.3, warnNapalmShellTargets)
	elseif args:IsSpellID(64529, 62997, 312437, 312790) then --?????????? ????????????
		blastWarn:Show(args.destName)
		if self.Options.SetIconOnPlasmaBlast then
			self:SetIcon(args.destName, 8, 6)
		end
	end
end

local function show_warning_for_spinup(self)
	if is_spinningUp then
		warnDarkGlare:Show()
	end
end	
		
function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(63027, 63667, 312436, 312789) then --????????
		timerProximityMines:Start()
	elseif args:IsSpellID(312450, 312803, 64566) then --??????????
		warnFlames:Show()
	elseif args:IsSpellID(63414, 312794, 312441) then --????????????????
		self.vb.glareCount = self.vb.glareCount + 1
		specwarnDarkGlare:Show(self.vb.glareCount)
		is_spinningUp = true
		timerSpinUp:Start()
		timerDarkGlareCast:Schedule(4)
		timerNextDarkGlare:Schedule(19) --4 (cast spinup) + 15 sec (cast dark glare)
		DBM:Schedule(0.15, show_warning_for_spinup)	--wait 0.15 and then announce it, otherwise it will sometimes fail
		lastSpinUp = GetTime()
	end
end

function mod:NextPhase()
	self.vb.phase = self.vb.phase + 1
	if self.vb.phase == 1 then
		if self.Options.HealthFrame then
			DBM.BossHealth:Clear()
			DBM.BossHealth:AddBoss(33432, L.MobPhase1)
		end
	elseif self.vb.phase == 2 then
		timerNextShockblast:Stop()
		timerProximityMines:Stop()
		timerFlameSuppressant:Stop()
		timerNextFlameSuppressant:Stop()
		timerP1toP2:Start()
		timerDarkGlareCast:Schedule(44)
		if self.Options.HealthFrame then
			DBM.BossHealth:Clear()
			DBM.BossHealth:AddBoss(33651, L.MobPhase2)
		end
		if self.Options.RangeFrame then
			DBM.RangeCheck:Hide()
		end
		if self.vb.hardmode then
            timerNextFrostBomb:Start(114)
        end
	elseif self.vb.phase == 3 then
		if self.Options.AutoChangeLootToFFA and DBM:GetRaidRank() == 2 then
			SetLootMethod("freeforall")
		end
		timerDarkGlareCast:Cancel()
		timerNextDarkGlare:Cancel()
		timerNextFrostBomb:Cancel()
		timerP2toP3:Start()
		if self.Options.HealthFrame then
			DBM.BossHealth:Clear()
			DBM.BossHealth:AddBoss(33670, L.MobPhase3)
		end
	elseif self.vb.phase == 4 then
		if self.Options.AutoChangeLootToFFA and DBM:GetRaidRank() == 2 then
			if masterlooterRaidID then
				SetLootMethod(lootmethod, "raid"..masterlooterRaidID)
			else
				SetLootMethod(lootmethod)
			end
		end
		timerP3toP4:Start()
		timerDarkGlareCast:Schedule(44)
		timerNextShockblast:Schedule(55)
		if self.vb.hardmode then
			self:UnscheduleMethod("Flames")
			self:Flames()
			timerNextFrostBomb:Start(73)
		end
		if self.Options.HealthFramePhase4 or self.Options.HealthFrame then
			DBM.BossHealth:Show(L.name)
			DBM.BossHealth:AddBoss(33670, L.MobPhase3)
			DBM.BossHealth:AddBoss(33651, L.MobPhase2)
			DBM.BossHealth:AddBoss(33432, L.MobPhase1)
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
		elseif args:IsSpellID(63666, 65026, 312347, 312435, 312700, 312788) then --?????????? ??????????????
			if self.Options.SetIconOnNapalm then
				self:SetIcon(args.destName, 0)
			end
		elseif args:IsSpellID(64529, 62997, 312437, 312790) then --?????????? ????????????
			if self.Options.SetIconOnPlasmaBlast then
				self:SetIcon(args.destName, 0)
            end
		end
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.YellPhase2 or msg:find(L.YellPhase2) then
		--DBM:AddMsg("ALPHA: yell detect phase2, syncing to clients")
		self:SendSync("Phase2")	-- untested alpha! (this will result in a wrong timer)

	elseif msg == L.YellPhase3 or msg:find(L.YellPhase3) then
		--DBM:AddMsg("ALPHA: yell detect phase3, syncing to clients")
		self:SendSync("Phase3")	-- untested alpha! (this will result in a wrong timer)

	elseif msg == L.YellPhase4 or msg:find(L.YellPhase4) then
		--DBM:AddMsg("ALPHA: yell detect phase3, syncing to clients")
		self:SendSync("Phase4") -- SPELL_AURA_REMOVED detection might fail in phase 3...there are simply not enough debuffs on him

	elseif msg == L.YellHardPull or msg:find(L.YellHardPull) then
		timerHardmode:Start()
		timerFlameSuppressant:Start()
		enrage:Stop()
		self.vb.hardmode = true
		timerNextFlames:Start(2)
		self:ScheduleMethod(2, "Flames")
	end
end

function mod:OnSync(event, args)
	if event == "SpinUpFail" then
		is_spinningUp = false
		timerSpinUp:Cancel()
		timerDarkGlareCast:Cancel()
		timerNextDarkGlare:Cancel()
		warnDarkGlare:Cancel()
	elseif event == "Phase2" and self.vb.phase == 1 then -- alternate localized-dependent detection
		self:NextPhase()
	elseif event == "Phase3" and self.vb.phase == 2 then
		self:NextPhase()
	elseif event == "Phase4" and self.vb.phase == 3 then
		self:NextPhase()
	end
end