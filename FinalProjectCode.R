rm(list = ls())
# required packages
pkgs_list <- list("here", "readr", "tidyverse", "car", "alr4", "leaps")

# install/load packages
package.check <- lapply(pkgs_list, FUN = function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, dependencies = TRUE)
    library(x, character.only = TRUE)
  }
})

data <- read_csv(here('life_expectancy_data.csv'))

# clean and rescale data
data <- data %>% filter(Year == 2015)
data <- data %>% 
  rename(LifeExpectancy = `Life expectancy`,  AdultMortality = `Adult Mortality`, infantDeaths = `infant deaths`, percentExpenditure = `percentage expenditure`, HepB = `Hepatitis B`, under5 = `under-five deaths`, TotalExpenditure = `Total expenditure`, thin1_19 = `thinness  1-19 years`, thin5_9 = `thinness 5-9 years`, Income = `Income composition of resources`) %>% 
  select(-TotalExpenditure, -Alcohol, -Year, -percentExpenditure) %>% 
  drop_na()
data$Status[data$Status == "Developed"] <-  1
data$Status[data$Status == "Developing"] <- 0
data$Status <- as.numeric(data$Status) # make sure dummy variable is numeric

m1 <- lm(LifeExpectancy ~ AdultMortality + infantDeaths + HepB + Measles + BMI + under5 + Polio + Diphtheria + `HIV/AIDS` + GDP + Population + thin1_19 + thin5_9 + Income + Schooling + Status)
summary(m1)
pairs(LifeExpectancy ~ AdultMortality + infantDeaths + HepB + Measles + BMI + under5 + Polio + Diphtheria + `HIV/AIDS` + GDP + Population + thin1_19 + thin5_9 + Income + Schooling,data=data,cex.labels=1.4)


data <- data %>% 
  mutate(logInfant = log1p(infantDeaths),
         logMeasles = log1p(Measles),
         logUnder5 = log1p(under5),
         logHIV = log1p(`HIV/AIDS`),
         logGDP = log1p(GDP),
         logPopulation = log(Population),
         logThin1_19 = log1p(thin1_19),
         logThin5_9 = log1p(thin5_9)) # early transformations for variables that need to be log transformed

attach(data)

m2 <- lm(LifeExpectancy ~ AdultMortality + logInfant + HepB + logMeasles + BMI + logUnder5 + Polio + Diphtheria + logHIV + logGDP + logPopulation + logThin1_19 + logThin5_9 + Income + Schooling + Status)
summary(m2)
pairs(LifeExpectancy ~ AdultMortality + logInfant + HepB + logMeasles + BMI + logUnder5 + Polio + Diphtheria + logHIV + logGDP + logPopulation + logThin1_19 + logThin5_9 + Income + Schooling,data=data,cex.labels=1.4)

###-------------------------- variable selection: do this first! -------------------###
# training/test data split

#the number of predictors in full model
m <- 8
npar <- 3:(m + 2)
#sample size
n <- length(LifeExpectancy)
#split the data
set.seed(10)
train.indx <- sample(1:n, n/2)
#Select training data
y.train <- as.matrix(data[train.indx,3])
x.train <- as.matrix(data[train.indx,c(2, 4, 6, 8, 10:11, 17:26)])
#Select the test data
y.test <- as.matrix(data[-train.indx,3])
x.test <- as.matrix(data[-train.indx,c(2, 4, 6, 8, 10:11, 17:26)])

###------------------------------------------------ Information theoretic multimodel selection methods ------------------###
X <- cbind(x.train[,1], x.train[,2], x.train[,3], x.train[,4], x.train[,5], x.train[,6], x.train[,7], x.train[,8], 
           x.train[,9], x.train[,10], x.train[,11], x.train[,12], x.train[,13], x.train[,14], x.train[,15], x.train[,16]) # bind noncollinear predictors
b.train <- regsubsets(x=as.matrix(X),y=y.train)
rs.train <- summary(b.train)
rs.train$outmat

#calculate adjusted R^2, AIC, corrected AIC, and BIC
om1 <- lm(y.train~x.train[,7])
om2 <- lm(y.train~x.train[,7]+x.train[,12])
om3 <- lm(y.train~x.train[,5]+x.train[,7]+x.train[,12])
om4 <- lm(y.train~x.train[,5]+x.train[,7]+x.train[,12]+x.train[,16])
om5 <- lm(y.train~x.train[,5]+x.train[,7]+x.train[,12]+x.train[,13]+x.train[,16])
om6 <- lm(y.train~x.train[,2]+x.train[,5]+x.train[,7]+x.train[,12]+x.train[,13]+x.train[,16])
om7 <- lm(y.train~x.train[,2]+x.train[,3]+x.train[,5]+x.train[,7]+x.train[,12]+x.train[,13]+x.train[,16])
om8 <- lm(y.train~x.train[,1]+x.train[,2]+x.train[,3]+x.train[,5]+x.train[,7]+x.train[,12]+x.train[,13]+x.train[,16])

om <- list(om1,om2,om3,om4, om5, om6, om7, om8)


n.train <- length(y.train)

#adjusted R^2
Rsq.adj <- round(rs.train$adjr2,5)
Rsq.adj
#AIC
AIC<- sapply(1:m, function(x) round(extractAIC(om[[x]],k=2)[2],2))
AIC
#corrected AIC
AICc <- sapply(1:m, function(x) round(extractAIC(om[[x]],k=2)[2]+
                                        2*npar[x]*(npar[x]+1)/(n-npar[x]+1),2))
AICc
#BIC
BIC<- sapply(1:m, function(x) round(extractAIC(om[[x]],k=log(n))[2],2))
BIC


cbind(Rsq.adj, AIC, AICc, BIC) # best performing models is om8
summary(om8)

### ---- ----------------- Check for multicollinearity in selected model ------------------- ###
vif(om8) # variable 7 is collinear
om8 <- lm(y.train~x.train[,1]+x.train[,2]+x.train[,3]+x.train[,5]+x.train[,12]+x.train[,13]+x.train[,16]) # re-estimate model without collinear variable

# afte re-estimation, om7 is preferred
vif(om7) # no collinearity problems! 
summary(om7)

### -------------------------- re-estimate models with test data ###
om7_test <- lm(LifeExpectancy ~  AdultMortality + HepB + Polio + Income + logHIV + logGDP + logThin5_9, data = as.data.frame(cbind(y.test, x.test)))
summary(om7_test) 

####---------------------- Diagnostic plots for selected model ------------------------###

fullModel <- lm(LifeExpectancy ~  AdultMortality + HepB + Polio + Income + logHIV + logGDP + logThin5_9)
summary(fullModel)
pairs(LifeExpectancy ~  AdultMortality + HepB + Polio + Income + logHIV + logGDP + logThin5_9,data=data,cex.labels=1.4)

StanRes <- rstandard(fullModel)

par(mfrow = c(2,2))
plot(AdultMortality, StanRes)
abline(h = 2)
abline(h = -2)
plot(HepB, StanRes) # might need transformation
abline(h = 2)
abline(h = -2)
plot(Polio, StanRes) # might need transformation
abline(h = 2)
abline(h = -2)
plot(Income, StanRes)
abline(h = 2)
abline(h = -2)
plot(logHIV, StanRes)
abline(h = 2)
abline(h = -2)
plot(logGDP, StanRes)
abline(h = 2)
abline(h = -2)
plot(logThin5_9, StanRes)
abline(h = 2)
abline(h = -2)
plot(fullModel$fitted.values, StanRes)
abline(h = 2)
abline(h = -2)

absrtsr <- sqrt(abs(StanRes))
par(mfrow=c(2,2))
plot(fullModel$fitted, LifeExpectancy, xlab=paste("fitted ", expression("Life Expectancy"),sep=""))
abline(a=0,b=1,lty = 1, col=1)
plot(fullModel$fitted,absrtsr,xlab = paste("fitted ", expression("Life Expectancy"),sep=""), 
     ylab="Square Root(|Standardized Residuals|)")
abline(lsfit(fullModel$fitted,absrtsr),lty=2,col=1)
qqnorm(StanRes, ylab = "Standardized Residuals")
qqline(StanRes, lty = 2, col=1)

par(mfrow = c(2,2))
plot(fullModel) # mostly good, some normality issues and variance issues

####---------------------- Transformations for selected model ---------------------------###
summary(powerTransform(cbind(LifeExpectancy + 10e-9, AdultMortality + 10e-9, HepB + 10e-9, Polio + 10e-100, Income + 10e-9,
                             logHIV + 10e-9, logGDP + 10e-9, logThin5_9 + 10e-9)))
# powerTransform suggests y^2, HepB^3, Polio^3
data <- data %>% 
  mutate(y_sq = LifeExpectancy^2,
         HepB_cubed = HepB^3,
         Polio_cubed = Polio^3)
attach(data)

t_model <- lm(LifeExpectancy ~  AdultMortality + HepB_cubed + Polio_cubed + Income + logHIV + logGDP + logThin5_9)
summary(t_model)
pairs(LifeExpectancy ~  AdultMortality + HepB_cubed + Polio_cubed + Income + logHIV + logGDP + logThin5_9,data=data,cex.labels=1.4)

plot(t_model)
vif(t_model)

par(mfrow = c(2,2))
plot(t_model)
vif(t_model)

# take another look at residuals
StanRes_t <- rstandard(t_model)
par(mfrow = c(2,2))
plot(AdultMortality, StanRes_t)
abline(h = 2)
abline(h = -2)
plot(HepB_cubed, StanRes_t)
abline(h = 2)
abline(h = -2)
plot(Polio_cubed, StanRes_t)
abline(h = 2)
abline(h = -2)
plot(Income, StanRes_t)
abline(h = 2)
abline(h = -2)
plot(logHIV, StanRes_t)
abline(h = 2)
abline(h = -2)
plot(logGDP, StanRes_t)
abline(h = 2)
abline(h = -2)
plot(logThin5_9, StanRes_t)
abline(h = 2)
abline(h = -2)
plot(t_model$fitted.values, StanRes_t)
abline(h = 2)
abline(h = -2)

absrtsr_t <- sqrt(abs(StanRes_t))
par(mfrow=c(2,2))
plot(t_model$fitted, LifeExpectancy, xlab=paste("fitted ", expression("Life Expectancy"),sep=""))
abline(a=0,b=1,lty = 1, col=1)
plot(t_model$fitted,absrtsr,xlab = paste("fitted ", expression("Life Expectancy"),sep=""), 
     ylab="Square Root(|Standardized Residuals|)")
abline(lsfit(t_model$fitted,absrtsr),lty=2,col=1)
qqnorm(StanRes_t, ylab = "Standardized Residuals")
qqline(StanRes_t, lty = 2, col=1)
# residuals look better

# added variable plots
par(mfrow=c(2,2))
avPlots(t_model,ask=FALSE)

# marginal model plots
par(mfrow=c(1,1))
mmp(t_model, t_model$fitted.values)

par(mfrow=c(2,2))
mmp(t_model, AdultMortality)
mmp(t_model, HepB_cubed)
mmp(t_model, Polio_cubed)
mmp(t_model, Income)
mmp(t_model, logHIV)
mmp(t_model, logGDP)
mmp(t_model, thin5_9)

### Confidence Intervals of Betas ###
confint(t_model, level=0.95)

