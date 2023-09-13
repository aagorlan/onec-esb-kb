﻿#Область ПрограммныйИнтерфейс

// Сверяет версию данных и версию конфигурации и выполняет обработчики обновления данных
//
// Возвращаемое значение:
//  Булево - Успешно выполнено обновление или нет
//
Функция ВыполнитьОбновлениеДанных() Экспорт
	ТекущаяВерсияДанных = Константы.ТекущаяВерсияДанных.Получить();
	Если ЧислоРелиза(ТекущаяВерсияДанных) < ЧислоРелиза(Метаданные.Версия) Тогда
		Попытка
			ВыполнитьНовыеОбработчики();
			Константы.ТекущаяВерсияДанных.Установить(Метаданные.Версия);
		Исключение
			ОписаниеОшибки = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
			// BSLLS:UsageWriteLogEvent-off
			ЗаписьЖурналаРегистрации("ОбновлениеДанных", УровеньЖурналаРегистрации.Ошибка, , , ОписаниеОшибки);
			Возврат Ложь;
		КонецПопытки;
	КонецЕсли;
	Возврат Истина;
КонецФункции
	
#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Возвращает из номера релиза число
//
// Параметры:
//  НомерРелиза - Строка - строка, содержащая номер релиза в формате #.#.#.#, где # это числовое значение
//
// Возвращаемое значение:
//  Число - Номер релиза, приведенный к целому числу
//
Функция ЧислоРелиза(НомерРелиза)
	
	Если Не ЗначениеЗаполнено(НомерРелиза) Тогда
		Возврат 0;
	КонецЕсли;
	
	МассивРелиза = СтрРазделить(НомерРелиза, ".");
	
	ЦифрВРелизе = 4;
	
	Для Каждого СоставляющаяРелиза Из МассивРелиза Цикл
		СоставляющаяРелиза = Лев("0000", ЦифрВРелизе - СтрДлина(СоставляющаяРелиза)) + СоставляющаяРелиза;
	КонецЦикла;
	
	СтрокаРелиза = СтрСоединить(МассивРелиза, "");
	
	Возврат Число(СтрокаРелиза);
КонецФункции

// Получает список обработчиков, которые ранее не выполнялись при обновлении данных
//
Процедура ВыполнитьНовыеОбработчики()
	МассивОбработчиков = НастройкаОбновленияСервер.ПолучитьСписокОбработчиков();
	
	Для Каждого ДанныеОбработчика Из МассивОбработчиков Цикл
		Рег = РегистрыСведений.ВыполненныеОбработчикиОбновления.СоздатьМенеджерЗаписи();
		Рег.Обработчик = ДанныеОбработчика.Обработчик;
		Рег.Прочитать();
		Если Не Рег.Выбран() Тогда
			Комментарий = "Выполняется обработчик обновления """ + ДанныеОбработчика.Обработчик + """";
			ЗаписьЖурналаРегистрации("ОбновлениеДанных", УровеньЖурналаРегистрации.Информация, , , Комментарий);
			
			Параметры = ДанныеОбработчика.Параметры;
			
			ПараметрыСтрока = "";
			Если Параметры.Количество() > 0 Тогда
				Для Индекс = 0 По Параметры.ВГраница() Цикл 
					ПараметрыСтрока = ПараметрыСтрока + "Параметры[" + Индекс + "],";
				КонецЦикла;
				ПараметрыСтрока = Сред(ПараметрыСтрока, 1, СтрДлина(ПараметрыСтрока) - 1);
			КонецЕсли;
			
			УстановитьБезопасныйРежим(Истина);
			Выполнить ДанныеОбработчика.Обработчик + "(" + ПараметрыСтрока + ")";
			УстановитьБезопасныйРежим(Ложь);
			
			Рег.Обработчик = ДанныеОбработчика.Обработчик;
			Рег.НомерРелизаОбновления = Метаданные.Версия;
			Рег.ДатаВыполнения = ТекущаяДатаСеанса();
			Рег.Записать(Истина);
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

#КонецОбласти
