# Indian Car Market Analysis

**What drives car prices in the Indian market, and where is the best value for money?**

An end-to-end data analysis project: a raw car dataset was audited and cleaned in **SQL Server**, explored with seven analytical questions, tested statistically in **Python**, and presented in an interactive **Power BI** dashboard.

![Cover](images/01_cover.png)

## Tools

| Tool | Used for |
|---|---|
| SQL Server (SSMS) | Import, data quality audit, cleaning, feature engineering, analysis queries |
| Python (pandas, matplotlib) | Correlation test between horsepower and price |
| Power BI | Interactive dashboard with custom theme and slicers |

## Dataset

- `CARS_1.csv`: 203 cars, 16 columns (fuel type, engine, cylinders, power, torque, transmission, body type, seating, tank capacity, rating, reviews count, starting and ending price).
- All prices are in Indian Rupees (INR).

## Project structure

```
cars_project/
├── SQL        01_cleaning.sql, 02_analysis.sql, 03_export_for_python.sql
├── data       CARS_1.csv, cars_for_python.csv
├── python     07_power_vs_price.ipynb
├── powerbi    cars_dashboard.pbix, CarsTheme.json
└── images     dashboard screenshots
```

## Workflow

1. **Import**: loaded the CSV into `cars_raw` and set proper numeric data types. The raw table is never modified.
2. **Audit**: checked zeros, duplicates, inconsistent categories and outliers.
3. **Clean**: built `cars_clean` and the view `vw_CarAnalysis` (the only source Power BI reads).
4. **Analyse**: seven questions answered with SQL and Python.
5. **Visualise**: Power BI dashboard on the cleaned view.

## Data quality findings

| Issue | What I found | Decision |
|---|---|---|
| Zero tank capacity | 44 rows: 16 electric (expected) and 28 petrol/diesel (missing data) | Electric kept as 0, the 28 set to `NULL` |
| Zero RPM values | 6 non-electric cars (Volvo XC90, XC40, S90, S60, McLaren GT, Maserati GranCabrio) | Set to `NULL`, electric zeros kept |
| Missing seating | McLaren GT | Left as `NULL` |
| Inconsistent body types | Minivan, Hybrid and Luxury are not consistent body shapes | New column `body_type_clean`: Minivan to MUV, Hybrid to SUV, Luxury to Other |
| Suspect prices | 10 rows with prices inconsistent with the rest of their model or category | Flagged with `is_suspect_price = 1`, **not deleted**, excluded from analysis (193 cars remain) |
| Transmission vs fuel type | "Electric" appears 15 times in `fuel_type` but 13 times in `transmission_type` after filtering | Documented, not changed |

**Flagged prices:** BMW 3 Series Gran Limousine, Mahindra Bolero Neo, Porsche Cayenne Coupe, Toyota Glanza (2 rows), Mahindra Bolero PikUp ExtraLong, Strom Motors R3, Maruti Swift Dzire Tour, Hyundai Xcent Prime, Honda City Hybrid.
Flagging was based on internal consistency (duplicate model names with very different prices, and extreme outliers within the same brand or body type). It was not verified against an external source. Three of these were found only after reviewing the results of the price-per-horsepower analysis.

**Engineered columns:** `car_id`, `brand`, `body_type_clean`, `avg_price`, `price_segment` (Budget under 1M, Mid under 2.5M, Premium under 10M, Luxury 10M and above), `power_segment`, `rating_confidence` (Low when fewer than 10 reviews), `is_suspect_price`, `price_note`.

## Key findings

All findings use the 193 cars left after excluding suspect prices.

1. **Market mix:** petrol dominates with about 62% of cars (120), then diesel 27% (53), electric 8% (15) and CNG 3% (5).
2. **Best value:** mass-market brands give the most power per rupee (Datsun about 7.0K INR per BHP, Tata 8.8K, Renault 8.8K, Maruti 9.4K). Rolls-Royce is about 14 times more expensive per BHP than Datsun (101.6K). Supercar brands (Ferrari 41.8K, Lamborghini 52.7K) cost less per BHP than Jaguar (58.4K) and Bentley (64.2K). Among the German brands, Audi (27.4K) is better value than BMW (30.4K) and Mercedes-Benz (37.0K).
3. **Electric vs combustion depends on the segment:** electric is more expensive per BHP in Budget (13.0K vs 7.8K for petrol) and Mid (15.8K vs 10.2K), the best value in Premium (21.8K vs 25.9K petrol and 26.5K diesel, with higher average power: 309 vs 297 and 196 BHP), and the most expensive again in Luxury (66.6K vs 57.8K). Comparing without segments gives a misleading picture. Electric samples in Budget and Mid are only 2 cars each.
4. **Ratings barely differentiate brands:** 13 of 19 brands share a weighted rating of 4.50 and the full range is 4.24 to 4.58. BMW is highest (4.58, on a small review base), MG (4.24) and Hyundai (4.28) are lowest.
5. **Price and rating:** rating rises only slightly with price (Budget 4.43, Mid 4.47, Premium 4.48, Luxury 4.55), and Luxury rests on far fewer reviews (303 vs 14,630 for Budget).
6. **Manual gearboxes disappear as price rises:** 30.8% of Budget cars, 23.1% of Mid, 4.7% of Premium and 0% of Luxury.
7. **Power is strongly related to price:** Pearson 0.721, Spearman 0.863, and 0.798 on log-transformed price (n = 193). Prices climb faster than power above roughly 300 BHP.

## Dashboard

Three pages: a cover, a market overview, and a price, value and ratings page with slicers for fuel type and price segment. A page-level filter removes the flagged prices everywhere.

![Market overview](images/02_market_overview.png)
![Price, value and ratings](images/03_price_value_ratings.png)
![Horsepower vs price](images/power_vs_price.png)

## Limitations

- Correlation does not mean causation. Power alone does not determine price; brand, size and features also matter.
- Price per BHP ignores comfort, safety and technology, so it measures "power value" only.
- `avg_price` is the midpoint between starting and ending price, not a single fixed price.
- Ratings appear to be rounded to 0.5 steps and many cars have very few reviews, so small differences should not be over-interpreted. Cars with fewer than 10 reviews were excluded from rating analysis, and brands needed at least 3 cars.
- Some brands have small samples (for example Datsun, Renault, Kia, Nissan, Lamborghini, Bentley).
- The dataset is a snapshot, and its collection date is unknown.

## How to reproduce

1. Import `data/CARS_1.csv` into SQL Server as `dbo.cars_raw` (SSMS Import Flat File, numeric columns as `int` or `float`).
2. Run `SQL/01_cleaning.sql`, then `SQL/02_analysis.sql`.
3. Run `SQL/03_export_for_python.sql`, save the result as `cars_for_python.csv`, then run the notebook in `python/`.
4. Open `powerbi/cars_dashboard.pbix` and change the data source to your own SQL Server instance.

## Author

[Your name] | [LinkedIn profile link]
