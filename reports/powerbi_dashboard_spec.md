## 1. Design System & Style Guide

### Color Palette (Corporate Modern Dark/Light Hybrid)
We utilize a clean, semi-dark dashboard backdrop with high-contrast pastel accent colors for visual clarity.

| Role | Color Name | Hex Code | Visual Application |
|---|---|---|---|
| Background | Charcoal Grey | `#1E2229` | Dashboard sheet canvas background |
| Containers | Deep Slate | `#262B35` | Background cards/containers for individual visuals |
| Primary Accent | Cyan / Cool Blue | `#339AF0` | Sales, volumes, and revenue metrics |
| Secondary Accent | Emerald Green | `#51CF66` | Profit, profit margins, and positive gains |
| Alert / Attention | Coral Red | `#FF6B6B` | Negative profits, delays, and critical drop-offs |
| Primary Text | Ice White | `#F8F9FA` | Main titles, card KPI values |
| Secondary Text | Muted Grey | `#ADB5BD` | Axis labels, captions, gridlines, and legends |

### Typography
- **Dashboard Headers**: `Segoe UI Semibold` or `Outfit` (22pt, Bold, White)
- **Section Headers**: `Segoe UI` (14pt, Bold, Muted Grey)
- **KPI Card Values**: `Segoe UI Semibold` (32pt, Bold, White or Accent color)
- **Axis & Grid Labels**: `Segoe UI` (9pt, Regular, Muted Grey)

### Canvas Setup
- **Page Size**: Standard 16:9 widescreen layout (1280 x 720 pixels).
- **Grid Alignment**: 8px margin spacing grid enabled for perfect visual alignment of card containers.

---

## 2. Dashboard Page Blueprint

### Shared Left Navigation & Filtering Sidebar
A persistent 200px column on the left edge of every page containing:
- **Dashboard Logo & Title**: "Retail Analytics"
- **Page Navigation Icons**: Dynamic button icons to quickly switch between pages (Overview, Geography, Products, Customers).
- **Global Slicers**:
  - **Year Slicer**: Single-select vertical list (2014, 2015, 2016, 2017).
  - **Region Slicer**: Multi-select dropdown list (East, West, Central, South).
  - **Segment Slicer**: Multi-select buttons (Consumer, Corporate, Home Office).

---

### PAGE 1: Executive Overview

```
+---------------------------------------------------------------------------------+
| SIDEBAR |  KPI 1: Sales  |  KPI 2: Profit  |  KPI 3: Margin %  |  KPI 4: Orders  |
|         |    $2.30M      |    $286.4K      |     12.47%        |     5,009       |
|         +-----------------------------------------------------------------------+
|         | [Visual 1: Monthly Sales & Profit Trends]                             |
|         | Line & Clustered Column Chart (Sales as columns, Profit as line)      |
|         +-----------------------------------------------------------------------+
|         | [Visual 2: Segment Profitability]    | [Visual 3: Ship Mode Analysis] |
|         | Donut Chart                          | Horizontal Bar Chart           |
+---------+--------------------------------------+--------------------------------+
```

#### Visual Specifications:
1. **KPI Scorecard Block** (Row of 4 standard KPI cards at the top):
   - **Sales Card**: `[Total Sales]` metric, formatted as currency (`$2.30M`), labeled "Total Sales".
   - **Profit Card**: `[Total Profit]` metric, color-coded green if positive, labeled "Net Profit".
   - **Profit Margin Card**: `[Profit Margin %]` metric, formatted as percentage (`12.47%`), labeled "Operating Margin".
   - **Orders Card**: `[Total Orders]` count, formatted with thousands separator (`5,009`), labeled "Orders Placed".
2. **Visual 1: Monthly Sales & Profit Trends** (Center, wide area):
   - **Visual Type**: Line and Clustered Column Chart.
   - **X-Axis**: `Order Date` (hierarchical: Year > Month).
   - **Y-Axis (Columns)**: `[Total Sales]` (Cyan Blue).
   - **Y-Axis (Line)**: `[Total Profit]` (Emerald Green).
   - **Insight**: Highlights seasonal peaks in November/December and visualizes historical growth trajectory.
3. **Visual 2: Revenue Contribution by Segment** (Bottom-left card):
   - **Visual Type**: Donut Chart.
   - **Legend**: `Segment` (Consumer, Corporate, Home Office).
   - **Values**: `[Total Sales]`.
4. **Visual 3: Shipping Performance by Ship Mode** (Bottom-right card):
   - **Visual Type**: Clustered Horizontal Bar Chart.
   - **Y-Axis**: `Ship Mode`.
   - **X-Axis**: `[Average Shipping Duration]` (in days) and `[Total Orders]` as tooltips.

---

### PAGE 2: Regional Performance (Geography)

```
+---------------------------------------------------------------------------------+
| SIDEBAR | [Visual 1: USA States Sales Map]                                      |
|         | Filled Map / Bubble Map representing Sales by State                    |
|         | Color scale: Muted Blue (Low) to Bright Cyan (High Sales)            |
|         +-----------------------------------------------------------------------+
|         | [Visual 2: Top States by Profit]     | [Visual 3: Regional Table Grid] |
|         | Horizontal Bar Chart showing State   | Matrix table displaying sales, |
|         | Net Profit (with red/green colors)   | margin %, quantity by region.  |
+---------+--------------------------------------+--------------------------------+
```

#### Visual Specifications:
1. **Visual 1: USA Sales Geo Map** (Upper canvas, large visual):
   - **Visual Type**: Shape Map or Filled Map.
   - **Location**: `State`.
   - **Legend/Color Saturation**: `[Total Sales]`.
   - **Tooltip fields**: `Region`, `[Total Profit]`, `[Profit Margin %]`.
   - **UX Note**: Map zoom set to default United States bounds.
2. **Visual 2: Top States by Net Profit** (Bottom-left card):
   - **Visual Type**: Clustered Bar Chart.
   - **Y-Axis**: `State` (Top 15 states filtered using Visual Level Filters).
   - **X-Axis**: `[Total Profit]`.
   - **Formatting**: Conditional color formatting applied (Green if `Profit >= 0`, Red if `Profit < 0`).
3. **Visual 3: Regional Metrics Matrix Grid** (Bottom-right card):
   - **Visual Type**: Matrix Table.
   - **Rows**: `Region` > `City`.
   - **Values**: `[Total Sales]`, `[Total Profit]`, `[Profit Margin %]`, `[YoY Growth %]`.
   - **Formatting**: Micro databars on `[Total Sales]` column.

---

### PAGE 3: Product Analytics

```
+---------------------------------------------------------------------------------+
| SIDEBAR | [Visual 1: Category & Sub-Category Sales Hierarchy]                   |
|         | Treemap showing Sales (Size) and Profit Margin (Color scale)          |
|         +-----------------------------------------------------------------------+
|         | [Visual 2: Sub-Category Profit Margin]| [Visual 3: Sales vs Discount] |
|         | Diverging Bar Chart showing Margin % | Scatter Plot (Sales vs Profit, |
|         | by Sub-Category. Red marks negative. | dots colored by discount rate)|
+---------+--------------------------------------+--------------------------------+
```

#### Visual Specifications:
1. **Visual 1: Category & Sub-Category Sales Hierarchy** (Top wide visual):
   - **Visual Type**: Treemap.
   - **Group/Details**: `Category` and `Sub-Category`.
   - **Values**: `[Total Sales]` (determines box size).
   - **Color Saturation**: `[Total Profit]` using a diverging scale (Red for negative, Yellow for neutral, Green for positive).
2. **Visual 2: Net Profit Margin by Sub-Category** (Bottom-left card):
   - **Visual Type**: Clustered Bar Chart.
   - **Y-Axis**: `Sub-Category` (sorted by Profit Margin descending).
   - **X-Axis**: `[Profit Margin %]`.
   - **Formatting**: Horizontal bar colors linked to margin sign (positive = green, negative = red).
3. **Visual 3: Pricing Discount vs. Profit Margin** (Bottom-right card):
   - **Visual Type**: Scatter Plot.
   - **Y-Axis**: `[Profit Margin %]`.
   - **X-Axis**: `[Total Sales]` (Logarithmic scale recommended if sales values are extreme).
   - **Legend/Details**: `Product Name`.
   - **Play Axis**: (Optional) `Order_Year`.
   - **Tooltip**: `Discount`.

---

### PAGE 4: Customer Insights

```
+---------------------------------------------------------------------------------+
| SIDEBAR | [Visual 1: Customer Segmentation Profile]                             |
|         | Clustered Column Chart (Orders and Sales by Customer Segment)         |
|         +-----------------------------------------------------------------------+
|         | [Visual 2: Top 15 Customer LTV]      | [Visual 3: Repeat Buyer Matrix]|
|         | Horizontal Bar Chart showing total   | Table detailing top clients,   |
|         | Sales and Order Frequency (Tooltip)  | repeat purchase counts, AOV.   |
+---------+--------------------------------------+--------------------------------+
```

#### Visual Specifications:
1. **Visual 1: Customer Segment Profile** (Top visual):
   - **Visual Type**: Line and Stacked Column Chart.
   - **X-Axis**: `Segment` (Consumer, Corporate, Home Office).
   - **Y-Axis (Columns)**: `[Total Sales]`.
   - **Y-Axis (Line)**: `[AOV (Average Order Value)]`.
2. **Visual 2: Top 15 Customers by LTV Spend** (Bottom-left card):
   - **Visual Type**: Horizontal Bar Chart.
   - **Y-Axis**: `Customer Name` (Top 15 filter).
   - **X-Axis**: `[Total Sales]`.
   - **Data Labels**: Enabled, indicating exact lifetime purchase values.
3. **Visual 3: Customer Retention & Repeat Purchase Details** (Bottom-right card):
   - **Visual Type**: Matrix Table.
   - **Rows**: `Customer ID`, `Customer Name`.
   - **Columns/Values**: `[Total Sales]`, `[Order Count]`, `[AOV]`, `[Customer Status]` (derived category).
   - **Formatting**: Conditional coloring on `[Order Count]` (darker green represents highly loyal customers with repeat order counts > 5).

---

## 3. Recommended Interactivity & Tooltips

1. **Drillthrough Filter Action**:
   - Enable Drillthrough on the `Geography` page: Right-clicking any State on Page 2 allows the user to drill through to a hidden details table showing list of orders and products sold in that state.
   - Enable Drillthrough on the `Product` page: Right-clicking a product sub-category drills through to individual product sales listings.
2. **Report Page Tooltips (Modern Hover UX)**:
   - Create a hidden Tooltip page named "Product Hover Card".
   - When users hover over a sub-category in Visual 2 of Page 3, a tooltip appears displaying a mini bar chart showing the top 3 best-selling products within that specific sub-category.
3. **Cross-Filtering Behavior**:
   - Ensure clicking a category in Page 3's Treemap filters all other visuals on that page, rather than highlighting. Change visual interaction settings from "Highlight" to "Filter".
