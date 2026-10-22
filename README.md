# NYC Yellow Taxi Analysis 🚕

An end-to-end data analytics project on **4M+ NYC yellow taxi trips (May 2026)** to find out **when and where demand peaks, how people pay and tip, which vendors and airports matter most, and which trips look wrong**, using Python, SQL, and Power BI.

<img width="1280" height="320" alt="image" src="https://github.com/user-attachments/assets/2ae3bfa4-ce3a-4c48-80bc-3e6f189158d6" />

## 📌 Project Overview

This project is framed as a consulting-style case study. The business scenario is fictional, but **the data is real**: the official public trip records from the NYC Taxi & Limousine Commission (TLC).

A taxi operator has millions of raw trip records but no single view of demand, revenue, payment behaviour, vendors, and data quality. Raw trip files also contain refunds, zero distances, wrong durations, unusual fares, and missing locations. This project cleans the raw data, builds a star-schema database, answers business questions with SQL, and presents the results in an 8-page Power BI dashboard.

**Result at a glance**

| Metric | Value |
|---|---|
| Raw Trip Records | 4,090,836 |
| Cleaned Trips | 4,050,862 (39,974 rows removed, 0.98%) |
| Total Revenue (recorded trip amount) | 124.36M |
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

**Who uses the dashboard:** executives (overall health), operations (peak hours and zones), revenue and finance (fares, tips, payment mix), and fleet managers (where to place cars).

## 🗂️ Dataset Summary

Source: NYC TLC Yellow Taxi trip records for **May 2026**, plus the TLC taxi zone lookup.

| File / Table | What it contains |
|---|---|
| `yellow_tripdata` | Raw trip records, 4,090,836 rows and 20 source columns |
| `fact_yellow_trip` | Cleaned fact table used for analysis and the dashboard (4,050,862 rows) |
| `exception_trips` | Trips removed or flagged during cleaning (negative amounts, cancelled, disputes, outliers) |
| `dim_vendor` | Vendor names |
| `dim_zone` | Zone, borough, and service zone (taxi zone lookup, 263 zones after removing rows with missing fields) |
| `dim_payment_type` | Payment method names |
| `dim_rate_code` | Rate code names (Standard, JFK, Newark and others) |
| `dim_store_and_fwd_flag` | Store-and-forward flag names |
| `Date Table` | Calendar table for day, weekday/weekend, and date filters |

**How revenue is defined:** revenue means the **recorded trip amount** (`total_amount`, with `expected_total` used when `total_amount` is missing). It is a revenue proxy, not profit, because the data has no cost information.

## 🚀 Project Workflow

### Phase 1: Data Cleaning & Feature Engineering (Python)

Used Pandas to audit and clean the raw trips before loading them into the database.

| Audit finding (before cleaning) | Count | How it was handled |
|---|---|---|
| Zero-distance trips | 111,259 (2.73%) | Distance set to missing, trip kept |
| Zero or negative durations | 52,063 | Duration set to missing |
| Fare outliers | 31,982 | Flagged (`is_fare_outlier`) |
| Distance outliers | 68 | Flagged (`is_distance_outlier`) |
| Total amount that does not match its parts | 550,780 | `total_amount` set to missing, `expected_total` used as fallback |
| Cash trips with a recorded tip | 25 | Flagged (`is_cash_tip_error`) |
| Invalid location IDs | 25,019 | Removed |

These counts come from different cleaning steps and can overlap, so **do not add them together**.

Other steps:
- Moved rows with negative amounts into a separate exception table instead of deleting them silently, and flagged them as `is_cancelled` or `is_dispute_adjustment`.
- Converted passenger count and rate code to nullable integers.
- Created new columns: pickup hour, trip duration (minutes), distance (km), fare per mile, and expected total.
- Loaded the cleaned fact table and the exception table into PostgreSQL.
- Final result: **4,050,862 trips**, which is 0.98% fewer than the raw 4,090,836. This is a cleaning result, not a business loss.

### Phase 2: Analysis & KPIs (SQL)

- The data was already cleaned in Python, so no cleaning was done in SQL.
- 50 business questions (Q01 to Q50) were answered across revenue, demand, zones, tips, vendors, rate codes, and trip behaviour.
- Techniques used: aggregations, joins (including two joins on the same table for pickup and drop-off routes), `COALESCE` fallbacks, `FILTER`, subqueries, CTEs, and window functions (`RANK`, `PARTITION BY`, `SUM() OVER`).
- Key results were checked against the dashboard numbers (for example, 4.051M trips and the 78.83% top vendor share).

### Phase 3: Dashboard (Power BI)

An interactive report with 8 pages, a navigation panel, 6 synced slicers (Day Type, Payment Method, Rate Code, Borough, Service Zone, Vendors), and a reset button.

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

1. **Home** <img width="2255" height="1293" alt="dashboard_1_home" src="https://github.com/user-attachments/assets/07a3b0e7-fe8c-45e7-be1c-deefbb2ee6e1" />

2. **Executive Overview** <img width="2255" height="1293" alt="dashboard_2_executive_overview" src="https://github.com/user-attachments/assets/adafbaab-f951-4822-9b81-bbb0c1d50438" />

3. **Demand Analysis** <img width="2255" height="1293" alt="dashboard_3_demand_analysis" src="https://github.com/user-attachments/assets/063f6ed7-6e2d-47db-9c78-ce9f86376d7c" />

4. **Zone Analysis** <img width="2255" height="1293" alt="dashboard_4_zone_analysis" src="https://github.com/user-attachments/assets/6ee9cca7-d9f3-42dc-a3ce-db398f244ab7" />

5. **Revenue & Fare Analysis** <img width="2255" height="1293" alt="dashboard_5_revenue_and_fare" src="https://github.com/user-attachments/assets/92ef5374-b45f-4d78-a1b9-9d57f0f0c129" />

6. **Payment & Tips** <img width="2255" height="1293" alt="dashboard_6_payment_and_tips" src="https://github.com/user-attachments/assets/81df0dca-dc79-4c71-8fb3-ba1dd6f9403d" />

7. **Vendor & Airport** <img width="2255" height="1293" alt="dashboard_7_vendor_and_airport" src="https://github.com/user-attachments/assets/c3eb2aa2-bc5e-4955-b3db-f95e7b861c6d" />

8. **Exception Monitoring** <img width="2255" height="1293" alt="dashboard_8_exception_monitoring" src="https://github.com/user-attachments/assets/0307fe41-0642-4637-85c3-ff328b062c1f" />


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
- **Manhattan brings in 94.63M of the 124.36M revenue**, and Queens brings in 22.76M. Upper East Side South is the top pickup zone, and JFK Airport earns the most revenue.
- **Airport trips are 6.08% of trips** (246K, about 1 in 16) but earn a much higher fare, about 53 on average compared with about 20 for other trips.
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

➢ **Compare Counts and Rates** → When comparing vendors or boroughs, show exception counts next to exception rates, because bigger groups have more flagged trips simply because they have more trips.

➢ **Add More Months** → Add comparable months of data before making long-term staffing decisions or claiming trends.

## ⚠️ Limitations

- The data covers **one month (May 2026)**, so it supports daily and hourly patterns, but not month-over-month or year-over-year comparisons.
- Revenue is a **recorded trip amount (revenue proxy)**, not profit. There is no customer, driver, or cost data.
- Cash tips are missing, so tip insights reflect card payments only.
- Fare outliers are defined by a project rule (top 1% of fare per mile), so they are "unusual" trips, not always "wrong" trips. Flags are review signals, not proof of fraud.
- One trip can carry more than one exception flag, so the exception types add up to more than the total.

## 📂 Repository Contents

| File | Description |
|---|---|
| `Taxi_Analysis.ipynb` | Python cleaning and feature engineering |
| SQL file (`.sql`) | 50 business questions with answers |
| `Business_Problems.pdf` | Business requirement document and interview guide |
| `NYC_Taxi_Insights_Recommendations_Report_.pdf` | Insights and recommendations report |
| `Full_Project_PDF.pdf` | Dashboard export (all 8 pages) |
| `images/` | Banner and dashboard screenshots used in this README |

The raw data, the cleaned fact table, and the Power BI file are linked in the **Large Files** section above.
