###############################################################################
# DATAFRAME INITIALIZATION
###############################################################################

df <- read.csv("./data/population.csv")
library(ggplot2)
library(dplyr)

###############################################################################
# POPULATION GROWTH ANALISYS ==== LINEAR REGRESSION
###############################################################################

# USA ANALYSIS
usa <- df[df$Country == "United States", ]

model <- lm(Population ~ Year, data = usa)
summary(model)
plot(fitted(model), rstandard(model))
abline(0, 0)
qqnorm(rstandard(model), main = "Normal qq-plot (USA)",
    ylab = "Empirical Quantiles", xlab = "Theoretical Quantiles")
qqline(rstandard(model), col = "red", lty = 4, lwd = 2)

# Pearson's product-moment correlation
cor.test(usa$Population, usa$Year)

ggplot(data = usa, aes(x = Year, y = Population)) +
    geom_point() + geom_smooth(method = "lm") +
    labs(x = "Time (y)", y = "Population (ab)")
ggsave("./img/usa.png")

# PAKISTAN ANALYSIS
# Pakistan has an exponential growth -> log scale to fit a linear model

pak <- df[df$Country == "Pakistan", ]
pak[, "log_Population"] <- log(pak[, "Population"] + 1)

# non modified
model <- lm(Population ~ Year, data = pak)
summary(model)
plot(fitted(model), rstandard(model))
abline(0, 0)
qqnorm(rstandard(model), main = "Normal qq-plot (Pakistan)",
    ylab = "Empirical Quantiles", xlab = "Theoretical Quantiles")
qqline(rstandard(model), col = "red", lty = 4, lwd = 2)
# logaritmic transformation
model <- lm(log_Population ~ Year, data = pak)
summary(model)
plot(fitted(model), rstandard(model))
abline(0, 0)
qqnorm(rstandard(model), main = "Normal qq-plot (Pakistan - log)",
    ylab = "Empirical Quantiles", xlab = "Theoretical Quantiles")
qqline(rstandard(model), col = "red", lty = 4, lwd = 2)

# Pearson's product-moment correlation
cor.test(pak$Population, pak$Year)
cor.test(pak$log_Population, pak$Year)

ggplot(data = pak, aes(x = Year, y = Population)) +
    geom_point() + geom_smooth(method = "lm") +
    labs(x = "Time (y)", y = "Population (ab)")
ggsave("./img/pak.png")
ggplot(data = pak, aes(x = Year, y = log_Population)) +
    geom_point() + geom_smooth(method = "lm") +
    labs(x = "Time (y)", y = "log(Population) (a.u.)")
ggsave("./img/pak_log.png")

###############################################################################
# POPULATION GROWTH BETWEEN CONTINENTS==== HYPOTHESIS TESTING
###############################################################################

# H0: the two populations have the same mean

asia <- df[df$Continent == "Asia", ]
asia <- asia %>% group_by(Year) %>% summarise(sum = sum(Population))
asia[, "sum"] <- log(asia[, "sum"] + 1)

oceania <- df[df$Continent == "Oceania", ]
oceania <- oceania %>% group_by(Year) %>% summarise(sum = sum(Population))
oceania[, "sum"] <- log(oceania[, "sum"] + 1)

ggplot(data = oceania, aes(x = Year, y = sum)) +
    geom_point(color = "blue") +
    geom_point(data = asia, color = "red") +
    labs(x = "Time (y)", y = "log(Population) (a.u.)")
ggsave("./img/asia_oceania.png")

ggplot() +
    geom_histogram(aes(x = oceania$sum), fill = "blue", alpha = 0.5, bins = 15) + # nolint: line_length_linter.
    geom_histogram(aes(x = asia$sum), fill = "red", alpha = 0.5, bins = 15) +
    labs(x = "log(Population)", y = "Frequency")
ggsave("./img/asia_oceania_hist.png")

qqnorm(asia$sum, main = "Normal qq-plot (Asia)",
    ylab = "Empirical Quantiles", xlab = "Theoretical Quantiles")
qqline(asia$sum, col = "red", lty = 4, lwd = 2)

qqnorm(oceania$sum, main = "Normal qq-plot (Oceania)",
    ylab = "Empirical Quantiles", xlab = "Theoretical Quantiles")
qqline(oceania$sum, col = "red", lty = 4, lwd = 2)

t.test(asia$sum, oceania$sum)

###############################################################################
# YEARLY CHANGE ==== MULTILINEAR REGRESSION
###############################################################################

france <- df[df$Country == "France", ]

result <- lm(data = france, Yearly.Change ~ Population + Migrants.net.
    + FertilityRate + MedianAge + UrbanPopulation)
summary(result)