-- Жаңа пайдаланушыны тіркеу процедурасы
CREATE OR REPLACE PROCEDURE register_user(
    p_name VARCHAR,
    p_email VARCHAR,
    p_city VARCHAR,
    p_street VARCHAR,
    p_house VARCHAR
) AS $$
BEGIN
    INSERT INTO Users (first_name, email, city, street, house_number)
    VALUES (p_name, p_email, p_city, p_street, p_house);
END;
$$ LANGUAGE plpgsql;

-- Санат бойынша тауар санын есептеу функциясы
CREATE OR REPLACE FUNCTION count_by_category(p_cat_id INT) 
RETURNS INT AS $$
BEGIN
    RETURN (SELECT COUNT(*) FROM Products WHERE category_id = p_cat_id);
END;
$$ LANGUAGE plpgsql;

-- Тауар бағасына пайыздық жеңілдік есептеу функциясы
CREATE OR REPLACE FUNCTION calculate_discount(p_price DECIMAL, p_discount_pct DECIMAL)
RETURNS DECIMAL AS $$
BEGIN
    RETURN p_price - (p_price * p_discount_pct / 100);
END;
$$ LANGUAGE plpgsql;

-- Пайдаланушының тапсырыс сомасына қарай статусын анықтау
CREATE OR REPLACE FUNCTION get_user_status(p_user_id INT)
RETURNS VARCHAR AS $$
DECLARE
    v_total_spent DECIMAL;
BEGIN
    SELECT SUM(quantity * unit_price) INTO v_total_spent
    FROM Order_Items oi
    JOIN Orders o ON oi.order_id = o.order_id
    WHERE o.user_id = p_user_id;

    IF v_total_spent > 1000000 THEN RETURN 'Platinum Client';
    ELSIF v_total_spent > 500000 THEN RETURN 'Gold Client';
    ELSE RETURN 'Silver Client';
    END IF;
END;
$$ LANGUAGE plpgsql;