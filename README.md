# NYC Yellow Taxi Analysis 🚕

An end-to-end data analytics project on 4M+ NYC yellow taxi trips to find out **when and where demand peaks, how people pay and tip, which vendors and airports matter most, and which trips look wrong**, using Python, SQL, and Power BI.

![banner](images/banner.png)

## 📌 Project Overview

New York's yellow taxis make millions of trips, but raw trip records are messy. They contain refunds, wrong distances, missing locations, and unusual fares. A taxi operator needs to know when to put more cars on the road, which areas and payment types earn the most, and how reliable the data is before using it.

This project cleans the raw trip data, builds a star-schema database, answers business questions with SQL, and presents the results in an 8-page Power BI dashboard.

The cleaned data holds about **4.05 million trips**. Most trips fall in a single month (May), and only a few stray trips appear in April and June, so the project does not claim monthly trends.

**Result at a glance**

| Metric | Value |
|---|---|
| Total Trips | 4.051M |
| Total Revenue | 124.36M |
| Average Fare | 21.37 |
| Average Trip Distance / Duration | 4.91 miles / 18.70 minutes |
| Peak Hour | 18:00 (281K trips) |
| Airport Trips | 6.08% of all trips |
| Tips as Share of Revenue | 9.62% |
| Exception Trips | 47K (1.16%) |

## 🛠️ Tech Stack

- **Data Cleaning & Feature Engineering:** Python (Pandas, SQLAlchemy), Jupyter Notebook
- **Database & Analysis:** SQL (PostgreSQL)
- **Data Visualization:** Power BI (DAX measures, star-schema model, synced slicers)
- **Analytical Concepts:** Demand Analysis, Revenue & Fare Analysis, Tip Analysis, Route Analysis, Exception (Data Quality) Monitoring

## ❓ Business Problems Solved

- **When is demand highest?** Found the busiest hours and days, so cars can be planned in advance.
- **Where do trips and money come from?** Compared pickup zones, boroughs, and routes by trips and revenue.
- **How do people pay and tip?** Checked payment methods, tip amounts, and tip share of revenue.
- **Which vendors and airports matter?** Compared vendors, and measured how valuable airport trips are.
- **Can the data be trusted?** Flagged cancelled, disputed, and unusual trips in a separate exception table.

## 🗂️ Dataset Summary

The data comes from the NYC Taxi & Limousine Commission (TLC) yellow taxi trip records.

| File / Table | What it contains |
|---|---|
| `yellow_tripdata` | Raw trip records (pickup and drop-off time, locations, distance, fares, tips, payment type) |
| `fact_yellow_trip` | Cleaned fact table used for analysis and the dashboard (about 4.05M rows) |
| `exception_trips` | Trips removed or flagged during cleaning (negative amounts, cancelled, disputes, outliers) |
| `dim_vendor` | Vendor names |
| `dim_zone` | Zone, borough, and service zone for each location ID |
| `dim_payment_type` | Payment method names |
| `dim_rate_code` | Rate code names (Standard, JFK, Newark and others) |
| `dim_store_and_fwd_flag` | Store-and-forward flag names |
| `Date Table` | Calendar table for day, weekday/weekend, and date filters |

## 🚀 Project Workflow

### Phase 1: Data Cleaning & Feature Engineering (Python)

Used Pandas to clean the raw trips and prepare them for the database.

- Handled null values and fixed data types.
- Moved rows with negative amounts into a separate exception table instead of deleting them silently.
- Removed trips with invalid pickup or drop-off locations.
- Set zero distances to null, so averages are not pulled down.
- Created new columns: pickup hour, trip duration (minutes), distance (km), fare per mile, and expected total.
- Created flags: `is_cancelled`, `is_dispute_adjustment`, `is_fare_outlier`, `is_distance_outlier`, and `is_cash_tip_error`.
- Loaded the clean fact table and the exception table into PostgreSQL.

### Phase 2: Analysis & KPIs (SQL)

- The data was already cleaned in Python, so no cleaning was done in SQL.
- 50 business questions (Q01 to Q50) were answered across revenue, demand, zones, tips, vendors, rate codes, and trip behaviour.
- Techniques used: aggregations, joins (including two joins on the same table for pickup and drop-off routes), `COALESCE` fallbacks, `FILTER`, subqueries, CTEs, and window functions (`RANK`, `PARTITION BY`, `SUM() OVER`).
- Key results were checked against the dashboard numbers (for example, 4.051M trips and the 78.83% top vendor share).

### Phase 3: Dashboard (Power BI)

An interactive report with 8 pages, a navigation panel, 6 synced slicers, and a reset button.

| Page | What it shows |
|---|---|
| Home | Key insights, recommendations, and the slicers that filter every page |
| Executive Overview | Main KPIs, trips by hour, trips by day |
| Demand Analysis | Peak hour, trips by rate code, payment method, and vendor |
| Zone Analysis | Top pickup and drop-off zones, trips by service zone and borough |
| Revenue & Fare Analysis | Revenue by zone and borough, average fare, trips and revenue by day |
| Payment & Tips | Payment mix by day, tips by day, weekend vs weekday tips |
| Vendor & Airport | Vendor share, airport trips, revenue, fares, and trips by hour |
| Exception Monitoring | Cancelled, disputed, and outlier trips by vendor, zone, payment, and day |

## 📸 Dashboard Preview

1. **Home** ![home](images/dashboard_1_home.png)
2. **Executive Overview** ![executive overview](images/dashboard_2_executive_overview.png)
3. **Demand Analysis** ![demand analysis](images/dashboard_3_demand_analysis.png)
4. **Zone Analysis** ![zone analysis](images/dashboard_4_zone_analysis.png)
5. **Revenue & Fare Analysis** ![revenue and fare analysis](images/dashboard_5_revenue_and_fare.png)
6. **Payment & Tips** ![payment and tips](images/dashboard_6_payment_and_tips.png)
7. **Vendor & Airport** ![vendor and airport](images/dashboard_7_vendor_and_airport.png)
8. **Exception Monitoring** ![exception monitoring](images/dashboard_8_exception_monitoring.png)

## 📁 Large Files (not uploaded to GitHub due to size)

| File | What it is | Link |
|---|---|---|
| `yellow_tripdata.csv` | Raw trip data | [Download](https://1drv.ms/x/c/f2e0a4c9963077ba/IQBKj32qceGvRacopiKnCcz1Ad70yE90V-QJ4jjeknHa8n4?e=e0iWAl) |
| `fact_yellow_trip.csv` | Cleaned fact table | [Download](https://1drv.ms/x/c/f2e0a4c9963077ba/IQB1tS3kxnB1QKmasaO_h_BNAbe5RjJ7YGMa66235RCyyFM?e=BQq4aC) |
| `NYC Yellow Taxi Analysis.pbix` | Power BI report | [Download](https://1drv.ms/u/c/f2e0a4c9963077ba/IQANV6e4PA84RrkCLfPCf-vbAWwIOJ0kGraJ6kM2O-Bbx5k?e=auN2zg) |

## 💡 Key Insights

- **Demand peaks at 18:00** with 281K trips, about 7% of all trips. Early morning (3 to 4 AM) is the quietest time.
- **Friday and Saturday are the busiest days** (about 680K trips each). Monday is the lowest (about 430K). Weekdays carry about 69% of trips.
- **Credit card is the main payment method** (66.9% of trips), followed by Flex Fare (23.5%) and cash (9%).
- **Tips are 9.62% of revenue** (average tip 2.95). Cash tips are not recorded, so real tipping is higher.
- **Manhattan brings in about 95M of the 124.36M revenue.** Upper East Side South is the top pickup zone, and JFK Airport earns the most revenue.
- **Airport trips are 6.08% of trips** (246K) but earn a much higher fare, about 53 on average compared with about 20 for other trips.
- **Curb Mobility carries 78.83% of trips.** The other three vendors share the rest.
- **Only 1.16% of trips are exceptions.** Fare outliers are about two thirds of them (32K).
- **Curb Mobility has the highest exception rate** (1.41%), and Flex Fare trips make up about 49% of all exceptions.
- **Store-and-forward trips are very rare** (0.08%), so data recording is reliable.
- **About 1.1M trips have no rate code**, which is more than a quarter of all trips.

## ✅ Business Recommendations

➢ **Put More Cars on the Road at Peak Times** → Add drivers from 4 PM to 7 PM, Thursday to Saturday, and run offers on Mondays.

➢ **Raise Tips on Card Payments** → Add on-screen tip suggestions (15%, 20%, 25%), since cards are two thirds of trips.

➢ **Cover Airports Smartly** → Keep enough cars at airport pick-up lines in the afternoon, and plan early-morning flight pickups separately.

➢ **Fix Data Issues at the Source** → Ask Curb Mobility to check its meter or data system, and review how Flex Fare trips are recorded.

➢ **Review the Fare Rules** → Check that unusual fares at JFK (tolls and flat fares) are not wrongly treated as errors.

➢ **Record Rate Codes Properly** → Reduce the large group of trips with no rate code.

## ⚠️ Limitations

- Most trips fall in one month, so monthly trends are not reliable.
- Cash tips are missing, so tip insights reflect card payments only.
- Fare outliers are defined as the top 1% of fare per mile, so they are "unusual" trips, not always "wrong" trips.
- One trip can carry more than one exception flag, so the exception types add up to more than the total.

## 📂 Repository Contents

| File | Description |
|---|---|
| `Taxi_Analysis.ipynb` | Python cleaning and feature engineering |
| SQL file | 50 business questions with answers |
| `NYC_Yellow_Taxi_Analysis.pdf` | Dashboard export (all pages) |
| `images/` | Dashboard screenshots |

The raw data, the cleaned fact table, and the Power BI file are linked in the **Large Files** section above.
