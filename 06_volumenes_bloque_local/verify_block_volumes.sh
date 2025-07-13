#!/bin/bash
set -euo pipefail

# LESSON6 - Block Volumes Architecture Verification Script
# This script verifies the complete deployment including Load Balancer, FSS, and Block Volumes

echo "🔍 LESSON6 - Verificación Completa de Arquitectura con Block Volumes"
echo "=================================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get Load Balancer IP
echo -e "${BLUE}📡 Obteniendo información del Load Balancer...${NC}"
LB_IP=$(terraform output -raw LoadBalancer_IP 2>/dev/null)

if [ -z "$LB_IP" ]; then
    echo -e "${RED}❌ No se pudo obtener la IP del Load Balancer${NC}"
    echo "Ejecuta: terraform output LoadBalancer_IP"
    exit 1
fi

echo -e "${GREEN}✅ Load Balancer IP: $LB_IP${NC}"

# Get Bastion IP
echo -e "${BLUE}📡 Obteniendo información del Bastion...${NC}"
BASTION_IP=$(terraform output -raw Bastion_IP 2>/dev/null)

if [ -z "$BASTION_IP" ]; then
    echo -e "${RED}❌ No se pudo obtener la IP del Bastion${NC}"
    echo "Ejecuta: terraform output Bastion_IP"
    exit 1
fi

echo -e "${GREEN}✅ Bastion IP: $BASTION_IP${NC}"

# Test Load Balancer Health
echo -e "\n${BLUE}🏥 Verificando Health Check del Load Balancer...${NC}"
for i in {1..5}; do
    echo -e "${YELLOW}Intento $i/5:${NC}"
    RESPONSE=$(curl -s -w "HTTP_CODE:%{http_code}" http://$LB_IP/ 2>/dev/null)
    HTTP_CODE=$(echo $RESPONSE | grep -o 'HTTP_CODE:[0-9]*' | cut -d: -f2)
    CONTENT=$(echo $RESPONSE | sed 's/HTTP_CODE:[0-9]*$//')
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "${GREEN}✅ Load Balancer responde correctamente (HTTP $HTTP_CODE)${NC}"
        echo -e "${GREEN}📄 Contenido recibido: $(echo $CONTENT | grep -o '<title>[^<]*' | sed 's/<title>//')${NC}"
        break
    else
        echo -e "${RED}❌ Load Balancer no responde correctamente (HTTP $HTTP_CODE)${NC}"
        if [ $i -eq 5 ]; then
            echo -e "${RED}💥 Load Balancer falló después de 5 intentos${NC}"
        else
            echo -e "${YELLOW}⏳ Esperando 10 segundos antes del siguiente intento...${NC}"
            sleep 10
        fi
    fi
done

# Test Load Balancer Distribution
echo -e "\n${BLUE}⚖️ Verificando distribución de carga...${NC}"
echo "Realizando 10 peticiones para verificar round-robin:"

declare -A server_count
for i in {1..10}; do
    RESPONSE=$(curl -s http://$LB_IP/ 2>/dev/null)
    if [[ $RESPONSE =~ WebServer[[:space:]]+([^[:space:]]+) ]]; then
        SERVER="${BASH_REMATCH[1]}"
        ((server_count[$SERVER]++))
        echo -e "${GREEN}Petición $i: Servidor $SERVER${NC}"
    else
        echo -e "${RED}Petición $i: No se pudo identificar el servidor${NC}"
    fi
    sleep 1
done

echo -e "\n${BLUE}📊 Resumen de distribución:${NC}"
for server in "${!server_count[@]}"; do
    echo -e "${GREEN}  $server: ${server_count[$server]} peticiones${NC}"
done

# Test specific content paths
echo -e "\n${BLUE}📁 Verificando contenido específico...${NC}"

# Test FSS content
echo -e "${YELLOW}🗂️ Verificando contenido FSS...${NC}"
FSS_RESPONSE=$(curl -s -w "HTTP_CODE:%{http_code}" http://$LB_IP/shared/shared-content.html 2>/dev/null)
FSS_HTTP_CODE=$(echo $FSS_RESPONSE | grep -o 'HTTP_CODE:[0-9]*' | cut -d: -f2)

if [ "$FSS_HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ Contenido FSS accesible${NC}"
else
    echo -e "${RED}❌ Contenido FSS no accesible (HTTP $FSS_HTTP_CODE)${NC}"
fi

# Test Block Volume content
echo -e "${YELLOW}💾 Verificando contenido Block Volume...${NC}"
BV_RESPONSE=$(curl -s -w "HTTP_CODE:%{http_code}" http://$LB_IP/blockvolume/ 2>/dev/null)
BV_HTTP_CODE=$(echo $BV_RESPONSE | grep -o 'HTTP_CODE:[0-9]*' | cut -d: -f2)

if [ "$BV_HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ Contenido Block Volume accesible${NC}"
else
    echo -e "${RED}❌ Contenido Block Volume no accesible (HTTP $BV_HTTP_CODE)${NC}"
fi

# Test Bastion connectivity
echo -e "\n${BLUE}🏰 Verificando conectividad del Bastion...${NC}"
if ping -c 1 $BASTION_IP > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Bastion Host es accesible${NC}"
else
    echo -e "${RED}❌ Bastion Host no es accesible${NC}"
fi

# Performance test
echo -e "\n${BLUE}⚡ Prueba de rendimiento básica...${NC}"
echo "Realizando 20 peticiones concurrentes:"

start_time=$(date +%s)
for i in {1..20}; do
    curl -s http://$LB_IP/ > /dev/null &
done
wait
end_time=$(date +%s)
duration=$((end_time - start_time))

echo -e "${GREEN}✅ 20 peticiones completadas en $duration segundos${NC}"

# Summary
echo -e "\n${BLUE}📋 RESUMEN DE VERIFICACIÓN${NC}"
echo "================================"
echo -e "${GREEN}✅ Load Balancer IP: $LB_IP${NC}"
echo -e "${GREEN}✅ Bastion IP: $BASTION_IP${NC}"

# Final recommendations
echo -e "\n${BLUE}💡 RECOMENDACIONES${NC}"
echo "==================="
echo "1. Verificar que todos los backends estén healthy en la consola de OCI"
echo "2. Monitorear los logs de Apache en los servidores web"
echo "3. Verificar montaje de FSS y Block Volumes via Bastion"
echo "4. Probar acceso SSH via Bastion a los servidores web"

echo -e "\n${BLUE}🔗 URLs de prueba:${NC}"
echo "=================="
echo "• Página principal: http://$LB_IP/"
echo "• Contenido FSS: http://$LB_IP/shared/shared-content.html"
echo "• Contenido Block Volume: http://$LB_IP/blockvolume/"

echo -e "\n${GREEN}🎉 Verificación de LESSON6 completada${NC}" 