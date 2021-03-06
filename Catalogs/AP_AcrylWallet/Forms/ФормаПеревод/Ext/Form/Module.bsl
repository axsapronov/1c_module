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

&НаКлиенте
Перем ИндентификаторЗадания, АдресРезультата;

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Отправить(Команда)
	 
	Если НЕ ПроверитьЗаполнение() Тогда 
	
		ПоказатьПредупреждение(, "Заполните обязательные поля!",, "Ошибка");
	
		Возврат;
	
	КонецЕсли;
	
	АдресРезультата = ПоместитьВоВременноеХранилище(Новый Структура, ЭтаФорма.УникальныйИдентификатор);
	
	ИндентификаторЗадания = ВыполнитьОтправкуТранзакции(АдресПолучателя, Сумма, Кошелек, АдресРезультата);
	
	Элементы.грДанныеТранзакции.Видимость = Ложь;
	
	Элементы.ФормаКоманднаяПанель.Видимость = Ложь;
	
	Элементы.грОжидание.Видимость = Истина;
	
	ПодключитьОбработчикОжидания("ОтправкаТранзакцииЗавершение", 5);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаКлиенте
Процедура НомерТраназкцииНажатие(Элемент)
	
	ЗапуститьПриложение(Элементы.НомерТраназкции.Заголовок);	
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
Функция ВыполнитьОтправкуТранзакции(АдресПолучателя, Сумма, Кошелек, АдресРезультата)

    ПараметрыЗадания = Новый Массив;
	
	ПараметрыЗадания.Добавить(АдресПолучателя);
	ПараметрыЗадания.Добавить(Сумма);
	ПараметрыЗадания.Добавить(Кошелек.ПубличныйКлюч);
	ПараметрыЗадания.Добавить(Кошелек.ПриватныйКлюч);
	ПараметрыЗадания.Добавить(АдресРезультата);
	ПараметрыЗадания.Добавить(Кошелек.TestNet);

    
    ФоновоеЗадание = ФоновыеЗадания.Выполнить("AP_TransactionsКлиентСервер.transfer", 
       		 		  ПараметрыЗадания, , "Transfer transactions"); 
					  
	Возврат ФоновоеЗадание.УникальныйИдентификатор;
    
КонецФункции
		 
&НаКлиенте
Процедура ОтправкаТранзакцииЗавершение()
	
	СостояниеЗадания = ОтправкаТранзакцииЗавершениеНаСервере(ИндентификаторЗадания);

	Если СостояниеЗадания <> 0 Тогда 
		
		ОтключитьОбработчикОжидания("ОтправкаТранзакцииЗавершение");
		
		Результат = ПолучитьИзВременногоХранилища(АдресРезультата);
		
		Если Результат.Свойство("КодСостояния") Тогда
		
			Если Результат.КодСостояния = 200 Тогда
				
				Ошибка = Результат.ОтветСервера.Получить("error");
				
				НомерТранзакции = Результат.ОтветСервера.Получить("id");
				
				Если Ошибка <> Неопределено Тогда 
					
					Элементы.Декорация3.Видимость = Ложь;
					Элементы.Декорация4.Видимость = Ложь;
					
					Элементы.ЗаголовокНомерТранзакции.Видимость = Ложь;
					Элементы.НомерТраназкции.Видимость = Ложь;
					
					Элементы.Декорация7.Видимость = Истина;				
					
					Элементы.Декорация8.Видимость = Истина;
					
					Сообщение = Результат.ОтветСервера.Получить("message");
					
					Если Сообщение <> Неопределено Тогда
						
						Элементы.ОшибкаТранзакции.Заголовок = Сообщение;
						
						Элементы.ОшибкаТранзакции.Видимость = Истина;
						
					КонецЕсли;
					
				КонецЕсли;
							
				Если НомерТранзакции <> Неопределено Тогда  
								                                                                              
					Элементы.НомерТраназкции.Заголовок = "https://explorer.acrylplatform.com/tx/" + НомерТранзакции;
					
					Элементы.НомерТраназкции.Видимость = Истина;
					
				КонецЕсли;
					
			КонецЕсли;

		КонецЕсли;
			
		Элементы.грОжидание.Видимость = Ложь;
				
	КонецЕсли;
		
	Если СостояниеЗадания = 1 Тогда 
	
		Элементы.грГотово.Видимость = Истина;			
		
	ИначеЕсли СостояниеЗадания = 2 Тогда
		
		Элементы.грОшибка.Видимость = Истина;		
		Элементы.Декорация6.Заголовок = "Завершено аварийно. Повторите попытку";

	ИначеЕсли СостояниеЗадания = 3 Тогда 
		
		Элементы.грОшибка.Видимость = Истина;		
		Элементы.Декорация6.Заголовок = "Завершено отменено.";
		
	КонецЕсли;
	 
КонецПроцедуры
 
 &НаСервереБезКонтекста
Функция ОтправкаТранзакцииЗавершениеНаСервере(ИндентификаторЗадания)
	
	Состояние = 0;
	
	Отбор = Новый Структура("УникальныйИдентификатор", ИндентификаторЗадания); 
	
	СписокФоновыхЗадач = ФоновыеЗадания.ПолучитьФоновыеЗадания();
	
	Если СписокФоновыхЗадач.Количество() <> 0 Тогда                    
		
		ФоновоеЗадание = СписокФоновыхЗадач[0];
		
	КонецЕсли;

	Если ФоновоеЗадание.Состояние = СостояниеФоновогоЗадания.Завершено Тогда 

		Состояние = 1;
		
	ИначеЕсли ФоновоеЗадание.Состояние = СостояниеФоновогоЗадания.ЗавершеноАварийно Тогда 

		Состояние = 2;
		
	ИначеЕсли ФоновоеЗадание.Состояние = СостояниеФоновогоЗадания.Отменено Тогда 

		Состояние = 3;
		
	КонецЕсли;

	Возврат Состояние;
	 
КонецФункции

#КонецОбласти
