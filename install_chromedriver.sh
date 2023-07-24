#!/bin/bash

# Script para instalar o ChromeDriver no ambiente do WSL 2

# Define a versão do ChromeDriver que você deseja baixar
CHROMEDRIVER_VERSION="100.0.4896.20"

# Define o diretório onde o ChromeDriver será instalado
CHROMEDRIVER_DIR="priv/chromedriver"

# Define o URL de download do ChromeDriver
CHROMEDRIVER_URL="https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip"

# Cria o diretório para o ChromeDriver
mkdir -p $CHROMEDRIVER_DIR

# Baixa o ChromeDriver
wget $CHROMEDRIVER_URL -P $CHROMEDRIVER_DIR

# Descompacta o ChromeDriver
unzip "${CHROMEDRIVER_DIR}/chromedriver_linux64.zip" -d $CHROMEDRIVER_DIR

# Define as permissões de execução para o ChromeDriver
chmod +x "${CHROMEDRIVER_DIR}/chromedriver"

# Exibe uma mensagem de conclusão
echo "ChromeDriver instalado com sucesso em ${CHROMEDRIVER_DIR}"
