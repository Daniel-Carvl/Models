library(kuenm2)
library(terra)
library(tidyverse)
library(readxl)

# Current directory
getwd()

# Saving original plotting parameters
original_par <- par(no.readonly = TRUE)

# Lendo tabela  -----------------------------------------------------------

# Ler o arquivo Excel
dados <- read_excel("data/data/Trips palmi.xlsx")
dados <- data.frame(dados)

dados$species = 'Trips_palmi'

# transformando pra numerico
dados$lon <- as.numeric(as.character(dados$lon))
dados$lat <- as.numeric(as.character(dados$lat))

# Lendo camadas do presente -----------------------------------------------

dir_layers <- "data/layers/current_asc"

arquivos <- list.files(
  dir_layers,
  pattern = "\\.asc$",
  full.names = TRUE
)

var <- rast(arquivos)

# Keep only one layer
bio1 <- var$wc2.1_5m_bio_1

terra::plot(bio1)


# plotando os pontos de ocorrência ----------------------------------------

terra::plot(bio1, main = "Bio 1")
points(dados[, c("lon", "lat")])


# limpando os dados -------------------------------------------------------
dados <- as.data.frame(dados)
clean_init <- initial_cleaning(data = dados, species = "species", 
                               x = "lon", y = "lat", remove_na = TRUE, 
                               remove_empty = TRUE, remove_duplicates = TRUE, 
                               by_decimal_precision = TRUE,
                               decimal_precision = 2)

# quick check
cat(nrow(dados))  # original data
#> [1] 64
cat(nrow(clean_init))  # data after all basic cleaning steps
#> [1] 51

# a final plot to check
par(mfrow = c(2, 2))

## initial data
terra::plot(bio1, main = "Initial data")
points(dados[, c("lon", "lat")])

## data after basic cleaning steps
terra::plot(bio1, main = "After basic cleaning")
points(clean_init[, c("lon", "lat")])


# versão avançada ---------------------------------------------------------

clean_data <- advanced_cleaning(data = clean_init, x = "lon", y = "lat", 
                                raster_layer = bio1, cell_duplicates = TRUE,
                                move_points_inside = TRUE, 
                                #validar com Dani
                                move_limit_distance = 10)
#> Moving occurrences to closest pixels...

# exclude points not moved
clean_data <- clean_data[clean_data$condition != "Not_moved", 1:3]

# quick check
nrow(dados)  # original data
#> [1] 64
nrow(clean_init)  # data after all basic cleaning steps
#> [1] 51
nrow(clean_data)  # data after all basic cleaning steps
#> [1] 41

# a final plot to check
par(mfrow = c(3, 2))

## initial data
terra::plot(bio1, main = "Initial")
points(dados[, c("lon", "lat")])

## data after basic cleaning steps
terra::plot(bio1, main = "Basic cleaning")
points(clean_init[, c("lon", "lat")])

# terra::plot(var, main = "Basic cleaning (zoom)")
# points(clean_init[, c("lon", "lat")])

## data after basic cleaning steps
terra::plot(bio1, main = "Final data")
points(clean_data[, c("lon", "lat")])

## zoom to a particular area, initial data
# terra::plot(var, xlim = c(-48, -47), ylim = c(-23, -22),  main = "Initial (zoom +)")
# points(dados[, c("lon", "lat")])
# 
# ## zoom to a particular area, final data
# terra::plot(var, xlim = c(-48, -47), ylim = c(-23, -22),  main = "Initial (zoom +)")
# points(clean_data[, c("lon", "lat")])

# Save as CSV
# write.csv(clean_data, file = "data/data/clean_data.csv", row.names = FALSE)
# 
# # Save as RDS
# saveRDS(clean_data, file = "Clean_data.rds")


# Calibrando o modelo -----------------------------------------------------

d <- prepare_data (algorithm = "maxnet",
                   occ = clean_data,
                   x = "lon", y = "lat",
                   raster_variables = var,
                   do_pca = TRUE, center = TRUE, scale = TRUE,  # PCA parameters
                   species = "Trips_palmi",
                   partition_method = "kfolds", 
                   n_partitions = 4,
                   n_background = 1000,
                   features = c("l", "q", "lq", "lqp"),
                   r_multiplier = c(0.1, 1, 2))
