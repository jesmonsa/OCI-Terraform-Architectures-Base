# Créditos y Adaptaciones

Este proyecto está basado en el repositorio original de Foggykitchen (https://github.com/foggykitchen/oci-terraform-examples). Incluye adaptaciones y mejoras realizadas por Jesus Montoya, Arquitecto Cloud.

# 🏗️ Arquitecturas de Referencia Terraform OCI

## 🌐 Arquitectura 2a - Segundo Servidor Web en Otro FD

### 📋 Descripción General

Esta arquitectura de referencia representa una **variante especializada de la Arquitectura 2**, diseñada específicamente para regiones OCI que **solo disponen de un Availability Domain (AD)**. En lugar de distribuir servidores entre múltiples ADs, esta implementación utiliza **Fault Domains (FDs)** para proporcionar alta disponibilidad dentro del mismo AD.

La arquitectura despliega dos servidores web idénticos distribuidos en diferentes Fault Domains del mismo Availability Domain, proporcionando redundancia a nivel de infraestructura física y protección contra fallos de hardware localizados.

### 🎯 Objetivo

Crear una infraestructura de alta disponibilidad que incluye:
- Dos servidores web distribuidos en diferentes Fault Domains del mismo AD
- Red compartida con subred regional optimizada para single-AD
- Configuración de seguridad avanzada con Network Security Groups
- Aprovisionamiento automático optimizado con Ansible
- Páginas web diferenciadas con información específica de cada servidor

### 🏛️ Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                    Oracle Cloud Infrastructure              │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                  Compartimento Enterprise               │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────┐    │ │
│  │  │                VCN (10.0.0.0/16)               │ │
│  │  │                                                 │ │
│  │  │  ┌─────────────────────────────────────────┐    │ │
│  │  │  │         Subred Regional Pública         │ │
│  │  │  │         (10.0.1.0/24)                  │ │
│  │  │  │                                         │ │
│  │  │  │  ┌────────────────┐  ┌────────────────┐ │ │
│  │  │  │  │🖥️ Servidor Web 1│  │🖥️ Servidor Web 2│ │ │
│  │  │  │  │   (FD-1)       │  │   (FD-2)       │ │ │
│  │  │  │  │ Ubuntu 22.04 +  │  │ Ubuntu 22.04 +  │ │ │
│  │  │  │  │    Apache2      │  │    Apache2      │ │ │
│  │  │  │  │   IP: x.x.x.1   │  │   IP: x.x.x.2   │ │ │
│  │  │  │  └────────────────┘  └────────────────┘ │ │
│  │  │  └─────────────────────────────────────────┘ │ │
│  │  │                                                 │ │
│  │  │  🛡️ Network Security Group                     │ │
│  │  │  📡 Internet Gateway                           │ │
│  │  └─────────────────────────────────────────────────┘ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP/HTTPS (80/443)
                              │ SSH (22)
                              ▼
                         🌐 Internet
```

### 🔄 Diferencias Clave con la Arquitectura 2

| Aspecto | Arquitectura 2 (Multi-AD) | Arquitectura 2a (Multi-FD) |
|---------|---------------------------|----------------------------|
| **Distribución** | Múltiples Availability Domains | Múltiples Fault Domains |
| **Ubicación** | AD-1, AD-2 | FD-1, FD-2 (mismo AD) |
| **Disponibilidad** | Tolerancia a fallas de AD completo | Tolerancia a fallas de infraestructura física |
| **Casos de uso** | Regiones con múltiples ADs | Regiones con un solo AD |
| **Granularidad** | Separación geográfica mayor | Separación de infraestructura física |
| **Configuración** | `availability_domain` diferente | `fault_domain` diferente |

### ✨ Características

- **🔧 Alta Disponibilidad Intra-AD**: Distribución en Fault Domains para redundancia física
- **🌍 Acceso Público**: Ambos servidores accesibles directamente desde Internet
- **🛡️ Seguridad Multi-Capa**: Network Security Groups + iptables automático 
- **⚡ Aprovisionamiento Inteligente**: Ansible paralelo con retry logic (3-5 minutos)
- **📍 Distribución Multi-FD**: Redundancia a nivel de infraestructura física
- **🎨 Páginas Web Diferenciadas**: Cada servidor con diseño único y colores distintivos
- **🔄 Despliegue Paralelo**: Configuración simultánea de ambos servidores
- **📊 Información Específica**: Cada página muestra su FD y rol (Primario/Secundario)

### 🛠️ Recursos Desplegados

| Recurso | Tipo | Descripción |
|---------|------|-------------|
| **Compartimento** | `oci_identity_compartment` | Contenedor lógico Enterprise |
| **VCN** | `oci_core_virtual_network` | Red virtual privada (10.0.0.0/16) |
| **Subred Regional** | `oci_core_subnet` | Subred optimizada para single-AD (10.0.1.0/24) |
| **Internet Gateway** | `oci_core_internet_gateway` | Puerta de enlace para acceso a Internet |
| **Tabla de Rutas** | `oci_core_route_table` | Enrutamiento del tráfico hacia Internet Gateway |
| **Network Security Group** | `oci_core_network_security_group` | Reglas de firewall granulares |
| **Instancias Compute (x2)** | `oci_core_instance` | Máquinas virtuales distribuidas en FDs |
| **Claves SSH** | `tls_private_key` | Par de claves para acceso SSH |

### 🎯 Cuándo Usar Esta Arquitectura

**✅ Usar Arquitectura 2a cuando:**
- Tu región OCI solo tiene **un Availability Domain**
- Necesitas alta disponibilidad dentro del mismo AD
- Quieres protección contra fallos de infraestructura física
- El presupuesto o recursos no justifican multi-región

**❌ Usar Arquitectura 2 cuando:**
- Tu región tiene **múltiples Availability Domains**
- Necesitas máxima disponibilidad y tolerancia a fallos
- El presupuesto permite separación geográfica completa

### 🛡️ Configuración de Seguridad

#### 🌐 Network Security Groups
- **SSH**: Puerto 22 desde cualquier IP (0.0.0.0/0)
- **HTTP**: Puerto 80 desde cualquier IP (0.0.0.0/0)
- **HTTPS**: Puerto 443 desde cualquier IP (0.0.0.0/0)
- **Egress**: Todo el tráfico permitido hacia cualquier destino

#### 🔥 IPTables (Configurado por Ansible)
- **Política por defecto**: DROP (deniega todo excepto lo explícitamente permitido)
- **SSH**: Puerto 22 con conexiones establecidas y nuevas
- **HTTP**: Puerto 80 con conexiones establecidas y nuevas  
- **HTTPS**: Puerto 443 con conexiones establecidas y nuevas
- **Loopback**: Tráfico local permitido
- **Conexiones establecidas**: Tráfico de respuesta permitido

---

## 🚀 Métodos de Despliegue

### 🔧 Prerrequisitos

- **Terraform** >= 0.15.0 o **OpenTofu** >= 1.0.0
- **Ansible** >= 2.9 (para aprovisionamiento automático)
- Cuenta activa de Oracle Cloud Infrastructure
- Credenciales de API configuradas
- Cliente Git instalado

> 📝 **Nota**: Esta arquitectura usa Ansible para el aprovisionamiento de ambos servidores web, proporcionando configuración paralela y mejor gestión que remote-exec.

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
export TF_VAR_region="eu-amsterdam-1"
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
region                  = "eu-amsterdam-1"
compartment_ocid        = "ocid1.compartment.oc1..*******"
```

</details>

---

## 🖥️ Despliegue con Terraform/OpenTofu

### 📥 **1. Clonar el Repositorio**

```bash
git clone https://github.com/usuario/arquitecturas-oci-terraform.git
cd arquitecturas-oci-terraform/02a_segundo_servidor_web_en_otro_FD
```

### ✅ **2. Verificar Prerrequisitos**

Asegúrate de tener:
- Terraform >= 0.15.0 o OpenTofu >= 1.0.0 instalado
- Ansible >= 2.9 instalado
- Credenciales OCI configuradas
- Todos los archivos terraform.tfvars configurados

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

   [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/usuario/arquitecturas-oci-terraform/releases/latest/download/02a_segundo_servidor_web_en_otro_FD.zip)

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
| `EnterpriseWebserver1PublicIP` | IP pública del servidor web 1 | `130.61.45.123` |
| `EnterpriseWebserver2PublicIP` | IP pública del servidor web 2 | `130.61.45.124` |

### 🌐 Acceso a los Servidores Web

Una vez completado el despliegue (generalmente 3-5 minutos):

1. **Servidor Web 1 (Primario)**: Visita `http://[IP_PUBLICA_1]` en tu navegador
   - Diseño con tema azul/verde
   - Información del Fault Domain 1
   - Rol: Servidor Primario

2. **Servidor Web 2 (Secundario)**: Visita `http://[IP_PUBLICA_2]` en tu navegador
   - Diseño con tema naranja/morado
   - Información del Fault Domain 2
   - Rol: Servidor Secundario

3. **SSH**: Conecta usando `ssh -i id_rsa_enterprise ubuntu@[IP_PUBLICA]`
   - Usuario: `ubuntu` (no `opc`)
   - Clave: `id_rsa_enterprise` (generada automáticamente)

### 🎨 Características de las Páginas Web

Cada servidor web incluye:
- 🚀 **Header dinámico** con información específica del servidor
- 📊 **Cards informativos** con datos del sistema (IP, hostname, OS, FD)
- 🛠️ **Stack tecnológico** mostrado con badges
- ✅ **Indicadores de estado** del servidor y servicios
- 📱 **Diseño responsive** que se adapta a todos los dispositivos
- 🎨 **Temas de colores diferenciados** para identificar cada servidor
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
| `fault_domain_1` | Fault Domain del servidor 1 | `FAULT-DOMAIN-1` | `FAULT-DOMAIN-2` |
| `fault_domain_2` | Fault Domain del servidor 2 | `FAULT-DOMAIN-2` | `FAULT-DOMAIN-3` |

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
fault_domain_1 = "FAULT-DOMAIN-2"
fault_domain_2 = "FAULT-DOMAIN-3"
```

---

## 🆘 Solución de Problemas

### ❌ Problemas Comunes

<details>
<summary>🔐 <strong>Error de Autenticación SSH/Ansible</strong></summary>

**Problema**: `no such identity: mi_llave_oci.pem: No such file or directory`

**Solución**:
1. Verifica que Terraform haya completado exitosamente: `terraform apply`
2. Comprueba que la clave existe: `ls -la mi_llave_oci.pem`
3. Asegúrate de que la clave tenga permisos correctos: `chmod 600 mi_llave_oci.pem`
4. Verifica que Ansible esté instalado: `ansible --version`

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
<summary>🏠 <strong>Error de Fault Domain</strong></summary>

**Problema**: `Error: The specified fault domain is not available`

**Solución**:
1. Verifica los Fault Domains disponibles en tu región: `oci iam availability-domain list`
2. Ajusta las variables `fault_domain_1` y `fault_domain_2` según los disponibles
3. Asegúrate de que sean diferentes para alta disponibilidad

</details>

<details>
<summary>🌍 <strong>Error de Región Single-AD</strong></summary>

**Problema**: `Error: Region has multiple ADs, use Architecture 2 instead`

**Solución**:
1. Verifica que tu región solo tenga un Availability Domain
2. Si tiene múltiples ADs, usa la Arquitectura 2 estándar
3. Consulta la documentación de OCI para verificar la configuración de tu región

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

# Verificar conectividad manual SSH
ssh -i mi_llave_oci.pem ubuntu@$(terraform output -raw EnterpriseWebserver1PublicIP)

# Ver logs de Ansible
tail -f ansible.log

# Verificar Fault Domains disponibles
oci iam availability-domain list --region eu-amsterdam-1
```

---

## 📚 Recursos Adicionales

### 📖 Documentación

- [Documentación de Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [Guía de Oracle Cloud Infrastructure](https://docs.oracle.com/en-us/iaas/Content/home.htm)
- [Mejores Prácticas de Terraform](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Fault Domains en OCI](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm#fault)

### 📁 Documentación del Proyecto

- [SECURITY.md](SECURITY.md) - Guía de seguridad y mejores prácticas
- [playbook.yml](playbook.yml) - Configuración de Ansible para aprovisionamiento
- [variables.tf](variables.tf) - Variables configurables del proyecto

### 🎓 Próximos Pasos

Después de dominar esta arquitectura, continúa con:

1. **Arquitectura 3**: Balanceador de carga con múltiples servidores
2. **Arquitectura 4**: NAT Gateway y host bastión
3. **Arquitectura 5**: Sistema de archivos compartido

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