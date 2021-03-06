﻿///////////////////////////////////////////////////////////////////////////////////
//
// MIT License Copyright (c) 2020 AcrylPlatform.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights 
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
// copies of the Software, and to permit persons to whom the Software 
// is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be 
// included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT 
// SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE 
// OR OTHER DEALINGS IN THE SOFTWARE.
//
///////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
// Функция - Получить текущий баланс acryl
//
// Параметры:
//  Кошелек	 - СправочникСсылка.AP_AcrylWallet - Кошелек для которого получаем баланс в Acryl
// 
// Возвращаемое значение:
// Число  - Баланс в Acryl
//
Функция ПолучитьТекущийБалансAcryl(Кошелек)
	
	Если Кошелек.TestNet Тогда
		
		ApiUrl = "nodestestnet.acrylplatform.com";
		
	Иначе
		
		ApiUrl = "nodes.acrylplatform.com";
		
	КонецЕсли;
		
	
	
	HTTPСоедение = AP_HTTPКлиентСервер.ПолучитьHTTPСоеденение(ApiUrl, Истина);

	Ответ = AP_HTTPКлиентСервер.ВызватьHTTPМетод("GET", HTTPСоедение, "/addresses/balance/" + Кошелек + "/0");
	
	Если Ответ.КодСостояния = 200 Тогда
		
		ТекущийБаланс = Ответ.ОтветСервера.Получить("balance");
		
		Если ТекущийБаланс <> Неопределено Тогда
			
			Возврат ТекущийБаланс / 100000000;
			
		Иначе
			
			ЗаписьЖурналаРегистрации("ПолучитьТекущийБалансAcryl", УровеньЖурналаРегистрации.Ошибка, , Кошелек,
			"Не удалось получить текущий баланс. Поле ""balance"" отсутствует в ответе от сервера. Проверьте API AcrylPlatform");
			
			Возврат Неопределено;
			
		КонецЕсли;
		
	Иначе 
		
		ЗаписьЖурналаРегистрации("ПолучитьТекущийБалансAcryl", УровеньЖурналаРегистрации.Ошибка, , Кошелек,
		"Не удалось получить текущий баланс. Код ответа от сервера: "
		+ Ответ.КодСостояния +". Проверьте API AcrylPlatform");
		
		Возврат Неопределено;

		
	КонецЕсли;
	
КонецФункции

&НаСервере
// Функция - Получить список транзакций
//
// Параметры:
//  Кошелек	 - СправочникСсылка.AP_AcrylWallet - Кошелек для которого получаем баланс в Acryl
// 
// Возвращаемое значение:
// Число  - Список транзакций
//
Функция ПолучитьСписокТранзакций(Кошелек)
	
	Если Кошелек.TestNet Тогда
		
		ApiUrl = "nodestestnet.acrylplatform.com";
		
	Иначе
		
		ApiUrl = "nodes.acrylplatform.com";
		
	КонецЕсли;

	Транзакции.Очистить();
	
	HTTPСоедение = AP_HTTPКлиентСервер.ПолучитьHTTPСоеденение(ApiUrl, Истина);

	Ответ = AP_HTTPКлиентСервер.ВызватьHTTPМетод("GET", HTTPСоедение, 
		"/transactions/address/" + Кошелек + "/limit/10000");
	
	Если Ответ.КодСостояния <> 200 Тогда
			
				
		ЗаписьЖурналаРегистрации("ПолучитьДанныеПоТранзакциям", УровеньЖурналаРегистрации.Ошибка, , Кошелек, 
		"Не удалось получить данные по первой транзакции. Код ответа от сервера: " 
		+ Ответ.КодСостояния + ". Проверьте API AcrylPlatform");
		
		Возврат Неопределено;
	
	КонецЕсли;	

		
	Если ТипЗнч(Ответ.ОтветСервера) <> ТипЗнч(Новый Массив) Тогда
		
			
		ЗаписьЖурналаРегистрации("ПолучитьДанныеПоТранзакциям", УровеньЖурналаРегистрации.Ошибка, , Кошелек, 
		"Не удалось получить данные по первой транзакции. Код ответа от сервера: " 
		+ Ответ.КодСостояния + ". Проверьте API AcrylPlatform");
		
		Возврат Неопределено;
	
	КонецЕсли;	

			
	Если Ответ.ОтветСервера.Количество() = 0  Тогда
		
		Возврат Неопределено;    
				
	КонецЕсли;

			
	СписокТранзакций =  Ответ.ОтветСервера[0];
	
	Если СписокТранзакций.Количество() = 0 Тогда
		
		Возврат Неопределено;
		
	КонецЕсли;
		
	TransferTransactions = 4;
	DataTransactions = 12;
	
	Для Каждого Транзакция Из СписокТранзакций Цикл 
		
		НоваяТранзакция = Транзакции.Добавить();
		
		Если DataTransactions = Транзакция.Получить("type") Тогда 
			
			НоваяТранзакция.ТипТранзакции = "Транзакция записи данных";
			
		ИначеЕсли TransferTransactions = Транзакция.Получить("type") Тогда
			
			Если Транзакция.Получить("sender") = Строка(Кошелек) Тогда 
				
				НоваяТранзакция.ТипТранзакции = "Транзакция перевода средств";
				НоваяТранзакция.Адрес = " на адрес " + Транзакция.Получить("recipient");
				
			Иначе
				
				НоваяТранзакция.ТипТранзакции = "Транзакция получения средств";	
				НоваяТранзакция.Адрес = " с адреса " + Транзакция.Получить("sender");
				
			КонецЕсли;
			
			НоваяТранзакция.Сумма = Транзакция.Получить("amount") / 100000000;
			
		КонецЕсли;
		
		ПредставленеЧасовогоПояса = ПредставлениеЧасовогоПояса(ЧасовойПоясСеанса());
		
		Смещение = СтрЗаменить(ПредставленеЧасовогоПояса, "GMT+", "");
		Смещение = СтрЗаменить(Смещение, ":00", "");
		
		Смещение = Смещение * 60 *60;
		
		
		НоваяТранзакция.Дата = Дата("19700101") 
								+ Окр(Транзакция.Получить("timestamp") / 1000) + Смещение;
								

		НоваяТранзакция.Номер = Транзакция.Получить("id");
								
	КонецЦикла;              
	
КонецФункции

&НаКлиенте
Процедура ОбновитьТекущийБаланс()
	
	Если ЗначениеЗаполнено(Кошелек) Тогда 
		
		ТекущийБаланс = ПолучитьТекущийБалансAcryl(Кошелек);
		
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Обновить(Команда)
	
	ОбновитьТекущийБаланс();
	
	ПолучитьСписокТранзакций(Кошелек);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаКлиенте
Процедура КошелекПриИзменении(Элемент)
	
	ОбновитьТекущийБаланс();
	
	ПолучитьСписокТранзакций(Кошелек);
		
КонецПроцедуры

&НаКлиенте
Процедура ТекущийБалансНажатие(Элемент, СтандартнаяОбработка)
	
	ОбновитьТекущийБаланс();

КонецПроцедуры

&НаКлиенте
Процедура ТранзакцииВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;	
	
	Если Поле.Имя = "ТранзакцииНомер" Тогда 
		
		Номер = Транзакции[ВыбраннаяСтрока].Номер;
		
		Если ЗначениеЗаполнено(Номер) Тогда 
			
			ЗапуститьПриложение("https://explorer.acrylplatform.com/tx/" + Номер);
			
		КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
