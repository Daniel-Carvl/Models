source("utils/functions.R")
source("utils/libraries.R")
library(geodata)
library(terra)

current_layer <- 
  geodata::worldclim_global(
    "bio",
    res = 5,
    path = 'data/layers/current'
  )

# diretório de saída em asc
out_dir <- "data/layers/current_asc"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
tif_dir <- "data/layers/current"     

tif_files <- list.files(
  tif_dir,
  pattern = "\\.tif$",
  full.names = TRUE
)


for (f in tif_files) {
  
  r <- rast(f)
  
  # Extrair número após "bio_" e criar bioX.asc
  out_name <- gsub(".*bio_([0-9]+)\\.tif$", "bio\\1.asc", basename(f), ignore.case = TRUE)
  out_file <- file.path(out_dir, out_name)
  
  writeRaster(r, out_file, filetype = "AAIGrid", overwrite = TRUE, NAflag = -9999)
  cat("Convertido:", basename(f), "->", out_name, "\n")
}



base_dir <- file.path(getwd(), "data/layers/cmip6")
dir.create(base_dir, showWarnings = FALSE)

scenarios <- data.frame(
  model = c(
    "HadGEM3-GC31-LL", "HadGEM3-GC31-LL",
    "HadGEM3-GC31-LL", "HadGEM3-GC31-LL",
    "MIROC6", "MIROC6",
    "MIROC6", "MIROC6"
  ),
  ssp = c(
    "245", "245", "585", "585",
    "245", "245", "585", "585"
  ),
  period = c(
    "2041-2060", "2081-2100",
    "2041-2060", "2081-2100",
    "2041-2060", "2081-2100",
    "2041-2060", "2081-2100"
  ),
  scenario_name = c(
    "HadGEM3-GC31-LL_ssp245_2041-2060",
    "HadGEM3-GC31-LL_ssp245_2081-2100",
    "HadGEM3-GC31-LL_ssp585_2041-2060",
    "HadGEM3-GC31-LL_ssp585_2081-2100",
    "MIROC6_ssp245_2041-2060",
    "MIROC6_ssp245_2081-2100",
    "MIROC6_ssp585_2041-2060",
    "MIROC6_ssp585_2081-2100"
  ),
  stringsAsFactors = FALSE
)

for (i in seq_len(nrow(scenarios))) {
  
  scenario_name <- scenarios$scenario_name[i]
  scenario_dir  <- file.path(base_dir, scenario_name)
  dir.create(scenario_dir, showWarnings = FALSE)
  
  message("Processando: ", scenario_name)
  
  r <- geodata::cmip6_world(
    model = scenarios$model[i],
    ssp   = scenarios$ssp[i],
    time  = scenarios$period[i],
    var   = "bioc",
    res   = 5,
    path  = getwd()
  )
  
  for (j in seq_len(nlyr(r))) {
    
    out_file <- file.path(
      scenario_dir,
      paste0("bio", j, ".asc")
    )
    
    layer <- r[[j]]
    
    # 🔑 FORÇA leitura dos valores
    v <- values(layer, mat = FALSE)
    
    # recria raster materializado
    layer_mem <- rast(layer)
    values(layer_mem) <- v
    
    writeRaster(
      layer_mem,
      out_file,
      overwrite = TRUE,
      filetype = "AAIGrid",
      wopt = list(NAflag = -9999)
    )
  }
  
  rm(r)
  gc()
}





