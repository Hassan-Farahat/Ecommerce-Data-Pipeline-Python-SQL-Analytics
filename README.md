# E-Commerce Data Pipeline & Analytics (Python & SQL)

An end-to-end local data engineering and analytics project. Raw e-commerce data (Olist dataset) is cleaned and structured using Python, ingested into **Microsoft SQL Server**, and analyzed using advanced **T-SQL queries** to extract key business metrics.

---

## 📁 Repository Structure

```text
├── data/
│   ├── customers.csv
│   ├── geolocation.zip       # Unzip locally before running ingestion script
│   ├── order_items.csv
│   ├── orders.csv
│   ├── payments.csv
│   ├── products.csv
│   └── sellers.csv
├── ecommerce_analysis_queries.sql
├── Python_SQL_Ecommerce_Analysis.ipynb
├── .gitignore
├── LICENSE
└── README.md
```

---

## 🛠️ Tech Stack & Tools

* **Programming:** Python 3.x (Pandas, SQLAlchemy, PyODBC)
* **Database Management:** Microsoft SQL Server, SQL Server Management Studio (SSMS)
* **Querying:** T-SQL (CTE, Window Functions, Aggregations)
* **Environment:** Jupyter Notebook

---

## 🚀 Pipeline Workflow

1. **Extraction & Cleaning:** `Python_SQL_Ecommerce_Analysis.ipynb` loads raw CSV files, handles missing values, validates data types, and prepares relational schemas.
2. **Database Ingestion:** Automated ingestion pipeline writes cleaned DataFrames directly into local **MS SQL Server** staging/production tables via SQLAlchemy.
3. **Business Analytics:** `ecommerce_analysis_queries.sql` executes SQL analytics on customer retention, revenue trends, logistics performance, and seller metrics.

---

## ⚙️ How to Run Locally

1. **Clone the Repository:**
   ```bash
   git clone [https://github.com/Hassan-Farahat/Ecommerce-Data-Pipeline-Python-SQL-Analytics.git](https://github.com/Hassan-Farahat/Ecommerce-Data-Pipeline-Python-SQL-Analytics.git)
   cd Ecommerce-Data-Pipeline-Python-SQL-Analytics
   ```

2. **Extract Geolocation Data:**
   * Extract `data/geolocation.zip` into the `data/` directory so that `data/geolocation.csv` is present.

3. **Configure Database Connection:**
   * Open `Python_SQL_Ecommerce_Analysis.ipynb`.
   * Update the MS SQL Server connection string (`SERVER`, `DATABASE`, `DRIVER`) to match your local SQL Server instance.

4. **Run Pipeline & SQL Analysis:**
   * Execute all cells in `Python_SQL_Ecommerce_Analysis.ipynb` to populate your SQL Server database.
   * Open `ecommerce_analysis_queries.sql` in SSMS to execute analytical queries.

---

## 📄 License
Distributed under the MIT License. See `LICENSE` for details.
