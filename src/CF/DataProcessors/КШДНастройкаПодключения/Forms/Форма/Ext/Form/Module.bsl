﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Элементы.СтраницыФормы.ТекущаяСтраница = Элементы.ТекущийСтатус;
	СписокСервисов.Параметры.УстановитьЗначениеПараметра("ТекущееВремя", ТекущаяУниверсальнаяДатаВМиллисекундах());
	ПроверитьПодключениеНаСервере();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ПутьКGitПриИзменении(Элемент)
	ПутьКGitПриИзмененииНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ДанныеРепозиторияПриИзменении(Элемент)
	ПутьЛокальногоХранения = СокрЛП(ПутьЛокальногоХранения);
	Если Прав(ПутьЛокальногоХранения, 1) = "/" ИЛИ Прав(ПутьЛокальногоХранения, 1) = "\" Тогда
		ПутьЛокальногоХранения = Лев(ПутьЛокальногоХранения, СтрДлина(ПутьЛокальногоХранения) - 1);
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(СпособАвторизации) Тогда
		Элементы.СтраницыАвторизации.ТекущаяСтраница = Элементы.НеВыбранСпособ;
		ВсеЗаполнено = Ложь;
	Иначе
		Если Не ИзменитьСохраненные Тогда
			Элементы.СтраницыАвторизации.ТекущаяСтраница = Элементы.Сохранены;
			ВсеЗаполнено = Истина;
		Иначе
			ВсеЗаполнено = ПоляАвторизацииЗаполнены();
		КонецЕсли;
	КонецЕсли;
	Если Не ЗначениеЗаполнено(ПротоколСоединения) Тогда
		ВсеЗаполнено = Ложь;
	КонецЕсли;
	Если Не ЗначениеЗаполнено(ПутьКРепозиторию) Тогда
		ВсеЗаполнено = Ложь;
	КонецЕсли;
	Если Не ЗначениеЗаполнено(ПутьЛокальногоХранения) Тогда
		ВсеЗаполнено = Ложь;
	КонецЕсли;
	
	Если ВсеЗаполнено Тогда
		ДанныеРепозиторияПриИзмененииНаСервере();
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ДекорацияДанныеАвторизацииСохраненыОбработкаНавигационнойСсылки(Элемент, 
		НавигационнаяСсылкаФорматированнойСтроки, СтандартнаяОбработка)
	ИзменитьСохраненные = Истина;
	ДанныеРепозиторияПриИзменении(Элемент);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ПодключитьККШД(Команда)
	Элементы.СтраницыФормы.ТекущаяСтраница = Элементы.ПодключениеККШД;
	ОбновитьДанныеПодключенияНаСервере();
	Элементы.ПодключенныеКонтуры.Развернуть(0, Истина);    
КонецПроцедуры

&НаКлиенте
Процедура ЗавершитьПодключение(Команда)
	Успешно = Истина;
	Если Не ЗначениеЗаполнено(Проект) Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Необходимо указать проект к которому относится текущая база";
		Сообщение.Поле = "Проект";
		Сообщение.УстановитьДанные(ЭтотОбъект);
		Сообщение.Сообщить();
		Успешно = Ложь;
	КонецЕсли;
	Если Не ЗначениеЗаполнено(ТипРесурса) Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Необходимо тип ресурса к которому относится текущая база";
		Сообщение.Поле = "ТипРесурса";
		Сообщение.УстановитьДанные(ЭтотОбъект);
		Сообщение.Сообщить();
		Успешно = Ложь;
	КонецЕсли;
	МассивКонтуров = МассивВыбранныхКонтуров();
	Если МассивКонтуров.Количество() = 0 Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Необходимо указать один или несколько контуров к которым относится текущая база";
		Сообщение.Поле = "ПодключенныеКонтуры";
		Сообщение.УстановитьДанные(ЭтотОбъект);
		Сообщение.Сообщить();
		Успешно = Ложь;
	КонецЕсли;
	Если Успешно Тогда
		ЗавершитьПодключениеНаСервере(МассивКонтуров);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ВключитьСервис(Команда)
	Если Не Элементы.СписокСервисов.ТекущиеДанные.Включен Тогда
		ВключитьСервисНаСервере(Элементы.СписокСервисов.ТекущиеДанные.Идентификатор);
	КонецЕсли;
	Элементы.СписокСервисов.Обновить();
КонецПроцедуры

&НаКлиенте
Процедура ОтключитьСервис(Команда)
	Если Элементы.СписокСервисов.ТекущиеДанные.Включен Тогда
		ОтключитьСервисНаСервере(Элементы.СписокСервисов.ТекущиеДанные.Идентификатор);
	КонецЕсли;
	Элементы.СписокСервисов.Обновить();
КонецПроцедуры

&НаКлиенте
Процедура Обновить(Команда)
	ОбновитьДанныеСервисов();
КонецПроцедуры

&НаКлиенте
Процедура Автообновление(Команда)
	Если АвтообновлениеСервисов Тогда
		ОтключитьОбработчикОжидания("ОбновитьДанныеСервисов");
		Элементы.СписокСервисовАвтообновление.ЦветФона = Новый Цвет;
	Иначе
		ПодключитьОбработчикОжидания("ОбновитьДанныеСервисов", 1);
	КонецЕсли;
	АвтообновлениеСервисов = Не АвтообновлениеСервисов;
КонецПроцедуры

&НаКлиенте
Асинх Процедура УстановитьКоличествоПотоков(Команда)
	Результат = Ждать ВвестиЧислоАсинх(1, "Количество потоков", 3, 0);
	Если Результат <> Неопределено Тогда
		УстановитьКоличествоПотоковНаСервере(Элементы.СписокСервисов.ТекущиеДанные.Идентификатор, Результат);
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ОбновитьДанныеПодключенияНаСервере()
	ПутьКGit = Константы.РГПутьКИсполняемомуФайлу.Получить();
	Если ЗначениеЗаполнено(ВерсияGit) Тогда
		Элементы.КомментарийПутьКGit.Заголовок = Новый ФорматированнаяСтрока(ВерсияGit, , Новый Цвет(0, 255, 0));
		Элементы.ПодключениеИнициализация.Доступность = Истина;
	Иначе
		Элементы.КомментарийПутьКGit.Заголовок = Новый ФорматированнаяСтрока(ОшибкаGit, , Новый Цвет(255, 0, 0));
		Элементы.ПодключениеИнициализация.Доступность = Ложь;
	КонецЕсли;
	
	ПроверитьПодключениеГлавногоУзла();
	
	Если Не ЗначениеЗаполнено(СпособАвторизации) Тогда
		Элементы.СтраницыАвторизации.ТекущаяСтраница = Элементы.НеВыбранСпособ;
	ИначеЕсли Не ИзменитьСохраненные Тогда
		Элементы.СтраницыАвторизации.ТекущаяСтраница = Элементы.Сохранены;
	Иначе
		Если СпособАвторизации = ПредопределенноеЗначение("Перечисление.РГСпособыАвторизации.OAuth") Тогда
			Элементы.СтраницыАвторизации.ТекущаяСтраница = Элементы.ПоТокену;
		КонецЕсли;
		Если СпособАвторизации = ПредопределенноеЗначение("Перечисление.РГСпособыАвторизации.ПоПаролю") Тогда
			Элементы.СтраницыАвторизации.ТекущаяСтраница = Элементы.ПоЛогину;
		КонецЕсли;
	КонецЕсли;
	
	Проекты = КШДЯдроВызовСервераПовтИсп.ЗначениеИзКэша("", Перечисления.КШДЯдроКлючиКэшаНастроек.СписокПроектов);
	Элементы.Проект.СписокВыбора.Очистить();
	Если ЗначениеЗаполнено(Проекты) Тогда
		Для Каждого ДанныеПроекта Из Проекты Цикл
			Элементы.Проект.СписокВыбора.Добавить(ДанныеПроекта.Ключ, ДанныеПроекта.Значение);
		КонецЦикла;
	КонецЕсли;
	
	МассивПометок = КШДЯдроВызовСервераПовтИсп.ЗначениеИзКэша("", Перечисления.КШДЯдроКлючиКэшаНастроек.УзелКонтуры);
	Дерево = КШДЯдроВызовСервера.ПолучитьДеревоКонтуровКШД(Истина, МассивПометок);
	ЗначениеВРеквизитФормы(Дерево, "ПодключенныеКонтуры");

	Если Не НастройкаПодключения.Пустая() И НастройкаПодключения.Инициализирован Тогда
		Элементы.ПодключениеКонтуры.Доступность = Истина;
	Иначе
		Элементы.ПодключениеКонтуры.Доступность = Ложь;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПроверитьПодключениеНаСервере()
	Главный = "master";
	НастройкаПодключения = Справочники.РГНастройкиРепозиториев.НайтиПоНаименованию(Главный);
	Настройка = КШДЯдроВызовСервера.БазаПодключенаККШД(Истина);
	ЗаполнитьЗначенияСвойств(ЭтотОбъект, Настройка);
	Если Не ЗначениеЗаполнено(ВерсияGit) ИЛИ Не РепозиторийИнициализирован Тогда
		Элементы.АктуальностьПодключения.ТекущаяСтраница = Элементы.НеПодключен;
		Возврат;
	ИначеЕсли Не РасположениеУзлаАктуально Тогда
		МассивСтроки = Новый Массив;
		МассивСтроки.Добавить(Новый ФорматированнаяСтрока("Подключение узла не актуально. ", Новый Шрифт(, , Истина)));
		МассивСтроки.Добавить("Узел подключен для расположения ");
		МассивСтроки.Добавить(Новый ФорматированнаяСтрока(Настройка.СохраненноеРасположениеУзла, Новый Шрифт(, , Истина)));
		Элементы.НадписьПодключениеНеАктуально.Заголовок = Новый ФорматированнаяСтрока(МассивСтроки);
		Элементы.АктуальностьПодключения.ТекущаяСтраница = Элементы.ПодключениеНеАктуально;
		Возврат;
	Иначе
		Элементы.АктуальностьПодключения.ТекущаяСтраница = Элементы.ПодключениеАктуально;
	КонецЕсли;
	
	Проекты = КШДЯдроВызовСервераПовтИсп.ЗначениеИзКэша("", Перечисления.КШДЯдроКлючиКэшаНастроек.СписокПроектов);
	Проект = КШДЯдроВызовСервераПовтИсп.ЗначениеИзКэша("", Перечисления.КШДЯдроКлючиКэшаНастроек.УзелПроект);
	Для Каждого ДанныеПроекта Из Проекты Цикл
		Если ДанныеПроекта.Ключ = Проект Тогда
			ПроектСтрокой = ДанныеПроекта.Значение;
		КонецЕсли;
	КонецЦикла;
	
	ТипРесурса = КШДЯдроВызовСервераПовтИсп.ЗначениеИзКэша("", Перечисления.КШДЯдроКлючиКэшаНастроек.УзелТип);
	ЭлементТипа = Элементы.ТипРесурса.СписокВыбора.НайтиПоЗначению(ТипРесурса);
	ТипРесурсаСтрокой = ЭлементТипа.Представление;
	ОписаниеРесурса = КШДЯдроВызовСервераПовтИсп.ЗначениеИзКэша("", Перечисления.КШДЯдроКлючиКэшаНастроек.УзелОписание);
	ПодключенныеКонтурыСтрокой = "";
	ЗаполнитьЗначенияСвойств(ЭтотОбъект, НастройкаПодключения);
	ПутьЛокальногоХранения = Лев(ПутьЛокальногоХранения, СтрДлина(ПутьЛокальногоХранения) - СтрДлина(Главный) - 1);

	МассивКонтуров = КШДЯдроВызовСервераПовтИсп.ЗначениеИзКэша("", Перечисления.КШДЯдроКлючиКэшаНастроек.МассивКонтуров);
	СоответствиеКонтуров = Новый Соответствие;
	СоответствиеКонтуров.Вставить("all", "Все");
	Для Каждого Контур Из МассивКонтуров Цикл
		СоответствиеКонтуров.Вставить(Контур.id, Контур.name);
	КонецЦикла;
	КонтурыУзла = КШДЯдроВызовСервераПовтИсп.ЗначениеИзКэша("", Перечисления.КШДЯдроКлючиКэшаНастроек.УзелКонтуры);
	Для Каждого ПодключенныйКонтур Из КонтурыУзла Цикл
		ТекКонтур = СоответствиеКонтуров.Получить(ПодключенныйКонтур);
		Если ТекКонтур <> Неопределено Тогда
			ПодключенныеКонтурыСтрокой = ПодключенныеКонтурыСтрокой 
				+ ?(ЗначениеЗаполнено(ПодключенныеКонтурыСтрокой), ", ", "") + ТекКонтур;
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

&НаСервере
Процедура ПутьКGitПриИзмененииНаСервере()
	Константы.РГПутьКИсполняемомуФайлу.Установить(ПутьКGit);
	ПроверитьПодключениеНаСервере();
	ОбновитьДанныеПодключенияНаСервере();
КонецПроцедуры

&НаСервере
Процедура ДанныеРепозиторияПриИзмененииНаСервере()
	СимволРазделения = ?(СтрНайти(ПутьЛокальногоХранения, "/") > 0, "/", "\");
	
	Главный = "master";
	НачатьТранзакцию();
	Попытка
		НастройкаПодключения = Справочники.РГНастройкиРепозиториев.НайтиПоНаименованию(Главный);
		Если НастройкаПодключения.Пустая() Тогда
			ТекНастройка = Справочники.РГНастройкиРепозиториев.СоздатьЭлемент();
			ТекНастройка.Наименование = Главный;
		Иначе
			ТекНастройка = НастройкаПодключения.ПолучитьОбъект();
		КонецЕсли;
		ТекНастройка.ПутьКРепозиторию = ПутьКРепозиторию;
		ТекНастройка.ПротоколСоединения = ПротоколСоединения;
		ТекНастройка.ПутьЛокальногоХранения = ПутьЛокальногоХранения + СимволРазделения + Главный;
		ТекНастройка.СпособАвторизации = СпособАвторизации;
		ТекНастройка.Инициализирован = Ложь;
		
		ТекНастройка.Записать();
		Если ИзменитьСохраненные Тогда
			Если СпособАвторизации = Перечисления.РГСпособыАвторизации.ПоПаролю И ЗначениеЗаполнено(Логин) Тогда
				РГПолныеПрава.ЗаписатьДанныеВБезопасноеХранилище(ТекНастройка.Ссылка, СокрЛП(Логин), "Логин");
				РГПолныеПрава.ЗаписатьДанныеВБезопасноеХранилище(ТекНастройка.Ссылка, СокрЛП(Пароль));	
			КонецЕсли;
			Если СпособАвторизации = Перечисления.РГСпособыАвторизации.OAuth И ЗначениеЗаполнено(Токен) Тогда
				РГПолныеПрава.ЗаписатьДанныеВБезопасноеХранилище(ТекНастройка.Ссылка, СокрЛП(Токен), "Токен");
			КонецЕсли;
		КонецЕсли;
		Результат = РГОбщегоНазначения.ИнициализацияПодключенияКРепозиторию(ТекНастройка.Ссылка, Главный);
		Если Результат.Успешно Тогда
			Элементы.НадписьРезультатПодключения.Заголовок = 
				Новый ФорматированнаяСтрока("Репозиторий подключен", , Новый Цвет(0, 255, 0));
		Иначе
			ВызватьИсключение Результат.Ошибка;
		КонецЕсли;
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		Элементы.НадписьРезультатПодключения.Заголовок = 
			Новый ФорматированнаяСтрока(ОшибкаИнициализации, , Новый Цвет(255, 0, 0));
	КонецПопытки;
	ОбновитьДанныеПодключенияНаСервере();
КонецПроцедуры

&НаСервереБезКонтекста
Функция ДанныеАвторизацииСохранены(Настройка, СпособАвторизации)
	Если Не ЗначениеЗаполнено(Настройка) Тогда
		Возврат Ложь;
	КонецЕсли;
	Если СпособАвторизации = ПредопределенноеЗначение("Перечисление.РГСпособыАвторизации.OAuth") Тогда
		ДанныеАвторизации = РГПолныеПрава.ПрочитатьДанныеИзБезопасногоХранилища(Настройка, "Токен");
	ИначеЕсли СпособАвторизации = ПредопределенноеЗначение("Перечисление.РГСпособыАвторизации.ПоПаролю") Тогда
		ДанныеАвторизации = РГПолныеПрава.ПрочитатьДанныеИзБезопасногоХранилища(Настройка, "Логин");
	Иначе
		ДанныеАвторизации = Неопределено;	
	КонецЕсли;
	Если ЗначениеЗаполнено(ДанныеАвторизации) Тогда
		Возврат Истина;
	Иначе
		Возврат Ложь;
	КонецЕсли;
КонецФункции

&НаСервере
Процедура ЗавершитьПодключениеНаСервере(Знач МассивКонтуров)
	Главный = "master";
	НастройкаПодключения = Справочники.РГНастройкиРепозиториев.НайтиПоНаименованию(Главный);
	Результат = РГОбщегоНазначения.ПолучитьИзУдаленногоРепозитория(НастройкаПодключения);
	Если Не Результат.Успешно Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не получилось получить изменения - " + Результат.Ошибка;
		Сообщение.Сообщить();
		Возврат;
	КонецЕсли;
	
	Путь = КШДЯдроВызовСервера.ПолучитьПутьКФайлам(Главный) + "nodes.json";
	Файл = Новый Файл(Путь);
	
	Если Файл.Существует() Тогда
		Чтение = Новый ЧтениеJSON;
		Чтение.ОткрытьФайл(Путь);
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
		ДанныеУзла = Новый Структура("id, project, description, localpath, type, outline");
		ДанныеУзла.id = ТекущийУзел;
		ДанныеУзлов.Добавить(ДанныеУзла);
		ДанныеУзла = ДанныеУзлов[ДанныеУзлов.Количество() - 1];
	КонецЕсли;
	
	ДанныеУзла.project = Проект;
	ДанныеУзла.description = ОписаниеРесурса;
	ДанныеУзла.localpath = ПутьЛокальногоХранения;
	ДанныеУзла.type = ТипРесурса;
	ДанныеУзла.outline = МассивКонтуров;
	
	Запись = Новый ЗаписьJSON;
	Запись.ОткрытьФайл(Путь);
	ЗаписатьJSON(Запись, ДанныеУзлов);
	Запись.Закрыть();
	
	Результат = РГОбщегоНазначения.ИндексироватьФайлы(НастройкаПодключения);
	Если Результат.Успешно Тогда
		Результат = РГОбщегоНазначения.СоздатьОтправитьКоммит(НастройкаПодключения, "Регистрация узла " + ТекущийУзел);
	Иначе
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не получилось индексировать изменения - " + Результат.Ошибка;
		Сообщение.Сообщить();
		Возврат;
	КонецЕсли;
	
	Если Результат.Успешно Тогда
		Константы.КШДРасположениеУзла.Установить(ТекущийУзел);
		Элементы.СтраницыФормы.ТекущаяСтраница = Элементы.ТекущийСтатус;
		ПроверитьПодключениеНаСервере();
	Иначе
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не получилось отправить коммит на сервер - " + Результат.Ошибка;
		Сообщение.Сообщить();
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция МассивВыбранныхКонтуров()
	МассивКонтуров = Новый Массив;
	ЗаполнитьМассивВыбранныхКонтуров(Неопределено, МассивКонтуров);
	
	Возврат МассивКонтуров;
КонецФункции

&НаСервере
Процедура ЗаполнитьМассивВыбранныхКонтуров(Знач СтрокиДерева, МассивКонтуров)
	Если СтрокиДерева = Неопределено Тогда
		Дерево = РеквизитФормыВЗначение("ПодключенныеКонтуры");
		СтрокиДерева = Дерево;
	КонецЕсли;
	Для Каждого СтрокаДерева Из СтрокиДерева.Строки Цикл
		Если СтрокаДерева.Пометка Тогда
			МассивКонтуров.Добавить(СтрокаДерева.Имя);
		КонецЕсли;
		ЗаполнитьМассивВыбранныхКонтуров(СтрокаДерева, МассивКонтуров);
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Функция ПоляАвторизацииЗаполнены()
	ВсеЗаполнено = Истина;
	Если СпособАвторизации = ПредопределенноеЗначение("Перечисление.РГСпособыАвторизации.OAuth") Тогда
		Элементы.СтраницыАвторизации.ТекущаяСтраница = Элементы.ПоТокену;
		Если Не ЗначениеЗаполнено(Токен) Тогда
			ВсеЗаполнено = Ложь;
		КонецЕсли;
	КонецЕсли;
	Если СпособАвторизации = ПредопределенноеЗначение("Перечисление.РГСпособыАвторизации.ПоПаролю") Тогда
		Элементы.СтраницыАвторизации.ТекущаяСтраница = Элементы.ПоЛогину;
		Если Не ЗначениеЗаполнено(Логин) ИЛИ Не ЗначениеЗаполнено(Пароль) Тогда
			ВсеЗаполнено = Ложь;
		КонецЕсли;
	КонецЕсли;
	Возврат ВсеЗаполнено;
КонецФункции

&НаСервере
Процедура ПроверитьПодключениеГлавногоУзла()
	Главный = "master";
	НастройкаПодключения = Справочники.РГНастройкиРепозиториев.НайтиПоНаименованию(Главный);
	Если Не НастройкаПодключения.Пустая() Тогда
		ЗаполнитьЗначенияСвойств(ЭтотОбъект, НастройкаПодключения);
		ПутьЛокальногоХранения = Лев(ПутьЛокальногоХранения, СтрДлина(ПутьЛокальногоХранения) - СтрДлина(Главный) - 1);
		Если НастройкаПодключения.Инициализирован Тогда
			Элементы.НадписьРезультатПодключения.Заголовок = 
				Новый ФорматированнаяСтрока("Репозиторий подключен", , Новый Цвет(0, 255, 0));
		Иначе
			Если ЗначениеЗаполнено(ОшибкаИнициализации) Тогда
				Элементы.НадписьРезультатПодключения.Заголовок = 
					Новый ФорматированнаяСтрока(ОшибкаИнициализации, , Новый Цвет(255, 0, 0));
			Иначе
				Элементы.НадписьРезультатПодключения.Заголовок = "Для подключения заполните данные репозитория";
			КонецЕсли;
		КонецЕсли;
	Иначе
		Элементы.НадписьРезультатПодключения.Заголовок = "Для подключения заполните данные репозитория";
		ИзменитьСохраненные = Истина;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ВключитьСервисНаСервере(Знач Идентификатор)
	КШДЯдроСервер.ПодключитьСервис(Идентификатор);
КонецПроцедуры

&НаСервере
Процедура ОтключитьСервисНаСервере(Знач Идентификатор)
	КШДЯдроСервер.ОтключитьСервис(Идентификатор);
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьДанныеСервисов()
	СписокСервисов.Параметры.УстановитьЗначениеПараметра("ТекущееВремя", ТекущаяУниверсальнаяДатаВМиллисекундах());
	Элементы.СписокСервисовАвтообновление.Пометка = Не Элементы.СписокСервисовАвтообновление.Пометка;
	Если Элементы.СписокСервисовАвтообновление.Пометка И АвтообновлениеСервисов Тогда
		Элементы.СписокСервисовАвтообновление.ЦветФона = Новый Цвет(0, 178, 0);
	Иначе
		Элементы.СписокСервисовАвтообновление.ЦветФона = Новый Цвет;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура УстановитьКоличествоПотоковНаСервере(Знач Идентификатор, Знач Количество)
	НачатьТранзакцию();
	Попытка
		Блокировка = Новый БлокировкаДанных;
		ОписаниеБлокировки = Блокировка.Добавить("РегистрСведений.КШДЯдроСостояниеСервисовУзла");
		ОписаниеБлокировки.УстановитьЗначение("Идентификатор", Идентификатор);
		Блокировка.Заблокировать();
		
		Рег = РегистрыСведений.КШДЯдроСостояниеСервисовУзла.СоздатьМенеджерЗаписи();
		Рег.Идентификатор = Идентификатор;
		Рег.Прочитать();
		
		Рег.КоличествоПотоков = Количество;
		
		Рег.Записать(Истина);
		
		ЗафиксироватьТранзакцию();		
	Исключение
		ОтменитьТранзакцию();
		ОписаниеОшибки = ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		// BSLLS:UsageWriteLogEvent-off
		ЗаписьЖурналаРегистрации("КШД.Ядро.Включение сервиса", УровеньЖурналаРегистрации.Ошибка, , ,
			"При включении сервиса " + Идентификатор + " произошла ошибка:" + Символы.ПС
			+ ОписаниеОшибки);
		// BSLLS:UsageWriteLogEvent-on
	КонецПопытки;
КонецПроцедуры

#КонецОбласти