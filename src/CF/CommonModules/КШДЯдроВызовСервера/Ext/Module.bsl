﻿#Область ПрограммныйИнтерфейс

#Область СервисПодключениеУзла

// Получает информацию о подключении базы к КШД
//
// Параметры:
//	ОбновитьКонфигурациюУзла - Булево - выполнение проверки и подключения узла если изменилось расположение
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
Функция БазаПодключенаККШД(ОбновитьКонфигурациюУзла = Ложь) Экспорт
	СтруктураОтвета = Новый Структура;
	СтруктураОтвета.Вставить("ВерсияGit", "");
	СтруктураОтвета.Вставить("ОшибкаGit", "");
	СтруктураОтвета.Вставить("РасположениеУзлаАктуально", Ложь);
	СтруктураОтвета.Вставить("РепозиторийИнициализирован", Ложь);
	СтруктураОтвета.Вставить("СохраненноеРасположениеУзла", "");
	
	Если ОбновитьКонфигурациюУзла Тогда
		УстановленнаяВерсия = РГОбщегоНазначения.ВерсияGit();
		СтруктураОтвета.Вставить("ВерсияGit", УстановленнаяВерсия.Версия);
		СтруктураОтвета.Вставить("ОшибкаGit", УстановленнаяВерсия.Ошибка); 
		Если ЗначениеЗаполнено(УстановленнаяВерсия.Ошибка) Тогда
			КШДЯдроСервер.ОчиститьКэшНастроек("");
		КонецЕсли;
	КонецЕсли;
	
	СохраненноеРасположение = Константы.КШДРасположениеУзла.Получить();

	Если СтрокаСоединенияИнформационнойБазы() = СохраненноеРасположение Тогда
		СтруктураОтвета.Вставить("РасположениеУзлаАктуально", Истина);
	Иначе
		СтруктураОтвета.Вставить("СохраненноеРасположениеУзла", СохраненноеРасположение);
		КШДЯдроСервер.ОчиститьКэшНастроек("");
	КонецЕсли;
	
	Главный = "master";
	
	НастройкаПодключения = Справочники.РГНастройкиРепозиториев.НайтиПоНаименованию(Главный);
	Если Не НастройкаПодключения.Пустая() И НастройкаПодключения.Инициализирован Тогда
		СтруктураОтвета.Вставить("РепозиторийИнициализирован", Истина);
		Если ОбновитьКонфигурациюУзла Тогда
			ОбновитьСправочнуюИнформацию(СтруктураОтвета, НастройкаПодключения);
		КонецЕсли;
	КонецЕсли;
	
	Возврат СтруктураОтвета;
КонецФункции

// Формирует дерево контуров КШД с установкой пометок у переданного массива контуров
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
	
	ДанныеКонтуров = КШДЯдроВызовСервераПовтИсп.ЗначениеИзКэша("", Перечисления.КШДЯдроКлючиКэшаНастроек.МассивКонтуров);
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

// Возвращает структруру с типами контуров и узлов
// 
// Возвращаемое значение:
//   Структура:
//		* production - Строка - Рабочий
//		* staging - Строка - Предрелизный
//		* test - Строка - Тестовый
//		* copy - Строка - Копия
//		* develop - Строка - Разработка
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

// Установка параметров сеанса
//
Процедура УстановкаПараметровСеанса() Экспорт
	Результат = БазаПодключенаККШД();
	Актуально = (Результат.РасположениеУзлаАктуально И Результат.РепозиторийИнициализирован);
	ПараметрыСеанса.КШДЯдроПодключениеАктуально = Актуально;
КонецПроцедуры

#КонецОбласти

#Область СервисКэшированияНастроек

// Записывает произвольное значение в кэш
//
// Параметры:
//  Контур	 - Строка - Идентификатор контура
//  Ключ	 - Перечисление.КШДЯдроКлючиКэшаНастроек - Ключ записываемых настроек
//  Значение - Произвольный - Записываемое значение
//
Процедура ЗаписатьЗначениеВКэш(Контур, Ключ, Значение) Экспорт
	Рег = РегистрыСведений.КШДЯдроКэшНастроек.СоздатьМенеджерЗаписи();
	Рег.Контур = Контур;
	Рег.Ключ = Ключ;
	
	ФорматОпределен = Ложь;
	
	Если ТипЗнч(Значение) = Тип("Число") Тогда
		Если Число(Формат(Значение, "ЧЦ=15; ЧДЦ=4; ЧГ=0")) = Значение Тогда
			Рег.ТипЗначения = Перечисления.КШДЯдроТипыХранимыхЗначений.Число;
			Рег.Число = Значение;
			ФорматОпределен = Истина;
		КонецЕсли;
	КонецЕсли;
	Если ТипЗнч(Значение) = Тип("Строка") Тогда
		Если Лев(Значение, 1024) = Значение Тогда
			Рег.ТипЗначения = Перечисления.КШДЯдроТипыХранимыхЗначений.Строка;
			Рег.Строка = Значение;
			ФорматОпределен = Истина;
		КонецЕсли;
	КонецЕсли;
	Если ТипЗнч(Значение) = Тип("Дата") Тогда
		Рег.ТипЗначения = Перечисления.КШДЯдроТипыХранимыхЗначений.Дата;
		Рег.Дата = Значение;
		ФорматОпределен = Истина;
	КонецЕсли;
	Если ТипЗнч(Значение) = Тип("Булево") Тогда
		Рег.ТипЗначения = Перечисления.КШДЯдроТипыХранимыхЗначений.Булево;
		Рег.Булево = Значение;
		ФорматОпределен = Истина;
	КонецЕсли;
	Если Не ФорматОпределен Тогда
		Рег.ТипЗначения = Перечисления.КШДЯдроТипыХранимыхЗначений.Прочее;
		Рег.Прочее = Новый ХранилищеЗначения(Значение);
	КонецЕсли;
	
	Рег.Записать(Истина);
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ОбновитьСправочнуюИнформацию(СтруктураОтвета, НастройкаПодключения)
	Главный = "master";
	РГОбщегоНазначения.ПолучитьИзУдаленногоРепозитория(НастройкаПодключения);
	ТекущийКоммит = РГОбщегоНазначения.ПолучитьИндексТекущегоКоммита(НастройкаПодключения);
	Версия = КШДЯдроВызовСервераПовтИсп.ЗначениеИзКэша("", Перечисления.КШДЯдроКлючиКэшаНастроек.ВерсияНастройки);
	Если ТекущийКоммит <> Версия Тогда
		КШДЯдроСервер.ОчиститьКэшНастроек("");
		КШДЯдроВызовСервера.ЗаписатьЗначениеВКэш("", Перечисления.КШДЯдроКлючиКэшаНастроек.ВерсияНастройки,
			ТекущийКоммит);
		КШДЯдроСервер.ОбновитьКэшОсновныхНастроек();
	КонецЕсли;
	
	Путь = КШДЯдроВызовСервераПовтИсп.ЗначениеИзКэша("", Перечисления.КШДЯдроКлючиКэшаНастроек.УзелЛокальныйПуть);
	
	СимволРазделения = ?(СтрНайти(Путь, "/") > 0, "/", "\");
	Если ЗначениеЗаполнено(Путь) И (Путь + СимволРазделения + Главный) <> НастройкаПодключения.ПутьЛокальногоХранения Тогда
		ТекущиеНастройки = НастройкаПодключения.ПолучитьОбъект();
		ТекущиеНастройки.ПутьЛокальногоХранения = Путь + СимволРазделения + Главный;
		ТекущиеНастройки.Записать();
		РГОбщегоНазначения.ПолучитьИзУдаленногоРепозитория(НастройкаПодключения);
		КШДЯдроСервер.ОчиститьКэшНастроек("");
		КШДЯдроВызовСервера.ЗаписатьЗначениеВКэш("", Перечисления.КШДЯдроКлючиКэшаНастроек.ВерсияНастройки,
			ТекущийКоммит);
		КШДЯдроСервер.ОбновитьКэшОсновныхНастроек();
	КонецЕсли;
КонецПроцедуры

#КонецОбласти