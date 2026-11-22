SELECT COUNT(*) FROM cars_raw;
SELECT TOP 10 * FROM cars_raw;

SELECT fuel_type, COUNT(*) AS zero_tank
FROM cars_raw
WHERE fuel_tank_capacity = 0
GROUP BY fuel_type;

SELECT car_name, COUNT(*) AS cnt
FROM cars_raw
GROUP BY car_name
HAVING COUNT(*) > 1;

SELECT fuel_type, COUNT(*) AS zero_rpm
FROM cars_raw
WHERE max_torque_rpm = 0 OR max_power_rp = 0
GROUP BY fuel_type;

SELECT
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS car_id,
    car_name,
    reviews_count,
    fuel_type,
    engine_displacement,
    no_cylinder,
    seating_capacity,
    transmission_type,
    CASE WHEN fuel_type <> 'Electric' AND fuel_tank_capacity = 0
         THEN NULL ELSE fuel_tank_capacity END AS fuel_tank_capacity,
    body_type,
    rating,
    starting_price,
    ending_price,
    max_torque_nm,
    CASE WHEN fuel_type <> 'Electric' AND max_torque_rpm = 0
         THEN NULL ELSE max_torque_rpm END AS max_torque_rpm,
    max_power_bhp,
    CASE WHEN fuel_type <> 'Electric' AND max_power_rp = 0
         THEN NULL ELSE max_power_rp END AS max_power_rp,
    CASE WHEN car_name IN (
            SELECT car_name FROM cars_raw
            GROUP BY car_name HAVING COUNT(*) > 1)
         THEN 1 ELSE 0 END AS is_duplicate_name
INTO cars_clean
FROM cars_raw;

SELECT COUNT(*) FROM cars_clean;

SELECT fuel_type, COUNT(*) AS null_tank
FROM cars_clean WHERE fuel_tank_capacity IS NULL
GROUP BY fuel_type;

SELECT COUNT(*) AS null_rpm
FROM cars_clean WHERE max_torque_rpm IS NULL OR max_power_rp IS NULL;

SELECT car_id, car_name, fuel_type, starting_price, ending_price, reviews_count
FROM cars_clean
WHERE is_duplicate_name = 1
ORDER BY car_name, reviews_count DESC;

ALTER TABLE cars_clean
ADD is_suspect_price BIT NOT NULL DEFAULT 0,
    price_note NVARCHAR(100) NULL;

    UPDATE cars_clean
SET is_suspect_price = 1,
    price_note = 'Price inconsistent with duplicate row'
WHERE car_id IN (200, 187, 195, 192, 193);

SELECT car_id, car_name, starting_price, is_suspect_price
FROM cars_clean
WHERE is_suspect_price = 1;

SELECT body_type, COUNT(*) AS cnt
FROM cars_clean
GROUP BY body_type
ORDER BY cnt DESC;

ALTER TABLE cars_clean
ADD body_type_clean NVARCHAR(50) NULL;

UPDATE cars_clean
SET body_type_clean = CASE body_type
    WHEN 'Minivan' THEN 'MUV'
    WHEN 'Hybrid'  THEN 'SUV'
    WHEN 'Luxury'  THEN 'Other'
    ELSE body_type
END;ٌٌٌ

SELECT body_type_clean, COUNT(*) AS cnt
FROM cars_clean
GROUP BY body_type_clean
ORDER BY cnt DESC;

UPDATE cars_clean
SET is_suspect_price = 1,
    price_note = 'Price outlier within Pickup Truck category'
WHERE car_name = 'Mahindra Bolero PikUp ExtraLong';

SELECT COUNT(*) AS suspect_rows
FROM cars_clean
WHERE is_suspect_price = 1;

ALTER TABLE cars_clean
ADD price_segment NVARCHAR(20) NULL,
    power_segment NVARCHAR(20) NULL;

    UPDATE cars_clean
SET price_segment = CASE
        WHEN starting_price < 1000000  THEN 'Budget'
        WHEN starting_price < 2500000  THEN 'Mid'
        WHEN starting_price < 10000000 THEN 'Premium'
        ELSE 'Luxury' END,
    power_segment = CASE
        WHEN max_power_bhp < 100 THEN 'Low'
        WHEN max_power_bhp < 200 THEN 'Moderate'
        WHEN max_power_bhp < 400 THEN 'High'
        ELSE 'Extreme' END;

        SELECT price_segment, power_segment, COUNT(*) AS cnt
FROM cars_clean
GROUP BY price_segment, power_segment
ORDER BY price_segment, power_segment;

ALTER TABLE cars_clean
ADD brand NVARCHAR(50) NULL;

UPDATE cars_clean
SET brand = CASE
    WHEN car_name LIKE 'Land Rover%'   THEN 'Land Rover'
    WHEN car_name LIKE 'Aston Martin%' THEN 'Aston Martin'
    WHEN car_name LIKE 'Rolls%'        THEN 'Rolls-Royce'
    WHEN car_name LIKE 'Strom Motors%' THEN 'Strom Motors'
    WHEN car_name LIKE 'Compass%'      THEN 'Jeep'
    WHEN car_name LIKE 'Mclaren%'      THEN 'McLaren'
    ELSE LEFT(car_name, CHARINDEX(' ', car_name + ' ') - 1)
END;

SELECT brand, COUNT(*) AS cnt
FROM cars_clean
GROUP BY brand
ORDER BY cnt DESC;

UPDATE cars_clean
SET is_suspect_price = 1,
    price_note = 'Price outlier within Hatchback category'
WHERE car_name = 'Strom Motors R3';

SELECT COUNT(*) FROM cars_clean WHERE is_suspect_price = 1;


CREATE VIEW vw_CarAnalysis AS
SELECT
    car_id,
    brand,
    car_name,
    body_type_clean AS body_type,
    fuel_type,
    transmission_type,
    seating_capacity,
    engine_displacement,
    no_cylinder,
    fuel_tank_capacity,
    max_power_bhp,
    max_power_rp,
    max_torque_nm,
    max_torque_rpm,
    starting_price,
    ending_price,
    (CAST(starting_price AS BIGINT) + ending_price) / 2 AS avg_price,
    rating,
    reviews_count,
    CASE WHEN reviews_count < 10 THEN 'Low' ELSE 'OK' END AS rating_confidence,
    price_segment,
    power_segment,
    is_suspect_price,
    price_note
FROM cars_clean;

SELECT COUNT(*) FROM vw_CarAnalysis;
SELECT TOP 5 * FROM vw_CarAnalysis;

-- Flag 3 more suspect prices found during Q2 review
UPDATE cars_clean
SET is_suspect_price = 1,
    price_note = 'Price outlier found during value analysis'
WHERE car_name IN ('Maruti Swift Dzire Tour',
                   'Hyundai Xcent Prime',
                   'Honda City Hybrid');

                   SELECT COUNT(*) FROM cars_clean WHERE is_suspect_price = 1;

