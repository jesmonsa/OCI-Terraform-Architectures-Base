#!/bin/bash

# =============================================================================
# SCRIPT DE VERIFICACIÓN DE SEGURIDAD
# =============================================================================
# Este script verifica que no haya archivos sensibles en el repositorio
# Ejecutar antes de hacer commit: ./security_check.sh

set -e  # Salir si hay algún error

echo "🔍 Iniciando verificación de seguridad..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir errores
print_error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
}

# Función para imprimir advertencias
print_warning() {
    echo -e "${YELLOW}⚠️  ADVERTENCIA: $1${NC}"
}

# Función para imprimir éxito
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Contador de errores
ERROR_COUNT=0

echo "📁 Verificando archivos terraform.tfvars..."

# Verificar archivos terraform.tfvars (no deben existir excepto los .example)
for file in $(find . -name "terraform.tfvars" -not -name "*.example" 2>/dev/null); do
    print_error "Archivo sensible encontrado: $file"
    print_error "  Este archivo contiene credenciales reales y NO debe estar en el repositorio"
    print_error "  Usa terraform.tfvars.example como plantilla"
    ERROR_COUNT=$((ERROR_COUNT + 1))
done

echo "🔑 Verificando claves privadas..."

# Verificar claves privadas
for file in $(find . -name "*.pem" -o -name "*.key" -o -name "id_rsa*" 2>/dev/null); do
    print_error "Clave privada encontrada: $file"
    print_error "  Las claves privadas NO deben estar en el repositorio"
    ERROR_COUNT=$((ERROR_COUNT + 1))
done

echo "⚙️  Verificando archivos de configuración..."

# Verificar archivos de configuración de OCI
for file in $(find . -name "oci_config" -o -name "oci_api_key*" 2>/dev/null); do
    print_error "Archivo de configuración OCI encontrado: $file"
    print_error "  Los archivos de configuración NO deben estar en el repositorio"
    ERROR_COUNT=$((ERROR_COUNT + 1))
done

echo "🌍 Verificando variables de entorno..."

# Verificar archivos de variables de entorno
for file in $(find . -name "*.env" -o -name ".env*" 2>/dev/null); do
    print_error "Archivo de variables de entorno encontrado: $file"
    print_error "  Los archivos .env NO deben estar en el repositorio"
    ERROR_COUNT=$((ERROR_COUNT + 1))
done

echo "📊 Verificando archivos de estado de Terraform..."

# Verificar archivos de estado de Terraform
for file in $(find . -name "*.tfstate*" -o -name "*.tfplan" 2>/dev/null); do
    print_error "Archivo de estado de Terraform encontrado: $file"
    print_error "  Los archivos de estado NO deben estar en el repositorio"
    ERROR_COUNT=$((ERROR_COUNT + 1))
done

echo "🔍 Verificando contenido de archivos de ejemplo..."

# Verificar que los archivos de ejemplo no contengan información real
for file in $(find . -name "*.tfvars.example" 2>/dev/null); do
    if grep -q "ocid1\.tenancy\.oc1\..*[a-zA-Z0-9]\{60\}" "$file"; then
        print_warning "Archivo de ejemplo puede contener OCIDs reales: $file"
        print_warning "  Verifica que solo contenga valores de ejemplo"
    fi
    
    if grep -q "password.*=.*[a-zA-Z0-9]" "$file"; then
        print_warning "Archivo de ejemplo puede contener contraseñas: $file"
        print_warning "  Verifica que solo contenga valores de ejemplo"
    fi
done

echo "📋 Verificando .gitignore..."

# Verificar que .gitignore esté configurado correctamente
if [ ! -f ".gitignore" ]; then
    print_error "No se encontró archivo .gitignore en el directorio raíz"
    ERROR_COUNT=$((ERROR_COUNT + 1))
else
    # Verificar que .gitignore contenga las reglas básicas
    if ! grep -q "terraform\.tfvars" .gitignore; then
        print_warning ".gitignore no incluye terraform.tfvars"
    fi
    
    if ! grep -q "\.tfstate" .gitignore; then
        print_warning ".gitignore no incluye archivos de estado"
    fi
    
    if ! grep -q "\.pem\|\.key" .gitignore; then
        print_warning ".gitignore no incluye claves privadas"
    fi
fi

# Resumen final
echo ""
echo "=============================================================================="
echo "📊 RESUMEN DE VERIFICACIÓN DE SEGURIDAD"
echo "=============================================================================="

if [ $ERROR_COUNT -eq 0 ]; then
    print_success "Verificación completada sin errores críticos"
    print_success "El repositorio está listo para commit"
    exit 0
else
    print_error "Se encontraron $ERROR_COUNT errores críticos"
    print_error "Corrige estos problemas antes de hacer commit"
    echo ""
    echo "📖 Consulta SECURITY.md para más información sobre mejores prácticas"
    exit 1
fi 