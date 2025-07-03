#!/bin/bash

# Script de verificación automática para LESSON2
# Verifica que ambos servidores web estén funcionando correctamente

echo "🔍 VERIFICANDO DESPLIEGUE LESSON2 - MÚLTIPLES AD"
echo "================================================"

# Obtener IPs desde Terraform
echo "📋 Obteniendo IPs de los servidores..."
WEBSERVER1_IP=$(terraform output -json | jq -r '.EnterpriseWebserver_Public_IPs_Formatted.value.EnterpriseWebServer1')
WEBSERVER2_IP=$(terraform output -json | jq -r '.EnterpriseWebserver_Public_IPs_Formatted.value.EnterpriseWebServer2')

echo "🌐 WebServer1 IP: $WEBSERVER1_IP"
echo "🌐 WebServer2 IP: $WEBSERVER2_IP"
echo ""

# Función para verificar servidor
verify_server() {
    local server_name=$1
    local server_ip=$2
    
    echo "🔍 Verificando $server_name ($server_ip)..."
    
    # Verificar conectividad SSH
    echo "  📡 Probando SSH..."
    if ssh -i id_rsa_enterprise -o ConnectTimeout=10 -o StrictHostKeyChecking=no ubuntu@$server_ip "echo 'SSH OK'" 2>/dev/null; then
        echo "  ✅ SSH: OK"
    else
        echo "  ❌ SSH: FAILED"
        return 1
    fi
    
    # Verificar servicio Apache
    echo "  🌐 Probando Apache..."
    if ssh -i id_rsa_enterprise -o StrictHostKeyChecking=no ubuntu@$server_ip "sudo systemctl is-active apache2" 2>/dev/null | grep -q "active"; then
        echo "  ✅ Apache: OK"
    else
        echo "  ❌ Apache: FAILED"
        return 1
    fi
    
    # Verificar respuesta HTTP
    echo "  🌍 Probando HTTP..."
    if curl -s -o /dev/null -w "%{http_code}" http://$server_ip | grep -q "200"; then
        echo "  ✅ HTTP: OK"
    else
        echo "  ❌ HTTP: FAILED"
        return 1
    fi
    
    # Verificar contenido de la página
    echo "  📄 Verificando contenido..."
    if curl -s http://$server_ip | grep -q "VICTORIA FINAL"; then
        echo "  ✅ Contenido: OK"
    else
        echo "  ❌ Contenido: FAILED"
        return 1
    fi
    
    echo "  🎉 $server_name: TODAS LAS VERIFICACIONES PASARON"
    return 0
}

# Verificar ambos servidores
echo "🚀 INICIANDO VERIFICACIONES..."
echo ""

WEBSERVER1_OK=false
WEBSERVER2_OK=false

if verify_server "WebServer1" "$WEBSERVER1_IP"; then
    WEBSERVER1_OK=true
else
    echo "⚠️  WebServer1 necesita atención"
fi

echo ""

if verify_server "WebServer2" "$WEBSERVER2_IP"; then
    WEBSERVER2_OK=true
else
    echo "⚠️  WebServer2 necesita atención"
fi

echo ""
echo "📊 RESUMEN DE VERIFICACIÓN:"
echo "============================"

if [ "$WEBSERVER1_OK" = true ] && [ "$WEBSERVER2_OK" = true ]; then
    echo "🎉 ¡ÉXITO TOTAL! Ambos servidores funcionan correctamente"
    echo "✅ Redundancia Multi-AD: FUNCIONANDO"
    echo "✅ Alta Disponibilidad: GARANTIZADA"
    echo "✅ LESSON2: COMPLETAMENTE EXITOSA"
    exit 0
elif [ "$WEBSERVER1_OK" = true ]; then
    echo "⚠️  WebServer1: OK | WebServer2: PROBLEMAS"
    echo "🔧 Ejecutar: ansible-playbook -i inventory_webserver2 playbook.yml"
    exit 1
elif [ "$WEBSERVER2_OK" = true ]; then
    echo "⚠️  WebServer1: PROBLEMAS | WebServer2: OK"
    echo "🔧 Ejecutar: ansible-playbook -i inventory_webserver1 playbook.yml"
    exit 1
else
    echo "❌ AMBOS SERVIDORES TIENEN PROBLEMAS"
    echo "🔧 Revisar logs y ejecutar Ansible manualmente"
    exit 2
fi 