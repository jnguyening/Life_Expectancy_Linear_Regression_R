# Global Life Expectancy: A Multiple Linear Regression Analysis

## Overview

In this study, I applied advanced statistical methodologies in R to model the drivers of global life expectancy. Beyond simple correlation, this project focuses on the predictive reliability and mathematical validity of the regression model.

By leveraging the leaps package for subset selection and the car package for diagnostics, I moved from a high-dimensional model of 16 predictors to a refined 7-variable model. This process involved handling real-world data challenges, such as heteroscedasticity and non-linearity, by applying logarithmic scaling to economic indicators (GDP) and power transformations to immunization data (Polio/HepB). The final model serves as a validated framework for understanding how socio-economic resources and health interventions non-linearly compound to influence human longevity.

## Final Model
$$ \text{LifeExpectancy} = \beta_0 + \beta_1(\text{AdultMortality}) + \beta_2(\text{HepB}^3) + \beta_3(\text{Polio}^3) + \beta_4(\text{Income}) + \beta_5(\log\text{HIV}) + \beta_6(\log\text{GDP}) + \beta_7(\log\text{Thin5-9}) + \epsilon $$

## Final Model Summary Table

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
