﻿#Область ПрограммныйИнтерфейс

// Проверка подключения контуров, подключение контура если ранее не был подключен, удаление настройки и 
// папки в случае отсуствия контура в настройке.
//
Процедура КШДПроверкаНастройкаКонтуров() Экспорт
	ОбщегоНазначения.ПриНачалеВыполненияРегламентногоЗадания(Метаданные.РегламентныеЗадания.КШДПроверкаНастройкаКонтуров);
	
	Главный = "master";
	НастройкаПодключения = Справочники.РГНастройкиРепозиториев.НайтиПоНаименованию(Главный);
	Настройка = КШДЯдроВызовСервера.БазаПодключенаККШД(Истина);
	Если Не Настройка.РасположениеУзлаАктуально ИЛИ Не Настройка.РепозиторийИнициализирован Тогда
		Возврат; //Подключение к КШД не настроено
	КонецЕсли;
	
	МассивПодключенных = Настройка.КонфигурацияУзла.outline;
	
	Если МассивПодключенных[0] = "all" Тогда
		СписокВсехКонтуров = КШДЯдроВызовСервера.ПолучитьСписокКонтуровКШД();
		МассивПодключенных.Очистить();
		Для Каждого ТекущийКонтур Из СписокВсехКонтуров Цикл
			МассивПодключенных.Добавить(ТекущийКонтур.id);
		КонецЦикла;
	КонецЕсли;
	
	МассивНужныхНастроек = Новый Массив;
	МассивНужныхНастроек.Добавить(НастройкаПодключения);
	Для Каждого ПодключенныйКонтур Из МассивПодключенных Цикл
		Настройка = ПроверитьПодключитьКонтур(ПодключенныйКонтур, НастройкаПодключения);
		Если Настройка <> Неопределено Тогда
			МассивНужныхНастроек.Добавить(Настройка);
		КонецЕсли;
	КонецЦикла;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	РГНастройкиРепозиториев.Ссылка КАК Ссылка
	               |ИЗ
	               |	Справочник.РГНастройкиРепозиториев КАК РГНастройкиРепозиториев
	               |ГДЕ
	               |	НЕ РГНастройкиРепозиториев.Ссылка В (&МассивНастроек)";
	Запрос.УстановитьПараметр("МассивНастроек", МассивНужныхНастроек);
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		НастройкаПодключения = Выборка.Ссылка;
		РГПолныеПрава.УдалитьДанныеИзБезопасногоХранилища(НастройкаПодключения);
		РГОбщегоНазначения.УдалитьКаталог(НастройкаПодключения.ПутьЛокальногоХранения);
		ТекНастройка = НастройкаПодключения.ПолучитьОбъект();
		ТекНастройка.Удалить();
	КонецЦикла;
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ПроверитьПодключитьКонтур(ИмяКонтура, ОсновнаяНастройка)
	Главный = "master";
	НастройкаПодключения = Справочники.РГНастройкиРепозиториев.НайтиПоНаименованию(ИмяКонтура);
	СимволовБезПапки = СтрДлина(ОсновнаяНастройка.ПутьЛокальногоХранения) - СтрДлина(Главный);
	ПутьЛокальногоХранения = Лев(ОсновнаяНастройка.ПутьЛокальногоХранения, СимволовБезПапки) + ИмяКонтура;
	
	Если Не НастройкаПодключения.Пустая() И НастройкаПодключения.Инициализирован Тогда
		Если НастройкаПодключения.ПутьЛокальногоХранения = ПутьЛокальногоХранения Тогда
			//Пробуем обновить
			Результат = РГОбщегоНазначения.ПолучитьИзУдаленногоРепозитория(НастройкаПодключения);
			Если Не Результат.Успешно Тогда
				//Зафиксируем ошибку и инициализируем заново
				ТекстЗаписи = "Ошибка обновления контура " + ИмяКонтура + ", ошибка: " + Результат.Ошибка;
				ЗаписьЖурналаРегистрации("КШДПроверка.ОбновлениеКонтура", УровеньЖурналаРегистрации.Ошибка, , , ТекстЗаписи);
			Иначе
				Возврат НастройкаПодключения;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Если НастройкаПодключения.Пустая() Тогда
		НоваяНастройка = ОсновнаяНастройка.Скопировать();
		НоваяНастройка.Наименование = ИмяКонтура;
	Иначе
		НоваяНастройка = НастройкаПодключения.ПолучитьОбъект();
	КонецЕсли;
	
	НоваяНастройка.Инициализирован = Ложь;
	НоваяНастройка.ПутьЛокальногоХранения = ПутьЛокальногоХранения;
	НоваяНастройка.Записать();
	НастройкаПодключения = НоваяНастройка.Ссылка;
	
	Если НоваяНастройка.СпособАвторизации = Перечисления.РГСпособыАвторизации.OAuth Тогда
		ДанныеАвторизации = РГПолныеПрава.ПрочитатьДанныеИзБезопасногоХранилища(ОсновнаяНастройка, "Токен");
		Если Не ДанныеАвторизации = Неопределено Тогда
			РГПолныеПрава.ЗаписатьДанныеВБезопасноеХранилище(НастройкаПодключения, ДанныеАвторизации, "Токен");		
		КонецЕсли;
	КонецЕсли; 
	Если НоваяНастройка.СпособАвторизации = Перечисления.РГСпособыАвторизации.ПоПаролю Тогда
		ДанныеАвторизации = РГПолныеПрава.ПрочитатьДанныеИзБезопасногоХранилища(ОсновнаяНастройка, "Логин, Пароль"); 
		Если Не ДанныеАвторизации = Неопределено Тогда
			РГПолныеПрава.ЗаписатьДанныеВБезопасноеХранилище(НастройкаПодключения, ДанныеАвторизации.Логин, "Логин");
			РГПолныеПрава.ЗаписатьДанныеВБезопасноеХранилище(НастройкаПодключения, ДанныеАвторизации.Пароль, "Пароль");
		КонецЕсли;
	КонецЕсли; 
	Результат = РГОбщегоНазначения.ИнициализацияПодключенияКРепозиторию(НастройкаПодключения, ИмяКонтура);
	Если Не Результат.Успешно Тогда
		ТекстЗаписи = "Ошибка инициализации контура " + ИмяКонтура + ", ошибка: " + Результат.Ошибка;
		ЗаписьЖурналаРегистрации("КШДПроверка.ОбновлениеКонтура", УровеньЖурналаРегистрации.Ошибка, , , ТекстЗаписи);
	КонецЕсли;
	
	Возврат НастройкаПодключения;
КонецФункции

#КонецОбласти