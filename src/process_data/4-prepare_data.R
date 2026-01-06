# Load packages
library(kuenm2)
library(terra)

# Current directory
getwd()

# Saving original plotting parameters
original_par <- par(no.readonly = TRUE)


terra::plot(var)

# Prepare data for maxnet model
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
