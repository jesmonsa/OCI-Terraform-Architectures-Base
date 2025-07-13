# 🔒 GUÍA DE SEGURIDAD - OCI Terraform Foundations

## ⚠️ ADVERTENCIAS IMPORTANTES

### Archivos que NUNCA deben subirse al repositorio:

- `terraform.tfvars` (contiene credenciales reales)
- `*.pem`, `*.key` (claves privadas)
- `oci_config` (configuración de OCI)
- `*.env` (variables de entorno)
- `*.tfstate*` (archivos de estado de Terraform)
- `*.tfplan` (planes de Terraform)

## 🛡️ MEJORES PRÁCTICAS DE SEGURIDAD

### 1. Gestión de Credenciales

#### ✅ CORRECTO:
```bash
# Usar variables de entorno para contraseñas
export TF_VAR_db_admin_password="TuContraseñaSegura123!"

# Usar archivos de ejemplo
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars con tus credenciales reales
```

#### ❌ INCORRECTO:
```bash
# NUNCA hacer esto
echo 'db_admin_password = "MiContraseña123"' >> terraform.tfvars
git add terraform.tfvars
git commit -m "Agregar credenciales"
```

### 2. Configuración de OCI

#### Configuración de API Key:
1. Genera una nueva API key en la consola de OCI
2. Descarga la clave privada
3. Configura el fingerprint en la consola
4. Guarda la clave en `~/.oci/oci_api_key.pem`

#### Configuración de Compartments:
- Usa compartments separados para diferentes entornos
- Aplica políticas de acceso mínimas necesarias
- Revisa regularmente los permisos

### 3. Configuración de Red

#### Security Lists:
- Abre solo los puertos necesarios
- Usa rangos de IP específicos en lugar de 0.0.0.0/0
- Revisa regularmente las reglas de seguridad

#### Network Security Groups:
- Usa NSGs para control granular de acceso
- Aplica el principio de menor privilegio
- Documenta el propósito de cada NSG

### 4. Configuración de Base de Datos

#### Contraseñas:
- Usa contraseñas complejas (mínimo 12 caracteres)
- Incluye mayúsculas, minúsculas, números y símbolos
- Rota las contraseñas regularmente

#### Configuración de Seguridad:
- Habilita TDE (Transparent Data Encryption)
- Configura backup automático
- Usa Data Guard para alta disponibilidad

### 5. Configuración de Compute

#### SSH Keys:
- Usa claves SSH de 2048 bits o más
- Protege las claves privadas con permisos 600
- Rota las claves regularmente

#### Instancias:
- Usa imágenes oficiales de Oracle
- Mantén las instancias actualizadas
- Configura monitoreo de seguridad

## 🔍 VERIFICACIÓN DE SEGURIDAD

### Antes de hacer commit:

1. **Verificar archivos sensibles:**
```bash
git diff --cached | grep -E "(password|secret|key|token)"
```

2. **Verificar archivos de configuración:**
```bash
git diff --cached --name-only | grep -E "\.(tfvars|pem|key|env)$"
```

3. **Verificar archivos de estado:**
```bash
git diff --cached --name-only | grep -E "\.(tfstate|tfplan)$"
```

### Script de verificación automática:

```bash
#!/bin/bash
# security_check.sh

echo "🔍 Verificando archivos sensibles..."

# Verificar archivos que no deben estar en el repositorio
for file in $(find . -name "terraform.tfvars" -not -name "*.example"); do
    echo "❌ ERROR: $file contiene información sensible"
    exit 1
done

# Verificar claves privadas
for file in $(find . -name "*.pem" -o -name "*.key"); do
    echo "❌ ERROR: $file es una clave privada"
    exit 1
done

echo "✅ Verificación de seguridad completada"
```

## 🚨 INCIDENTES DE SEGURIDAD

### Si accidentalmente subiste información sensible:

1. **Inmediatamente:**
   - Cambia todas las credenciales expuestas
   - Revoca las claves API comprometidas
   - Notifica al equipo de seguridad

2. **Limpieza del repositorio:**
   - Usa `git filter-branch` o `git filter-repo` para limpiar el historial
   - Haz push force al repositorio remoto
   - Considera crear un nuevo repositorio

3. **Prevención futura:**
   - Revisa y actualiza el `.gitignore`
   - Implementa hooks de pre-commit
   - Capacita al equipo en seguridad

## 📚 RECURSOS ADICIONALES

- [OCI Security Best Practices](https://docs.oracle.com/en-us/iaas/Content/Security/Reference/security_best_practices.htm)
- [Terraform Security Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/security.html)
- [Git Security Best Practices](https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work)

## 📞 CONTACTO

Si encuentras un problema de seguridad, contacta inmediatamente al equipo de seguridad de tu organización.

---

**Recuerda: La seguridad es responsabilidad de todos. Siempre verifica antes de hacer commit.** 