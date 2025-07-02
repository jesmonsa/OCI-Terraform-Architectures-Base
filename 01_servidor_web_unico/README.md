# 🏗️ Arquitecturas de Referencia Terraform OCI

## 🌐 Arquitectura 1 - Servidor Web Único

### 📋 Descripción General

Esta arquitectura de referencia demuestra la implementación más básica de recursos en Oracle Cloud Infrastructure (OCI), creando un servidor web simple accesible desde Internet. Es el punto de partida ideal para comprender los conceptos fundamentales de la infraestructura como código en OCI.

### 🎯 Objetivo

Crear la configuración más simple de recursos OCI que incluye:
- Un compartimento para organizar los recursos
- Una Red Virtual en la Nube (VCN) con su subred pública
- Una instancia de máquina virtual que funciona como servidor web
- Configuración de seguridad básica para acceso HTTP/HTTPS y SSH

### 🏛️ Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                    Oracle Cloud Infrastructure              │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                  Compartimento                          │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────┐    │ │
│  │  │                VCN (10.0.0.0/16)               │    │ │
│  │  │                                                 │    │ │
│  │  │  ┌─────────────────────────────────────────┐    │    │ │
│  │  │  │         Subred Pública                  │    │    │ │
│  │  │  │         (10.0.1.0/24)                  │    │    │ │
│  │  │  │                                         │    │    │ │
│  │  │  │  ┌─────────────────────────────────┐    │    │    │ │
│  │  │  │  │      🖥️ Servidor Web 1         │    │    │    │ │
│  │  │  │  │    (Oracle Linux + Apache)     │    │    │    │ │
│  │  │  │  │         IP Pública             │    │    │    │ │
│  │  │  │  └─────────────────────────────────┘    │    │    │ │
│  │  │  └─────────────────────────────────────────┘    │    │ │
│  │  │                                                 │    │ │
│  │  │  📡 Internet Gateway                           │    │ │
│  │  └─────────────────────────────────────────────────┘    │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP/HTTPS (80/443)
                              │ SSH (22)
                              ▼
                         🌐 Internet
```

### ✨ Características

- **🔧 Simplicidad**: Configuración mínima para comenzar con OCI
- **🌍 Acceso Público**: Servidor web accesible directamente desde Internet
- **🔒 Seguridad Básica**: Lista de seguridad configurada para HTTP, HTTPS y SSH
- **⚡ Aprovisionamiento Automático**: Instalación automática de Apache y página web de ejemplo
- **📍 Multi-AD**: La subred abarca todos los dominios de disponibilidad (AD1-AD3)

### 🛠️ Recursos Desplegados

| Recurso | Tipo | Descripción |
|---------|------|-------------|
| **Compartimento** | `oci_identity_compartment` | Contenedor lógico para organizar recursos |
| **VCN** | `oci_core_virtual_network` | Red virtual privada (10.0.0.0/16) |
| **Subred Pública** | `oci_core_subnet` | Subred con acceso a Internet (10.0.1.0/24) |
| **Internet Gateway** | `oci_core_internet_gateway` | Puerta de enlace para acceso a Internet |
| **Tabla de Rutas** | `oci_core_route_table` | Enrutamiento del tráfico hacia Internet Gateway |
| **Lista de Seguridad** | `oci_core_security_list` | Reglas de firewall (SSH:22, HTTP:80, HTTPS:443) |
| **Instancia Compute** | `oci_core_instance` | Máquina virtual con Oracle Linux |
| **Claves SSH** | `tls_private_key` | Par de claves para acceso SSH |

### 🔐 Configuración de Seguridad

#### Reglas de Entrada (Ingress)
- **SSH**: Puerto 22 desde cualquier IP (0.0.0.0/0)
- **HTTP**: Puerto 80 desde cualquier IP (0.0.0.0/0)
- **HTTPS**: Puerto 443 desde cualquier IP (0.0.0.0/0)

#### Reglas de Salida (Egress)
- **Todo el tráfico**: Permitido hacia cualquier destino

> ⚠️ **Nota de Seguridad**: Esta configuración permite acceso SSH desde cualquier IP. En entornos de producción, se recomienda restringir el acceso SSH a IPs específicas.

---

## 🚀 Métodos de Despliegue

### 🔧 Prerrequisitos

- **Terraform** >= 0.15.0 o **OpenTofu** >= 1.0.0
- Cuenta activa de Oracle Cloud Infrastructure
- Credenciales de API configuradas
- Cliente Git instalado

---

## 🔑 Autenticación con OCI

Antes de desplegar los recursos, configura la autenticación con OCI. Puedes elegir entre dos métodos:

### 📁 **Opción 1: Variables de Entorno**

<details>
<summary>👆 Haz clic para expandir las instrucciones</summary>

#### 1. Copiar el archivo de ejemplo
```bash
cp setup_oci_tf_vars.sh.example setup_oci_tf_vars.sh
```

#### 2. Editar el archivo de configuración
Abre `setup_oci_tf_vars.sh` y actualiza con tus credenciales:

```bash
export TF_VAR_user_ocid="ocid1.user.oc1..*******"
export TF_VAR_tenancy_ocid="ocid1.tenancy.oc1..*******"
export TF_VAR_compartment_ocid="ocid1.compartment.oc1..*******"
export TF_VAR_fingerprint="xx:xx:xx:*******:xx:xx"
export TF_VAR_private_key_path="/Users/TuUsuario/.oci/oci_api_key.pem"
export TF_VAR_region="eu-frankfurt-1"
```

#### 3. Cargar las variables
```bash
source setup_oci_tf_vars.sh
```

</details>

### 📄 **Opción 2: Archivo terraform.tfvars**

<details>
<summary>👆 Haz clic para expandir las instrucciones</summary>

#### 1. Copiar el archivo de ejemplo
```bash
cp terraform.tfvars.example terraform.tfvars
```

#### 2. Editar el archivo terraform.tfvars
```hcl
tenancy_ocid            = "ocid1.tenancy.oc1..*******"
user_ocid               = "ocid1.user.oc1..*******"
fingerprint             = "xx:xx:xx:*******:xx:xx"
private_key_path        = "/Users/TuUsuario/.oci/oci_api_key.pem"
region                  = "eu-frankfurt-1"
compartment_ocid        = "ocid1.compartment.oc1..*******"
```

</details>

---

## 🖥️ Despliegue con Terraform/OpenTofu

### 📥 **1. Clonar el Repositorio**

```bash
git clone https://github.com/usuario/arquitecturas-oci-terraform.git
cd arquitecturas-oci-terraform/01_servidor_web_unico
```

### 🔄 **2. Inicializar el Proyecto**

<table>
<tr>
<td><strong>🔵 Terraform</strong></td>
<td><strong>🟢 OpenTofu</strong></td>
</tr>
<tr>
<td>

```bash
terraform init
```

</td>
<td>

```bash
tofu init
```

</td>
</tr>
</table>

### 📋 **3. Planificar el Despliegue**

<table>
<tr>
<td><strong>🔵 Terraform</strong></td>
<td><strong>🟢 OpenTofu</strong></td>
</tr>
<tr>
<td>

```bash
terraform plan
```

</td>
<td>

```bash
tofu plan
```

</td>
</tr>
</table>

### ✅ **4. Aplicar los Cambios**

<table>
<tr>
<td><strong>🔵 Terraform</strong></td>
<td><strong>🟢 OpenTofu</strong></td>
</tr>
<tr>
<td>

```bash
terraform apply
```

</td>
<td>

```bash
tofu apply
```

</td>
</tr>
</table>

### 🧹 **5. Limpiar Recursos**

<table>
<tr>
<td><strong>🔵 Terraform</strong></td>
<td><strong>🟢 OpenTofu</strong></td>
</tr>
<tr>
<td>

```bash
terraform destroy
```

</td>
<td>

```bash
tofu destroy
```

</td>
</tr>
</table>

---

## ☁️ Despliegue con Oracle Resource Manager

### 🚀 Despliegue Rápido

1. **Haz clic en el botón de despliegue**:

   [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/usuario/arquitecturas-oci-terraform/releases/latest/download/01_servidor_web_unico.zip)

2. **Iniciar sesión**: Si no has iniciado sesión, introduce las credenciales de tu tenancy y usuario.

3. **Revisar términos**: Acepta los términos y condiciones.

4. **Seleccionar región**: Elige la región donde deseas desplegar el stack.

5. **Crear el stack**: Sigue las instrucciones en pantalla.

6. **Planificar**: Haz clic en **Terraform Actions** → **Plan**.

7. **Revisar**: Espera a que se complete el trabajo y revisa el plan.

8. **Aplicar**: Si todo está correcto, haz clic en **Terraform Actions** → **Apply**.

---

## 📊 Salidas del Despliegue

Después de un despliegue exitoso, obtendrás las siguientes salidas:

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `generated_ssh_private_key` | Clave SSH privada generada | `-----BEGIN RSA PRIVATE KEY-----...` |
| `EnterpriseWebserver1PublicIP` | IP pública del servidor web | `130.61.45.123` |

### 🌐 Acceso al Servidor Web

Una vez completado el despliegue:

1. **Página Web**: Visita `http://[IP_PUBLICA]` en tu navegador
2. **SSH**: Conecta usando `ssh -i clave_privada opc@[IP_PUBLICA]`

---

## 🔧 Personalización

### 📝 Variables Configurables

| Variable | Descripción | Valor por Defecto | Ejemplo |
|----------|-------------|-------------------|---------|
| `VCN-CIDR` | CIDR de la VCN | `10.0.0.0/16` | `192.168.0.0/16` |
| `Subnet-CIDR` | CIDR de la subred | `10.0.1.0/24` | `192.168.1.0/24` |
| `Shape` | Tipo de instancia | `VM.Standard.E4.Flex` | `VM.Standard.E3.Flex` |
| `FlexShapeOCPUS` | Número de CPUs | `1` | `2` |
| `FlexShapeMemory` | Memoria en GB | `2` | `4` |

### ⚙️ Ejemplo de Personalización

```hcl
# terraform.tfvars
VCN-CIDR = "192.168.0.0/16"
Subnet-CIDR = "192.168.1.0/24"
Shape = "VM.Standard.E3.Flex"
FlexShapeOCPUS = 2
FlexShapeMemory = 4
```

---

## 🆘 Solución de Problemas

### ❌ Problemas Comunes

<details>
<summary>🔐 <strong>Error de Autenticación</strong></summary>

**Problema**: `Error: 401-NotAuthenticated`

**Solución**:
1. Verifica que las credenciales en `terraform.tfvars` o variables de entorno sean correctas
2. Asegúrate de que la clave privada tenga los permisos correctos: `chmod 600 tu_clave_privada.pem`
3. Confirma que el fingerprint coincida con el de tu clave API

</details>

<details>
<summary>🏠 <strong>Error de Compartimento</strong></summary>

**Problema**: `Error: 404-NotAuthorizedOrNotFound`

**Solución**:
1. Verifica que el `compartment_ocid` sea correcto
2. Asegúrate de tener permisos para crear recursos en ese compartimento
3. Si usas el compartimento raíz, usa el mismo OCID que `tenancy_ocid`

</details>

<details>
<summary>🌍 <strong>Error de Región</strong></summary>

**Problema**: `Error: Service 'Core' is not available in this region`

**Solución**:
1. Verifica que la región especificada sea válida
2. Confirma que tu tenancy tenga acceso a esa región
3. Usa el formato correcto: `eu-frankfurt-1`, `us-ashburn-1`, etc.

</details>

<details>
<summary>💾 <strong>Error de Shape No Disponible</strong></summary>

**Problema**: `Error: The specified shape VM.Standard.E4.Flex is not available`

**Solución**:
1. Verifica la disponibilidad del shape en tu región
2. Prueba con un shape diferente como `VM.Standard.E3.Flex`
3. Revisa los límites de servicio de tu tenancy

</details>

### 🔍 Comandos de Diagnóstico

```bash
# Verificar el plan sin aplicar
terraform plan

# Mostrar el estado actual
terraform show

# Verificar la configuración
terraform validate

# Ver las salidas
terraform output
```

---

## 📚 Recursos Adicionales

### 📖 Documentación

- [Documentación de Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [Guía de Oracle Cloud Infrastructure](https://docs.oracle.com/en-us/iaas/Content/home.htm)
- [Mejores Prácticas de Terraform](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

### 🎓 Próximos Pasos

Después de dominar esta arquitectura, continúa con:

1. **Arquitectura 2**: Segundo servidor web en otro dominio de disponibilidad
2. **Arquitectura 3**: Balanceador de carga
3. **Arquitectura 4**: NAT Gateway y host bastión

---

## 🤝 Contribución

Este proyecto es de código abierto. ¡Envía tus contribuciones haciendo fork del repositorio y enviando un pull request!

### 📋 Cómo Contribuir

1. Haz fork del repositorio
2. Crea una rama para tu funcionalidad (`git checkout -b feature/nueva-funcionalidad`)
3. Haz commit de tus cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

---

## 📄 Licencia

Copyright (c) 2025

Licenciado bajo la Licencia Permisiva Universal (UPL), Versión 1.0.

Consulta [LICENSE](LICENSE) para más detalles.

---

<div align="center">

**¿Te gusta este proyecto? ¡Dale una ⭐ en GitHub!**

Hecho con ❤️ para la comunidad de Oracle Cloud Infrastructure

</div>