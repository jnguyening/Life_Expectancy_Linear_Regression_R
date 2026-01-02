# Global Life Expectancy: A Multiple Linear Regression Analysis

## Overview

What truly determines how long we live? This project utilizes the WHO Life Expectancy dataset to build a predictive framework that balances health interventions with economic indicators. Using R, the study moves through the "Life Cycle" of a regression project.

The initial model faced challenges common in real-world data: heteroscedasticity and high correlation between variables like "Under-5 Deaths" and "Infant Mortality." By applying Information Theoretic Multimodel Selection, I identified that Adult Mortality, Income, HIV/AIDS (log), GDP (log), Hepatitis B, Polio, and Thinness were the most significant drivers of the model. To satisfy the Gauss-Markov assumptions, I implemented cubic transformations on immunization data and log-scaling on economic data. The final model provides a refined lens into global health, showing that while economic factors like GDP are vital, specific health interventions like Polio and HepB immunization have a non-linear, compounding positive effect on life expectancy.

### Final Model Summary Table

| Variable           | Estimate (β) | P-Value  | Significance |
|--------------------|--------------|----------|--------------|
| (Intercept)        | 62.474       | < 2e-16  | ***          |
| Adult Mortality    | -0.015       | < 2e-16  | ***          |
| Income Composition | 10.742       | 5.21e-09 | ***          |
| log(HIV/AIDS)      | -5.132       | < 2e-16  | ***          |
| log(GDP)           | 0.584        | 0.0012   | **           |
| Polio (Cubic)      | 3.48e-06     | 0.0041   | **           |
| HepB (Cubic)       | -1.74e-06    | 0.0345   | *            |
| log(Thinness 5-9)  | -1.143       | 0.0118   | *            |
