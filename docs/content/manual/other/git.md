﻿---
title: "Библиотека работы с git"
date: 2023-09-27
author: "rusetskiy"
tags: ["Git"]
description: "Работа с библиотекой взаимодействия git и 1С"
---

{{< toc >}}

## Общие сведения и требования к инфраструктуре

Библиотека предназначена для автоматизации работы 1С с системой контроля версий Git. Использование бибилиотеки
предполагает работу с локальными и удалёнными репозиториями посредством последовательного вызова управляющих функций.

Объекты конфигурации, необходимые для работы библиотеки, имеют название, начинающееся с префикса *Git_*. Дополнительно
используются функции для работы с безопасным хранилищем данных, размещённые в модуле *SDS_ОбщегоНазначения*.
В конфигурациях со встроенной БСП (библиотекой стандартных подсистем) допускается замена в вызовах
модуля *SDS_ОбщегоНазначения* на *ОбщегоНазначения*.
Для использования бибилиотеки должны быть выполнены требования:

* На сервере "1С Предриятия" необходимо установить Git;
* На сервере 1С доступны сетевое подключение к удалённому репозиторию и сетевое или локальное подключение к локальному
  каталогу с правом записи для службы "1С Предприятия";
* Ввиду особенностей работы Git функции библиотеки вызываются последовательно в одной очереди для исключения
  одновременного вызова команд для разных репозиториев, или разных веток одного репозитория, или чередования вызовов
  разными пользователями. Рекомендуется реализия архитектуры очереди, в которой каждая команда отдельного набора
  содержит информацию об общем количестве команд в наборе и свой порядковый номер.

## Настройка интеграции с Git и репозитория

Для работы с Git требуется выполнить минимальную первоначальную настройку:

1. Указать полный путь к исполняемому файлу Git (обычно *C:\Program Files\Git\bin\git.exe*) на сервере 1С в меню:
   *Интеграция с Git* &#8594; *Сервис* &#8594; *Путь к исполняемому файлу Git*.
2. Создать настройку репозитория Git в меню: *Интеграция с Git* &#8594; *Git: Настройки репозиториев*.
   Настройка предполагает заполнение данных подключения:
   * *Наименование* - произвольное наименование настройки, например по наименованию репозитория или проекта.
   * *Путь к репозиторию* - сетевой путь к удалённому репозиторию без указания протокола соединения,
        например *github.com/aagorlan/onec-esb-kb.git*. Протокол соединения указывается отдельно.
   * *Протокол соедиенения* - выбор протокола соединения из доступных значений, например *http://*.
   * *Инициализирован* - настройка доступна с момента первого успешного [подключения к репозиторию](#инициализация-репозитория) в случае изменения
        *пути локального хранения*, после изменения пути в карточке флаг необходимо деактивировать для повторной
        инициализации.
   * *Путь локального хранения* - путь к каталогу на сервере 1С или к сетевой папке, например *C:\gitrepo\ourproject*.
        Каталог должен быть доступен для чтения и записи службе 1С-Предприятия.
   * *Способ авторизации* - способ авторизации, доступный для удалённого репозитория. Поддерживаются значения:
    *без пароля*, *по паролю* и *OAuth*. В зависимости от выбранного значения после записи карточки настройки отображаются
    поля ввода данных авторизации. При повторном открытии карточки данные авторизации заменяются на уведомление о том,
    что данные введены. В целях безопасности повторное редактирование данных недоступно, при необходимости изменения
    используется кнопка очистки запомненных данных авторизации.

## Основные функции

### Инициализация репозитория

Используется для выбора репозитория и рабочей ветки. Если на момент вызова удалённый репоизторий не
инициализирован - будет автоматически выполнена команда "git init". Если указанная ветка не создана -
выполняется создание ветки. Завершается выполнение функции переключением на указанную ветку.

>Вызов функции: *Git_ОбщегоНазначения.ИнициализацияПодключенияКРепозиторию(НастройкаGit, ИмяВетки);*
>
>* *НастройкаGit* - элемент справочника "Git_НастройкиРепозиториев";
>* *ИмяВетки* - Строка;
>
>Возвращаемое значение: Булево - результат выполнения;

### Проверка наличия изменений файлов

Используется для проверки наличия изменений файлов в рабочем каталоге локального репозитория. В зависимости от
текущей потребности доступны различные вызовы

Наличие изменений в индексированных файлах:

> Вызов функции: *Git_ОбщегоНазначения.ЕстьИзмененияФайлов(Настройка);*
>
> *НастройкаGit* - элемент справочника "Git_НастройкиРепозиториев";
>
> Возвращаемое значение: Булево - "Истина", если изменения есть, иначе "Ложь";

Наличие изменений всех файлов, включая новые:

> Вызов функции: *Git_ОбщегоНазначения.СтатусФайлов(НастройкаGit, ТолькоПроверитьИзменения);*
>
> * *НастройкаGit* - элемент справочника "Git_НастройкиРепозиториев";
> * *ТолькоПроверитьИзменения* - Булево;
>
> Возвращаемые значения:
>
> * Булево, если в параметре "ТолькоПроверитьИзменения" передано значение "Истина" - признак наличия изменений в
> индексированных файлах;
> * Структура, если в параметре "ТолькоПроверитьИзменения" передано значение "Ложь".
> Содержит ключи "Новые", "Измененные" и "Удаленные", выбор которых возвращает соответствующие
> массивы имён файлов.

### Индексирование файлов

Индексирует файлы в рабочем каталоге локального репозитория.

>Вызов функции: *Git_ОбщегоНазначения.ИндексироватьФайлы(Настройка);*
>
>*НастройкаGit* - элемент справочника "Git_НастройкиРепозиториев";
>
>Возвращаемое значение: Булево - результат выполнения;

### Создание коммита

Собирает коммит для указанной ветки из проиндексированных файлов с переданным сообщением и отправляет изменения в
удалённый репозиторий.

>Вызов функции: *Git_ОбщегоНазначения.СоздатьОтправитьКоммит(НастройкаGit, СообщениеКоммита);*
>
>* *НастройкаGit* - элемент справочника "Git_НастройкиРепозиториев";
>* *СообщениеКоммита* - Строка;
>
>Возвращаемое значение: Булево - результат выполнения;

### Перебазирование

Перебазирует ветку на указанный базовый коммит или ветку и отправляет изменения в удалённый репозиторий.

>Вызов функции: *Git_ОбщегоНазначения.Перебазировать(НастройкаGit, ИмяВетки, НоваяБаза);*
>
>* *НастройкаGit* - элемент справочника "Git_НастройкиРепозиториев";
>* *ИмяВетки* - Строка;
>* *НоваяБаза* - Строка - Имя новой базовой ветки или хэш нового базового коммита;
>
>Возвращаемое значение: Структура, содержащая значения с ключами:
>
>* *Результат* - Число:
>   * 0 - если выполнение команды завершилось успешно;
>   * 1 - если возник конфликт перебазирования, запрос *rebase* в этом случае автоматически отменяется;
>   * 2 - если команда вернула ошибку выполнения;
>* Сообщение - Строка - текст ответа или ошибки команды

### Слияние

Вливает ветку в целевую и отправляет изменения в удалённый репозиторий.

>Вызов функции: *Git_ОбщегоНазначения.СлитьВетки(НастройкаGit, ИмяЦелевойВетки, ИмяВливаемойВетки);*
>
>* *НастройкаGit* - элемент справочника "Git_НастройкиРепозиториев";
>* *ИмяЦелевойВетки* - Строка;
>* *ИмяВливаемойВетки* - Строка;
>
>Возвращаемое значение: Структура, содержащая значения с ключами:
>
>* *Результат* - Число:
>   * 0 - если выполнение команды завершилось успешно;
>   * 1 - если возник конфликт слияния, запрос *merge* в этом случае автоматически отменяется;
>   * 2 - если команда вернула ошибку выполнения;
>* Сообщение - Строка - текст ответа или ошибки команды

### Удаление ветки

Удаляет ветку в локальном или удалённом репозитории. При удалении в обоих репозиториях запускается сначала для
удаленного.

>Вызов функции: *Git_ОбщегоНазначения.УдалитьВетку(НастройкаGit, ИмяВетки, ВУдаленномРепозитории);*
>
>* *НастройкаGit* - элемент справочника "Git_НастройкиРепозиториев";
>* *ИмяВетки* - Строка;
>* *ВУдаленномРепозитории* - Булево - Если передано значение "Истина", будет удалена ветка в удалённом репозитории,
>иначе в локальном;
>
>Возвращаемое значение: Булево - результат выполнения;

## Информационные и управляющие функций Git

### Получение имени текущей ветки

Возвращает название текущей ветки в локальном репозитории.

>Вызов функции: *Git_ОбщегоНазначения.ПолучитьИмяТекущейВетки(Настройка);*
>
>*НастройкаGit* - элемент справочника "Git_НастройкиРепозиториев";
>
>Возвращаемое значение: Строка;

### Получение индекса текущего коммита

Возвращает индекс текущего коммита в локальном репозитории.

>Вызов функции: *Git_ОбщегоНазначения.ПолучитьИндексТекущегоКоммита(Настройка);*
>
>*НастройкаGit* - элемент справочника "Git_НастройкиРепозиториев";
>
>Возвращаемое значение: Строка;

### Переключение на ветку (без создания в случае отсутствия) или коммит

Переключает на указанные ветку или коммит.

>Вызов функции: *Git_ОбщегоНазначения.ПереключитьсяНаВеткуКоммит(НастройкаGit, ИмяВеткиИдКоммита);*
>
>* *НастройкаGit* - элемент справочника "Git_НастройкиРепозиториев";
>* *ИмяВеткиИдКоммита* - Строка - имя ветки или хэш коммита;
>
>Возвращаемое значение: Булево - результат выполнения;

### Получение данных из удалённого репозитория

Выполняет команду Git *Pull*.

>Вызов функции: *Git_ОбщегоНазначения.ПолучитьИзУдаленногоРепозитория(Настройка);*
>
>*НастройкаGit* - элемент справочника "Git_НастройкиРепозиториев";
>
>Возвращаемое значение: Структура, содержащая значения с ключами:
>
>* *Результат* - Число:
>   * 0 - если выполнение команды завершилось успешно;
>   * 1 - если возник конфликт;
>   * 2 - если команда вернула ошибку выполнения;
>* Сообщение - Строка - текст ответа или ошибки команды

### Отправка данных в удалённый репозиторий

Выполняет команду Git *Push*. Если переданы *ПараметрыКоманды*, запускает команду с их использованием.

>Вызов функции: *Git_ОбщегоНазначения.ОтправитьВУдаленныйРепозиторий(НастройкаGit, ПараметрыКоманды);*
>
>* *НастройкаGit* - элемент справочника "Git_НастройкиРепозиториев";
>* *Параметры команды* - Строка - параметры команды Git.
>
>Возвращаемое значение: Структура, содержащая значения с ключами:
>
>* *Результат* - Число:
>   * 0 - если выполнение команды завершилось успешно;
>   * 1 - если возник конфликт;
>   * 2 - если команда вернула ошибку выполнения;
>* Сообщение - Строка - текст ответа или ошибки команды