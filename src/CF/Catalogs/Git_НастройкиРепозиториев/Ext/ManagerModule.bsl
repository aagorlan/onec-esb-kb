﻿#Область ПрограммныйИнтерфейс
// Возвращает строку соединения для подключения к Git.
//
// Параметры:
//  Настройка   - СправочникСсылка.Git_НастройкиРепозиториев
// 
// Возвращаемое значение:
//  Строка
Функция ПолучитьСтрокуСоединения(Настройка) Экспорт 

	Если Настройка.СпособАвторизации = Перечисления.Git_СпособыАвторизации.OAuth Тогда
		ДанныеАвторизации = Git_ПолныеПрава.ПрочитатьДанныеИзБезопасногоХранилища(Настройка, "Токен");
		Если Не ДанныеАвторизации = Неопределено Тогда
			СтрокаАвторизации = "" + ДанныеАвторизации + "@";		
		КонецЕсли;
	ИначеЕсли Настройка.СпособАвторизации = Перечисления.Git_СпособыАвторизации.ПоПаролю Тогда
		ДанныеАвторизации = Git_ПолныеПрава.ПрочитатьДанныеИзБезопасногоХранилища(Настройка, 
																						"Логин, Пароль"); 
		Если Не ДанныеАвторизации = Неопределено Тогда
			СтрокаАвторизации = "" + ДанныеАвторизации.Логин + ":" + ДанныеАвторизации.Пароль + "@";
		Иначе
			СтрокаАвторизации = "";
		КонецЕсли;
	Иначе
		СтрокаАвторизации = "";
	КонецЕсли; 
	
	Возврат Строка(Настройка.ПротоколСоединения) + СтрокаАвторизации + Настройка.ПутьКРепозиторию;
	
КонецФункции
#КонецОбласти 
