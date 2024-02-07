﻿#Область ПрограммныйИнтерфейс

// Демонстрационная процедура - Обработать входящий пакет
//
// Параметры:
//  Контур					 - Строка	 - Контур в рамках которого получено сообщение
//  Пакет					 - Строка	 - Данные сообщения
//  ИдентификаторСообщения	 - Строка	 - Уникальный идентификатор сообщения
//
Процедура ОбработатьВходящийПакет(Контур, Пакет, ИдентификаторСообщения) Экспорт
	Идентификатор = "6cbf4a3d-ab83-4223-ba74-653ad0003b71";
	
	// Подтверждаем прием и обработку сообщения
	КШДЯдроСервер.ЗавершитьЧтениеСообщенияИзОчереди(Идентификатор, ИдентификаторСообщения);
	
	Если Константы.КШДДемоСервисЗацикливать.Получить() Тогда
		// Отправляем пакет себе же
		КШДЯдроСервер.ДобавитьПакетВОчередь(Идентификатор, Контур, Пакет, ИдентификаторСообщения);
	КонецЕсли;
КонецПроцедуры

#КонецОбласти
