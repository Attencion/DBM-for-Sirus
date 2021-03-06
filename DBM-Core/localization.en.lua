DBM_DEADLY_BOSS_MODS				= "Deadly Boss Mods"
DBM_DBM								= "DBM"

DBM_HOW_TO_USE_MOD					= "Welcome to "..DBM_DBM..". Type /dbm help for a list of supported commands. To access options type /dbm in your chat to begin configuration. Load specific zones manually to configure any boss specific settings to your liking as well. DBM will setup defaults for your spec, but you may want to fine tune these."
DBM_SILENT_REMINDER					= "Reminder: "..DBM_DBM.." is still in silent mode."

DBM_CORE_UPDATEREMINDER_URL			= "https://github.com/Aleksart163/DBM-for-Sirus"

DBM_COPY_URL_DIALOG					= "Copy URL"

DBM_CORE_NEED_SUPPORT				= "Are you good with programming or languages? If yes, the DBM team needs your help to keep DBM the best boss mod for WoW. Join the team by visiting www.deadlybossmods.com or sending a message to tandanu@deadlybossmods.com or nitram@deadlybossmods.com."

DBM_CORE_LOAD_MOD_ERROR				= "Error while loading boss mods for %s: %s"
DBM_CORE_LOAD_MOD_SUCCESS			= "Loaded '%s' boss mods. For more options, type /dbm in your chat."
DBM_CORE_LOAD_GUI_ERROR				= "Could not load GUI: %s"

DBM_CORE_COMBAT_STARTED				= "%s engaged. Good luck and have fun! :)"
DBM_CORE_COMBAT_STARTED_IN_PROGRESS	= "Engaged an in progress fight against %s. Good luck and have fun! :)"
DBM_CORE_GUILD_COMBAT_STARTED		= "%s has been engaged by guild"
DBM_CORE_BOSS_DOWN					= "%s down after %s!"
DBM_CORE_BOSS_DOWN_I				= "%s down! You have %d total victories."
DBM_CORE_BOSS_DOWN_L				= "%s down after %s! Your last kill took %s and your fastest kill took %s. You have %d total victories."
DBM_CORE_BOSS_DOWN_NR				= "%s down after %s! This is a new record! (Old record was %s). You have %d total victories."
DBM_CORE_GUILD_BOSS_DOWN			= "%s has been defeated by guild after %s!"
DBM_CORE_COMBAT_ENDED_AT			= "Combat against %s (%s) ended after %s."
DBM_CORE_COMBAT_ENDED_AT_LONG		= "Combat against %s (%s) ended after %s. You have %d total wipes on this difficulty."
DBM_CORE_GUILD_COMBAT_ENDED_AT		= "Guild has wiped on %s (%s) after %s."
DBM_CORE_COMBAT_STATE_RECOVERED		= "%s was engaged %s ago, recovering timers..."

DBM_CORE_AFK_WARNING				= "You are AFK and in combat (%d percent health remaining), firing sound alert. If you are not AFK, clear your AFK flag or disable this option in 'extra features'."

DBM_CORE_COMBAT_STARTED_AI_TIMER	= "My CPU is a neural net processor; a learning computer. (This fight will use the new timer AI feature to generate timer approximations)"

DBM_CORE_PROFILE_NOT_FOUND			= "<Deadly Boss Mods> Your current profile is corrupted. Deadly Boss Mods will load 'Default' profile."
DBM_CORE_PROFILE_CREATED			= "'%s' profile created."
DBM_CORE_PROFILE_CREATE_ERROR		= "Create profile failed. Invalid profile name."
DBM_CORE_PROFILE_CREATE_ERROR_D		= "Create profile failed. '%s' profile already exists."
DBM_CORE_PROFILE_APPLIED			= "'%s' profile applied."
DBM_CORE_PROFILE_APPLY_ERROR		= "Apply profile failed. '%s' profile does not exist."
DBM_CORE_PROFILE_COPIED				= "'%s' profile copied."
DBM_CORE_PROFILE_COPY_ERROR			= "Copy profile failed. '%s' profile does not exist."
DBM_CORE_PROFILE_COPY_ERROR_SELF	= "Cannot copy profile to itself."
DBM_CORE_PROFILE_DELETED			= "'%s' profile deleted. 'Default' profile will be applied."
DBM_CORE_PROFILE_DELETE_ERROR		= "Delete profile failed. '%s' profile does not exist."
DBM_CORE_PROFILE_CANNOT_DELETE		= "Cannot delete 'Default' profile."
DBM_CORE_MPROFILE_COPY_SUCCESS		= "%s's (%d spec) mod settings have been copied."
DBM_CORE_MPROFILE_COPY_SELF_ERROR	= "Cannot copy character settings to itself"
DBM_CORE_MPROFILE_COPY_S_ERROR		= "Source is corrupted. Settings not copied or partly copied. Copy failed."
DBM_CORE_MPROFILE_COPYS_SUCCESS		= "%s's (%d spec) mod sound or note settings have been copied."
DBM_CORE_MPROFILE_COPYS_SELF_ERROR	= "Cannot copy character sound or note settings to itself"
DBM_CORE_MPROFILE_COPYS_S_ERROR		= "Source is corrupted. Sound or note settings not copied or partly copied. Copy failed."
DBM_CORE_MPROFILE_DELETE_SUCCESS	= "%s's (%d spec) mod settings deleted."
DBM_CORE_MPROFILE_DELETE_SELF_ERROR	= "Cannot delete mod settings currently in use."
DBM_CORE_MPROFILE_DELETE_S_ERROR	= "Source is corrupted. Settings not deleted or partly deleted. Delete failed."

DBM_CORE_NOTE_SHARE_SUCCESS			= "%s has shared their note for %s"
DBM_CORE_NOTE_SHARE_FAIL			= "%s attempted to share note text with you for %s. However, mod associated with this ability is not uninstalled or is not loaded. If you need this note, make sure you load the mod they are sharing notes for and ask them to share again"

DBM_CORE_NOTEHEADER					= "Enter your note text here for %s. Enclosing a players name with >< class colors it. For alerts with multiple counts, separate notes with '/'"
DBM_CORE_NOTEFOOTER					= "Press 'Okay' to accept changes or 'Cancel' to decline changes"
DBM_CORE_NOTESHAREDHEADER			= "%s has shared below note text for %s. If you accept it, it will overwrite your existing note"
DBM_CORE_NOTESHARED					= "Your note has been sent to the group"
DBM_CORE_NOTESHAREERRORSOLO			= "Lonely? Shouldn't be passing notes to yourself"
DBM_CORE_NOTESHAREERRORBLANK		= "Cannot share blank notes"
DBM_CORE_NOTESHAREERRORGROUPFINDER	= "Notes cannot be shared in BGs, LFR, or LFG"
DBM_CORE_NOTESHAREERRORALREADYOPEN	= "Cannot open a shared note link while note editor is already open, to prevent you from losing the note you are currently editing"

DBM_CORE_ALLMOD_DEFAULT_LOADED		= "Default options for all mods in this instance have been loaded."
DBM_CORE_ALLMOD_STATS_RESETED		= "All mod stats have been reset."
DBM_CORE_MOD_DEFAULT_LOADED			= "Default options for this fight have been loaded."
DBM_CORE_SOUNDKIT_MIGRATION			= "One or more of your warning/special warning sounds were reset to defaults do to incompatability media type or invalid sound path. DBM now only supports sound files residing your addons folder, or SoundKit IDs for playing media"

DBM_CORE_TIMER_FORMAT_SECS			= "%.2f |4second:seconds;"
DBM_CORE_TIMER_FORMAT_MINS			= "%d |4minute:minutes;"
DBM_CORE_TIMER_FORMAT				= "%d |4minute:minutes; and %.2f |4second:seconds;"

DBM_CORE_MIN						= "min"
DBM_CORE_MIN_FMT					= "%d min"
DBM_CORE_SEC						= "sec"
DBM_CORE_SEC_FMT					= "%s sec"

DBM_CORE_GENERIC_WARNING_OTHERS		= "and one other"
DBM_CORE_GENERIC_WARNING_OTHERS2	= "and %d others"
DBM_CORE_GENERIC_WARNING_BERSERK	= "Berserk in %s %s"
DBM_CORE_GENERIC_TIMER_BERSERK		= "Berserk"
DBM_CORE_OPTION_TIMER_BERSERK		= "Show timer for $spell:26662"
DBM_CORE_GENERIC_TIMER_COMBAT		= "Combat starts"
DBM_CORE_OPTION_TIMER_COMBAT		= "Show timer for combat start"
DBM_CORE_BAD						= "Bad"

DBM_CORE_OPTION_CATEGORY_TIMERS			= "Bars"
--Sub cats for "announce" object
DBM_CORE_OPTION_CATEGORY_WARNINGS		= "General Announces"
DBM_CORE_OPTION_CATEGORY_WARNINGS_YOU	= "Personal Announces"
DBM_CORE_OPTION_CATEGORY_WARNINGS_OTHER	= "Target Announces"
DBM_CORE_OPTION_CATEGORY_WARNINGS_ROLE	= "Role Announces"

DBM_CORE_OPTION_CATEGORY_SOUNDS			= "Sounds"
--Misc object broken down into sub cats
DBM_CORE_OPTION_CATEGORY_DROPDOWNS		= "Dropdowns"--Still put in MISC sub grooup, just used for line separators since multiple of these on a fight (or even having on of these at all) is rare.
DBM_CORE_OPTION_CATEGORY_YELLS			= "Yells"
DBM_CORE_OPTION_CATEGORY_ICONS			= "Icons"

DBM_CORE_AUTO_RESPONDED						= "Auto-responded."
DBM_CORE_STATUS_WHISPER						= "%s: %s, %d/%d people alive"
DBM_CORE_AUTO_RESPOND_WHISPER				= "%s is busy fighting against %s (%s, %d/%d people alive)"
DBM_CORE_WHISPER_COMBAT_END_KILL			= "%s has defeated %s!"
DBM_CORE_WHISPER_COMBAT_END_KILL_STATS		= "%s has defeated %s! They have %d total victories."
DBM_CORE_WHISPER_COMBAT_END_WIPE_AT			= "%s has wiped on %s at %s"
DBM_CORE_WHISPER_COMBAT_END_WIPE_STATS_AT	= "%s has wiped on %s at %s. They have %d total wipes on this difficulty."

DBM_CORE_VERSIONCHECK_HEADER		= "Boss Mod - Versions"
DBM_CORE_VERSIONCHECK_ENTRY			= "%s: %s (%s) %s"--One Boss mod
DBM_CORE_VERSIONCHECK_ENTRY_NO_DBM	= "%s: No boss mod installed"
DBM_CORE_VERSIONCHECK_FOOTER		= "Found %d player(s) with DBM"
DBM_CORE_VERSIONCHECK_OUTDATED		= "Following %d player(s) have outdated boss mod version: %s"
DBM_CORE_YOUR_VERSION_OUTDATED      = "Your version of Deadly Boss Mods is out-of-date. Please visit " .. DBM_CORE_UPDATEREMINDER_URL .. " to get the latest version."
DBM_CORE_VOICE_PACK_OUTDATED		= "Your selected DBM voice pack is missing some sounds supported by DBM. Some warning sounds will still play default sounds. Please download a newer version of voice pack or pack contact author for an update that contains missing audio"
DBM_CORE_VOICE_MISSING				= "You have a DBM voice pack selected that could not be found. If this is an error, make sure your voice pack is properly installed and enabled in addons."
DBM_CORE_VOICE_DISABLED				= "You currently have at least one DBM voice pack installed but none enabled. If you intend to use a voice pack, make sure it's chosen in 'Spoken Alerts', else uninstall unused voice packs to hide this message"
DBM_CORE_VOICE_COUNT_MISSING		= "Countdown voice %d is set to a voice/count pack that could not be found. It has be reset to default setting: %s."

DBM_CORE_UPDATEREMINDER_HEADER			= "Your version of Deadly Boss Mods is out-of-date.\n Version %s (r%d) is available for download here:"
DBM_CORE_UPDATEREMINDER_FOOTER			= "Press " .. (IsMacClient() and "Cmd-C" or "Ctrl-C")  ..  " to copy the download link to your clipboard."
DBM_CORE_UPDATEREMINDER_FOOTER_GENERIC	= "Press " .. (IsMacClient() and "Cmd-C" or "Ctrl-C")  ..  " to copy the link to your clipboard."
DBM_CORE_UPDATEREMINDER_DISABLE			= "WARNING: Due to your "..DBM_DEADLY_BOSS_MODS.." being too out of date it has been force disabled and cannot be used until updated. This is to ensure outdated or incompatible mods do not cause poor play experience for yourself or fellow group members."
DBM_CORE_UPDATEREMINDER_NOTAGAIN		= "Show popup when a new version is available"

DBM_CORE_MOVABLE_BAR				= "Drag me!"

DBM_PIZZA_SYNC_INFO					= "|Hplayer:%1$s|h[%1$s]|h sent you a DBM timer: '%2$s'\n|HDBM:cancel:%2$s:nil|h|cff3588ff[Cancel this timer]|r|h  |HDBM:ignore:%2$s:%1$s|h|cff3588ff[Ignore timers from %1$s]|r|h"
DBM_PIZZA_CONFIRM_IGNORE			= "Do you really want to ignore DBM timers from %s for this session?"
DBM_PIZZA_ERROR_USAGE				= "Usage: /dbm [broadcast] timer <time> <text>"

DBM_CORE_ERROR_DBMV3_LOADED			= "Deadly Boss Mods is running twice because you have DBMv3 and DBMv4 installed and enabled!\nClick \"Okay\" to disable DBMv3 and reload your interface.\nYou should also clean up your AddOns folder by deleting the old DBMv3 folders."

DBM_CORE_MINIMAP_TOOLTIP_HEADER		= "Deadly Boss Mods"
DBM_CORE_MINIMAP_TOOLTIP_FOOTER		= "Shift+click or right-click to move\nAlt+shift+click for free drag and drop"

DBM_CORE_RANGECHECK_HEADER			= "Range Check (%d yd)"
DBM_CORE_RANGECHECK_SETRANGE		= "Set range"
DBM_CORE_RANGECHECK_SOUNDS			= "Sounds"
DBM_CORE_RANGECHECK_SOUND_OPTION_1	= "Sound when one player is in range"
DBM_CORE_RANGECHECK_SOUND_OPTION_2	= "Sound when more than one player is in range"
DBM_CORE_RANGECHECK_SOUND_0			= "No sound"
DBM_CORE_RANGECHECK_SOUND_1			= "Default sound"
DBM_CORE_RANGECHECK_SOUND_2			= "Annoying beep"
DBM_CORE_RANGECHECK_HIDE			= "Hide"
DBM_CORE_RANGECHECK_SETRANGE_TO		= "%d yd"
DBM_CORE_RANGECHECK_LOCK			= "Lock frame"
DBM_CORE_RANGECHECK_OPTION_FRAMES	= "Frames"
DBM_CORE_RANGECHECK_OPTION_RADAR	= "Show radar frame"
DBM_CORE_RANGECHECK_OPTION_TEXT		= "Show text frame"
DBM_CORE_RANGECHECK_OPTION_BOTH		= "Show both frames"
DBM_CORE_RANGECHECK_OPTION_SPEED	= "Update Rate (Reload Req.)"
DBM_CORE_RANGECHECK_OPTION_SLOW		= "Slow (lowest CPU)"
DBM_CORE_RANGECHECK_OPTION_AVERAGE	= "Medium"
DBM_CORE_RANGECHECK_OPTION_FAST		= "Fast (Most real-time)"
DBM_CORE_RANGERADAR_HEADER			= "Range Radar (%d yd)"
DBM_LFG_INVITE						= "LFG Invite"
DBM_LFG_CD                          = "LFG cooldown"
DBM_PHASE							= "Phase %d"

DBM_CORE_SLASHCMD_HELP				= {
	"Available slash commands:",
	"/dbm version: Performs a raid-wide version check (alias: ver).",
	"/dbm unlock: Shows a movable status bar timer (alias: move).",
	"/dbm timer <x> <text>: Starts a <x> second DBM Timer with the name <text>.",
	"/dbm broadcast timer <x> <text>: Broadcasts a <x> second DBM Timer with the name <text> to the raid (requires leader/promoted status).",
	"/dbm break <min>: Starts a break timer for <min> minutes. Gives all raid members with DBM a break timer (requires leader/promoted status).",
	"/dbm help: Shows slash command descriptions",
}

DBM_ERROR_NO_PERMISSION				= "You don't have the required permission to do this."

DBM_CORE_BOSSHEALTH_HIDE_FRAME		= "Close health frame"

DBM_CORE_ALLIANCE					= "Alliance"
DBM_CORE_HORDE						= "Horde"

DBM_CORE_UNKNOWN					= "unknown"

DBM_CORE_BREAK_USAGE				= "Break timer cannot be longer than 60 minutes. Make sure you're inputting time in minutes and not seconds."
DBM_CORE_BREAK_START				= "Break starting now -- you have %s! (Sent by %s)"
DBM_CORE_BREAK_MIN					= "Break ends in %s minute(s)!"
DBM_CORE_BREAK_SEC					= "Break ends in %s seconds!"
DBM_CORE_TIMER_BREAK				= "Break time!"
DBM_CORE_ANNOUNCE_BREAK_OVER		= "Break has ended at %s"

DBM_CORE_TIMER_PULL					= "Pull in"
DBM_CORE_ANNOUNCE_PULL				= "Pull in %d sec. (Sent by %s)"
DBM_CORE_ANNOUNCE_PULL_NOW			= "Pull now!"
DBM_CORE_ANNOUNCE_PULL_TARGET		= "Pulling %s in %d sec. (Sent by %s)"
DBM_CORE_ANNOUNCE_PULL_NOW_TARGET	= "Pulling %s now!"
DBM_CORE_GEAR_WARNING_WEAPON		= "Warning: Check if your weapon is correctly equipped."
DBM_CORE_GEAR_FISHING_POLE			= "Fishing Pole"

DBM_CORE_ACHIEVEMENT_TIMER_SPEED_KILL = "Speed Kill"

-- Auto-generated Warning Localizations
DBM_CORE_AUTO_ANNOUNCE_TEXTS = {
	you			= "%s on YOU",
	target		= "%s on >%%s<",
	targetsource= ">%%s< cast %s on >%%s<",
	targetcount	= "%s (%%s) on >%%s<",
	spell		= "%s",
	ends 		= "%s ended",
	endtarget	= "%s ended: >%%s<",
	fades		= "%s faded",
	adds		= "%s remaining: %%d",
	cast		= "Casting %s: %.1f sec",
	soon		= "%s soon",
	sooncount	= "%s (%%s) soon",
	countdown	= "%s in %%ds",
	prewarn		= "%s in %s",
	bait		= "%s soon - bait now",
	stage		= "Stage %s",
	prestage	= "Stage %s soon",
	count		= "%s (%%s)",
	stack		= "%s on >%%s< (%%d)",
	moveto		= "%s - move to >%%s<"
}

local prewarnOption = "Show pre-warning for $spell:%s"
DBM_CORE_AUTO_ANNOUNCE_OPTIONS = {
	you			= "Announce when $spell:%s on you",
	target		= "Announce $spell:%s targets",
	targetsource= "Announce $spell:%s targets (with source)",
	targetcount	= "Announce $spell:%s targets (with count)",
	spell		= "Show warning for $spell:%s",
	ends		= "Show warning when $spell:%s has ended",
	endtarget	= "Show warning when $spell:%s has ended",
	fades		= "Show warning when $spell:%s has faded",
	adds		= "Announce how many $spell:%s remain",
	cast		= "Show warning when $spell:%s is being cast",
	soon		= prewarnOption,
	sooncount	= prewarnOption,
	countdown	= "Show pre-warning countdown spam for $spell:%s",
	prewarn 	= prewarnOption,
	bait		= "Show pre-warning (to bait) for $spell:%s",
	stage		= "Announce Stage %s",
	stagechange	= "Announce stage changes",
	prestage	= "Show a prewarning for Stage %s",
	count		= "Show warning for $spell:%s (with count)",
	stack		= "Announce $spell:%s stacks",
	moveto		= "Show warning to move to someone or some place for $spell:%s"
}

DBM_CORE_AUTO_SPEC_WARN_TEXTS = {
	spell			= "%s!",
	ends			= "%s ended",
	fades			= "%s faded",
	soon			= "%s soon",
	sooncount		= "%s (%%s) soon",
	bait			= "%s soon - bait now",
	prewarn			= "%s in %s",
	dispel			= "%s on >%%s< - dispel now",
	interrupt		= "%s - interrupt >%%s<!",
	interruptcount	= "%s - interrupt >%%s<! (%%d)",
	you				= "%s on you",
	youcount		= "%s (%%s) on you",
	youpos			= "%s (Position: %%s) on you",
	soakpos			= "%s (Soak Position: %%s)",
	target			= "%s on >%%s<",
	targetcount		= "%s (%%s) on >%%s< ",
	defensive		= "%s - defensive",
	taunt			= "%s on >%%s< - taunt now",
	close			= "%s on >%%s< near you",
	move			= "%s - move away",
	keepmove		= "%s - keep moving",
	stopmove		= "%s - stop moving",
	dodge			= "%s - dodge attack",
	dodgecount		= "%s (%%s) - dodge attack",
	dodgeloc		= "%s - dodge from %%s",
	moveaway		= "%s - move away from others",
	moveawaycount	= "%s (%%s) - move away from others",
	moveto			= "%s - move to >%%s<",
	soak			= "%s - soak it",
	jump			= "%s - jump",
	run				= "%s - run away",
	cast			= "%s - stop casting",
	lookaway		= "%s on %%s - look away",
	reflect			= "%s on >%%s< - stop attacking",
	count			= "%s! (%%s)",
	stack			= "%%d stacks of %s on you",
	switch			= "%s - switch targets",
	switchcount		= "%s - switch targets (%%s)",
	gtfo			= "%%s under you - move away",
	adds			= "Incoming Adds - switch targets",
	addscustom		= "Incoming Adds - %%s",
	targetchange	= "Target Change - switch to %%s"
}

-- Auto-generated Special Warning Localizations
DBM_CORE_AUTO_SPEC_WARN_OPTIONS = {
	spell 			= "Show special warning for $spell:%s",
	ends 			= "Show special warning when $spell:%s has ended",
	fades 			= "Show special warning when $spell:%s has faded",
	soon 			= "Show pre-special warning for $spell:%s",
	sooncount		= "Show pre-special warning (with count) for $spell:%s",
	bait			= "Show pre-special warning (to bait) for $spell:%s",
	prewarn 		= "Show pre-special warning %s seconds before $spell:%s",
	dispel 			= "Show special warning to dispel/spellsteal $spell:%s",
	interrupt		= "Show special warning to interrupt $spell:%s",
	interruptcount	= "Show special warning (with count) to interrupt $spell:%s",
	you 			= "Show special warning when you are affected by $spell:%s",
	youcount		= "Show special warning (with count) when you are affected by $spell:%s",
	youpos			= "Show special warning (with position) when you are affected by $spell:%s",
	soakpos			= "Show special warning (with position) to help soak others affected by $spell:%s",
	target 			= "Show special warning when someone is affected by $spell:%s",
	targetcount 	= "Show special warning (with count) when someone is affected by $spell:%s",
	defensive 		= "Show special warning to use defensive abilites for $spell:%s",
	taunt 			= "Show special warning to taunt when other tank affected by $spell:%s",
	close 			= "Show special warning when someone close to you is affected by $spell:%s",
	move 			= "Show special warning to move out from $spell:%s",
	keepmove 		= "Show special warning to keep moving for $spell:%s",
	stopmove 		= "Show special warning to stop moving for $spell:%s",
	dodge 			= "Show special warning to dodge $spell:%s",
	dodgecount		= "Show special warning (with count) to dodge $spell:%s",
	dodgeloc		= "Show special warning (with location) to dodge $spell:%s",
	moveaway		= "Show special warning to move away from others for $spell:%s",
	moveawaycount	= "Show special warning (with count) to move away from others for $spell:%s",
	moveto			= "Show special warning to move to someone or some place for $spell:%s",
	soak			= "Show special warning to soak for $spell:%s",
	jump			= "Show special warning to move to jump for $spell:%s",
	run 			= "Show special warning to run away from $spell:%s",
	cast 			= "Show special warning to stop casting for $spell:%s",--Spell Interrupt
	lookaway		= "Show special warning to look away for $spell:%s",
	reflect 		= "Show special warning to stop attacking $spell:%s",--Spell Reflect
	count 			= "Show special warning (with count) for $spell:%s",
	stack 			= "Show special warning when you are affected by >=%d stacks of $spell:%s",
	switch			= "Show special warning to switch targets for $spell:%s",
	switchcount		= "Show special warning (with count) to switch targets for $spell:%s",
	gtfo 			= "Show special warning to move out of bad stuff on ground",
	adds			= "Show special warning to switch targets for incoming adds",
	addscustom		= "Show special warning for incoming adds",
	targetchange	= "Show special warning for priority target changes"
}

-- Auto-generated Timer Localizations
DBM_CORE_AUTO_TIMER_TEXTS = {
	target			= "%s: %%s",
	cast			= "%s",
	castshort		= "%s ",--if short timers enabled, cast and next are same timer text, this is a conflict. the space resolves it
	castcount		= "%s (%%s)",
	castcountshort	= "%s (%%s) ",--Resolve short timer conflict with next timers
	castsource		= "%s: %%s",
	castsourceshort	= "%s: %%s ",--Resolve short timer conflict with next timers
	active			= "%s ends",--Buff/Debuff/event on boss
	fades			= "%s fades",--Buff/Debuff on players
	ai				= "%s AI",
	cd				= "%s CD",
	cdshort			= "~%s",
	cdcount			= "%s CD (%%s)",
	cdcountshort	= "~%s (%%s)",
	cdsource		= "%s CD: >%%s<",
	cdsourceshort	= "~%s: >%%s<",
	cdspecial		= "Special CD",
	cdspecialshort	= "~Special",
	next			= "Next %s",
	nextshort		= "%s",
	nextcount		= "Next %s (%%s)",
	nextcountshort	= "%s (%%s)",
	nextsource		= "Next %s: %%s",
	nextsourceshort	= "%s: %%s",
	nextspecial		= "Next Special",
	nextspecialshort= "Special",
	achievement		= "%s",
	stage			= "Next Stage",
	stageshort		= "Stage",
	adds			= "Incoming Adds",
	addsshort		= "Adds",
	addscustom		= "Incoming Adds (%%s)",
	addscustomshort	= "Adds (%%s)",
	roleplay		= GUILD_INTEREST_RP
}

DBM_CORE_AUTO_TIMER_OPTIONS = {
	target		= "Show timer for $spell:%s debuff",
	cast		= "Show timer for $spell:%s cast",
	castcount	= "Show timer (with count) for $spell:%s cast",
	castsource	= "Show timer (with source) for $spell:%s cast",
	active		= "Show timer for $spell:%s duration",
	fades		= "Show timer for when $spell:%s fades from players",
	ai			= "Show AI timer for $spell:%s cooldown",
	cd			= "Show timer for $spell:%s cooldown",
	cdcount		= "Show timer for $spell:%s cooldown",
	cdsource	= "Show timer (with source) for $spell:%s cooldown",--Maybe better wording?
	cdspecial	= "Show timer for special ability cooldown",
	next		= "Show timer for next $spell:%s",
	nextcount	= "Show timer for next $spell:%s",
	nextsource	= "Show timer (with source) for next $spell:%s",--Maybe better wording?
	nextspecial	= "Show timer for next special ability",
	achievement	= "Show timer for %s",
	stage		= "Show timer for next stage",
	adds		= "Show timer for incoming adds",
	addscustom	= "Show timer for incoming adds",
	roleplay	= "Show timer for roleplay duration"--This does need localizing though.
}


DBM_CORE_AUTO_ICONS_OPTION_TEXT			= "Set icons on $spell:%s targets"
DBM_CORE_AUTO_ICONS_OPTION_TEXT2		= "Set icons on $spell:%s"
DBM_CORE_AUTO_ARROW_OPTION_TEXT			= "Show Deadly Boss Mods Arrow to move toward target affected by $spell:%s"
DBM_CORE_AUTO_ARROW_OPTION_TEXT2		= "Show Deadly Boss Mods Arrow to move away from target affected by $spell:%s"
DBM_CORE_AUTO_ARROW_OPTION_TEXT3		= "Show Deadly Boss Mods Arrow to move toward specific location for $spell:%s"
DBM_CORE_AUTO_YELL_OPTION_TEXT = {
	shortyell		= "Yell when you are affected by $spell:%s",
	yell			= "Yell (with player name) when you are affected by $spell:%s",
	count			= "Yell (with count) when you are affected by $spell:%s",
	fade			= "Yell (with countdown and spell name) when $spell:%s is fading",
	shortfade		= "Yell (with countdown) when $spell:%s is fading",
	iconfade		= "Yell (with countdown and icon) when $spell:%s is fading",
	position		= "Yell (with position) when you are affected by $spell:%s",
	combo			= "Yell (with custom text) when you are affected by $spell:%s and other spells at same time"
}
DBM_CORE_AUTO_YELL_ANNOUNCE_TEXT = {
	shortyell		= "%s",
	yell			= "%s on " .. UnitName("player"),
	count			= "%s on " .. UnitName("player") .. " (%%d)",
	fade			= "%s fading in %%d",
	shortfade		= "%%d",
	iconfade		= "{rt%%2$d}%%1$d",
	position 		= "%s %%s on {rt%%d}"..UnitName("player").."{rt%%d}",
	combo			= "%s and %%s"--Spell name (from option, plus spellname given in arg)
}
DBM_CORE_AUTO_YELL_CUSTOM_POSITION		= "{rt%d}%s"--Doesn't need translating. Has no strings
DBM_CORE_AUTO_YELL_CUSTOM_POSITION2		= "{rt%d}%s{rt%d}"--Doesn't need translating. Has no strings
DBM_CORE_AUTO_YELL_CUSTOM_FADE			= "%s faded"
DBM_CORE_AUTO_HUD_OPTION_TEXT			= "Show HudMap for $spell:%s (Retired)"
DBM_CORE_AUTO_HUD_OPTION_TEXT_MULTI		= "Show HudMap for various mechanics (Retired)"
DBM_CORE_AUTO_NAMEPLATE_OPTION_TEXT		= "Show Nameplate Auras for $spell:%s"
DBM_CORE_AUTO_RANGE_OPTION_TEXT			= "Show range frame (%s) for $spell:%s"--string used for range so we can use things like "5/2" as a value for that field
DBM_CORE_AUTO_RANGE_OPTION_TEXT_SHORT	= "Show range frame (%s)"--For when a range frame is just used for more than one thing
DBM_CORE_AUTO_RRANGE_OPTION_TEXT		= "Show reverse range frame (%s) for $spell:%s"--Reverse range frame (green when players in range, red when not)
DBM_CORE_AUTO_RRANGE_OPTION_TEXT_SHORT	= "Show reverse range frame (%s)"
DBM_CORE_AUTO_INFO_FRAME_OPTION_TEXT	= "Show info frame for $spell:%s"
DBM_CORE_AUTO_INFO_FRAME_OPTION_TEXT2	= "Show info frame for encounter overview"
DBM_CORE_AUTO_READY_CHECK_OPTION_TEXT	= "Play ready check sound when boss is pulled (even if it's not targeted)"


DBM_CORE_AUTO_ICONS_OPTION_TEXT		= "Set icons on $spell:%d targets"
DBM_CORE_AUTO_SOUND_OPTION_TEXT		= "Play sound on $spell:%d"


-- New special warnings
DBM_CORE_MOVE_WARNING_BAR			= "Announce movable"
DBM_CORE_MOVE_WARNING_MESSAGE		= "Thanks for using Deadly Boss Mods"
DBM_CORE_MOVE_SPECIAL_WARNING_BAR	= "Special warning movable"
DBM_CORE_MOVE_SPECIAL_WARNING_TEXT	= "Special Warning"


DBM_CORE_RANGE_CHECK_ZONE_UNSUPPORTED	= "A %d yard range check is not supported in this zone.\nSupported ranges are 10, 11, 15 and 28 yard."

DBM_ARROW_MOVABLE					= "Arrow movable"
DBM_ARROW_NO_RAIDGROUP				= "This function only works in raid groups and within raid instances."
DBM_ARROW_ERROR_USAGE	= {
	"DBM-Arrow usage:",
	"/dbm arrow <x> <y>  creates an arrow that points to a specific locataion (0 < x/y < 100)",
	"/dbm arrow <player>  creates and arrow that points to a specific player in your party or raid",
	"/dbm arrow hide  hides the arrow",
	"/dbm arrow move  makes the arrow movable",
}

DBM_SPEED_KILL_TIMER_TEXT	= "Record Victory"
DBM_CORE_TIMER_RESPAWN		= "%s Respawn"

DBM_REQ_INSTANCE_ID_PERMISSION		= "%s requested to see your current instance IDs and progress.\nDo you want to send this information to %s? He or she will be able to request this information during your current session (i. e. until you relog)."
DBM_ERROR_NO_RAID					= "You need to be in a raid group to use this feature."
DBM_INSTANCE_INFO_REQUESTED			= "Sent request for raid lockout information to the raid group.\nPlease note that the users will be asked for permission before sending the data to you, so it might take a minute until we get all responses."
DBM_INSTANCE_INFO_STATUS_UPDATE		= "Got responses from %d players of %d DBM users: %d sent data, %d denied the request. Waiting %d more seconds for responses..."
DBM_INSTANCE_INFO_ALL_RESPONSES		= "Received responses from all raid members"
DBM_INSTANCE_INFO_DETAIL_DEBUG		= "Sender: %s ResultType: %s InstanceName: %s InstanceID: %s Difficulty: %d Size: %d Progress: %s"
DBM_INSTANCE_INFO_DETAIL_HEADER		= "%s, difficulty %s:"
DBM_INSTANCE_INFO_DETAIL_INSTANCE	= "    ID %s, progress %d: %s"
DBM_INSTANCE_INFO_DETAIL_INSTANCE2	= "    Progress %d: %s"
DBM_INSTANCE_INFO_NOLOCKOUT			= "There is no raid lockout information in your raid group."
DBM_INSTANCE_INFO_STATS_DENIED		= "Denied the request: %s"
DBM_INSTANCE_INFO_STATS_AWAY		= "Away: %s"
DBM_INSTANCE_INFO_STATS_NO_RESPONSE	= "No recent "..DBM_DBM.." version installed: %s"
DBM_INSTANCE_INFO_RESULTS			= "Instance ID scan results. Note that instances might show up more than once if there are players with localized WoW clients in your raid."
--DBM_INSTANCE_INFO_SHOW_RESULTS		= "Players yet to respond: %s\n|HDBM:showRaidIdResults|h|cff3588ff[Show results now]|r|h"
DBM_INSTANCE_INFO_SHOW_RESULTS		= "Players yet to respond: %s"

DBM_CORE_LAG_CHECKING				= "Checking raid Latency..."
DBM_CORE_LAG_HEADER					= DBM_DEADLY_BOSS_MODS.." - Latency Results"
DBM_CORE_LAG_ENTRY					= "%s: World delay [%d ms] / Home delay [%d ms]"
DBM_CORE_LAG_FOOTER					= "No Response: %s"

DBM_CORE_DUR_CHECKING				= "Checking raid Durability..."
DBM_CORE_DUR_HEADER					= DBM_DEADLY_BOSS_MODS.." - Durability Results"
DBM_CORE_DUR_ENTRY					= "%s: Durability [%d percent] / Gear broken [%s]"
DBM_CORE_LAG_FOOTER					= "No Response: %s"

--Role Icons
DBM_CORE_TANK_ICON			= "|TInterface\\AddOns\\DBM-Core\\textures\\UI-EJ-Icons.blp:20:20:0:0:255:66:6:21:7:27|t"
DBM_CORE_DAMAGE_ICON		= "|TInterface\\AddOns\\DBM-Core\\textures\\UI-EJ-Icons.blp:20:20:0:0:255:66:39:55:7:27|t"
DBM_CORE_HEALER_ICON		= "|TInterface\\AddOns\\DBM-Core\\textures\\UI-EJ-Icons.blp:20:20:0:0:255:66:70:86:7:27|t"

DBM_CORE_TANK_ICON_SMALL	= "|TInterface\\AddOns\\DBM-Core\\textures\\UI-EJ-Icons.blp:12:12:0:0:255:66:6:21:7:27|t"
DBM_CORE_DAMAGE_ICON_SMALL	= "|TInterface\\AddOns\\DBM-Core\\textures\\UI-EJ-Icons.blp:12:12:0:0:255:66:39:55:7:27|t"
DBM_CORE_HEALER_ICON_SMALL	= "|TInterface\\AddOns\\DBM-Core\\textures\\UI-EJ-Icons.blp:12:12:0:0:255:66:70:86:7:27|t"
--Importance Icons
DBM_CORE_HEROIC_ICON		= "|TInterface\\AddOns\\DBM-Core\\textures\\UI-EJ-Icons.blp:22:22:0:0:255:66:102:118:7:27|t"
DBM_CORE_DEADLY_ICON		= "|TInterface\\AddOns\\DBM-Core\\textures\\UI-EJ-Icons.blp:22:22:0:0:255:66:133:153:7:27|t"
DBM_CORE_IMPORTANT_ICON		= "|TInterface\\AddOns\\DBM-Core\\textures\\UI-EJ-Icons.blp:20:20:0:0:255:66:168:182:7:27|t"
DBM_CORE_MYTHIC_ICON		= "|TInterface\\AddOns\\DBM-Core\\textures\\UI-EJ-Icons.blp:22:22:0:0:255:66:133:153:40:58|t"

DBM_CORE_HEROIC_ICON_SMALL	= "|TInterface\\AddOns\\DBM-Core\\textures\\UI-EJ-Icons.blp:14:14:0:0:255:66:102:118:7:27|t"
DBM_CORE_DEADLY_ICON_SMALL	= "|TInterface\\AddOns\\DBM-Core\\textures\\UI-EJ-Icons.blp:14:14:0:0:255:66:133:153:7:27|t"
DBM_CORE_IMPORTANT_ICON_SMALL= "|TInterface\\AddOns\\DBM-Core\\textures\\UI-EJ-Icons.blp:12:12:0:0:255:66:168:182:7:27|t"
--Type Icons
DBM_CORE_INTERRUPT_ICON		= "|TInterface\\AddOns\\DBM-Core\\textures\\UI-EJ-Icons.blp:20:20:0:0:255:66:198:214:7:27|t"
DBM_CORE_MAGIC_ICON			= "|TInterface\\AddOns\\DBM-Core\\textures\\UI-EJ-Icons.blp:20:20:0:0:255:66:229:247:7:27|t"
DBM_CORE_CURSE_ICON			= "|TInterface\\AddOns\\DBM-Core\\textures\\UI-EJ-Icons.blp:20:20:0:0:255:66:6:21:40:58|t"
DBM_CORE_POISON_ICON		= "|TInterface\\AddOns\\DBM-Core\\textures\\UI-EJ-Icons.blp:20:20:0:0:255:66:39:55:40:58|t"
DBM_CORE_DISEASE_ICON		= "|TInterface\\AddOns\\DBM-Core\\textures\\UI-EJ-Icons.blp:20:20:0:0:255:66:70:86:40:58|t"
DBM_CORE_ENRAGE_ICON		= "|TInterface\\AddOns\\DBM-Core\\textures\\UI-EJ-Icons.blp:20:20:0:0:255:66:102:118:40:58|t"

--LDB
DBM_LDB_TOOLTIP_HELP1	= "Click to open DBM"
