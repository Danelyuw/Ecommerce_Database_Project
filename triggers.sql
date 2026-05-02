-- 1. Баға өзгергенде лог сақтау триггері
CREATE OR REPLACE FUNCTION log_product_price_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.price <> NEW.price THEN
        INSERT INTO price_logs (product_id, old_price, new_price)
        VALUES (OLD.product_id, OLD.price, NEW.price);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_price_logger
AFTER UPDATE ON Products
FOR EACH ROW
EXECUTE FUNCTION log_product_price_change();

-- 2. Тапсырыс бергенде қоймадағы тауар санын тексеру
CREATE OR REPLACE FUNCTION check_stock_before_order()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT stock_quantity FROM Products WHERE product_id = NEW.product_id) < NEW.quantity THEN
        RAISE EXCEPTION 'Қоймада тауар жеткіліксіз!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_stock
BEFORE INSERT ON Order_Items
FOR EACH ROW
EXECUTE FUNCTION check_stock_before_order();

-- 3. DDL (кесте құрылымы) өзгергенде хабарлама беру
CREATE OR REPLACE FUNCTION notify_ddl_change()
RETURNS event_trigger AS $$
BEGIN
    RAISE NOTICE 'Деректер қорының құрылымына өзгеріс енгізілді: %', tg_tag;
END;
$$ LANGUAGE plpgsql;

CREATE EVENT TRIGGER trg_ddl_audit
ON ddl_command_start
EXECUTE FUNCTION notify_ddl_change();