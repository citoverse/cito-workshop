# Cito Workshop

Install packages:

```r
devtools::install_github('citoverse/cito')
devtools::install_github(repo = "TheoreticalEcology/EcoData", dependencies = F, build_vignettes = F)
```

## 1 - Introduction to cito

- How to fit simple fully-connected neural networks
- Adjusting learning rate and epochs to improve convergence
- Regularization in cito
- Automatic hyperparameter tuning in cito

```
01_Intro.R
```


## 2 - Inference with cito (using explainable AI)

- PDP, ALE, Feature Importance, and Average conditional effects in cito
- Confidence intervals

```
02_xAI.R
```

## 3 - Convolutional neural networks

- Multi-class task - predicting flower species from images

```
03_CNN.R
```
