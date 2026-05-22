## 1. Core Financial Measures

### Total Sales
Sums the total sales volume across all order lines.
```dax
Total Sales = 
SUM('fact_sales'[sales])
```

### Total Profit
Sums the total net profit across all order lines.
```dax
Total Profit = 
SUM('fact_sales'[profit])
```

### Profit Margin %
Calculates the net profit margin percentage. Uses `DIVIDE` for safe division in case `Total Sales` is zero.
```dax
Profit Margin % = 
DIVIDE(
    [Total Profit],
    [Total Sales],
    0
)
```

### Total Quantity
Calculates the total number of units sold.
```dax
Total Quantity = 
SUM('fact_sales'[quantity])
```

### Average Order Value (AOV)
Measures the average financial size of a single transaction order.
```dax
Average Order Value = 
DIVIDE(
    [Total Sales],
    DISTINCTCOUNT('fact_sales'[order_id]),
    0
)
```

---

## 2. Temporal & Time Intelligence Measures
*(Note: These measures require a standard continuous Calendar table linked to `fact_sales[order_date]`)*

### YTD Sales (Year-To-Date)
Calculates cumulative sales from the beginning of the current calendar year to the selected date.
```dax
YTD Sales = 
TOTALYTD(
    [Total Sales],
    'dim_calendar'[date]
)
```

### Prior Year Sales (LY Sales)
Returns the sales amount for the same period in the previous year.
```dax
Prior Year Sales = 
CALCULATE(
    [Total Sales],
    SAMEPERIODLASTYEAR('dim_calendar'[date])
)
```

### YoY Sales Growth ($)
Measures the absolute dollar change in sales compared to the previous year.
```dax
YoY Sales Growth = 
[Total Sales] - [Prior Year Sales]
```

### YoY Sales Growth (%)
Measures the percentage change in sales compared to the previous year.
```dax
YoY Sales Growth % = 
DIVIDE(
    [YoY Sales Growth],
    [Prior Year Sales],
    0
)
```

### Prior Month Sales (LM Sales)
Returns the sales amount for the previous month.
```dax
Prior Month Sales = 
CALCULATE(
    [Total Sales],
    DATEADD('dim_calendar'[date], -1, MONTH)
)
```

### MoM Sales Growth %
Measures the percentage change in sales compared to the previous month.
```dax
MoM Sales Growth % = 
DIVIDE(
    [Total Sales] - [Prior Month Sales],
    [Prior Month Sales],
    0
)
```

---

## 3. Customer Retention & Segment Measures

### Unique Customers
Counts the total number of unique customers who placed an order.
```dax
Unique Customers = 
DISTINCTCOUNT('fact_sales'[customer_key])
```

### Total Orders
Counts the unique number of order invoices.
```dax
Total Orders = 
DISTINCTCOUNT('fact_sales'[order_id])
```

### Repeat Customer Count
Counts customers who have placed more than one order across the entire timeline.
```dax
Repeat Customer Count = 
COUNTROWS(
    FILTER(
        ADDCOLUMNS(
            VALUES('dim_customers'[customer_key]),
            "OrderCount", CALCULATE(DISTINCTCOUNT('fact_sales'[order_id]))
        ),
        [OrderCount] > 1
    )
)
```

### Repeat Customer Rate (%)
Calculates the proportion of customers who are repeat buyers (loyalty index).
```dax
Repeat Customer Rate % = 
DIVIDE(
    [Repeat Customer Count],
    [Unique Customers],
    0
)
```

### Customer Lifetime Value (CLV)
Calculates the average lifetime spend of active customers in the system.
```dax
Average Customer CLV = 
DIVIDE(
    [Total Sales],
    [Unique Customers],
    0
)
```

---

## 4. Operational & Logistics Measures

### Average Shipping Duration (Days)
Calculates the average number of days it takes for an order to ship.
```dax
Average Shipping Duration = 
AVERAGE('fact_sales'[shipping_duration])
```

### Delayed Orders Count
Counts the number of orders where shipping duration exceeded standard SLAs (e.g., First Class > 2 days, Standard > 5 days).
```dax
Delayed Orders Count = 
CALCULATE(
    DISTINCTCOUNT('fact_sales'[order_id]),
    FILTER(
        'fact_sales',
        ('fact_sales'[ship_mode] = "Same Day" && 'fact_sales'[shipping_duration] > 0) ||
        ('fact_sales'[ship_mode] = "First Class" && 'fact_sales'[shipping_duration] > 2) ||
        ('fact_sales'[ship_mode] = "Second Class" && 'fact_sales'[shipping_duration] > 4) ||
        ('fact_sales'[ship_mode] = "Standard Class" && 'fact_sales'[shipping_duration] > 5)
    )
)
```

### Delay Rate %
Calculates the percentage of shipments that were delayed.
```dax
Logistics Delay Rate % = 
DIVIDE(
    [Delayed Orders Count],
    [Total Orders],
    0
)
```
