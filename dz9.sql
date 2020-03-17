-- В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных.
-- Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.

truncate table sample.users; # очищаем таблицу sample.users
select * from sample.users; # убеждаемся в пустоте таблицы sample.users

start transaction; # начинаем транзакцию
insert into sample.users select * from shop.users where id = 1; #вставляем в таблицу sample.users первую строку shop.users
select * from sample.users; # проверяем что данные перенесены

rollback; # отменяем осуществление транзакции
select * from sample.users; # проверяем корректно ли отработана отмета транзакции.
-- Создайте представление, которое выводит название name товарной позиции из таблицы products и
-- соответствующее название каталога name из таблицы catalogs.

use shop; # выбираем базу данных
drop view if exists view_of_prod;
create view view_of_prod as # создаем представление ....
select products.name 'Продукт', catalogs.name 'Каталог' # ... из нашей сджоенной таблицы
from products
left join catalogs
on products.catalog_id = catalogs.id
order by catalogs.name, products.name;

select * from view_of_prod; # выводим на экран содержимое представления
-- Создайте хранимую функцию hello(), которая будет возвращать приветствие,
-- в зависимости от текущего времени суток.
-- С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро",
-- с 12:00 до 18:00 функция должна возвращать фразу "Добрый день",
-- с 18:00 до 00:00 — "Добрый вечер",
-- с 00:00 до 6:00 — "Доброй ночи".

delimiter //
drop function if exists hello//

create function hello(time_ TIME)
returns varchar(15) deterministic
begin
    declare word varchar(15);
    if (time_ >= '06:00:00' and time_ <'12:00:00') then set word = 'Доброе утро!';
    elseif (time_ >= '12:00:00' and time_ <'18:00:00') then set word = 'Добрый день!';
    elseif (time_ >= '18:00:00' and time_ <='23:59:59') then set word = 'Добрый вечер!';
    else set word = 'Доброй ночи!';
    end if;
return word;
end//

select hello('07:09:56')// # доброе утро!
select hello('4:00:00')// # доброй ночи!
select hello('12:00:00')// # добрый день!
select hello('19:30:00')// # добрый вечер
select hello('17:59:59')// # добрый день!
delimiter ;
-- В таблице products есть два текстовых поля: name с названием товара
-- и description с его описанием. Допустимо присутствие обоих полей или одно из них.
-- Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема.
-- Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены.
-- При попытке присвоить полям NULL-значение необходимо отменить операцию.

delimiter //
use shop//
# триггер на создание записи
drop trigger if exists not_null_create//
create trigger not_null_create before insert on products
for each row
begin
    declare name_def varchar(255) default 'name';
    declare descrip varchar(255) default 'description';
    set new.name = coalesce (new.name, name_def);
    set new.description = coalesce (new.description, descrip);
end//

# триггер на обновление записи
drop trigger if exists not_null_update//
create trigger not_null_update before update on products
for each row
begin
    declare name_def varchar(255) default 'name';
    declare descrip varchar(255) default 'description';
    set new.name = coalesce (new.name, old.name, name_def);
    set new.description = coalesce (new.description, old.description, descrip);
end//
delimiter ;