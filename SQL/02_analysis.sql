-- Question 1:
-- How many cars are there for each fuel type,
-- and what is the average price and power of each type?

SELECT fuel_type,
       COUNT(*) AS cars,
       AVG(avg_price) AS avg_price,
       ROUND(AVG(max_power_bhp), 0) AS avg_bhp
FROM vw_CarAnalysis
WHERE is_suspect_price = 0
GROUP BY fuel_type
ORDER BY cars DESC;

--Conclusion:Petrol dominates the dataset (~62%). Diesel and CNG cluster in the budget-to-mid segment, while the electric cars in this dataset skew premium, with an average price close to petrol and higher average power than diesel.


-- Question 2:
-- Which brands give the best value for money?
-- Measured as average price per horsepower (lower = better value).
-- Only brands with 3+ cars are included to avoid misleading results.

SELECT brand,
       COUNT(*) AS cars,
       ROUND(AVG(avg_price * 1.0 / max_power_bhp), 0) AS price_per_bhp
FROM vw_CarAnalysis
WHERE is_suspect_price = 0
GROUP BY brand
HAVING COUNT(*) >= 3
ORDER BY price_per_bhp;

--Conclusion Mass-market brands (Datsun, Tata, Renault, Maruti) deliver the most power per rupee, while ultra-luxury brands such as Rolls-Royce cost ~14x more per horsepower. Interestingly, supercar brands (Ferrari, Lamborghini) offer better power-per-price than some luxury brands like Jaguar and Bentley.


-- Question 3:
-- Within each price segment, how do electric cars compare
-- with petrol, diesel and CNG cars in power and value for money?

SELECT price_segment,
       fuel_type,
       COUNT(*) AS cars,
       ROUND(AVG(max_power_bhp), 0) AS avg_bhp,
       ROUND(AVG(avg_price * 1.0 / max_power_bhp), 0) AS price_per_bhp
FROM vw_CarAnalysis
WHERE is_suspect_price = 0
GROUP BY price_segment, fuel_type
ORDER BY
    CASE price_segment
        WHEN 'Budget'  THEN 1
        WHEN 'Mid'     THEN 2
        WHEN 'Premium' THEN 3
        ELSE 4 END,
    fuel_type;

    -- Finding: Electric cars are not consistently more expensive per horsepower.
-- They cost more than petrol in the Budget and Mid segments, but offer
-- the best value in the Premium segment (21,849 vs 25,907 for petrol)
-- while also delivering higher average power (309 vs 297 bhp).
-- In the Luxury segment, petrol regains the lead in both power and value.
-- Caveat: electric samples in Budget and Mid are only 2 cars each.


-- Question 4:
-- Which brands have the highest customer ratings?
-- Rating is weighted by number of reviews, and cars with fewer
-- than 10 reviews are excluded because their ratings are unreliable.

SELECT brand,
       COUNT(*) AS cars,
       SUM(reviews_count) AS total_reviews,
       ROUND(SUM(rating * reviews_count) / SUM(reviews_count), 2) AS weighted_rating
FROM vw_CarAnalysis
WHERE is_suspect_price = 0
  AND rating_confidence = 'OK'
GROUP BY brand
HAVING COUNT(*) >= 3
ORDER BY weighted_rating DESC, total_reviews DESC;

-- Finding: Customer ratings barely differentiate between brands.
-- 14 of 19 brands share the exact same weighted rating of 4.5,
-- and the full range is only 4.24 to 4.58.
-- BMW ranks first (4.58), but on a small base of 195 reviews across 8 cars.
-- Tata (4,949 reviews) and Mahindra (3,896 reviews) hold the largest review
-- volumes with a solid 4.5. MG (4.24) and Hyundai (4.28) rank lowest.
-- Caveat: ratings appear rounded to 0.5 steps, so small differences
-- should not be over-interpreted. Cars with fewer than 10 reviews and
-- brands with fewer than 3 qualifying cars were excluded.


-- Question 5:
-- Is there a relationship between price segment and customer rating?
-- Same method as Q4: weighted by reviews, cars with < 10 reviews excluded.

SELECT price_segment,
       COUNT(*) AS cars,
       SUM(reviews_count) AS total_reviews,
       ROUND(SUM(rating * reviews_count) / SUM(reviews_count), 2) AS weighted_rating
FROM vw_CarAnalysis
WHERE is_suspect_price = 0
  AND rating_confidence = 'OK'
GROUP BY price_segment
ORDER BY
    CASE price_segment
        WHEN 'Budget'  THEN 1
        WHEN 'Mid'     THEN 2
        WHEN 'Premium' THEN 3
        ELSE 4 END;

        -- Finding: Ratings rise slightly with price, from 4.43 (Budget)
-- to 4.55 (Luxury), but the gap is only 0.12 points.
-- Review volume drops sharply as price increases:
-- 14,630 reviews for Budget vs only 303 for Luxury.
-- Conclusion: price has at most a weak relationship with customer rating.
-- Caveat: the Luxury rating is based on far fewer reviews,
-- so it is the least reliable of the four figures.


-- Question 6:
-- How is transmission type distributed across price segments?
-- Shows the share of each transmission type within every segment.

SELECT price_segment,
       transmission_type,
       COUNT(*) AS cars,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY price_segment), 1) AS pct_of_segment
FROM vw_CarAnalysis
WHERE is_suspect_price = 0
GROUP BY price_segment, transmission_type
ORDER BY
    CASE price_segment
        WHEN 'Budget'  THEN 1
        WHEN 'Mid'     THEN 2
        WHEN 'Premium' THEN 3
        ELSE 4 END,
    cars DESC;

    -- Finding: Manual transmission fades out as price rises.
-- Manual share: 30.8% (Budget) -> 23.1% (Mid) -> 4.7% (Premium) -> 0% (Luxury).
-- Automatic share rises from 65.4% (Budget) to 90.2% (Luxury),
-- and no Luxury car in the dataset has a manual gearbox.
-- Caveat: the data labels all non-manual conventional gearboxes as "Automatic"
-- and does not separate sub-types (AMT, CVT, DCT).
-- Also, 13 cars are labeled "Electric" in transmission_type versus 15 electric
-- fuel-type cars in this filtered set, so the two columns are not fully consistent.


