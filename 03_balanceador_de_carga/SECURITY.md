# Guía de Seguridad - Arquitectura 03_balanceador_de_carga

## ⚠️ ADVERTENCIAS DE SEGURIDAD

### Archivos Sensibles que NUNCA deben subirse a GitHub

Los siguientes archivos contienen información sensible y **NUNCA** deben ser subidos a repositorios públicos:

#### 1. Archivos de Credenciales de OCI
- `terraform.tfvars` - Contiene OCIDs reales y rutas de claves privadas
- `*.pem` - Claves privadas de OCI
- `oci_api_key*` - Claves API de OCI
- `.oci/` - Directorio de configuración de OCI CLI

#### 2. Archivos de Estado de Terraform
- `*.tfstate` - Contiene información detallada de la infraestructura
- `*.tfstate.backup` - Backup del estado
- `*.tfplan` - Planes de Terraform que pueden contener información sensible

#### 3. Claves SSH
- `id_rsa*` - Claves SSH privadas
- `id_ed25519*` - Claves SSH Ed25519
- `*.ppk` - Claves PuTTY

#### 4. Variables de Entorno
- `.env` - Variables de entorno
- `*.env` - Archivos de entorno específicos

## ✅ Archivos Seguros para Subir

Los siguientes archivos **SÍ** pueden subirse de forma segura:

- `*.tfvars.example` - Ejemplos de variables (con valores ficticios)
- `setup_oci_tf_vars.sh.example` - Ejemplo de script de configuración
- `*.tf` - Archivos de configuración de Terraform
- `README.md` - Documentación
- `LICENSE` - Licencia del proyecto

## 🔒 Mejores Prácticas de Seguridad

### 1. Configuración de Credenciales

#### Opción A: Variables de Entorno (Recomendado)
```bash
# Crear archivo de variables de entorno
cp setup_oci_tf_vars.sh.example setup_oci_tf_vars.sh

# Editar con tus credenciales reales
nano setup_oci_tf_vars.sh

# Cargar variables
source setup_oci_tf_vars.sh
```

#### Opción B: Archivo terraform.tfvars (Solo para desarrollo local)
```bash
# Crear archivo de variables
touch terraform.tfvars
# Editar con tus credenciales reales
nano terraform.tfvars
```

### 2. Gestión de Claves Privadas

```bash
# Crear directorio para claves OCI
mkdir -p ~/.oci

# Generar clave privada (si no tienes una)
openssl genrsa -out ~/.oci/oci_api_key.pem 2048

# Configurar permisos correctos
chmod 600 ~/.oci/oci_api_key.pem

# Generar clave pública
openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem
```

### 3. Configuración de OCI CLI

```bash
# Configurar OCI CLI
oci setup config

# Verificar configuración
oci iam user get --user-id $USER_OCID
```

### 4. Verificación de Seguridad

Antes de hacer commit, verifica que no hay archivos sensibles:

```bash
# Verificar archivos que serían subidos
git status

# Verificar archivos ignorados
git check-ignore *

# Buscar archivos sensibles
find . -name "*.tfvars" -not -name "*.example"
find . -name "*.pem"
find . -name "*.tfstate*"
find . -name ".env*"
```

## 🚨 Checklist de Seguridad

Antes de subir a GitHub, verifica:

- [ ] No hay archivos `terraform.tfvars` con credenciales reales
- [ ] No hay archivos `*.pem` o `*.key`
- [ ] No hay archivos `*.tfstate*`
- [ ] No hay archivos `.env*`
- [ ] Los archivos de ejemplo usan valores ficticios (`*******`)
- [ ] El `.gitignore` está configurado correctamente
- [ ] Se han revisado todos los archivos con `git status`

## 🔍 Comandos de Verificación

```bash
# Verificar qué archivos serían subidos
git add .
git status

# Verificar archivos ignorados
git check-ignore -v *

# Buscar OCIDs reales en el código
grep -r "ocid1\." . --exclude-dir=.git

# Verificar permisos de archivos sensibles
ls -la ~/.oci/
ls -la *.pem 2>/dev/null || echo "No hay archivos .pem"
```

## 📞 Contacto de Seguridad

Si encuentras credenciales expuestas accidentalmente:

1. **INMEDIATAMENTE**: Revoca las credenciales en OCI Console
2. **INMEDIATAMENTE**: Genera nuevas credenciales
3. **INMEDIATAMENTE**: Actualiza todos los sistemas que usen las credenciales
4. Reporta el incidente al equipo de seguridad

## 📚 Recursos Adicionales

- [OCI Security Best Practices](https://docs.oracle.com/en-us/iaas/Content/Security/Reference/security_best_practices.htm)
- [Terraform Security Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/security.html)
- [GitHub Security Best Practices](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure) 