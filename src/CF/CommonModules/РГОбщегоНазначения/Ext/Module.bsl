﻿#Область ПрограммныйИнтерфейс 

#Область РаботаСGit   

// Проводит инициализацию локального хранилища и перевод на указанную ветку, если хранилище инициализировано
// существующее локальное хранилище удаляется и создается снова.
//
// Параметры:
// 	НастройкаGit 	- СправочникСсылка.РГНастройкиРепозиториев - Текущая настройка Git
// 	ИмяВетки 		- Строка - Имя ветки Git
//
// Возвращаемое значение:
//	Структура:
//		* Успешно - Булево - признак успешности завершения действий
//		* Ошибка - Строка - содержит информацию об ошибке, возникшей при выполнении
//
Функция ИнициализацияПодключенияКРепозиторию(НастройкаGit, ИмяВетки = "master") Экспорт
	Результат = Новый Структура;
	Результат.Вставить("Успешно", Ложь);
	Результат.Вставить("Ошибка", "");
	
	СтрокаСоединения = Справочники.РГНастройкиРепозиториев.ПолучитьСтрокуСоединения(НастройкаGit);
	ПутьКGit = Константы.РГПутьКИсполняемомуФайлу.Получить();	

	НастройкаGitОбъект = НастройкаGit.Ссылка.ПолучитьОбъект();
	НастройкаGitОбъект.Инициализирован = Ложь;
	НастройкаGitОбъект.Записать();
	
	Попытка
		УдалитьКаталог(НастройкаGit.ПутьЛокальногоХранения);
		СоздатьКаталог(НастройкаGit.ПутьЛокальногоХранения);
	Исключение
		Результат.Ошибка = ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
		Возврат Результат;
	КонецПопытки;
	
	КомандаClone = ПутьКGit + " clone " + СтрокаСоединения + " """ + НастройкаGit.ПутьЛокальногоХранения + """";
	РезультатКоманды = ВыполнитьКомандуНаСервере(КомандаClone);
	
	Если РезультатКоманды.Код = 0 Тогда
		//включаем автосоздание ссылок на отслеживание по умолчанию
		КомандаНастройки = ПутьКGit + " config --global push.autoSetupRemote true";
		РезультатКоманды = ВыполнитьКомандуНаСервере(КомандаНастройки);
	Иначе
		Результат.Ошибка = "" + РезультатКоманды.Код + " - " + РезультатКоманды.Ошибка;
		Возврат Результат;
	КонецЕсли;

	Если РезультатКоманды.Код = 0 Тогда
		НастройкаGitОбъект = НастройкаGit.Ссылка.ПолучитьОбъект();
		НастройкаGitОбъект.Инициализирован = Истина;
		НастройкаGitОбъект.Записать();
		
		РезультатКоманды = ПереключитьсяНаВетку(НастройкаGit, ИмяВетки, ИмяВетки);
	Иначе
		Результат.Ошибка = "" + РезультатКоманды.Код + " - " + РезультатКоманды.Ошибка;
		Возврат Результат;
	КонецЕсли;
	
	Если РезультатКоманды.Успешно Тогда
		Результат.Успешно = Истина;
	Иначе
		Результат.Ошибка = "" + РезультатКоманды.Ошибка;
	КонецЕсли;
			
	Возврат Результат;
КонецФункции 

// Возвращает имя текущей ветки 
//
// Параметры:
// 	НастройкаGit - СправочникСсылка.РГНастройкиРепозиториев - Текущая настройка Git
//
// Возвращаемое значение:
//  - Строка - имя текущей ветки
//  - Неопределено - при ошибке получения имени
//
Функция ПолучитьИмяТекущейВетки(НастройкаGit) Экспорт
	ПутьКGit = Константы.РГПутьКИсполняемомуФайлу.Получить();	
	
	КомандаИмяВетки = ПутьКGit + " symbolic-ref --short HEAD";
	РезультатИмяВетки = ВыполнитьКомандуНаСервере(КомандаИмяВетки, НастройкаGit.ПутьЛокальногоХранения); 
	Успешно = РезультатИмяВетки.Код = 0; 
		
	Если Успешно Тогда 
		Возврат СокрЛП(РезультатИмяВетки.Ответ);
	Иначе
		Возврат Неопределено;
	КонецЕсли;
КонецФункции  

// Возвращает индекс текущго коммита
//
// Параметры:
// 	НастройкаGit - СправочникСсылка.РГНастройкиРепозиториев - Текущая настройка Git 
//
// Возвращаемое значение:
//  - Строка - хэш текущго коммита
//	- Неопределено - при ошибке получения индекса
//
Функция ПолучитьИндексТекущегоКоммита(НастройкаGit) Экспорт
	ПутьКGit = Константы.РГПутьКИсполняемомуФайлу.Получить();	
	
	КомандаИндекс = ПутьКGit + " rev-parse HEAD";
	РезультатИндекс = ВыполнитьКомандуНаСервере(КомандаИндекс, НастройкаGit.ПутьЛокальногоХранения); 
	Успешно = РезультатИндекс.Код = 0; 
		
	Если Успешно Тогда 
		Возврат СокрЛП(РезультатИндекс.Ответ);
	Иначе
		Возврат Неопределено;
	КонецЕсли;
КонецФункции

// Переключает на указанную ветку, если ветка не существует
//
// Параметры:
// 	НастройкаGit - СправочникСсылка.РГНастройкиРепозиториев - Текущая настройка Git
// 	ИмяВетки - Строка - Имя ветки на которую надо переключиться
//	СоздатьВетку - Булево - Создать новую ветку в случае отсуствия в репозитории
//	Родитель - Строка - Имя ветки от которой необходимо создать новую
//
// Возвращаемое значение:
//	Структура:
//		* Успешно - Булево - признак успешности завершения действий
//		* Ошибка - Строка - содержит информацию об ошибке, возникшей при выполнении
//
Функция ПереключитьсяНаВетку(НастройкаGit, ИмяВетки, СоздатьВетку = Ложь, Родитель = "") Экспорт
	Результат = Новый Структура;
	Результат.Вставить("Успешно", Ложь);
	Результат.Вставить("Ошибка", "");
	
	ПутьКGit = Константы.РГПутьКИсполняемомуФайлу.Получить();	
	
	//Проверим есть ли ветка
	КомандаCheckout = ПутьКGit + " checkout -B """ + ИмяВетки + """ ""origin/" + ИмяВетки + """";
	РезультатКоманды = ВыполнитьКомандуНаСервере(КомандаCheckout, НастройкаGit.ПутьЛокальногоХранения);
	
	КодОтсуствияВетки = 128;
	Если РезультатКоманды.Код = КодОтсуствияВетки И СоздатьВетку Тогда //Ветка отсуствует
		РезультатКоманды = СоздатьВетку(НастройкаGit, ИмяВетки, Родитель);
		Если РезультатКоманды.Успешно Тогда
			Результат.Успешно = Истина;
		Иначе
			Результат.Ошибка = РезультатКоманды.Ошибка;
		КонецЕсли;
	ИначеЕсли РезультатКоманды.Код = 0 Тогда
		Результат.Успешно = Истина;
	Иначе
		Результат.Ошибка = "" + РезультатКоманды.Код + " - " + РезультатКоманды.Ошибка;
	КонецЕсли;
 	
	Возврат Результат;
КонецФункции   

// Создает указанную ветку от указанной и переключается на нее
//
// Параметры:
// 	НастройкаGit - СправочникСсылка.Git_НастройкиРепозиториев - Текущая настройка Git
// 	ИмяВетки - Строка - Имя создаваемой ветки
//	Родитель - Строка - Имя ветки от которой необходимо создать новую
//
// Возвращаемое значение:
//	Структура:
//		* Успешно - Булево - признак успешности завершения действий
//		* Ошибка - Строка - содержит информацию об ошибке, возникшей при выполнении
//
Функция СоздатьВетку(НастройкаGit, ИмяВетки, Родитель = "") Экспорт
	Результат = Новый Структура;
	Результат.Вставить("Успешно", Ложь);
	Результат.Вставить("Ошибка", "");
	
	ПутьКGit = Константы.РГПутьКИсполняемомуФайлу.Получить();
	Если ЗначениеЗаполнено(Родитель) Тогда
		РезультатКоманды = ПереключитьсяНаВетку(НастройкаGit, Родитель);
		Если Не РезультатКоманды.Успешно Тогда
			Результат.Ошибка = РезультатКоманды.Ошибка;
			Возврат Результат;
		КонецЕсли;
		КомандаCheckout = ПутьКGit + " checkout -B """ + ИмяВетки + """";
	Иначе
		КомандаCheckout = ПутьКGit + " checkout --orphan """ + ИмяВетки + """";
	КонецЕсли;
	РезультатКоманды = ВыполнитьКомандуНаСервере(КомандаCheckout, НастройкаGit.ПутьЛокальногоХранения);
	Если РезультатКоманды.Код = 0 Тогда
		Если Не ЗначениеЗаполнено(Родитель) Тогда
			ПодготовитьПустуюВетку(ПутьКGit, НастройкаGit, Результат);
			Если ЗначениеЗаполнено(Результат.Ошибка) Тогда
				Возврат Результат;
			КонецЕсли;
		КонецЕсли;
		РезультатКоманды = СоздатьОтправитьКоммит(НастройкаGit, "Создание ветки " + ИмяВетки);
		Если РезультатКоманды.Успешно Тогда
			Результат.Успешно = Истина;
		Иначе
			Результат.Ошибка = "" + РезультатКоманды.Ошибка;
		КонецЕсли;
	Иначе
		Результат.Ошибка = "" + РезультатКоманды.Код + " - " + РезультатКоманды.Ошибка;
	КонецЕсли;
	
	Возврат Результат;
КонецФункции   

// Удаляет указанную ветку
//
// Параметры: 
// 	НастройкаGit 	- СправочникСсылка.РГНастройкиРепозиториев - Текущая настройка Git
// 	ИмяВетки 		- Строка - Удаляемая ветка  
// 	ВУдаленномРепозитории - Булево - При значении "Истина" будет удалена ветка в удалённом репозитории, 
//									иначе будет удалена локальная ветка.
//
// Возвращаемое значение:
//  Булево - Истина, если выполнение команды завершилось успешно
//
Функция УдалитьВетку(НастройкаGit, ИмяВетки, ВУдаленномРепозитории = Ложь) Экспорт
	ПутьКGit = Константы.РГПутьКИсполняемомуФайлу.Получить();	
	
	Если ВУдаленномРепозитории Тогда
		КомандаУдалить = ПутьКGit + " push origin --delete " + ИмяВетки;
	Иначе
		КомандаУдалить = ПутьКGit + " branch -D " + ИмяВетки;			
	КонецЕсли;
	РезультатУдалить = ВыполнитьКомандуНаСервере(КомандаУдалить, НастройкаGit.ПутьЛокальногоХранения);
	Успешно = РезультатУдалить.Код = 0;
 	
	Возврат Успешно;
КонецФункции  

// Отправляет данные локального репозитория в удалённый
//
// Параметры:
// 	НастройкаGit - СправочникСсылка.РГНастройкиРепозиториев - Текущая настройка Git
// 	ПараметрыКоманды - Строка - дополнительные опции команды
//
// Возвращаемое значение:
//  Структура:
//		* Успешно - Булево - признак успешности завершения действий
//		* Ошибка - Строка - содержит информацию об ошибке, возникшей при выполнении
//		* Конфликт - Булево - признак конфликта при отправке
//
Функция ОтправитьВУдаленныйРепозиторий(НастройкаGit, ПараметрыКоманды = Неопределено) Экспорт
	Результат = Новый Структура;
	Результат.Вставить("Успешно", Ложь);
	Результат.Вставить("Ошибка", "");
	Результат.Вставить("Конфликт", Ложь);
	
	ПутьКGit = Константы.РГПутьКИсполняемомуФайлу.Получить();	
	
	КомандаPush = ПутьКGit + " push" + ?(ПараметрыКоманды <> Неопределено, " " + ПараметрыКоманды, "");
	РезультатКоманды = ВыполнитьКомандуНаСервере(КомандаPush, НастройкаGit.ПутьЛокальногоХранения);
	Если РезультатКоманды.Код = 0 Тогда
		Результат.Вставить("Успешно", Истина);
	Иначе
		Результат.Вставить("Ошибка", "" + РезультатКоманды.Ответ + " (" + РезультатКоманды.Код + ") - " +
			РезультатКоманды.Ошибка);
		Если РезультатКоманды.Код = 1 Тогда
			Результат.Вставить("Конфликт", Истина);
		КонецЕсли;
	КонецЕсли;
	
	Возврат Результат;
КонецФункции 

// Получает данные удаленного репозитория 
//
// Параметры:
// 	НастройкаGit - СправочникСсылка.РГНастройкиРепозиториев - Текущая настройка Git
//
// Возвращаемое значение:
//  Структура:
//		* Успешно - Булево - Признак успешности завершения действий
//		* Ошибка - Строка - Содержит информацию об ошибке, возникшей при выполнении
//		* Конфликт - Булево - Признак конфликта при отправке
//
Функция ПолучитьИзУдаленногоРепозитория(НастройкаGit) Экспорт
	Результат = Новый Структура;
	Результат.Вставить("Успешно", Ложь);
	Результат.Вставить("Ошибка", "");
	Результат.Вставить("Конфликт", Ложь);
	
	ПутьКGit = Константы.РГПутьКИсполняемомуФайлу.Получить();	
	
	КомандаPull = ПутьКGit + " pull -p";
	РезультатКоманды = ВыполнитьКомандуНаСервере(КомандаPull, НастройкаGit.ПутьЛокальногоХранения);
	Если РезультатКоманды.Код = 0 Тогда
		Результат.Успешно = Истина;
	Иначе
		Результат.Ошибка = "" + РезультатКоманды.Ответ + " (" + РезультатКоманды.Код + ") - " +
			РезультатКоманды.Ошибка;
		Если РезультатКоманды.Код = 1 Тогда
			Результат.Конфликт = Истина;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

// Проверяет наличие изменений файлов в рабочем каталоге, не проверяя
// неиндексированные файлы.
//
// Параметры:
// 	НастройкаGit - СправочникСсылка.РГНастройкиРепозиториев - Текущая настройка Git
//
// Возвращаемое значение:
//  Булево - Истина, если есть хотя бы один индексированный файл изменён или удалён
//
Функция ЕстьИзмененияФайлов(НастройкаGit) Экспорт
	ЕстьИзменения = Ложь;
	
	ПутьКGit = Константы.РГПутьКИсполняемомуФайлу.Получить();

	КомандаDiff = ПутьКGit + " diff --exit-code";	 
	РезультатDiff = ВыполнитьКомандуНаСервере(КомандаDiff, НастройкаGit.ПутьЛокальногоХранения);
	ЕстьИзменения = РезультатDiff.Код = 1; 
	
	Возврат ЕстьИзменения; 
КонецФункции  

// Возвращает массивы новых, изменённых и удалённых файлов в рабочем каталоге, либо наличие изменений
//
// Параметры:
// 	НастройкаGit - СправочникСсылка.РГНастройкиРепозиториев - Текущая настройка Git 
// 	ТолькоПроверитьИзменения - Булево - При передаче "Истина" функция не собирает массивы файлов
//
// Возвращаемое значение:
//  - Структура:
//		* Новые - Массив из Строка - названий файлов и каталогов с адресацией от пути локального хранения
//		* Измененные - Массив из Строка - названий файлов и каталогов с адресацией от пути локального хранения
//		* Удаленные - Массив из Строка - названий файлов и каталогов с адресацией от пути локального хранения
//  - Булево - если передан параметр ТолькоПроверитьИзменения = "Истина", есть новые, изменённые или
//  			удалённые файлы.
//
Функция СтатусФайлов(НастройкаGit, ТолькоПроверитьИзменения = Ложь) Экспорт
	Новые = Новый Массив;
	Измененные = Новый Массив;
	Удаленные = Новый Массив;
	
	ПутьКGit = Константы.РГПутьКИсполняемомуФайлу.Получить();

	КомандаStatus = ПутьКGit + " status -s";	 
	РезультатStatus = ВыполнитьКомандуНаСервере(КомандаStatus, НастройкаGit.ПутьЛокальногоХранения);
	Если РезультатStatus.Код = 0 Тогда
		
		СтрокиФайлов = СтрРазделить(РезультатStatus.Ответ, Символы.ПС, Ложь);
		Для Каждого СтрокаФайла Из СтрокиФайлов Цикл
			СтатусФайла = Лев(СтрокаФайла, 2);
			Сдвиг3 = 3;
			ИмяФайла = СокрЛП(Прав(СтрокаФайла, СтрДлина(СтрокаФайла) - Сдвиг3));
			Если СтатусФайла = "??" Тогда
				Новые.Добавить(ИмяФайла);
			ИначеЕсли Прав(СтатусФайла, 1) = "m" Тогда 
				Измененные.Добавить(ИмяФайла);
			ИначеЕсли Прав(СтатусФайла, 1) = "d" Тогда 
				Удаленные.Добавить(ИмяФайла);
			Иначе
				Продолжить;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;

	Если ТолькоПроверитьИзменения Тогда
		Возврат Новые.Количество() Или Измененные.Количество() Или Удаленные.Количество();
	Иначе
		СтруктураВозврата = Новый Структура; 
		СтруктураВозврата.Вставить("Новые", Новые);
		СтруктураВозврата.Вставить("Измененные", Измененные);
		СтруктураВозврата.Вставить("Удаленные", Удаленные);
		Возврат СтруктураВозврата;
	КонецЕсли;
КонецФункции

// Индексирует файлы в локальном каталоге
//
// Параметры:
// 	НастройкаGit - СправочникСсылка.РГНастройкиРепозиториев
//
// Возвращаемое значение:
//	Структура:
//		* Успешно - Булево - признак успешности завершения действий
//		* Ошибка - Строка - содержит информацию об ошибке, возникшей при выполнении
//
Функция ИндексироватьФайлы(НастройкаGit) Экспорт
	Результат = Новый Структура;
	Результат.Вставить("Успешно", Ложь);
	Результат.Вставить("Ошибка", "");
	
	ПутьКGit = Константы.РГПутьКИсполняемомуФайлу.Получить();	
	
	Попытка
		КомандаAdd = ПутьКGit + " add -A";
		РезультатКоманды = ВыполнитьКомандуНаСервере(КомандаAdd, НастройкаGit.ПутьЛокальногоХранения); 
	
		Если РезультатКоманды.Код = 0 Тогда
			Результат.Успешно = Истина;
		Иначе
			Результат.Ошибка = "" + РезультатКоманды.Код + " - " + РезультатКоманды.Ошибка;
		КонецЕсли;
	Исключение
		Результат.Ошибка = ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
		Возврат Результат;
	КонецПопытки;
	
	Возврат Результат;
КонецФункции

// Создаёт коммит с указанным сообщением и отправляет изменения в удалённый репозиторий
//
// Параметры:
// 	НастройкаGit 		- СправочникСсылка.РГНастройкиРепозиториев
// 	СообщениеКоммита 	- Строка
//
// Возвращаемое значение:
//	Структура:
//		* Успешно - Булево - признак успешности завершения действий
//		* Ошибка - Строка - содержит информацию об ошибке, возникшей при выполнении
//
Функция СоздатьОтправитьКоммит(НастройкаGit, СообщениеКоммита) Экспорт
	Результат = Новый Структура;
	Результат.Вставить("Успешно", Ложь);
	Результат.Вставить("Ошибка", "");
	
	ПутьКGit = Константы.РГПутьКИсполняемомуФайлу.Получить();	
	
	Попытка
		ИмяФайла = ЗаписатьСообщениеВФайл(СообщениеКоммита, НастройкаGit.ПутьЛокальногоХранения);
		КомандаCommit = ПутьКGit + " commit -F " + """" + ИмяФайла + """";
		РезультатКоманды = ВыполнитьКомандуНаСервере(КомандаCommit, НастройкаGit.ПутьЛокальногоХранения);
		УдалитьФайлы(ИмяФайла);
		
		Если РезультатКоманды.Код = 0 Тогда
			РезультатКоманды = ОтправитьВУдаленныйРепозиторий(НастройкаGit);
		Иначе
			Результат.Ошибка = "" + РезультатКоманды.Код + " - " + РезультатКоманды.Ошибка;
			Возврат Результат;
		КонецЕсли;
	
		Если РезультатКоманды.Успешно Тогда
			Результат.Успешно = Истина;
		Иначе
			Результат.Ошибка = РезультатКоманды.Ошибка;
		КонецЕсли;
	Исключение
		Результат.Ошибка = ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
		Возврат Результат;
	КонецПопытки;
	
	Возврат Результат;
КонецФункции 

// Перебазирует ветку на указанный базовый коммит или ветку
//
// Параметры:
// 	НастройкаGit 	- СправочникСсылка.РГНастройкиРепозиториев - Текущая настройка Git 
// 	ИмяВетки 		- Строка - Имя перебазируемой ветки 
// 	НоваяБаза 		- Строка - Идентификатор нового базового коммита или имя ветки
//
// Возвращаемое значение:
//  Структура, содержащая значения с ключами:
//		Результат - Число - 0, если выполнение команды завершилось успешно
//							1, если возник конфликт перебазирования, запрос rebase в этом случае автоматически отменяется 
//							2, если команда вернула ошибку выполнения
//		Сообщение - Строка - текст ответа или ошибки команды
Функция Перебазировать(НастройкаGit, ИмяВетки, НоваяБаза) Экспорт
	СтруктураОтвета = Новый Структура();
	КлючРезультата 	= "Результат";
	КлючСообщения 	= "Сообщение";
	
	ПутьКGit = Константы.РГПутьКИсполняемомуФайлу.Получить();	
	
	Успешно = ПереключитьсяНаВетку(НастройкаGit, ИмяВетки, ИмяВетки);
	
	Если Успешно Тогда
		СтруктураОтвета = ПолучитьИзУдаленногоРепозитория(НастройкаGit);
		Успешно = СтруктураОтвета.Результат = 0;
	КонецЕсли;
	
	Если Успешно Тогда		
		КомандаRebase = ПутьКGit + " rebase " + НоваяБаза;
		РезультатRebase = ВыполнитьКомандуНаСервере(КомандаRebase, НастройкаGit.ПутьЛокальногоХранения); 
		Если РезультатRebase.Код = 0 Тогда
			СтруктураОтвета.Вставить(КлючРезультата, 0);
			СтруктураОтвета.Вставить(КлючСообщения, ""); 
		ИначеЕсли РезультатRebase.Код = 1 Тогда
			СтруктураОтвета.Вставить(КлючРезультата, 1);
			СтруктураОтвета.Вставить(КлючСообщения, РезультатRebase.Ответ);
			КомандаОтмены = ПутьКGit + " rebase --abort";
			ВыполнитьКомандуНаСервере(КомандаОтмены, НастройкаGit.ПутьЛокальногоХранения);
		Иначе
			СтруктураОтвета.Вставить(КлючРезультата, 2);
			СтруктураОтвета.Вставить(КлючСообщения, РезультатRebase.Ответ + РезультатRebase.Ошибка);			
		КонецЕсли;
		
		Если СтруктураОтвета.Результат = 0 Тогда
			СтруктураОтвета = ОтправитьВУдаленныйРепозиторий(НастройкаGit, "--force-with-lease");
		КонецЕсли;
	Иначе
		СтруктураОтвета.Вставить(КлючРезультата, 2);
		СтруктураОтвета.Вставить(КлючСообщения, "Ошибка переключения на ветку");			
	КонецЕсли;
	
	Возврат СтруктураОтвета;
КонецФункции  

// Вливает ветку в целевую (Merge) 
//
// Параметры:
// 	НастройкаGit 		- СправочникСсылка.РГНастройкиРепозиториев - Текущая настройка Git 
// 	ИмяЦелевойВетки 	- Строка - Ветка, в которую будет влита ветка	  
// 	ИмяВливаемойВетки 	- Строка - Вливаемая ветка 
//
// Возвращаемое значение:
//  Структура, содержащая значения с ключами:
//		Результат - Число - 0, если выполнение команды завершилось успешно
//							1, если возник конфликт слияния, запрос merge в этом случае автоматически отменяется
//							2, если команда вернула ошибку выполнения
//		Сообщение - Строка - текст ответа или ошибки команды
Функция СлитьВетки(НастройкаGit, ИмяЦелевойВетки, ИмяВливаемойВетки) Экспорт
	СтруктураОтвета = Новый Структура();
	КлючРезультата 	= "Результат";
	КлючСообщения 	= "Сообщение";
	
	ПутьКGit = Константы.РГПутьКИсполняемомуФайлу.Получить();	
	
	Успешно = ПереключитьсяНаВетку(НастройкаGit, ИмяЦелевойВетки, ИмяЦелевойВетки);

	Если Успешно Тогда
		СтруктураОтвета = ПолучитьИзУдаленногоРепозитория(НастройкаGit);
		Успешно = СтруктураОтвета.Результат = 0;
	КонецЕсли;
	
	Если Успешно Тогда
		КомандаMerge = ПутьКGit + " merge " + ИмяВливаемойВетки;	
		РезультатMerge = ВыполнитьКомандуНаСервере(КомандаMerge, НастройкаGit.ПутьЛокальногоХранения); 
		Если РезультатMerge.Код = 0 Тогда
			СтруктураОтвета.Вставить(КлючРезультата, 0);
			СтруктураОтвета.Вставить(КлючСообщения, ""); 
		ИначеЕсли РезультатMerge.Код = 1 Тогда
			СтруктураОтвета.Вставить(КлючРезультата, 1);
			СтруктураОтвета.Вставить(КлючСообщения, РезультатMerge.Ответ);
			КомандаОтмены = ПутьКGit + " merge --abort";
			ВыполнитьКомандуНаСервере(КомандаОтмены, НастройкаGit.ПутьЛокальногоХранения);
		Иначе
			СтруктураОтвета.Вставить(КлючРезультата, 2);
			СтруктураОтвета.Вставить(КлючСообщения, РезультатMerge.Ответ + РезультатMerge.Ошибка);			
		КонецЕсли;
	Иначе
		СтруктураОтвета.Вставить(КлючРезультата, 2);
		СтруктураОтвета.Вставить(КлючСообщения, "Ошибка переключения на целевую ветку");		
	КонецЕсли;
	
	Если СтруктураОтвета.Результат = 0 Тогда
		СтруктураОтвета = ОтправитьВУдаленныйРепозиторий(НастройкаGit);
	КонецЕсли;
		
	Возврат СтруктураОтвета;
КонецФункции 

#КонецОбласти  

#Область Служебные

// Проверка, что путь к Git задан, файл существует и возвращает текущую установленную версию
// 
// Возвращаемое значение:
//	- Строка - Номер версии устанолвенного Git
//	- Неопределено - Путь не прописан или ошибка при получении версии
//
Функция ВерсияGit() Экспорт
	Результат = Новый Структура;
	Результат.Вставить("Версия", Неопределено);
	Результат.Вставить("Ошибка", "");
	
	ПутьКGit = Константы.РГПутьКИсполняемомуФайлу.Получить();	
	Если ЗначениеЗаполнено(ПутьКGit) Тогда
		
		Попытка
			КомандаИмяВетки = ПутьКGit + " --version";
			РезультатИмяВетки = ВыполнитьКомандуНаСервере(КомандаИмяВетки, ""); 
			Успешно = (РезультатИмяВетки.Код = 0); 
				
			Если Успешно Тогда 
				МассивОтвета = СтрРазделить(СокрЛП(РезультатИмяВетки.Ответ), " ");
				Результат.Версия = МассивОтвета.Получить(МассивОтвета.Количество() - 1);
			Иначе
				Результат.Ошибка = "" + РезультатИмяВетки.Код + " - " + РезультатИмяВетки.Ошибка;
			КонецЕсли;
		Исключение
			Результат.Ошибка = ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
		КонецПопытки;
	Иначе
		Результат.Ошибка = "Не указан путь к исполняемому файлу Git";
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

#КонецОбласти 

// Обеспечивает паузу в выполнении кода на указанное количество секунд
//
// Параметры:
// Секунд - Число - Длительность паузы  
//
Процедура Пауза(Секунд) Экспорт
    
    ТекущийСеансИнформационнойБазы = ПолучитьТекущийСеансИнформационнойБазы();
    ФоновоеЗадание = ТекущийСеансИнформационнойБазы.ПолучитьФоновоеЗадание();
    
    Если ФоновоеЗадание = Неопределено Тогда
        Параметры = Новый Массив;
        Параметры.Добавить(Секунд);
        ФоновоеЗадание = ФоновыеЗадания.Выполнить("РГОбщегоНазначения.Пауза", Параметры);
    КонецЕсли;
        
    Попытка
        ФоновоеЗадание.ОжидатьЗавершения(Секунд);
    Исключение
        Возврат;
    КонецПопытки;
    
КонецПроцедуры 

// Обеспечивает удаление каталога независимо от статуса находящихся в нем файлов
//
// Параметры:
// Путь - Строка - путь к удаляемому каталога  
//
Процедура УдалитьКаталог(Путь) Экспорт
	СимволРазделения = ?(СтрНайти(Путь, "/") > 0, "/", "\");
	Каталог = Новый Файл(Путь);
	Если Каталог.Существует() Тогда
		СистемнаяИнформация = Новый СистемнаяИнформация;
		Если СистемнаяИнформация.ТипПлатформы = ТипПлатформы.Windows_x86
			Или СистемнаяИнформация.ТипПлатформы = ТипПлатформы.Windows_x86_64 Тогда
			РезультатКоманды = ВыполнитьКомандуНаСервере("attrib -h -r -s /s /d """ + 
				Путь + СимволРазделения + "*.*""");
			Если РезультатКоманды.Код <> 0 Тогда
				ВызватьИсключение РезультатКоманды.Ошибка;
			КонецЕсли;
		КонецЕсли;
		УдалитьФайлы(Путь);
	КонецЕсли;
КонецПроцедуры

#КонецОбласти    

#Область СлужебныеПроцедурыИФункции

Функция ЗаписатьСообщениеВФайл(СообщениеКоммита, ПутьЛокальногоХранения)
	ИмяФайла = ПутьЛокальногоХранения + "\.git\COMMITMESSAGE";
	
	Запись = Новый ЗаписьТекста(ИмяФайла, КодировкаТекста.UTF8, Символы.ПС, Ложь);    
    Запись.ЗаписатьСтроку(СообщениеКоммита);
    Запись.Закрыть(); 
	Возврат ИмяФайла; 
КонецФункции

Функция ВыполнитьКомандуНаСервере(СтрокаКоманды, Каталог = "")
	СтруктураВозврата = ПолучитьСтруктуруРезультатаВыполненияКоманды();
	СтруктураВозврата.Вставить("Код", "");
	СтруктураВозврата.Вставить("Ответ", "");
	СтруктураВозврата.Вставить("Ошибка", "");
	
	СистемнаяИнформация = Новый СистемнаяИнформация;
	Попытка
		Если СистемнаяИнформация.ТипПлатформы = ТипПлатформы.Windows_x86
			Или СистемнаяИнформация.ТипПлатформы = ТипПлатформы.Windows_x86_64 Тогда
		
			ОбъектShell = Новый COMОбъект("WScript.Shell") ; 
			Если ЗначениеЗаполнено(Каталог) Тогда
				ОбъектShell.CurrentDirectory = Каталог; 
			КонецЕсли;
			
			Результат = ОбъектShell.Exec(СтрокаКоманды);
			МаксимальноеВремяОжидания = 20;
			КонтрольОжидания = 0;
			Пока Результат.Status <> 1 Цикл
				Если КонтрольОжидания > МаксимальноеВремяОжидания Тогда
					Прервать;
				КонецЕсли;
				Пауза(1);
				КонтрольОжидания = КонтрольОжидания + 1;
			КонецЦикла;
			СтруктураВозврата.Код = Результат.ExitCode;
			СтруктураВозврата.Ответ = НРег(Результат.StdOut.ReadAll());
			СтруктураВозврата.Ошибка = Результат.StdErr.ReadAll();
	        
			ТекстЗаписи = "Команда """ 
							+ СтрокаКоманды + """: "
							+ СтруктураВозврата.Ответ
							+ Символы.ПС
							+ СтруктураВозврата.Ошибка;
			ЗаписьЖурналаРегистрации("Git.КомандаWindows", УровеньЖурналаРегистрации.Информация, , , ТекстЗаписи);
		Иначе
			КодВозврата = Неопределено;
			
			ИмяФайлаПотокаВывода = ПолучитьИмяВременногоФайла("stdout.tmp");                                    
			СтрокаКоманды = СтрокаКоманды + " > """ + ИмяФайлаПотокаВывода + """";
			ИмяФайлаПотокаОшибок = ПолучитьИмяВременногоФайла("stderr.tmp");
			СтрокаКоманды = СтрокаКоманды + " 2>""" + ИмяФайлаПотокаОшибок + """";

			ЗапуститьПриложение(СтрокаКоманды, Каталог, Истина, КодВозврата);

			ПотокВывода = ПрочитатьФайлЕслиСуществует(ИмяФайлаПотокаВывода, Неопределено);
			УдалитьФайлы(ИмяФайлаПотокаВывода);
			ПотокОшибок = ПрочитатьФайлЕслиСуществует(ИмяФайлаПотокаОшибок, Неопределено);
			УдалитьФайлы(ИмяФайлаПотокаОшибок);
			
			СтруктураВозврата.Код = КодВозврата;
			СтруктураВозврата.Ответ = НРег(ПотокВывода);
			СтруктураВозврата.Ошибка = ПотокОшибок;               
	        
			ТекстЗаписи = "Команда """ 
							+ СтрокаКоманды 
							+ """: " 
							+ СтруктураВозврата.Ответ 
							+ Символы.ПС 
							+ СтруктураВозврата.Ошибка;
			ЗаписьЖурналаРегистрации("Git.КомандаLinux", УровеньЖурналаРегистрации.Информация, , , ТекстЗаписи);
		КонецЕсли;
	Исключение
		СтруктураВозврата.Код = -1;
		СтруктураВозврата.Ошибка = ОбработкаОшибок.КраткоеПредставлениеОшибки(ИнформацияОбОшибке());               
	КонецПопытки;
	
	Возврат СтруктураВозврата;
КонецФункции

Функция ПолучитьСтруктуруРезультатаВыполненияКоманды()
	СтруктураВозврата = Новый Структура();
	СтруктураВозврата.Вставить("Код", Неопределено);
	СтруктураВозврата.Вставить("Ответ", Неопределено);
	СтруктураВозврата.Вставить("Ошибка", Неопределено);	
	Возврат СтруктураВозврата;
КонецФункции

Функция ПрочитатьФайлЕслиСуществует(Путь, Кодировка)
	
	Результат = Неопределено;
	
	ФайлИнфо = Новый Файл(Путь);
	
	Если ФайлИнфо.Существует() Тогда 
		
		ЧтениеПотокаОшибок = Новый ЧтениеТекста(Путь, Кодировка);
		Результат = ЧтениеПотокаОшибок.Прочитать();
		ЧтениеПотокаОшибок.Закрыть();
		
	КонецЕсли;
	
	Если Результат = Неопределено Тогда 
		Результат = "";
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции 

Процедура ПодготовитьПустуюВетку(ПутьКGit, НастройкаGit, Результат)
	Команда = ПутьКGit + " rm -rf .";
	РезультатКоманды = ВыполнитьКомандуНаСервере(Команда, НастройкаGit.ПутьЛокальногоХранения);
	Если РезультатКоманды.Код <> 0 Тогда
		Результат.Ошибка = "" + РезультатКоманды.Код + " - " + РезультатКоманды.Ошибка;
		Возврат;
	КонецЕсли;
	СимволРазделения = ?(СтрНайти(НастройкаGit.ПутьЛокальногоХранения, "/") > 0, "/", "\");
	Файл = НастройкаGit.ПутьЛокальногоХранения + СимволРазделения + ".empty";
	Запись = Новый ЗаписьТекста(Файл, КодировкаТекста.UTF8, Символы.ПС, Ложь);    
    Запись.ЗаписатьСтроку("");
    Запись.Закрыть(); 
	РезультатКоманды = ИндексироватьФайлы(НастройкаGit);
	Если Не РезультатКоманды.Успешно Тогда
		Результат.Ошибка = "" + РезультатКоманды.Ошибка;
	КонецЕсли;
КонецПроцедуры

#КонецОбласти