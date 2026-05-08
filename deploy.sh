#!/bin/bash
# ========================================
# SCRIPT DE DEPLOY AUTOMÁTICO
# ========================================
# Este script automatiza los pasos de build y deploy
# Uso: bash deploy.sh

echo "🚀 Starting Tweeter API Deployment..."

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuración
DOCKER_USERNAME="tu-usuario-dockerhub"
APP_NAME="tweeter-api"
VERSION="latest"

echo -e "${YELLOW}Paso 1: Compilando Backend...${NC}"
cd tweeter-api
mvn clean package -DskipTests

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Build completado exitosamente${NC}"
else
    echo -e "${RED}✗ Error en el build${NC}"
    exit 1
fi

echo -e "\n${YELLOW}Paso 2: Construyendo imagen Docker...${NC}"
docker build -t $DOCKER_USERNAME/$APP_NAME:$VERSION .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Imagen Docker creada${NC}"
else
    echo -e "${RED}✗ Error al crear imagen${NC}"
    exit 1
fi

echo -e "\n${YELLOW}Paso 3: Login en Docker Hub...${NC}"
docker login

echo -e "\n${YELLOW}Paso 4: Subiendo imagen a Docker Hub...${NC}"
docker push $DOCKER_USERNAME/$APP_NAME:$VERSION

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Imagen subida exitosamente${NC}"
else
    echo -e "${RED}✗ Error al subir imagen${NC}"
    exit 1
fi

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Deploy completado exitosamente!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\nPróximos pasos:"
echo "1. Ve a https://render.com"
echo "2. Crear nuevo Web Service"
echo "3. Usar imagen: $DOCKER_USERNAME/$APP_NAME:$VERSION"
echo "4. Configurar variables de ambiente (Database)"
echo "5. Deploy y copiar URL pública"
