if GetLocale() ~= "ruRU" then return end

local L

--------------------------
-- Hydross the Unstable --
--------------------------
L = DBM:GetModLocalization("Hydross")

L:SetGeneralLocalization{
	name = "Гидросс Нестабильный"
}

L:SetTimerLocalization{
	TimerMarkOfHydross      = "Знак Гидроса %s%%",
	TimerMarkOfCorruption   = "Знак порчи %s%%"
}

L:SetWarningLocalization{
	WarnMarkOfHydross       = "Знак Гидроса %s%%",
	WarnMarkOfCorruption    = "Знак порчи %s%%",
	SpecWarnThreatReset     = "Сброс угрозы - ОСТАНОВИТЕСЬ!!!",
	Yad                     = "Фаза яда - БЕГИТЕ В ЛУЖУ ВОДЫ",
	Chis                    = "Фаза воды - УКЛОНЯЙТЕСЬ ОТ ЦУНАМИ"
}

L:SetOptionLocalization{
	RangeFrame	= "Показывать игроков  в окне проверки дистанции",
	TimerMarkOfHydross      = DBM_CORE_AUTO_TIMER_OPTIONS.next:format(38215, GetSpellInfo(38215) or "unknown"),
	TimerMarkOfCorruption   = DBM_CORE_AUTO_TIMER_OPTIONS.next:format(38219, GetSpellInfo(38219) or "unknown"),
	WarnMarkOfHydross       = DBM_CORE_AUTO_ANNOUNCE_OPTIONS.spell:format(38215, GetSpellInfo(38215) or "unknown"),
	WarnMarkOfCorruption    = DBM_CORE_AUTO_ANNOUNCE_OPTIONS.spell:format(38219, GetSpellInfo(38219) or "unknown"),
	SpecWarnThreatReset     = "Спец. предупреждение о сбрасывании угрозы",
	SetIconOnSklepTargets   = "Устанавливать иконки на цели $spell:309046",
	SetIconOnKorTargets     = "Устанавливать иконки на цели $spell:309065",
	Yad                     = "Объявлять перефазу ",
	Chis                    = "Объявлять перефазу  ",
	AnnounceSklep	     	= "Объявлять игроков, на кого установлен $spell:309046, в рейд чат",
	AnnounceKor  		= "Объявлять игроков, на кого установлена $spell:309065, в рейд чат "
}

L:SetMiscLocalization{
	YellPull    = "Я не позволю вам вмешиваться!",
	YellPoison  = "Агрррхх, яд.",
	YellWater   = "Так лучше, намного лучше.",
	SklepIcon   = "Водяная гробница {rt%d} установлена на: %s",
	KorIcon	    = "Коррозия {rt%d} установлена на: %s"
}


-------------------------
-- Morogrim Tidewalker --
-------------------------
L = DBM:GetModLocalization("Tidewalker")

L:SetGeneralLocalization{
	name = "Морогрим Волноступ"
}

L:SetTimerLocalization{
	TimerMurlocks   = "Мурлоки"
}

L:SetWarningLocalization{
	WarnMurlocksSoon = "Мурлоки на подходе",
	WarnGlobes       = "Глобулы!"
}

L:SetOptionLocalization{
	RangeFrame	= "Показывать игроков  в окне проверки дистанции",
	AnnounceSuh	  = "Объявлять игроков, на кого установлено $spell:310155, в рейд чат ",
	WarnMurlocksSoon  = "Объявлять о скором вызове мурлоков",
	WarnGlobes        = "Объявлять о появлении глобул",
	TimerMurlocks     = "Отсчет времени до вызова мурлоков"
}

L:SetMiscLocalization{
	YellPull        = "Да поглотит вас пучина вод!",
	EmoteMurlocs    = "Сильный толчок землетрясения насторожил мурлоков поблизости!",
	EmoteGraves     = "%s отправляет своих врагов в водяные могилы!",
	EmoteGlobes     = "%s призывает водяные шары!"
}

-------------------------
-- Leotheras the Blind --
-------------------------
L = DBM:GetModLocalization("Leotheras")

L:SetGeneralLocalization{
	name = "Леотерас Слепец"
}

L:SetTimerLocalization{
	TimerDemon        = "Форма демона",
	TimerNormal       = "Обычная форма",
	TimerInnerDemons  = "Контроль над разумом"
}

L:SetWarningLocalization{
	WarnPhase2Soon		= "Скоро переход в фазу 2",
}

L:SetOptionLocalization{
	RangeFrame	= "Показывать игроков  в окне проверки дистанции",
	PlaySoundOnSpell		= "Звуковой сигнал при применении способностей",
	TimerDemon              = "Отсчет времени до превращения в демона",
	TimerNormal             = "Отсчет времени до конца формы демона",
	TimerInnerDemons        = DBM_CORE_AUTO_TIMER_OPTIONS.active:format(37676, GetSpellInfo(37676) or "unknown"),
	KleiIcon				= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(310496),
	SetIconOnDemonTargets   = "Устанавливать иконки на цели демонов",
	SetIconOnPepelTargets   = "Устанавливать иконки на цели испепеления",
	WarnPhase2Soon		= "Предупреждать заранее о переходе в фазу 2 (на ~37%)",
	AnnounceKlei		= "Объявлять игроков, на кого установлено $spell:310496 , в рейд чат",
	AnnouncePepel		= "Объявлять игроков, на кого установлено $spell:310514 , в рейд чат "
}

L:SetMiscLocalization{
	YellPull        = "Наконец-то мое заточение окончено!",
	YellDemon       = "Прочь, жалкий эльф. Настало мое время!",
	YellShadow      = "Нет... нет! Что вы наделали? Я – главный! Слышишь меня? Я... Ааааах! Мне его... не удержать.",
	PepelIcon	= "Испепеление {rt%d} установлено на %s",
	Klei		= "Клеймо {rt%d} установлено на %s"
}

----------------------
-- The Lurker Below --
----------------------
L = DBM:GetModLocalization("LurkerBelow")

L:SetGeneralLocalization{
	name           = "Скрытень из глубин"
}

L:SetTimerLocalization{
	Submerge     = "Погружение",
	Emerge       = "Появление"

}

L:SetWarningLocalization{
	WarnSubmerge = "Скоро погружение",
	WarnEmerge   = "Скоро появление"
}

L:SetOptionLocalization{
	WarnSubmerge = "Объявлять погружение",
	WarnEmerge   = "Объявлять появление",
	Submerge     = "Отсчет времени до погружения",
	Emerge       = "Отсчет времени до появления"
}

L:SetMiscLocalization{
	EmoteSpout = "%s делает глубокий вдох."
}

----------------------------
-- Fathom-Lord Karathress --
----------------------------
L = DBM:GetModLocalization("Fathomlord")

L:SetGeneralLocalization{
	name           = "Повелитель глубин Каратресс"
}

L:SetTimerLocalization{
	TimerKaraTarget = "Преследование на %s"
}

L:SetWarningLocalization{
	SpecWarnCastHeala	= "Исцеление - ПРЕРВИТЕ КАСТ",
	WarnKaraTarget	= "Каратресс преследует %s",
	SpecWarnKaraTarget	= "Вас преследует Каратресс - БЕГИТЕ"
}

L:SetOptionLocalization{
	RangeFrame	= "Показывать игроков  в окне проверки дистанции",
	BossHealthFrame	= "Показывать здоровье боссов в фазе 1 (должны быть в цели или фокусе хотя бы у одного члена рейда)",
	SpecWarnCastHeala	= "Спец-предупреждение об $spell:309256 (для кика)",
	YellOnStrela	= "Кричать, когда на вас $spell:309253",
	WarnPhase2Soon	= "Предупреждать заранее о переходе в фазу 2 (на ~52%)",
	SetIconOnSvazTargets	= "Устанавливать иконки на цели $spell:309262",
	AnnounceSvaz	= "Объявлять игроков, на кого установлено $spell:309261, в рейд чат ",
	WarnKaraTarget	= "Объявлять цели преследуемые Каратрессом",
	SpecWarnKaraTarget	= "Спец. предупреждение для преследуемого Каратрессом",
	TimerKaraTarget	= "Отсчет времени до смены цели Каратрессом"
}

L:SetMiscLocalization{
	Volniis	= "Волниис",
	Sharkkis	= "Шарккис",
	Karibdis	= "Карибдис",
	Karatress	= "Каратресс",
	YellPull	= "Стража, к бою! У нас гости...",
	SvazIcon	= "Пламенная свзь {rt%d} установлена на %s",
	KaraTarget	= "смотрит на |3%-3%([%w\128-\255]+%)."
}

----------------
-- Lady Vashj --
----------------
L = DBM:GetModLocalization("Vashj")

L:SetGeneralLocalization{
	name       = "Леди Вайш"
}

L:SetTimerLocalization{
	Strider              = "Странник",
	TaintedElemental     = "Нечистый элементаль",
	Naga                 = "Гвардеец"
}

L:SetWarningLocalization{
	WarnCore             = "%s получил порченую магму",
	WarnPhase            = "Фаза %d",
	WarnElemental        = "Нечистый элементаль на подходе",
	SpecWarnStaticAngerNear	   = "Статический заряд рядом - ОТОЙДИТЕ.",
	SpecWarnStaticAngerNear2   = "Статический заряд рядом - ОТОЙДИТЕ."
}

L:SetOptionLocalization{
	RangeFrame	= "Показывать игроков  в окне проверки дистанции",
	AutoChangeLootToFFA	= "Смена режима добычи на Каждый за себя в фазе 2 (в обычке, для лидера рейда)",
	YellOnStaticAnger	= "Кричать, когда на вас $spell:310636",
	YellOnStaticAnger2	= "Кричать, когда на вас $spell:310659",
	WarnCore	= "Объявить наличие порченой магмы",
	WarnPhase	= "Объявлять о смене фазы",
	Strider	= "Отсчет времени до следующего Странника",
	TaintedElemental	= "Отсчет времени до следующего Нечистого элементаля",
	Naga	= "Отсчет времени до следующего Гвардейца",
	WarnElemental	= "Объявлять о прибытии Нечистый элементаль",
	Elem	= "Показывать стрелку на Нечистого элементаля",
	AnnounceStatic	= "Объявлять игроков, на кого установлено $spell:310636, в рейд чат ",
	AnnounceStatic2	= "Объявлять игроков, на кого установлено $spell:310659, в рейд чат ",
	SpecWarnStaticAngerNear	= "Спец-предупреждение, когда $spell:310636 около вас",
	SpecWarnStaticAngerNear2	= "Спец-предупреждение, когда $spell:310659 около вас"
}

L:SetMiscLocalization{
	YellPhase2              = "Время пришло! Не щадите никого!",
	YellPhase3              = "Вам не пора прятаться?",
	TaintedElemental        = "Нечистый элементаль",
	StaticIcons	= "Статический заряд {rt%d} установлен на %s",
	StaticIcons2	= "Статический заряд {rt%d} установлен на %s"
}

-------------
-- Gorelac --
-------------
L = DBM:GetModLocalization("Gorelac")

L:SetGeneralLocalization{
	name           = "Горе'лац"
}

L:SetTimerLocalization{

}

L:SetWarningLocalization{
	SpecialMassiveShelll	= "Обстрел по вам - Берегитесь",
	MassiveShelll		= "Обстрел по >%s<"

}

L:SetOptionLocalization{
	RangeFrame	= "Показывать игроков  в окне проверки дистанции",
	SpecialMassiveShelll	= "Спец-предупреждение, когда на вас $spell:310560",
	MassiveShelll		= "Объявлять цели заклинания $spell:310560",
	YellOnPowerfulShot	= "Кричать, когда на вас $spell:310564",
	YellOnMassiveShell	= "Кричать, когда на вас $spell:310560",
	SetIconOnMassiveShellTarget	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(310560),
	SetIconOnPowerfulShotTarget	= DBM_CORE_AUTO_ICONS_OPTION_TEXT:format(310564)
}

L:SetMiscLocalization{

}

---------------
-- TrashMobs --
---------------
L = DBM:GetModLocalization("TrashMobs")

L:SetGeneralLocalization{
	name           = "Трэш мобы"
}