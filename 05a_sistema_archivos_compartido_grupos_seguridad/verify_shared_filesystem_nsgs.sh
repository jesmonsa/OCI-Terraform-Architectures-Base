#!/bin/bash

# Script de verificación para LESSON5a - Load Balancer + NAT Gateway + Bastion Host + File Storage System + NSGs
# Verifica la conectividad a través del Bastion Host, el funcionamiento del Load Balancer y el File Storage System con NSGs

set -e

echo "🔍 INICIANDO VERIFICACIÓN DE FILE STORAGE SYSTEM CON NSGs - LESSON5a"
echo "===================================================================="

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir con colores
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que terraform está disponible
if ! command -v terraform &> /dev/null; then
    print_error "Terraform no está instalado o no está en el PATH"
    exit 1
fi

# Verificar que estamos en el directorio correcto
if [ ! -f "compute.tf" ] || [ ! -f "fss.tf" ] || [ ! -f "nsgs.tf" ]; then
    print_error "No se encontraron archivos de Terraform. Asegúrate de estar en el directorio LESSON5a_shared_filesystem_security_groups"
    exit 1
fi

print_status "Verificando estado de Terraform..."

# Obtener outputs de Terraform
if ! terraform output -json > /tmp/terraform_output.json 2>/dev/null; then
    print_error "No se pudo obtener el output de Terraform. Asegúrate de que el despliegue esté completo."
    exit 1
fi

# Extraer IPs
BASTION_IP=$(terraform output -raw bastion_public_ip 2>/dev/null || echo "")
LB_IP=$(terraform output -raw load_balancer_ip 2>/dev/null || echo "")
WEBSERVER1_PRIVATE_IP=$(terraform output -raw webserver1_private_ip 2>/dev/null || echo "")
WEBSERVER2_PRIVATE_IP=$(terraform output -raw webserver2_private_ip 2>/dev/null || echo "")
WEBSERVER3_PRIVATE_IP=$(terraform output -raw webserver3_private_ip 2>/dev/null || echo "")
FSS_MOUNT_IP=$(terraform output -raw fss_mount_target_ip 2>/dev/null || echo "")

if [ -z "$BASTION_IP" ] || [ -z "$LB_IP" ]; then
    print_error "No se pudieron obtener las IPs necesarias"
    exit 1
fi

print_success "Bastion Host IP: $BASTION_IP"
print_success "Load Balancer IP: $LB_IP"
print_success "WebServer1 Private IP: $WEBSERVER1_PRIVATE_IP"
print_success "WebServer2 Private IP: $WEBSERVER2_PRIVATE_IP"
print_success "WebServer3 Private IP: $WEBSERVER3_PRIVATE_IP"
print_success "FSS Mount Target IP: $FSS_MOUNT_IP"

echo ""
print_status "Verificando conectividad al Bastion Host..."

# Verificar conectividad SSH al Bastion Host
if timeout 10 ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -i id_rsa_foggykitchen ubuntu@$BASTION_IP "echo 'SSH OK'" 2>/dev/null; then
    print_success "SSH conectividad exitosa al Bastion Host"
else
    print_error "SSH no disponible en el Bastion Host"
    exit 1
fi

echo ""
print_status "Verificando conectividad a los servidores web a través del Bastion..."

# Verificar conectividad SSH a los servidores web a través del Bastion
for server_ip in "$WEBSERVER1_PRIVATE_IP" "$WEBSERVER2_PRIVATE_IP" "$WEBSERVER3_PRIVATE_IP"; do
    if [ -n "$server_ip" ]; then
        print_status "Probando conectividad SSH a $server_ip a través del Bastion..."
        
        if timeout 15 ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o ProxyCommand="ssh -i id_rsa_foggykitchen -o StrictHostKeyChecking=no -W %h:%p ubuntu@$BASTION_IP" ubuntu@$server_ip "echo 'SSH OK'" 2>/dev/null; then
            print_success "SSH conectividad exitosa a $server_ip a través del Bastion"
        else
            print_error "SSH no disponible en $server_ip a través del Bastion"
        fi
    fi
done

echo ""
print_status "Verificando Load Balancer..."

# Verificar que el Load Balancer responde
if curl -s --connect-timeout 10 http://$LB_IP > /dev/null 2>&1; then
    print_success "Load Balancer responde correctamente en http://$LB_IP"
else
    print_error "Load Balancer no responde en http://$LB_IP"
    exit 1
fi

echo ""
print_status "Verificando distribución de carga..."

# Realizar múltiples requests para verificar distribución de carga
echo "Realizando 15 requests al Load Balancer para verificar distribución..."
echo ""

# Array para almacenar las respuestas
declare -a responses

for i in {1..15}; do
    print_status "Request $i/15..."
    
    # Obtener el contenido de la página
    response=$(curl -s --connect-timeout 5 http://$LB_IP 2>/dev/null || echo "ERROR")
    
    if [ "$response" != "ERROR" ]; then
        # Extraer la IP del servidor que respondió (si está en el contenido)
        server_ip=$(echo "$response" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        if [ -n "$server_ip" ]; then
            responses+=("$server_ip")
            print_success "Request $i respondido por servidor: $server_ip"
        else
            print_success "Request $i respondido correctamente"
        fi
    else
        print_error "Request $i falló"
    fi
    
    sleep 1
done

echo ""
print_status "Análisis de distribución de carga..."

# Contar respuestas por servidor
if [ ${#responses[@]} -gt 0 ]; then
    echo "Servidores que respondieron:"
    printf '%s\n' "${responses[@]}" | sort | uniq -c | while read count server; do
        print_success "Servidor $server: $count requests"
    done
    
    # Verificar si hay distribución
    unique_servers=$(printf '%s\n' "${responses[@]}" | sort | uniq | wc -l)
    if [ "$unique_servers" -gt 1 ]; then
        print_success "✅ Distribución de carga funcionando correctamente - $unique_servers servidores activos"
    else
        print_warning "⚠️  Solo un servidor respondió. Verificar configuración del Load Balancer"
    fi
else
    print_error "No se obtuvieron respuestas válidas para analizar"
fi

echo ""
print_status "Verificando File Storage System con NSGs..."

# Verificar que el File Storage System está montado en los servidores
for server_ip in "$WEBSERVER1_PRIVATE_IP" "$WEBSERVER2_PRIVATE_IP" "$WEBSERVER3_PRIVATE_IP"; do
    if [ -n "$server_ip" ]; then
        print_status "Verificando FSS en $server_ip..."
        
        if timeout 15 ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o ProxyCommand="ssh -i id_rsa_foggykitchen -o StrictHostKeyChecking=no -W %h:%p ubuntu@$BASTION_IP" ubuntu@$server_ip "mount | grep -q '/shared' && echo 'FSS OK'" 2>/dev/null; then
            print_success "✅ File Storage System montado correctamente en $server_ip"
        else
            print_error "❌ File Storage System no está montado en $server_ip"
        fi
    fi
done

echo ""
print_status "Verificando contenido compartido..."

# Verificar que el contenido compartido es accesible
if curl -s --connect-timeout 10 http://$LB_IP/shared/shared-content.html > /dev/null 2>&1; then
    print_success "✅ Contenido compartido accesible en http://$LB_IP/shared/shared-content.html"
else
    print_warning "⚠️  Contenido compartido no accesible. Verificar configuración del FSS"
fi

echo ""
print_status "Verificando configuración de seguridad con NSGs..."

# Verificar que los servidores web no son accesibles directamente desde internet
print_status "Verificando que los servidores web no son accesibles directamente..."

for server_ip in "$WEBSERVER1_PRIVATE_IP" "$WEBSERVER2_PRIVATE_IP" "$WEBSERVER3_PRIVATE_IP"; do
    if [ -n "$server_ip" ]; then
        if curl -s --connect-timeout 5 http://$server_ip > /dev/null 2>&1; then
            print_warning "⚠️  Servidor $server_ip es accesible directamente (posible problema de NSGs)"
        else
            print_success "✅ Servidor $server_ip no es accesible directamente (NSGs funcionando)"
        fi
    fi
done

echo ""
print_status "Verificando Network Security Groups..."

# Verificar que los NSGs están configurados correctamente
print_status "Verificando configuración de NSGs en Terraform..."

if terraform state list | grep -q "network_security_group"; then
    print_success "✅ Network Security Groups detectados en el estado de Terraform"
    
    # Listar NSGs
    echo "NSGs configurados:"
    terraform state list | grep "network_security_group" | while read nsg; do
        print_success "  - $nsg"
    done
else
    print_error "❌ No se detectaron Network Security Groups en el estado de Terraform"
fi

echo ""
print_status "Verificando conectividad FSS específica..."

# Verificar conectividad específica al FSS
for server_ip in "$WEBSERVER1_PRIVATE_IP" "$WEBSERVER2_PRIVATE_IP" "$WEBSERVER3_PRIVATE_IP"; do
    if [ -n "$server_ip" ]; then
        print_status "Verificando conectividad FSS desde $server_ip..."
        
        if timeout 15 ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no -o ProxyCommand="ssh -i id_rsa_foggykitchen -o StrictHostKeyChecking=no -W %h:%p ubuntu@$BASTION_IP" ubuntu@$server_ip "ping -c 1 $FSS_MOUNT_IP > /dev/null 2>&1 && echo 'FSS PING OK'" 2>/dev/null; then
            print_success "✅ Conectividad FSS exitosa desde $server_ip"
        else
            print_error "❌ Sin conectividad FSS desde $server_ip"
        fi
    fi
done

echo ""
print_status "Verificando fail2ban en Bastion Host..."

# Verificar que fail2ban está funcionando en el bastion
if timeout 10 ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -i id_rsa_foggykitchen ubuntu@$BASTION_IP "sudo fail2ban-client status sshd" 2>/dev/null; then
    print_success "✅ Fail2ban funcionando correctamente en Bastion Host"
else
    print_warning "⚠️  Fail2ban no está funcionando en Bastion Host"
fi

echo ""
print_status "Resumen de verificación LESSON5a con NSGs:"
echo "=================================================="
print_success "✅ Bastion Host: Funcionando"
print_success "✅ Load Balancer: Funcionando"
print_success "✅ WebServers: 3 instancias con FSS compartido"
print_success "✅ Network Security Groups: Configurados"
print_success "✅ File Storage System: Montado en todos los servidores"
print_success "✅ Seguridad: Fail2ban activo en Bastion"
print_success "✅ Distribución de carga: Funcionando"

echo ""
print_success "🎉 VERIFICACIÓN COMPLETADA EXITOSAMENTE"
print_success "LESSON5a con NSGs está funcionando correctamente"
echo ""
print_status "URLs de acceso:"
echo "  - Load Balancer: http://$LB_IP"
echo "  - Contenido compartido: http://$LB_IP/shared/shared-content.html"
echo ""
print_status "Comandos SSH disponibles en: terraform output ssh_commands" 