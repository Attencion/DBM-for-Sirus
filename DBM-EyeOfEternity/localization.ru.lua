if GetLocale() ~= "ruRU" then return end

local L

---------------
--  Malygos  --
---------------
L = DBM:GetModLocalization("Malygos")

L:SetGeneralLocalization({
	name = "Малигос"
})

L:SetWarningLocalization({
	WarningSpark		= "Искра мощи",
	WarningBreathSoon	= "Скоро Дыхание чар", 
	WarningBreath		= "Дыхание чар"
})

L:SetTimerLocalization({
    TimerSpeedKill		= "И ты не вечен",
	TimerSpark			= "Искра мощи",
	timerBreathCD		= "Дыхание чар"
})

L:SetOptionLocalization({
	WarningSpark		= "Предупреждение для Искры мощи",
	WarningBreathSoon	= "Предупреждать заранее о $spell:60072",
	WarningBreath		= "Предупреждение для $spell:60072",
	TimerSpark			= "Отсчет времени до следующей Искры мощи",
	timerBreathCD		= "Отсчет времени до следующего $spell:60072",
})

L:SetMiscLocalization({
	YellPull	= "Мое терпение лопнуло! Пора от вас избавиться!",
	EmoteSpark	= "Искра мощи появляется из ближайшей расселины!",
	YellPhase2	= "Я надеялся быстро с вами покончить",
	EmoteBreath	= "%s глубоко вдыхает.",
	YellBreath	= "Пока я дышу, вам не добиться своего!",
	YellPhase3	= "Вот и ваши благодетели появились"
})

