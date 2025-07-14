# Créditos y Adaptaciones

Este proyecto está basado en el repositorio original de Foggykitchen (https://github.com/mlinxfeld/foggykitchen_tf_oci_course). Incluye adaptaciones y mejoras realizadas por Jesus Montoya, Arquitecto Cloud.

# 🏗️ Arquitecturas de Referencia Terraform OCI

## 🌐 Arquitectura 1 - Servidor Web Único

### 📋 Descripción General

Esta arquitectura de referencia demuestra la implementación más básica de recursos en Oracle Cloud Infrastructure (OCI), creando un servidor web moderno y completamente funcional accesible desde Internet. Es el punto de partida ideal para comprender los conceptos fundamentales de la infraestructura como código en OCI, combinando Terraform para la infraestructura y Ansible para la configuración automática.

### 🎯 Objetivo

Crear una infraestructura completa y funcional que incluye:
- Un compartimento enterprise para organizar los recursos
- Una Red Virtual en la Nube (VCN) con subred pública optimizada
- Una instancia de máquina virtual Ubuntu con servidor web Apache
- Configuración de seguridad multi-capa (OCI Security Lists + iptables)
- Página web moderna con diseño responsive y información del sistema
- Aprovisionamiento 100% automático con Ansible

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
│  │  │  │  │      🖥️ Servidor Web Único      │    │    │    │ │
│  │  │  │  │    (Ubuntu 22.04 + Apache2)    │    │    │    │ │
│  │  │  │  │    VM.Standard.E3.Flex (1CPU)  │    │    │    │ │
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

- **🔧 Simplicidad**: Configuración mínima optimizada para comenzar con OCI
- **🌍 Acceso Público**: Servidor web con página moderna accesible desde Internet
- **🔒 Seguridad Multi-Capa**: OCI Security Lists + iptables configurado automáticamente
- **⚡ Aprovisionamiento Inteligente**: Ansible con retry logic y error handling
- **🎨 Página Web Moderna**: Diseño responsive con información del sistema en tiempo real
- **📍 Flexibilidad Multi-AD**: Subred regional que abarca todos los dominios de disponibilidad
- **🛠️ Stack Completo**: Ubuntu 22.04 + Apache2 + SSL ready + Firewall configurado

### 🛠️ Recursos Desplegados

| Recurso | Tipo | Descripción |
|---------|------|-------------|
| **Compartimento** | `oci_identity_compartment` | Contenedor lógico para organizar recursos |
| **VCN** | `oci_core_virtual_network` | Red virtual privada (10.0.0.0/16) |
| **Subred Pública** | `oci_core_subnet` | Subred con acceso a Internet (10.0.1.0/24) |
| **Internet Gateway** | `oci_core_internet_gateway` | Puerta de enlace para acceso a Internet |
| **Tabla de Rutas** | `oci_core_route_table` | Enrutamiento del tráfico hacia Internet Gateway |
| **Lista de Seguridad** | `oci_core_security_list` | Reglas de firewall (SSH:22, HTTP:80, HTTPS:443) |
| **Instancia Compute** | `oci_core_instance` | VM Ubuntu 22.04 con Apache2 configurado |
| **Claves SSH** | `tls_private_key` | Par de claves para acceso SSH |

### 🛡️ Configuración de Seguridad Multi-Capa

#### 🌐 Capa OCI - Security Lists
- **SSH**: Puerto 22 desde cualquier IP (0.0.0.0/0)
- **HTTP**: Puerto 80 desde cualquier IP (0.0.0.0/0)
- **HTTPS**: Puerto 443 desde cualquier IP (0.0.0.0/0)
- **Egress**: Todo el tráfico permitido hacia cualquier destino

#### 🔥 Capa Sistema - IPTables (Configurado por Ansible)
- **Política por defecto**: DROP (deniega todo excepto lo explícitamente permitido)
- **SSH**: Puerto 22 con conexiones establecidas y nuevas
- **HTTP**: Puerto 80 con conexiones establecidas y nuevas  
- **HTTPS**: Puerto 443 con conexiones establecidas y nuevas
- **Loopback**: Tráfico local permitido
- **Conexiones establecidas**: Tráfico de respuesta permitido

#### 🔧 Características de Seguridad Avanzadas
- ✅ **Firewall persistente** - Reglas guardadas automáticamente
- ✅ **Sin prompts interactivos** - Configuración totalmente automatizada
- ✅ **Orden de reglas optimizado** - ALLOW antes que DROP para evitar bloqueos
- ✅ **Logs de seguridad** - Eventos registrados para auditoría

> ⚠️ **Nota de Seguridad**: Esta configuración permite acceso SSH desde cualquier IP para fines educativos. En entornos de producción, se recomienda:
> - Usar un bastion host para acceso SSH
> - Restringir SSH a IPs específicas
> - Implementar autenticación multi-factor
> - Usar Network Security Groups para control granular

---

## 🚀 Métodos de Despliegue

### 🔧 Prerrequisitos

- **Terraform** >= 0.15.0 o **OpenTofu** >= 1.0.0
- **Ansible** >= 2.9 (para aprovisionamiento automático)
- Cuenta activa de Oracle Cloud Infrastructure
- Credenciales de API configuradas
- Cliente Git instalado

> 📝 **Nota**: Esta arquitectura usa Ansible para el aprovisionamiento del servidor web, lo que proporciona mayor velocidad y mejor gestión de configuración que remote-exec. Ver [ANSIBLE_REQUIREMENTS.md](ANSIBLE_REQUIREMENTS.md) para instrucciones de instalación.

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

### ✅ **2. Validar Configuración**

```bash
# Ejecutar script de validación completa
./validate_config.sh
```

Este script verificará:
- Instalación de Terraform/OpenTofu
- Instalación de Ansible
- Configuración de variables OCI
- Presencia de todos los archivos necesarios
- Sintaxis de Ansible

### 🔄 **3. Inicializar el Proyecto**

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

### 📋 **4. Planificar el Despliegue**

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

### ✅ **5. Aplicar los Cambios**

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

### 🧹 **6. Limpiar Recursos**

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

   [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/jesmonsa/01-oci-terraform-foundations/archive/refs/heads/main.zip)

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

Una vez completado el despliegue (generalmente 3-5 minutos):

1. **Página Web Moderna**: Visita `http://[IP_PUBLICA]` en tu navegador
   - Diseño moderno con gradientes y animaciones
   - Información del sistema en tiempo real
   - Responsive design para móviles y tablets
   - Stack tecnológico visible

2. **SSH**: Conecta usando `ssh -i id_rsa_enterprise ubuntu@[IP_PUBLICA]`
   - Usuario: `ubuntu` (no `opc`)
   - Clave: `id_rsa_enterprise` (generada automáticamente)

### 🎨 Características de la Página Web

La página web incluye:
- 🚀 **Header dinámico** con información de la arquitectura
- 📊 **Cards informativos** con datos del sistema (IP, hostname, OS)
- 🛠️ **Stack tecnológico** mostrado con badges
- ✅ **Indicadores de estado** del servidor y servicios
- 📱 **Diseño responsive** que se adapta a todos los dispositivos
- ⏰ **Timestamp** de despliegue actualizado automáticamente

---

## 🔧 Personalización

### 📝 Variables Configurables

| Variable | Descripción | Valor por Defecto | Ejemplo |
|----------|-------------|-------------------|---------|
| `vcn_cidr` | CIDR de la VCN | `10.0.0.0/16` | `192.168.0.0/16` |
| `subnet_cidr` | CIDR de la subred | `10.0.1.0/24` | `192.168.1.0/24` |
| `Shape` | Tipo de instancia | `VM.Standard.E3.Flex` | `VM.Standard.E4.Flex` |
| `FlexShapeOCPUS` | Número de CPUs | `1` | `2` |
| `FlexShapeMemory` | Memoria en GB | `2` | `4` |
| `instance_os` | Sistema operativo | `Canonical Ubuntu` | `Oracle Linux` |
| `linux_os_version` | Versión del SO | `22.04` | `20.04` |
| `service_ports` | Puertos abiertos | `[80, 443, 22]` | `[80, 22]` |

### ⚙️ Ejemplo de Personalización

```hcl
# terraform.tfvars
vcn_cidr = "192.168.0.0/16"
subnet_cidr = "192.168.1.0/24"
Shape = "VM.Standard.E4.Flex"
FlexShapeOCPUS = 2
FlexShapeMemory = 4
instance_os = "Oracle Linux"
linux_os_version = "8"
service_ports = [80, 22]  # Solo HTTP y SSH
```

---

## 🆘 Solución de Problemas

### ❌ Problemas Comunes

<details>
<summary>🔐 <strong>Error de Autenticación SSH/Ansible</strong></summary>

**Problema**: `no such identity: mi_llave_oci.pem: No such file or directory`

**Solución**:
1. Ejecuta el script de diagnóstico: `./debug_ssh.sh`
2. Verifica que Terraform haya completado exitosamente: `terraform apply`
3. Comprueba que la clave existe: `ls -la mi_llave_oci.pem`
4. Asegúrate de que la clave tenga permisos correctos: `chmod 600 mi_llave_oci.pem`

</details>

<details>
<summary>🔐 <strong>Error de Autenticación OCI</strong></summary>

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

# Script de diagnóstico SSH específico
./debug_ssh.sh

# Verificar conectividad manual SSH
ssh -i mi_llave_oci.pem opc@$(terraform output -raw EnterpriseWebserver1PublicIP | tr -d '[]" ')

# Ver logs de Ansible
tail -f ansible.log
```

---

## 📚 Recursos Adicionales

### 📖 Documentación

- [Documentación de Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [Guía de Oracle Cloud Infrastructure](https://docs.oracle.com/en-us/iaas/Content/home.htm)
- [Mejores Prácticas de Terraform](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

### 📁 Documentación del Proyecto

- [ANSIBLE_REQUIREMENTS.md](ANSIBLE_REQUIREMENTS.md) - Requisitos e instalación de Ansible
- [DEPENDENCY_MAP.md](DEPENDENCY_MAP.md) - Mapa completo de dependencias de recursos
- [validate_config.sh](validate_config.sh) - Script de validación de configuración
- [debug_ssh.sh](debug_ssh.sh) - Script de diagnóstico SSH

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