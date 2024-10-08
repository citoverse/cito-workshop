# devtools::install_github('citoverse/cito')
# devtools::install_github(repo = "TheoreticalEcology/EcoData", dependencies = F, build_vignettes = F)
library(EcoData)
library(cito)
library(ggplot2)
set.seed(42)
elephant = EcoData::elephant
indices = sample.int(nrow(elephant$occurenceData), 500)
df = elephant$occurenceData[indices, ]
head(df)

nn.fit = dnn(Presence~bio1+bio2+bio3+bio4+bio5, data = df, burnin = Inf, loss = binomial())
summary(nn.fit)

ALE(nn.fit)
PDP(nn.fit, ice = TRUE)


# Interesting but what about uncertainties?
nn.fit = dnn(Presence~bio1+bio2+bio3+bio4+bio5, data = df, burnin = Inf, loss = binomial(), bootstrap = 20L, lr = 0.1, epochs = 400L)
summ = summary(nn.fit, type = "link")
ale_plots = ALE(nn.fit)
ale_plots = lapply(ale_plots, function(p) p+ylim(-3, 3))
do.call(gridExtra::grid.arrange, c(ale_plots, ncol = length(ale_plots)))


# What about interactions? Again, it is unnessary to set interactions in DL because we assume that they can learn them automatically
nn.fit = dnn(Presence~., data = df, burnin = Inf, loss = binomial(), lr = 0.1, epochs = 400L)
ce = conditionalEffects(nn.fit, interactions = TRUE, type = "link")
fields::image.plot( ce[[1]]$mean )
