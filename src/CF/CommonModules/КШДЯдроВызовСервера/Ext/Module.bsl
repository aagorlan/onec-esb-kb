﻿#Область ПрограммныйИнтерфейс

// Получает информацию о подключении базы к КШД
//
// Параметры:
//	ПолучитьОбновитьКонфигурациюУзла - Булево - выполнение проверки и подключения узла если изменилось расположение
//	базы данных.
// 
// Возвращаемое значение:
//	Структура:
//		* ВерсияGit - Строка - Установленная версия Git
//		* ОшибкаGit - Строка - Ошибка установки Git
//		* РасположениеУзлаАктуально - Булево - Проверка что после настройки расположение базы не изменялось
//		* РепозиторийИнициализирован - Булево - Проверка что папка с репозиторием инициализирована
//		* СохраненноеРасположениеУзла - Строка - Строка подключения для которой был настроен узел
//		* ВерсияНастройки - Строка - Текущая версия настройки узла
//		* КонфигурацияУзла - Структура
//
Функция БазаПодключенаККШД(ПолучитьОбновитьКонфигурациюУзла = Ложь) Экспорт
	СтруктураОтвета = Новый Структура;
	СтруктураОтвета.Вставить("ВерсияGit", "");
	СтруктураОтвета.Вставить("ОшибкаGit", "");
	СтруктураОтвета.Вставить("РасположениеУзлаАктуально", Ложь);
	СтруктураОтвета.Вставить("РепозиторийИнициализирован", Ложь);
	СтруктураОтвета.Вставить("СохраненноеРасположениеУзла", "");
	СтруктураОтвета.Вставить("ВерсияНастройки", "");
	СтруктураОтвета.Вставить("КонфигурацияУзла", Новый Структура);
	
	Если ПолучитьОбновитьКонфигурациюУзла Тогда
		УстановленнаяВерсия = РГОбщегоНазначения.ВерсияGit();
		СтруктураОтвета.Вставить("ВерсияGit", УстановленнаяВерсия.Версия);
		СтруктураОтвета.Вставить("ОшибкаGit", УстановленнаяВерсия.Ошибка); 
	КонецЕсли;
	
	СохраненноеРасположение = Константы.КШДРасположениеУзла.Получить();

	Если СтрокаСоединенияИнформационнойБазы() = СохраненноеРасположение Тогда
		СтруктураОтвета.Вставить("РасположениеУзлаАктуально", Истина);
	Иначе
		СтруктураОтвета.Вставить("СохраненноеРасположениеУзла", СохраненноеРасположение);
	КонецЕсли;
	
	Главный = "master";
	
	НастройкаПодключения = Справочники.РГНастройкиРепозиториев.НайтиПоНаименованию(Главный);
	Если Не НастройкаПодключения.Пустая() И НастройкаПодключения.Инициализирован Тогда
		СтруктураОтвета.Вставить("РепозиторийИнициализирован", Истина);
		Если ПолучитьОбновитьКонфигурациюУзла Тогда
			ПолучитьОбновитьСправочнуюИнформацию(СтруктураОтвета, НастройкаПодключения);
		КонецЕсли;
	КонецЕсли;
	
	Возврат СтруктураОтвета;
КонецФункции

// Функция - Получить список проектов КШД
// 
// Возвращаемое значение:
//   Соответствие - Ключ - идентификатор проекта, Значение - имя проекта
//
Функция ПолучитьСписокПроектовКШД() Экспорт
	Главный = "master";
	Путь = ПолучитьПутьКФайлам(Главный);
	Файл = Новый Файл(Путь + "projects.json");
	
	Если Файл.Существует() Тогда
		Чтение = Новый ЧтениеJSON;
		Чтение.ОткрытьФайл(Путь + "projects.json");
		ДанныеПроектов = ПрочитатьJSON(Чтение, Истина);
	Иначе
		ДанныеПроектов = Новый Соответствие;
	КонецЕсли;
	
	Возврат ДанныеПроектов;
КонецФункции

// Функция - Получить список контуров КШД
// 
// Возвращаемое значение:
//   Массив из Структура см. https://aagorlan.github.io/onec-esb-kb/2024/01/11/file_formats/
//
Функция ПолучитьСписокКонтуровКШД() Экспорт
	Главный = "master";
	Путь = ПолучитьПутьКФайлам(Главный);
	Файл = Новый Файл(Путь + "outline.json");
	
	Если Файл.Существует() Тогда
		Чтение = Новый ЧтениеJSON;
		Чтение.ОткрытьФайл(Путь + "outline.json");
		ДанныеКонтуров = ПрочитатьJSON(Чтение);
	Иначе
		ДанныеКонтуров = Новый Массив;
	КонецЕсли;
	
	Возврат ДанныеКонтуров;
КонецФункции

// Функция - Получить дерево контуров КШД
//
// Параметры:
//  ВыборКорня - Булево - Добавить возможность выбора корня контуров (все) 
//  МассивПометок - Массив из Строка - Массив выбранных конутров, для которых будут установлены пометки
// 
// Возвращаемое значение:
//	ДеревоЗначений:
//		* Пометка - Булево - Признак выбранного контура
//		* Имя - Строка - Имя контура
//		* Представление - Строка - Представление контура
//		* Назначение - Строка - Тип контура
//
Функция ПолучитьДеревоКонтуровКШД(ВыборКорня = Ложь, МассивПометок = Неопределено) Экспорт
	Если МассивПометок = Неопределено Тогда
		МассивПометок = Новый Массив;
	КонецЕсли;
	
	Дерево = Новый ДеревоЗначений;
	
	МассивТипов = Новый Массив;
	МассивТипов.Добавить(Тип("Булево"));
	ОписаниеБулево = Новый ОписаниеТипов(МассивТипов);
	Дерево.Колонки.Добавить("Пометка", ОписаниеБулево);
	
	МассивТипов = Новый Массив;
	МассивТипов.Добавить(Тип("Строка"));
	КС = Новый КвалификаторыСтроки();
	ОписаниеСтрока = Новый ОписаниеТипов(МассивТипов, , КС);
	Дерево.Колонки.Добавить("Имя", ОписаниеСтрока);
	Дерево.Колонки.Добавить("Представление", ОписаниеСтрока);
	Дерево.Колонки.Добавить("Назначение", ОписаниеСтрока);
	
	СоответствиеСтрок = Новый Соответствие;
	
	Если ВыборКорня Тогда
		НоваяСтрока = Дерево.Строки.Добавить();
		НоваяСтрока.Имя = "all";
		НоваяСтрока.Представление = "Все";
		Если МассивПометок.Найти("all") <> Неопределено Тогда
			НоваяСтрока.Пометка = Истина;
		КонецЕсли;
		СоответствиеСтрок.Вставить("", НоваяСтрока);
	Иначе
		СоответствиеСтрок.Вставить("", Дерево);
	КонецЕсли;
	
	ДанныеКонтуров = ПолучитьСписокКонтуровКШД();
	СтруктураТиповКонтуров = ПолучитьСтруктуруТипов();
	
	Для Каждого Контур Из ДанныеКонтуров Цикл
		ТекРодитель = СоответствиеСтрок.Получить(Контур.parent);
		Если ТекРодитель = Неопределено Тогда
			ТекстЗаписи = "Нарушение структуры контуров. Контур " + Контур.id + " не найден родитель " + Контур.parent;
			ЗаписьЖурналаРегистрации("КШД.СтруктураКонтуров", УровеньЖурналаРегистрации.Ошибка, , , ТекстЗаписи);
			Продолжить;
		КонецЕсли;
		НоваяСтрока = ТекРодитель.Строки.Добавить();
		НоваяСтрока.Имя = Контур.id;
		НоваяСтрока.Представление = Контур.name;
		НоваяСтрока.Назначение = СтруктураТиповКонтуров[Контур.type];
		Если МассивПометок.Найти(Контур.id) <> Неопределено Тогда
			НоваяСтрока.Пометка = Истина;
		КонецЕсли;
		СоответствиеСтрок.Вставить(Контур.id, НоваяСтрока);
	КонецЦикла;
	
	Возврат Дерево;
КонецФункции

// Функция - Получить структуру типов
// 
// Возвращаемое значение:
//   Структура:
//		* production
//		* staging
//		* test
//		* copy
//		* develop
//
Функция ПолучитьСтруктуруТипов() Экспорт
	СтруктураТипов = Новый Структура;
	СтруктураТипов.Вставить("production", "Рабочий");
	СтруктураТипов.Вставить("staging", "Предрелизный");
	СтруктураТипов.Вставить("test", "Тестовый");
	СтруктураТипов.Вставить("copy", "Копия");
	СтруктураТипов.Вставить("develop", "Разработка");
	
	Возврат СтруктураТипов;
КонецФункции

// Функция - Получить данные узла КШД
// 
// Возвращаемое значение:
//   Структура - см. https://aagorlan.github.io/onec-esb-kb/2024/01/11/file_formats/
//
Функция ПолучитьДанныеУзлаКШД() Экспорт
	Главный = "master";
	Путь = ПолучитьПутьКФайлам(Главный);
	Файл = Новый Файл(Путь + "nodes.json");
	
	Если Файл.Существует() Тогда
		Чтение = Новый ЧтениеJSON;
		Чтение.ОткрытьФайл(Путь + "nodes.json");
		ДанныеУзлов = ПрочитатьJSON(Чтение);
		Чтение.Закрыть();
	Иначе
		ДанныеУзлов = Новый Массив;
	КонецЕсли;
	
	ТекущийУзел = СтрокаСоединенияИнформационнойБазы();
	Найден = Ложь;
	
	Для Каждого ДанныеУзла Из ДанныеУзлов Цикл
		Если ДанныеУзла.id = ТекущийУзел Тогда
			Найден = Истина;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Если Не Найден Тогда
		ДанныеУзла = Неопределено;
	КонецЕсли;
	
	Возврат ДанныеУзла;
КонецФункции

// Функция - Получить путь к файлам
//
// Параметры:
//  Ветка - Строка - Имя ветки (контура) для которой необходимо получить путь
//  ПутьВнутри - Строка - Путь внутри репозитория
// 
// Возвращаемое значение:
//  Строка - Путь для указанной ветки
//
Функция ПолучитьПутьКФайлам(Ветка, ПутьВнутри = "") Экспорт
	НастройкаПодключения = Справочники.РГНастройкиРепозиториев.НайтиПоНаименованию(Ветка);
	СимволРазделения = ?(СтрНайти(НастройкаПодключения.ПутьЛокальногоХранения, "/") > 0, "/", "\");
	
	Если СимволРазделения = "/" Тогда
		ПутьВнутри = СтрЗаменить(ПутьВнутри, "\", "/");
	Иначе
		ПутьВнутри = СтрЗаменить(ПутьВнутри, "/", "\");
	КонецЕсли;
	
	Если Прав(СокрЛП(ПутьВнутри), 1) <> СимволРазделения И ЗначениеЗаполнено(ПутьВнутри) Тогда
		ПутьВнутри = ПутьВнутри + СимволРазделения;
	КонецЕсли;
	
	Возврат НастройкаПодключения.ПутьЛокальногоХранения + СимволРазделения + ПутьВнутри;
КонецФункции

// Процедура - Установка параметров сеанса
//
Процедура УстановкаПараметровСеанса() Экспорт
	Результат = БазаПодключенаККШД();
	Актуально = (Результат.РасположениеУзлаАктуально И Результат.РепозиторийИнициализирован);
	ПараметрыСеанса.КШДЯдроПодключениеАктуально = Актуально;
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ПолучитьОбновитьСправочнуюИнформацию(СтруктураОтвета, НастройкаПодключения)
	Главный = "master";
	РГОбщегоНазначения.ПолучитьИзУдаленногоРепозитория(НастройкаПодключения);
	
	ДанныеУзла = ПолучитьДанныеУзлаКШД();
	
	Если ДанныеУзла = Неопределено Тогда
		СтруктураОтвета.Вставить("РасположениеУзлаАктуально", Ложь);
	Иначе
		СтруктураОтвета.Вставить("КонфигурацияУзла", ДанныеУзла);
		ТекущийКоммит = РГОбщегоНазначения.ПолучитьИндексТекущегоКоммита(НастройкаПодключения);
		СтруктураОтвета.Вставить("ВерсияНастройки", ТекущийКоммит);
		Если ДанныеУзла.localpath <> НастройкаПодключения.ПутьЛокальногоХранения Тогда
			ТекущиеНастройки = НастройкаПодключения.ПолучитьОбъект();
			СимволРазделения = ?(СтрНайти(ДанныеУзла.localpath, "/") > 0, "/", "\");
			ТекущиеНастройки.ПутьЛокальногоХранения = ДанныеУзла.localpath + СимволРазделения + Главный;
			ТекущиеНастройки.Записать();
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

#КонецОбласти