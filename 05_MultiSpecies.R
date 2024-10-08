# devtools::install_github('citoverse/cito')
# devtools::install_github(repo = "TheoreticalEcology/EcoData", dependencies = F, build_vignettes = F)
library(EcoData)
library(cito)
library(ggplot2)
set.seed(42)
load(url("https://github.com/TheoreticalEcology/s-jSDM/raw/master/sjSDM/data/eucalypts.rda"))

head(eucalypts$env)
head(eucalypts$PA)
df = cbind(eucalypts$PA, scale(eucalypts$env))
indices = sample.int(nrow(df), 300)


model = dnn(cbind(ALA, ARE, BAX, CAM, GON, MEL, OBL, OVA, WIL, ALP, VIM, ARO.SAB)~.,
            data = df,
            lr = 0.1,
            verbose = FALSE,
            loss = "binomial")
plot(model)
head(predict(model))


# Re-fit model with bootstrapping
model_boot = dnn(cbind(ALA, ARE, BAX, CAM, GON, MEL, OBL, OVA, WIL, ALP, VIM, ARO.SAB)~.,
                 data = df,
                 loss = "binomial",
                 epochs = 200L,
                 hidden = c(50L, 50L),
                 batchsize = 50L,
                 lr = 0.1,
                 lambda = 0.001,
                 alpha = 1.0,
                 validation = 0.2,
                 verbose = FALSE,
                 lr_scheduler = config_lr_scheduler("reduce_on_plateau", patience = 7), # reduce learning rate each 7 epochs if the validation loss didn't decrease,
                 early_stopping = 14, # stop training when validation loss didn't decrease for 10 epochs
                 bootstrap = 20L,
                 bootstrap_parallel = 5L)

summ = summary(model_boot, n_permute = 1L, type = "link")
ale_plots = ALE(model_boot, variable = "cvTemp", plot = FALSE)
do.call(gridExtra::grid.arrange, ale_plots)

