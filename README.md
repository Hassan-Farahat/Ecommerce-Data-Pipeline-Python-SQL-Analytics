# E-Commerce Data Analytics Portfolio Project

## Overview
This repository contains a comprehensive data analytics portfolio project that explores an e-commerce database to extract actionable business intelligence regarding customer behavior, sales performance, and logistical operations. By utilizing a hybrid environment, the analysis seamlessly integrates Python scripts with SQL Server to execute raw queries, model data, and generate advanced statistical visualizations. 

## Environment & Tech Stack
*   **Environment:** Jupyter Notebook + SSMS (SQL Server Management Studio)
*   **Languages:** Python, SQL
*   **Database Management:** SQL Server

## Dependencies & Library Setup
The following Python modules are required to manage data structures, establish high-performance database connections, execute formatted SQL commands, and build visual dashboards:

```python
# Import pandas for data manipulation.
import pandas as pd
# Create_engine from SQLAlchemy to establish a high-performance database connection.
from sqlalchemy import create_engine
# Import the Path class from pathlib for clean, cross-platform, object-oriented file path operations.
from pathlib import Path
# Import text construct from SQLAlchemy to execute safely formatted raw SQL queries inside engine connections.
from sqlalchemy import text
# Import pyplot module from matplotlib for generating data visualizations.
import matplotlib.pyplot as plt
# Import seaborn library for advanced statistical data visualization.
import seaborn as sns
# Import numpy library for numerical operations.
import numpy as np
```

## Dataset Details
The database is built from underlying flat files including `customers.csv` and `geolocation.csv`. The relational schema is structured around the following core tables:
*   **`customers`:** Stores geographic distributions including customer cities and states.
*   **`orders`:** Tracks order placement timestamps and overall order statuses.
*   **`order_items`:** Links specific products to orders and tracks itemized pricing.
*   **`payments`:** Logs transaction values and installment plan selections.
*   **`products`:** Classifies distinct product categories.
*   **`sellers`:** Identifies individual merchants fulfilling the items.

## Key Business Analytics
*   **Revenue Optimization:** Calculated total sales distributed by product category and ranked the highest-grossing sellers.
*   **Customer Behavior:** Mapped order volume across geographic states, identified the top three highest-spending customers annually, and calculated the percentage of orders paid in installments.
*   **Time-Series & Growth:** Tracked seasonal order volume by month, visualized cumulative monthly sales, and measured Year-over-Year (YoY) revenue growth percentages.
*   **Retention Metrics:** Developed a retention rate calculation defining loyal customers as those making secondary purchases within a 6-month window of their initial transaction.
*   **Statistical Analysis:** Derived the Pearson Correlation Coefficient to map the relationship between product pricing and overall purchase frequency.

## Technical SQL Implementations
*   **Advanced Window Functions:** Leveraged `LAG()` for comparative growth tracking, `DENSE_RANK()` for top-spender tiering, and `AVG() OVER (PARTITION BY...)` to generate moving averages of customer order histories.
*   **Common Table Expressions (CTEs):** Structured complex, multi-stage data aggregations prior to executing statistical math and demographic grouping.
*   **Performance Optimization:** Resolved `VARCHAR(MAX)` indexing limitations by strategically resizing key reference columns (such as `order_id`) to `VARCHAR(50)`, facilitating the successful implementation of non-clustered performance indexes to dramatically reduce query execution time.
