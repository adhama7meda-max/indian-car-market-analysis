SELECT car_id, brand, car_name, fuel_type, body_type,
       price_segment, max_power_bhp, avg_price
FROM vw_CarAnalysis
WHERE is_suspect_price = 0;