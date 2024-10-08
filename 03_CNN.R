# devtools::install_github('citoverse/cito')
# devtools::install_github(repo = "TheoreticalEcology/EcoData", dependencies = F, build_vignettes = F)
library(EcoData)
library(cito)

train = EcoData::dataset_flower()$train/255
train = aperm(train, c(1, 4, 2, 3))

test = EcoData::dataset_flower()$test/255
labels = EcoData::dataset_flower()$labels
unique(labels) # -> 5 different Flower Species
dim(train)

indx = 2000
train[indx,,,] |>
  aperm(c(2, 3, 1)) |>
  as.raster() |>
  plot()
text(x = -10, y = 1.0, label = paste0("Label: ", labels[indx]), xpd = NA)


# Create Architecture
architecture <- create_architecture(conv(5), maxPool(), conv(5), maxPool(), linear(5L))
plot(architecture, c(80L, 80L), )

# Train NN
cnn.fit = cnn(train, labels+1, architecture, loss = "softmax", epochs = 50, validation = 0.1, lr = 0.05, device="cpu", epochs = 10L)
predictions = predict(cnn.fit, type = "response")
mean(1*(apply(predictions, 1, which.max) == (labels+1)))

# Transfer learning
transfer_architecture <- create_architecture(transfer("resnet18"))
resnet <- cnn(train, labels+1, transfer_architecture, loss = "softmax",
              epochs = 2L, validation = 0.1, lr = 0.05)
predictions = predict(cnn.fit, type = "response")
mean(1*(apply(predictions, 1, which.max) == (labels+1)))

