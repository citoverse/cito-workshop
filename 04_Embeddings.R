library(mlmRev)
library(cito)
library(ggplot2)
library(EcoData)
library(lme4)

## Advanced - Embeddings
head(Exam)
# Response: “normexam” (Normalized exam score).
# Predictor 1: “standLRT” (Standardised LR test score; Reading test taken when they were 11 years old).
# Predictor 2: “sex” of the student (F / M).
# Grouping factor: school
nn.fit = dnn(normexam ~ standLRT + sex +  e(school, dim = 2L, lambda = 0.01), data = Exam)
conditionalEffects(nn.fit)
summary(nn.fit)

results = lapply(unique(Exam$school), function(i) {
  res_school = ALE(nn.fit, data = Exam[Exam$school == i, ], plot = FALSE )
  res_school$standLRT$data$School = i
  return(res_school$standLRT$data)
})
results = do.call(rbind, results)

ggplot(results, aes(x = x, y = y, col = School)) + geom_line() + theme_bw()



## Advanced - Count/Negative Binomial
library(DHARMa)
nn.fit = dnn(count ~ spp + mined, loss = "poisson", data = Salamanders)
pred = predict(nn.fit, type = "response")
simulations = sapply(1:100, function(i) rpois(length(pred), pred))
res = DHARMa::createDHARMa(simulations, nn.fit$data$Y[,1], fittedPredictedResponse = pred[,1], , integerResponse = TRUE)
plot(res)
testDispersion(res)


m2 = dnn(count ~ spp + mined, loss = "nbinom", data = Salamanders)
pred = predict(m2, type = "response")
sims = sapply(1:100, function(i) m2$loss$simulate(pred))

res = createDHARMa(sims, m2$data$Y[,1], pred[,1], integerResponse = TRUE)
plot(res, rank = FALSE)
