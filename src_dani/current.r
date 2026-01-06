# Models
# Carregar os pacotes necessários
library(ggplot2)    # To plot locations
library(maps)       # To access useful maps
library(rasterVis)  # To plot raster objects
library(zeallot)
library(terra)
library(rJava)
library(kableExtra)
library(plotROC)
library(dismo)
library(raster)
library(sf)
library(rnaturalearth)
library(geodata)
library(reshape2)
library(SDMtune)
library(rnaturalearthdata)
library(spThin)
library(readxl)

# Converter coordenadas para numérico
Trips_palmi$lon <- as.numeric(as.character(Trips_palmi$lon))
Trips_palmi$lat <- as.numeric(as.character(Trips_palmi$lat))

# Preparar dados para thinning
xy <- data.frame(sp = "Trips", Trips_palmi)
xy_unique <- xy[!duplicated(xy[, c("lat", "lon")]), ]
cat("Registros originais:", nrow(xy), "\n")
cat("Após remover duplicatas:", nrow(xy_unique), "\n")

# Thin points - remover pontos muito próximos
distance = 1 # km
xy.t <- thin(loc.data = xy_unique, lat.col = "lat", long.col = "lon", spec.col = "sp",
             thin.par = distance, reps = 1, write.files = FALSE, 
             locs.thinned.list.return = TRUE)

xy.t <- data.frame(spp = "Trips", xy.t[[1]])
colnames(xy.t)[2:3] <- c("lon", "lat")
geo <- xy.t
cat("Registros finais:", nrow(geo), "\n")
# Converter para SpatialPoints
coordinates(geo) <- ~ lon + lat
crs(geo) <- "+proj=longlat +datum=WGS84"

# Carregar variáveis ambientais (WorldClim)
folder <- "C:/Users/Usuário/Documents/Daniel/Artigo Adriano/WorldClim"
files <- list.files(folder, pattern = "\\.tif$", full.names = TRUE)
predictors <- rast(files)
names(predictors)
# Amostrar pontos aleatórios por célula (ajuste n conforme sua memória)
set.seed(123) # para reproducibilidade
sample_points <- spatSample(predictors, size = 10000, method = "random", na.rm = TRUE)

# Remover quaisquer NAs restantes
sample_points <- na.omit(sample_points)

# Verificar a amostra
dim(sample_points)
head(sample_points)

# Padronizar os dados (muito importante para PCA)
scaled_data <- scale(sample_points)

# Verificar se a padronização funcionou
summary(scaled_data)
apply(scaled_data, 2, mean) # Médias ≈ 0
apply(scaled_data, 2, sd)   # Desvios padrão ≈ 1

# Realizar a PCA
pca_result <- prcomp(scaled_data, center = FALSE, scale. = FALSE)

# Resumo detalhado
summary_pca <- summary(pca_result)
print(summary_pca)

# Definir número de componentes
n_final_components <- 2

cat("=== USANDO PC1 E PC2 PARA MODELAGEM ===\n")
cat("PC1 explica:", round(51.4, 1), "% da variância\n")
cat("PC2 explica:", round(22.05, 1), "% da variância\n")
cat("TOTAL:", round(73.45, 1), "% da variância explicada\n")

# Loadings específicos para PC1 e PC2
loadings_pc1_pc2 <- pca_result$rotation[, 1:2]
print("Loadings de PC1 e PC2:")
print(round(loadings_pc1_pc2, 3))

# Criar tabela mais legível
loadings_table <- data.frame(
  Variable = rownames(loadings_pc1_pc2),
  PC1 = round(loadings_pc1_pc2[, 1], 3),
  PC2 = round(loadings_pc1_pc2[, 2], 3),
  Abs_PC1 = round(abs(loadings_pc1_pc2[, 1]), 3),
  Abs_PC2 = round(abs(loadings_pc1_pc2[, 2]), 3)
)

# Ordenar por importância em PC1
loadings_table <- loadings_table[order(-loadings_table$Abs_PC1), ]
print("Variáveis ordenadas por importância no PC1:")
print(loadings_table)

# Interpretação ecológica
cat("\n=== INTERPRETAÇÃO DOS COMPONENTES ===\n")

# PC1
cat("\n📊 PC1 (51.4% da variância) - Gradiente Principal:\n")
top_pc1_positive <- head(loadings_table[order(-loadings_table$PC1), ], 3)
top_pc1_negative <- head(loadings_table[order(loadings_table$PC1), ], 3)

cat("Principais contribuições POSITIVAS:\n")
print(top_pc1_positive[, c("Variable", "PC1")])
cat("Principais contribuições NEGATIVAS:\n") 
print(top_pc1_negative[, c("Variable", "PC1")])

# PC2
cat("\n📊 PC2 (22.1% da variância) - Gradiente Secundário:\n")
top_pc2_positive <- head(loadings_table[order(-loadings_table$PC2), ], 3)
top_pc2_negative <- head(loadings_table[order(loadings_table$PC2), ], 3)

cat("Principais contribuições POSITIVAS:\n")
print(top_pc2_positive[, c("Variable", "PC2")])
cat("Principais contribuições NEGATIVAS:\n")
print(top_pc2_negative[, c("Variable", "PC2")])

# Vamos criar um dicionário das variáveis para facilitar a interpretação
bio_vars <- data.frame(
  Variable = c(
    "wc2.1_5m_bio_1", "wc2.1_5m_bio_2", "wc2.1_5m_bio_3", 
    "wc2.1_5m_bio_4", "wc2.1_5m_bio_5", "wc2.1_5m_bio_6",
    "wc2.1_5m_bio_7", "wc2.1_5m_bio_8", "wc2.1_5m_bio_9",
    "wc2.1_5m_bio_10", "wc2.1_5m_bio_11", "wc2.1_5m_bio_12",
    "wc2.1_5m_bio_13", "wc2.1_5m_bio_14", "wc2.1_5m_bio_15",
    "wc2.1_5m_bio_16", "wc2.1_5m_bio_17", "wc2.1_5m_bio_18",
    "wc2.1_5m_bio_19"
  ),
  Description = c(
    "Temperatura Média Anual",
    "Variação Média Diária (Média mensal (max temp - min temp))",
    "Isotermalidade (BIO2/BIO7) × 100",
    "Sazonalidade da Temperatura (desvio padrão × 100)",
    "Temperatura Máxima do Mês Mais Quente",
    "Temperatura Mínima do Mês Mais Frio",
    "Variação Anual da Temperatura (BIO5-BIO6)",
    "Temperatura Média do Trimestre Mais Chuvoso",
    "Temperatura Média do Trimestre Mais Seco",
    "Temperatura Média do Trimestre Mais Quente",
    "Temperatura Média do Trimestre Mais Frio",
    "Precipitação Anual",
    "Precipitação do Mês Mais Chuvoso",
    "Precipitação do Mês Mais Seco",
    "Sazonalidade da Precipitação (Coeficiente de Variação)",
    "Precipitação do Trimestre Mais Chuvoso",
    "Precipitação do Trimestre Mais Seco",
    "Precipitação do Trimestre Mais Quente",
    "Precipitação do Trimestre Mais Frio"
  )
)

print(bio_vars)
library(vegan)
library(factoextra)
# Biplot dos dois primeiros componentes
fviz_pca_biplot(pca_result, 
                axes = c(1, 2),
                col.var = "contrib",
                gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                repel = TRUE,
                title = "Biplot - PC1 vs PC2")

# Gráfico apenas das variáveis nos dois primeiros componentes
fviz_pca_var(pca_result, 
             axes = c(1, 2),
             col.var = "contrib",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE,
             title = "Variáveis nos Dois Primeiros Componentes")

# Função otimizada para 2 componentes
create_pc1_pc2_raster <- function(raster_data, pca_model) {
  # Extrair estatísticas de padronização
  center_vals <- attr(scaled_data, "scaled:center")
  scale_vals <- attr(scaled_data, "scaled:scale")
  
  # Função para aplicar PCA
  pca_fun <- function(x) {
    # Padronizar
    x_scaled <- scale(x, center = center_vals, scale = scale_vals)
    # Aplicar transformação PCA e manter apenas PC1 e PC2
    pca_scores <- x_scaled %*% pca_model$rotation
    return(pca_scores[, 1:2])
  }
  
  # Aplicar ao raster
  pc_raster <- app(raster_data, pca_fun)
  names(pc_raster) <- c("PC1", "PC2")
  
  return(pc_raster)
}

# Criar raster com PC1 e PC2
cat("Criando raster com PC1 e PC2...\n")
pc12_predictors <- create_pc1_pc2_raster(predictors, pca_result)

# Verificar resultado
print(pc12_predictors)
cat("Dimensões do raster PCA:", dim(pc12_predictors), "\n")

# Plotar os dois componentes lado a lado
par(mfrow = c(1, 2))
plot(pc12_predictors$PC1, 
     main = paste("PC1 (", round(51.4, 1), "%)"),
     col = colorRampPalette(c("blue", "white", "red"))(100))
plot(pc12_predictors$PC2, 
     main = paste("PC2 (", round(22.1, 1), "%)"),
     col = colorRampPalette(c("darkgreen", "lightgreen", "yellow"))(100))
par(mfrow = c(1, 1))

# Plot conjunto
plot(pc12_predictors, 
     main = "Componentes Principais 1 e 2 para Modelagem")

# Salvar raster com apenas PC1 e PC2
writeRaster(pc12_predictors, 
            filename = "worldclim_pc1_pc2.tif",
            overwrite = TRUE,
            filetype = "GTiff")

# Salvar versão compactada se necessário
writeRaster(pc12_predictors, 
            filename = "worldclim_pc1_pc2_compressed.tif",
            overwrite = TRUE,
            gdal = c("COMPRESS=DEFLATE"))

# Salvar metadados importantes
pca_metadata <- list(
  n_components = 2,
  variance_explained = summary_pca$importance[2, 1:2],
  cumulative_variance = summary_pca$importance[3, 2],
  loadings = loadings_pc1_pc2,
  scaling_center = attr(scaled_data, "scaled:center"),
  scaling_scale = attr(scaled_data, "scaled:scale")
)

saveRDS(pca_metadata, file = "pca_pc1_pc2_metadata.rds")

# Salvar tabela de loadings em CSV
write.csv(loadings_table, 
          file = "pc1_pc2_loadings.csv", 
          row.names = FALSE)

cat("\n=== ARQUIVOS SALVOS ===\n")
cat("✅ worldclim_pc1_pc2.tif - Raster com PC1 e PC2 para modelagem\n")
cat("✅ pca_pc1_pc2_metadata.rds - Metadados da PCA\n")
cat("✅ pc1_pc2_loadings.csv - Tabela de loadings\n")



# VERIFICAÇÕES INICIAIS ====================================================
print("=== VERIFICAÇÕES INICIAIS ===")
print(paste("Número de presenças após thinning:", nrow(geo)))
print("Extensão dos predictors:")
print(ext(pc12_predictors))

# CONFIGURAÇÃO OTIMIZADA PARA MODELAGEM ===================================
set.seed(123)

# Número otimizado de pseudo-ausências (ratio 5:1)
n_presencas <- nrow(geo)
n_pseudo_optimizado <- n_presencas * 5  # Ratio 5:1
print(paste("Número de presenças:", n_presencas))
print(paste("Número otimizado de pseudo-ausências:", n_pseudo_optimizado))

# CONVERTER SpatRaster global para RasterLayer
mask_raster_raster <- raster(pc12_predictors[[1]])
mask_raster_raster[!is.na(mask_raster_raster)] <- 1

# Gerar pseudo-ausências em TODO o mundo
pseudo_ausencias <- randomPoints(mask_raster_raster, n = n_pseudo_optimizado)

# Converter para dataframe
pseudo_ausencias_df <- data.frame(pseudo_ausencias)
colnames(pseudo_ausencias_df) <- c("lon", "lat")

# CRIAR presencas_df (que estava faltando)
presencas_df <- data.frame(geo)[, c("lon", "lat")]

# Adicionar coluna de presença/ausência
pseudo_ausencias_df$presence <- 0
presencas_df$presence <- 1

# Combinar presenças e pseudo-ausências
occ_data <- rbind(presencas_df, pseudo_ausencias_df)

print(paste("✅ Total de pontos:", nrow(occ_data)))
print(paste("✅ Presenças:", sum(occ_data$presence)))
print(paste("✅ Pseudo-ausências:", sum(occ_data$presence == 0)))
print(paste("✅ Ratio final:", round(n_pseudo_optimizado/n_presencas, 1), ":1"))

par(mfrow=c(1,1))
# PLOT DOS DADOS FINAIS ====================================================
plot(predictors[[1]], main = paste("Distribuição de Trips palmi\n",
                                   "Presenças:", n_presencas, 
                                   "Pseudo-ausências:", n_pseudo_optimizado))

# Adicionar mapa mundial
map('world', add = TRUE, col = "gray80", fill = TRUE)

# Plotar pseudo-ausências
points(occ_data$lon[occ_data$presence == 0], 
       occ_data$lat[occ_data$presence == 0], 
       col = adjustcolor("blue", alpha.f = 0.2), 
       pch = 16, cex = 0.3)

# Plotar presenças
points(occ_data$lon[occ_data$presence == 1], 
       occ_data$lat[occ_data$presence == 1], 
       col = "red", pch = 16, cex = 0.8)

legend("bottomleft", 
       legend = c(paste("Presenças (", n_presencas, ")"), 
                  paste("Pseudo-ausências (", n_pseudo_optimizado, ")")),
       col = c("red", adjustcolor("blue", alpha.f = 0.6)), 
       pch = 16, cex = 0.8, bg = "white")

# Carregar pacotes necessários
library(sdm)
library(raster)
library(terra)

# Preparar dados no formato do pacote sdm
# Usando seus dados já processados:
# occ_data tem presenças (1) e pseudo-ausências (0)
# predictors são suas variáveis ambientais

# Converter para formato sdmData
spp <- "Trips_palmi"

# Preparar dados de presença
presencas <- occ_data[occ_data$presence == 1, c("lon", "lat")]
presencas$species <- 1  # Adicionar coluna da espécie

# Preparar dados de background (pseudo-ausências)
background <- occ_data[occ_data$presence == 0, c("lon", "lat")]

# 1. Criar dataframe com coordenadas
sdm_train_data <- data.frame(
  species = occ_data$presence,
  x = occ_data$lon,
  y = occ_data$lat
)

# 2. Criar sdmData com coords() na fórmula - FORMA CORRETA
my.sdm.data <- sdmData(
  formula = species ~ . + coords(x + y),  # AQUI ESTÁ A CHAVE!
  train = sdm_train_data,
  predictors = pc12_predictors
)

print(my.sdm.data)

# Verificar o resumo dos dados
summary(my.sdm.data)

# Verificar quais métodos estão disponíveis
getmethodNames()

# maxnet é uma implementação moderna em R puro
available_models <- c("glm", "maxnet", "rf")

my.sdm.out2 <- sdm(
  formula = species ~ .,
  data = my.sdm.data,
  methods = available_models,
  replication = 'cv',
  cv.folds = 5,
  n = 10
)

# Ver se todos os modelos funcionaram
print(my.sdm.out2)
summary(my.sdm.out2)

cat("\n=== NOVO MODELO (com maxnet) ===\n") 
print(my.sdm.out2)

# Ensemble final com todos os 6 algoritmos funcionando
ensemble_global <- ensemble(
  my.sdm.out2, 
  newdata = pc12_predictors,
  filename = "Trips_palmi_global_ensemble_final.tif",
  setting = list(
    method = 'weighted', 
    stat = 'AUC', 
    opt = 2
  ),
  overwrite = TRUE
)

# Configurar plot para tela cheia
par(mar = c(4, 4, 4, 6))  # Margens maiores para a legenda

# Plotar o mapa em alta qualidade
plot(ensemble_global, 
     main = "Global Potential Distribution - Trips palmi",
     col = colorRampPalette(c("blue", "cyan", "yellow", "red"))(100),
     axes = TRUE,
     plg = list(size = c(1, 1.5), # Legenda maior
                title = "Suitability"),
     cex.main = 1.2,
     smooth = TRUE)  # Suaviza as cores

# Adicionar continentes com mais detalhes
library(maps)
map('world', add = TRUE, col = "gray20", fill = FALSE, lwd = 0.5)

# Adicionar pontos de ocorrência
points(occ_data$lon[occ_data$presence == 1], 
       occ_data$lat[occ_data$presence == 1], 
       col = "black", pch = 21, bg = "white", cex = 0.8, lwd = 0.1)

# Legenda detalhada
legend("bottomleft",
       legend = c("Alta adequabilidade", "Baixa adequabilidade", "Registros de ocorrência"),
       fill = c("red", "blue", NA),
       border = c(NA, NA, "black"),
       pch = c(NA, NA, 21),
       pt.bg = c(NA, NA, "white"),
       bg = "white", 
       cex = 0.8)
# Tabela de avaliação completa
eval_results <- getEvaluation(my.sdm.out2)
write.csv(eval_results, "Trips_palmi_model_evaluation_FINAL.csv", row.names = FALSE)

# Carregar o dplyr
library(dplyr)

# Agora sim, calcular as estatísticas resumidas
performance_summary <- eval_results %>%
  mutate(algorithm = case_when(
    modelID <= 50 ~ "glm",
    modelID <= 100 ~ "maxnet", 
    modelID <= 150 ~ "rf"
  )) %>%
  group_by(algorithm) %>%
  summarise(
    AUC_mean = round(mean(AUC), 3),
    AUC_sd = round(sd(AUC), 3),
    TSS_mean = round(mean(TSS), 3),
    TSS_sd = round(sd(TSS), 3),
    n_models = n()
  ) %>%
  arrange(desc(AUC_mean))

print(performance_summary)
# Carregar pacote para exportar HTML
library(knitr)
library(webshot)

# Salvar como HTML formatado
html_table <- performance_summary %>%
  knitr::kable(format = "html", digits = 3,
               caption = "Performance of Modeling Algorithms - Trips palmi",
               col.names = c("Algorithm", "Average AUC", "AUC SD", "Average TSS", "TSS SD", "N° Models")) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed"),
                            full_width = FALSE,
                            font_size = 14)

# Salvar arquivo HTML
writeLines(html_table, "Trips_palmi_performance_table.html")

# Análise de quais variáveis ambientais são mais importantes
var_imp <- getVarImp(my.sdm.out2)
plot(var_imp, main = "Importance of Variables - Trips palmi")

# Salvar tabela
var_imp_table <- var_imp@varImportanceMean
write.table(var_imp_table, "Trips_palmi_variable_importance.txt")
html_table <- var_imp_table %>%
  knitr::kable(format = "html", digits = 3,
               caption = "Importance of Variables - Trips palmi",
               col.names = c("Axes", "variables", "corTest", "lower", "upper")) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed"),
                            full_width = FALSE,
                            font_size = 14)
# Salvar arquivo HTML
writeLines(html_table, "Importance of Variables - Trips palmi.html")

# Calcular threshold
# Método 1: Threshold para o ENSEMBLE (recomendado)
thresholds <- sdm::threshold(my.sdm.out2, id = "ensemble")
print(thresholds)

# Criar mapa binário CORRETAMENTE
binary_map <- ensemble_global > thresholds

par(mfrow = c(1, 2))
# Plotar
plot(binary_map, 
     main = paste("Suitable Areas - Trips palmi\nThreshold =", round(thresholds, 3)),
     col = c("lightgray", "darkgreen"))

# Adicionar continentes
map('world', add = TRUE, col = "gray30", lwd = 0.6)

# Legenda
legend("bottomleft",
       legend = c(paste("Não Adequado (<", round(thresholds, 3), ")"), 
                  paste("Adequado (≥", round(thresholds, 3), ")")),
       fill = c("lightgray", "darkgreen"),
       bg = "white")

# Salvar
writeRaster(binary_map, "Trips_palmi_binary_map.tif", overwrite = TRUE)
cat("✅ Mapa binário salvo com threshold de", thresholds, "\n")