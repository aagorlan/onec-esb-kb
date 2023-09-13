﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если Не ЗначениеЗаполнено(Объект.Ссылка) Тогда
		ВыполнитьНачальноеЗаполнение();
	КонецЕсли;
	Если Объект.ТипКонтура = Перечисления.ТипыКонтуров.Разработка Тогда
		ЗагрузитьЭтапы();
	КонецЕсли;
	ВыбранныйЭтап = Объект.Этап;
	ВыполнитьНастройкуВида();
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	ВыполнитьНастройкуВида();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура СостояниеПриИзменении(Элемент)
	Записать();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовТаблицыФормыТаблицаЭтапов

&НаКлиенте
Процедура ТаблицаЭтаповПриАктивизацииСтроки(Элемент)
	ВыбранныйЭтап = Элементы.ТаблицаЭтапов.ТекущиеДанные.Этап;
	ВыполнитьНастройкуСтраницЭтапа();
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаЭтаповПриАктивизацииЯчейки(Элемент)
	Элементы.ТаблицаЭтапов.ВыделенныеСтроки.Очистить();
КонецПроцедуры

#КонецОбласти
 
#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура СледующийЭтап(Команда)
	Объект.Этап = СледующийЭтап;
	Записать();
КонецПроцедуры

&НаКлиенте
Процедура ПредыдущийЭтап(Команда)
	Объект.Этап = ПредыдущийЭтап;
	Записать();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ВыполнитьНачальноеЗаполнение()
	Если Не ЗначениеЗаполнено(Объект.Родитель) Тогда
		Объект.ТипКонтура = Перечисления.ТипыКонтуров.Продуктивный;
		Объект.Состояние = Перечисления.СостоянияКонтуров.ВРаботе;
		Объект.Наименование = "Продуктивный";
		Объект.ИмяВетки = "master";
	ИначеЕсли Объект.Родитель.ТипКонтура = Перечисления.ТипыКонтуров.Продуктивный Тогда
		Объект.ТипКонтура = Перечисления.ТипыКонтуров.Тестовый;
		Объект.Состояние = Перечисления.СостоянияКонтуров.ВРаботе;
		Объект.Наименование = "Тестовый";
		Объект.ИмяВетки = "develop";
		Объект.Репозиторий = Объект.Родитель.Репозиторий;
	Иначе
		Объект.ТипКонтура = Перечисления.ТипыКонтуров.Разработка;
		Объект.Состояние = Перечисления.СостоянияКонтуров.Черновик;
		Объект.Репозиторий = Объект.Родитель.Репозиторий;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ВыполнитьНастройкуВида()
	
	Если ЗначениеЗаполнено(Объект.Этап) Тогда
		ПорядокТекущего = Объект.Этап.Порядок;
	КонецЕсли;
	
	Если Объект.Состояние <> Перечисления.СостоянияКонтуров.Черновик Тогда
		Элементы.Состояние.Вид = ВидПоляФормы.ПолеНадписи;
		Элементы.ИмяВетки.Вид = ВидПоляФормы.ПолеНадписи;
	КонецЕсли;
	
	Если Объект.Состояние <> Перечисления.СостоянияКонтуров.ВРаботе Тогда
		Элементы.ГруппаУправленияЭтапами.Видимость = Ложь;
	КонецЕсли;
	
	Если Объект.ТипКонтура = Перечисления.ТипыКонтуров.Продуктивный 
		ИЛИ Объект.ТипКонтура = Перечисления.ТипыКонтуров.Тестовый Тогда
		Элементы.ТипКонтура.Вид = ВидПоляФормы.ПолеНадписи;
		Элементы.ТаблицаЭтапов.Видимость = Ложь;
		Элементы.ГруппаУправленияЭтапами.Видимость = Ложь;
	КонецЕсли;
	
	Если Объект.ТипКонтура <> Перечисления.ТипыКонтуров.Продуктивный Тогда
		Элементы.Репозиторий.Вид = ВидПоляФормы.ПолеНадписи;
		Элементы.Репозиторий.Гиперссылка = Истина;
	КонецЕсли;
	
	ВыполнитьНастройкуСтраницЭтапа();
	
	ВыполнитьНастройкуКнопокПерехода();
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьЭтапы()
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ЭтапыКонтуров.Ссылка КАК Этап,
	               |	ЭтапыКонтуров.Порядок КАК Порядок
	               |ИЗ
	               |	Справочник.ЭтапыКонтуров КАК ЭтапыКонтуров
	               |
	               |УПОРЯДОЧИТЬ ПО
	               |	ЭтапыКонтуров.Порядок";
	ТаблицаЭтапов.Загрузить(Запрос.Выполнить().Выгрузить());
КонецПроцедуры

&НаСервере
Процедура ВыполнитьНастройкуСтраницЭтапа()
	Если Объект.ТипКонтура = Перечисления.ТипыКонтуров.Продуктивный Тогда
		Элементы.СтраницыЭтапов.ТекущаяСтраница = Элементы.ЭтапПродуктивного;
	ИначеЕсли Объект.ТипКонтура = Перечисления.ТипыКонтуров.Тестовый Тогда
		Элементы.СтраницыЭтапов.ТекущаяСтраница = Элементы.ЭтапТестового;
	Иначе
		Если Не ЗначениеЗаполнено(Объект.Этап) Тогда
			Элементы.СтраницыЭтапов.ТекущаяСтраница = Элементы.ЭтапОтсуствует;
		ИначеЕсли ВыбранныйЭтап.Порядок > ПорядокТекущего Тогда
			Элементы.СтраницыЭтапов.ТекущаяСтраница = Элементы.ЭтапНеВыполнялся;
		Иначе
			ИмяЭтапа = ВыбранныйЭтап.ИмяПредопределенныхДанных;
			Элементы.СтраницыЭтапов.ТекущаяСтраница = Элементы["Этап" + ИмяЭтапа];
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ВыполнитьНастройкуКнопокПерехода()
	ПредыдущийЭтап = Справочники.ЭтапыКонтуров.ПустаяСсылка();
	СледующийЭтап = Справочники.ЭтапыКонтуров.ПустаяСсылка();
	Найден = Ложь;
	
	Для Каждого СтрокаЭтапа Из ТаблицаЭтапов Цикл
		Если Найден Тогда
			СледующийЭтап = СтрокаЭтапа.Этап;
			Прервать;
		КонецЕсли;
		Если СтрокаЭтапа.Этап = Объект.Этап Тогда
			Найден = Истина;
			Продолжить;
		КонецЕсли;
		ПредыдущийЭтап = СтрокаЭтапа.Этап;
	КонецЦикла;
	
	Если ЗначениеЗаполнено(ПредыдущийЭтап) Тогда
		Элементы.ПредыдущийЭтап.Видимость = Истина;
		Элементы.ПредыдущийЭтап.Заголовок = "Вернуться на этап " + ПредыдущийЭтап;
	Иначе
		Элементы.ПредыдущийЭтап.Видимость = Ложь;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(СледующийЭтап) Тогда
		Элементы.СледующийЭтап.Видимость = Истина;
		Элементы.СледующийЭтап.Заголовок = "Перейти на этап " + СледующийЭтап;
	Иначе
		Элементы.СледующийЭтап.Видимость = Ложь;
	КонецЕсли;
КонецПроцедуры


#КонецОбласти