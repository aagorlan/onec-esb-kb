﻿#Область ОбработчикиСобытий

Процедура ПриНачалеРаботыСистемы()
	
	//Обновление конфигурации
	ВыполненоОбновление = ОКВызовСервера.ВыполнитьОбновлениеДанных();
	Если Не ВыполненоОбновление Тогда
		ПоказатьПредупреждение(, "Внимание, выполнены не все обработчики обновления!
			|Дополнительная информация в журнале регистрации.");
	КонецЕсли;               
	//Конец Обновление конфигурации
	
КонецПроцедуры

#КонецОбласти
