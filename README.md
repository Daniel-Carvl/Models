📦 Modelagem de Nicho Ecológico com kuenm2

Este repositório contém scripts, dados e resultados relacionados à modelagem de nicho ecológico (ENM/SDM) utilizando o pacote kuenm2 em R, com foco na calibração, avaliação e projeção de modelos (ex.: MaxEnt).

📁 Estrutura do Projeto
.
├── .gitignore
├── Clean_data.rds
├── Models.Rproj
├── src/
  │   └── processed_data/
  │       ├── model/
  │       └── pos_processed/
  └── src_dani/
  
  🗂️ Descrição dos Diretórios e Arquivos
.gitignore

Define arquivos e pastas que não devem ser versionados (outputs grandes, rasters intermediários, arquivos temporários, etc.).

Clean_data.rds

Arquivo RDS contendo os dados já limpos e preparados para a modelagem, incluindo:
  
  registros de ocorrência

variáveis ambientais

filtros e pré-processamentos aplicados

Models.Rproj

Projeto do RStudio, utilizado para organização do ambiente e reprodutibilidade das análises.

📂 src/
  
  Diretório principal do pipeline atual de modelagem de nicho.

src/processed_data/
  
  Armazena dados intermediários e resultados gerados durante o processo de modelagem.

model/
  
  Contém os outputs gerados pelo kuenm2, tais como:
  
  modelos calibrados

métricas de avaliação (AICc, taxa de omissão, ROC parcial)

projeções espaciais

arquivos auxiliares do MaxEnt

pos_processed/
  
  Resultados das etapas de pós-processamento, incluindo:
  
  seleção do melhor modelo

análises comparativas

reclassificação de mapas

mapas finais prontos para visualização, relatórios ou publicação

📂 src_dani/
  
  Diretório contendo o modelo inicial desenvolvido pelo Daniel, mantido como referência metodológica e para comparação com a abordagem atual utilizando kuenm2.

🔁 Fluxo Geral do Projeto

Preparação e limpeza dos dados (Clean_data.rds)

Calibração dos modelos com kuenm2

Avaliação e seleção dos melhores modelos

Projeção espacial da adequabilidade ambiental

Pós-processamento e análise final dos resultados

🛠️ Requisitos

R (>= 4.x)

Java (necessário para MaxEnt)

Principais pacotes:
  
  kuenm2

terra

raster

sf

dplyr

ggplot2

📌 Observações

O projeto foi estruturado para garantir reprodutibilidade e organização clara do pipeline ENM/SDM.

Alterações no fluxo principal devem ser feitas preferencialmente dentro do diretório src/.

O diretório src_dani/ não deve ser modificado, pois representa o modelo base original.📦 Modelagem de Nicho Ecológico com kuenm2

Este repositório contém scripts, dados e resultados relacionados à modelagem de nicho ecológico (ENM/SDM) utilizando o pacote kuenm2 em R, com foco na calibração, avaliação e projeção de modelos (ex.: MaxEnt).

📁 Estrutura do Projeto
.
├── .gitignore
├── Clean_data.rds
├── Models.Rproj
├── src/
  │   └── processed_data/
  │       ├── model/
  │       └── pos_processed/
  └── src_dani/
  
  🗂️ Descrição dos Diretórios e Arquivos
.gitignore

Define arquivos e pastas que não devem ser versionados (outputs grandes, rasters intermediários, arquivos temporários, etc.).

Clean_data.rds

Arquivo RDS contendo os dados já limpos e preparados para a modelagem, incluindo:
  
  registros de ocorrência

variáveis ambientais

filtros e pré-processamentos aplicados

Models.Rproj

Projeto do RStudio, utilizado para organização do ambiente e reprodutibilidade das análises.

📂 src/
  
  Diretório principal do pipeline atual de modelagem de nicho.

src/processed_data/
  
  Armazena dados intermediários e resultados gerados durante o processo de modelagem.

model/
  
  Contém os outputs gerados pelo kuenm2, tais como:
  
  modelos calibrados

métricas de avaliação (AICc, taxa de omissão, ROC parcial)

projeções espaciais

arquivos auxiliares do MaxEnt

pos_processed/
  
  Resultados das etapas de pós-processamento, incluindo:
  
  seleção do melhor modelo

análises comparativas

reclassificação de mapas

mapas finais prontos para visualização, relatórios ou publicação

📂 src_dani/
  
  Diretório contendo o modelo inicial desenvolvido pelo Daniel, mantido como referência metodológica e para comparação com a abordagem atual utilizando kuenm2.

🔁 Fluxo Geral do Projeto

Preparação e limpeza dos dados (Clean_data.rds)

Calibração dos modelos com kuenm2

Avaliação e seleção dos melhores modelos

Projeção espacial da adequabilidade ambiental

Pós-processamento e análise final dos resultados

🛠️ Requisitos

R (>= 4.x)

Java (necessário para MaxEnt)

Principais pacotes:
  
  kuenm2

terra

raster

sf

dplyr

ggplot2

📌 Observações

O projeto foi estruturado para garantir reprodutibilidade e organização clara do pipeline ENM/SDM.

Alterações no fluxo principal devem ser feitas preferencialmente dentro do diretório src/.

O diretório src_dani/ não deve ser modificado, pois representa o modelo base original.