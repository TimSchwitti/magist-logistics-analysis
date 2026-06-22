# Strategic Logistics Assessment: Magist & Eniac Market Entry

## Project Overview
Eniac, a fictional company, requires a data-driven assessment of its market entry into Brazil by evaluating a potential partnership with the logistics provider Magist. By analyzing historical delivery performance and customer feedback, we identified critical logistics bottlenecks and strategic growth opportunities. This analysis provides actionable recommendations to balance rapid market scaling with the preservation of high brand value.

## Dataset & Sources
* **Source:** [Magist Brazilian E-commerce Dataset]
* **Size:** 60,000+ orders, covering the period 2016–2018.
* **Key Features:** Order status, delivery timestamps (estimated vs. actual), product categories, customer/seller locations, and payment/review metrics.
* **Notes:** Data includes English-translated category names; timestamps were pre-processed to calculate delivery latency.

## Key Findings & Results
* **Delivery Latency Risk:** A significant percentage of high-value technology products faces delivery delays, posing a risk to Eniac's brand reputation during initial launch.
* **Geographical Performance:** Logistics performance fluctuates significantly across states; central regions show higher stability, while peripheral areas currently suffer from longer delivery times.
* **Correlation of Feedback:** There is a direct, measurable link between delivery delays and lower customer review scores, confirming that logistics efficiency is the primary driver of customer satisfaction.

## Technologies Used
* **Programming:** SQL
* **Analysis Tool:** MySQL Workbench / DBeaver
* **Visualization:** Tableau (for dashboarding and visual reporting)
* **Documentation:** PDF (Strategy Presentation)

## Project Structure
* [magist_strategy_presentation.pdf](magist_strategy_presentation.pdf) – Contains the final strategy recommendation.
* [magist_analysis.sql](magist_analysis.sql) – Contains the core analysis queries.
* [magist_schema.pdf](magist_schema.pdf) – Database structure documentation.

## How to Use This Project
1. **Main Analysis:** Review the logic used to calculate delivery KPIs in [magist_analysis.sql](magist_analysis.sql).
2. **Strategy Presentation:** Access the high-level recommendations in [magist_strategy_presentation.pdf](magist_strategy_presentation.pdf).
3. **Data Schema:** Reference the [magist_schema.pdf](magist_schema.pdf) to understand table relationships.

## Future Work
* **Real-time Monitoring:** Develop a live dashboard to track daily delivery performance upon market entry.
* **Predictive Modeling:** Implement a model to predict potential delivery delays based on seller location and product category before an order is placed.
* **Competitor Benchmarking:** Integrate external market data to compare Magist’s performance against other regional logistics providers.
