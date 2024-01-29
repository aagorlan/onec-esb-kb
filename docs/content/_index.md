---
title: "Начало"
---
[![Статус порога качества](https://sonar.openbsl.ru/api/project_badges/measure?project=onec-esb-kb&metric=alert_status)](https://sonar.openbsl.ru/dashboard?id=onec-esb-kb)
[![Рейтинг сопровождаемости](https://sonar.openbsl.ru/api/project_badges/measure?project=onec-esb-kb&metric=sqale_rating)](https://sonar.openbsl.ru/dashboard?id=onec-esb-kb)
[![Рейтинг надежности](https://sonar.openbsl.ru/api/project_badges/measure?project=onec-esb-kb&metric=reliability_rating)](https://sonar.openbsl.ru/dashboard?id=onec-esb-kb)
[![Рейтинг безопасности](https://sonar.openbsl.ru/api/project_badges/measure?project=onec-esb-kb&metric=security_rating)](https://sonar.openbsl.ru/dashboard?id=onec-esb-kb)
[![Технический долг](https://sonar.openbsl.ru/api/project_badges/measure?project=onec-esb-kb&metric=sqale_index)](https://sonar.openbsl.ru/dashboard?id=onec-esb-kb)
# Краткое описание

Единая система классификации, передачи и хранения данных (ЕСД). Совмещает в себе несколько решений:

- ОМД: Онтологическая модель данных (классы, триплеты и правила верификации)
- БЗ: База знаний (хранение, извлечение, версионирование и управление данными)
- ШД: Шина данных (верификация, маршрутизация и преобразование данных)

## Онтологическая модель данных

Единая модель данных для хранения в БЗ и для передачи через ШД. Модель разрабатывается в ЕСД, хранится во внешнем репозитории и может быть интерпретирована в схему XDTO (для формирования пакетов передачи данных) или структуру базы данных.

## База знаний

Хранение данных в соответствии с заданной ОМД. Возможность получать информацию об отдельных объектах, связях между объектами или выполнение сложных запросов для получения объектов и цепочек связей.

## Шина данных

Передача пакетов данных между системами в соответствии со структурой ОДМ и схемой маршрутизации и преобразования данных. Работа параллельно в нескольких контурах (рабочий, тестовый предрелизный).
