#!/bin/bash

# Script de prueba para verificar la configuración de LESSON2
# Ejecutar antes de terraform apply

echo "=== Verificación de Configuración LESSON2 ==="
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -f "compute.tf" ] || [ ! -f "playbook.yml" ]; then
    echo "ERROR: No se encontraron archivos de configuración principales"
    echo "Asegúrate de estar en el directorio LESSON2_second_webserver_in_other_AD"
    exit 1
fi

echo "✓ Directorio correcto verificado"

# Verificar que Ansible está instalado
if ! command -v ansible &> /dev/null; then
    echo "ERROR: Ansible no está instalado"
    echo "Instala Ansible con: sudo dnf install ansible"
    exit 1
fi

echo "✓ Ansible está instalado"

# Verificar que Terraform está instalado
if ! command -v terraform &> /dev/null; then
    echo "ERROR: Terraform no está instalado"
    echo "Instala Terraform desde: https://www.terraform.io/downloads"
    exit 1
fi

echo "✓ Terraform está instalado"

# Verificar archivos de configuración
echo ""
echo "=== Verificación de Archivos ==="

files_to_check=(
    "compute.tf"
    "playbook.yml"
    "ansible.cfg"
    "tls.tf"
    "network.tf"
    "variables.tf"
    "provider.tf"
)

for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file existe"
    else
        echo "✗ $file NO existe"
    fi
done

# Verificar sintaxis de Terraform
echo ""
echo "=== Verificación de Sintaxis Terraform ==="
if terraform validate; then
    echo "✓ Sintaxis de Terraform válida"
else
    echo "✗ Errores en la sintaxis de Terraform"
    exit 1
fi

# Verificar sintaxis de Ansible
echo ""
echo "=== Verificación de Sintaxis Ansible ==="
if ansible-playbook --syntax-check playbook.yml; then
    echo "✓ Sintaxis de Ansible válida"
else
    echo "✗ Errores en la sintaxis de Ansible"
    exit 1
fi

echo ""
echo "=== Verificación Completada ==="
echo "✓ LESSON2 está listo para desplegar"
echo ""
echo "Para desplegar ejecuta:"
echo "  terraform init"
echo "  terraform plan"
echo "  terraform apply" 