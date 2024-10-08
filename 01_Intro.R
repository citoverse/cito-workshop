# Introduction to cito

# Install development version from github or via CRAN
# devtools::install_github('citoverse/cito')
# devtools::install_github(repo = "TheoreticalEcology/EcoData", dependencies = F, build_vignettes = F)
library(EcoData)
library(cito)
library(ggplot2)
set.seed(42)


# Regression - continuous response variables
nn.fit = dnn(Sepal.Width~Sepal.Length+Petal.Length, data = iris, loss = "mse") # Mean squared error
predictions = predict(nn.fit)
plot(iris$Sepal.Width, predictions)
abline(c(0, 1))

# Classification - binary or multiclass
nn.fit = dnn(Species~Sepal.Width+Petal.Length, data = iris, loss = "softmax") # multi-class (more than 2 levels in the response)
predict(nn.fit) # predict on the scale of the link
predict(nn.fit, type = "response") # predict on the scale of the response

pred = predict(nn.fit, type = "response") # probabilities that sum up to 1 over the rows
mean(1*(apply(pred, 1, which.max) == as.integer(iris$Species)))




# SDM - Predicting Elephant occurrences
elephant = EcoData::elephant
indices = sample.int(nrow(elephant$occurenceData), 500)
df = elephant$occurenceData[indices, ]
head(df)

nn.fit = dnn(Presence~bio1+bio2, data = df, burnin = Inf, loss = binomial())
plot(nn.fit)

## Change Architecture:
nn.fit = dnn(Presence~bio1+bio2,
             burnin = Inf, loss = binomial(),
             hidden = c(5L, 10L), # each element = one hidden layer with n nodes
             data = df)
plot(nn.fit)

## Change activation functions
## Usually there is no need to change the activation function
nn.fit = dnn(Presence~bio1+bio2,
             burnin = Inf, loss = binomial(),
             hidden = c(5L, 10L), # each element = one hidden layer with n nodes
             activation = "relu",
             data = df)
plot(nn.fit)


## Predictions
predictions = predict(nn.fit, type = "response")
Metrics::auc(df$Presence, predictions)


# Hyperparameters
## Important - Ensure that the model converged!
nn.fit = dnn(Presence~bio1+bio2, data = df, burnin = Inf, loss = binomial())
## Loss == Error of our model
## Baseline == Intercept only model
## Learning rate == step size of the updates

#  Learning rate is too high -> loss is above intercept model
nn.fit = dnn(Presence~bio1+bio2, data = df, burnin = Inf, loss = binomial(), lr = 2.0)

#  Learning rate is too low -> loss is above intercept model
nn.fit = dnn(Presence~bio1+bio2, data = df, burnin = Inf, loss = binomial(), lr = 0.00001)

# Loss is still decreasing? -> Increase number of epochs (=iterations)
nn.fit = dnn(Presence~bio1+bio2, data = df, burnin = Inf, loss = binomial(), lr = 0.1, epochs = 200L)
Metrics::auc(df$Presence, predict(nn.fit, type = "response"))

## Control for complexity
## Use holdout/validation data
set.seed(2)
torch::torch_manual_seed(2)
nn.fit = dnn(Presence~., data = df, burnin = Inf, loss = binomial(), lr = 0.2, epochs = 300L, validation = 0.2)
# Validation loss starts to increase --> Overfitting

## Regularization
## Option a) Mix of L1 and L2 on all weights
set.seed(2)
torch::torch_manual_seed(2)
nn.fit = dnn(Presence~., data = df, burnin = Inf, loss = binomial(), lr = 0.2, epochs = 300L, validation = 0.2, lambda = 0.01, alpha = 0.8)

## Option b) Dropout
set.seed(2)
torch::torch_manual_seed(2)
nn.fit = dnn(Presence~., data = df, burnin = Inf, loss = binomial(), lr = 0.2, epochs = 300L, validation = 0.2, dropout = 0.3)

## Hyperparameters such as lambda, alpha, dropout and learning rate must be tuned
nn.fit = dnn(Presence~.,
             data = df,
             lambda = tune(values = c(0.0001, 0.001, 0.01)),
             alpha = tune(lower = 0.5, upper = 1.0),
             burnin = Inf,
             loss = binomial(),
             lr = tune(lower = 0.05, upper = 0.2),
             epochs = 300L,
             validation = 0.2,
             dropout = tune(lower = 0.0, upper = 0.3),
             tuning = config_tuning(CV = 2L, cancel = FALSE) # 2-folded cross validation
)





