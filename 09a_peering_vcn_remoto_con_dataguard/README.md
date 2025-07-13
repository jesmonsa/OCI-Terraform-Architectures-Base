# Créditos y Adaptaciones

Este proyecto está basado en el repositorio original de Foggykitchen (https://github.com/foggykitchen/oci-terraform-examples). Incluye adaptaciones y mejoras realizadas por Jesus Montoya, Arquitecto Cloud.

# 🏗️ Arquitecturas de Referencia Terraform OCI

## 🌐 Arquitectura 9a - Peering VCN Remoto con DataGuard Cross-Region

### 📋 Descripción General

Esta arquitectura de referencia representa la **evolución más avanzada** de las arquitecturas de Terraform para OCI, diseñada para entornos de producción que requieren máxima disponibilidad y recuperación ante desastres (DR) a nivel multi-región. Combina las funcionalidades de peering VCN remoto con **Oracle DataGuard cross-region** para proporcionar replicación automática de datos entre regiones geográficamente separadas.

La arquitectura implementa una solución completa de Disaster Recovery que incluye VCN peering entre regiones, DataGuard Association cross-region, y todos los componentes necesarios para mantener aplicaciones funcionando incluso en caso de fallo completo de una región.

### 🎯 Objetivo

Crear una infraestructura de Disaster Recovery multi-región que incluye:
- Balanceador de carga con health checks automáticos en región primaria
- Base de datos Oracle primaria con DataGuard cross-region
- Base de datos Oracle standby en región secundaria
- Sistema de archivos compartido (FSS) en ambas regiones
- VCN Peering remoto para conectividad entre regiones
- Network Security Groups para control granular de tráfico
- Host bastión para acceso administrativo seguro
- Aprovisionamiento automático con Ansible

### 🏛️ Arquitectura

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              Oracle Cloud Infrastructure                        │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                    REGIÓN PRIMARIA (eu-frankfurt-1)                    │    │
│  │                                                                         │    │
│  │  ┌─────────────────────────────────────────────────────────────────┐    │    │
│  │  │                  Compartimento Enterprise                       │    │    │
│  │  │                                                               │    │    │
│  │  │  ┌─────────────────────────────────────────────────────────┐    │    │    │
│  │  │  │                VCN (10.0.0.0/16)                       │    │    │    │
│  │  │  │                                                         │    │    │    │
│  │  │  │  ┌─────────────────────────────────────────────────┐    │    │    │    │
│  │  │  │  │         Subred Pública                          │    │    │    │    │
│  │  │  │  │         (10.0.1.0/24)                          │    │    │    │    │
│  │  │  │  │                                                 │    │    │    │    │
│  │  │  │  │  ┌─────────────────────────────────────────┐    │    │    │    │    │
│  │  │  │  │  │      🖥️ Host Bastión                    │    │    │    │    │    │
│  │  │  │  │  │    (Ubuntu 22.04 + SSH)                 │    │    │    │    │    │
│  │  │  │  │  │         IP Pública                      │    │    │    │    │    │
│  │  │  │  │  └─────────────────────────────────────────┘    │    │    │    │    │
│  │  │  │  └─────────────────────────────────────────────────┘    │    │    │    │
│  │  │  │                                                         │    │    │    │
│  │  │  │  ┌─────────────────────────────────────────────────┐    │    │    │    │
│  │  │  │  │         Subred Privada                         │    │    │    │    │
│  │  │  │  │         (10.0.2.0/24)                          │    │    │    │    │
│  │  │  │  │                                                 │    │    │    │    │
│  │  │  │  │  ┌────────────────┐  ┌────────────────┐        │    │    │    │    │
│  │  │  │  │  │🖥️ Servidor Web 1│  │🖥️ Servidor Web 2│        │    │    │    │    │
│  │  │  │  │  │ Ubuntu 22.04 +  │  │ Ubuntu 22.04 +  │        │    │    │    │    │
│  │  │  │  │  │    Apache2      │  │    Apache2      │        │    │    │    │    │
│  │  │  │  │  │   IP Privada    │  │   IP Privada    │        │    │    │    │    │
│  │  │  │  │  └────────────────┘  └────────────────┘        │    │    │    │    │
│  │  │  │  └─────────────────────────────────────────────────┘    │    │    │    │
│  │  │  │                                                         │    │    │    │
│  │  │  │  ┌─────────────────────────────────────────────────┐    │    │    │    │
│  │  │  │  │         Subred de Base de Datos                 │    │    │    │    │
│  │  │  │  │         (10.0.3.0/24)                          │    │    │    │    │
│  │  │  │  │                                                 │    │    │    │    │
│  │  │  │  │  ┌─────────────────────────────────────────┐    │    │    │    │    │
│  │  │  │  │  │      🗄️ Base de Datos Primaria         │    │    │    │    │    │
│  │  │  │  │  │    (Oracle 19c - AD1)                   │    │    │    │    │    │
│  │  │  │  │  │         IP Privada                      │    │    │    │    │    │
│  │  │  │  │  └─────────────────────────────────────────┘    │    │    │    │    │
│  │  │  │  └─────────────────────────────────────────────────┘    │    │    │    │
│  │  │  │                                                         │    │    │    │
│  │  │  │  🛡️ Network Security Groups                             │    │    │    │
│  │  │  │  📡 Internet Gateway                                   │    │    │    │
│  │  │  │  🌐 NAT Gateway                                         │    │    │    │
│  │  │  │  ⚖️ Load Balancer                                       │    │    │    │
│  │  │  │  🌉 DRG (Dynamic Routing Gateway)                      │    │    │    │
│  │  │  └─────────────────────────────────────────────────────────┘    │    │    │
│  │  └─────────────────────────────────────────────────────────────────┘    │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                    REGIÓN SECUNDARIA (eu-amsterdam-1)                  │    │
│  │                                                                         │    │
│  │  ┌─────────────────────────────────────────────────────────────────┐    │    │
│  │  │                  Compartimento Enterprise                       │    │    │
│  │  │                                                               │    │    │
│  │  │  ┌─────────────────────────────────────────────────────────┐    │    │    │
│  │  │  │                VCN (172.16.0.0/16)                     │    │    │    │
│  │  │  │                                                         │    │    │    │
│  │  │  │  ┌─────────────────────────────────────────────────┐    │    │    │    │
│  │  │  │  │         Subred de Base de Datos                 │    │    │    │    │
│  │  │  │  │         (172.16.3.0/24)                         │    │    │    │    │
│  │  │  │  │                                                 │    │    │    │    │
│  │  │  │  │  ┌─────────────────────────────────────────┐    │    │    │    │    │
│  │  │  │  │  │      🗄️ Base de Datos Standby          │    │    │    │    │    │
│  │  │  │  │  │    (Oracle 19c - AD1)                   │    │    │    │    │    │
│  │  │  │  │  │         IP Privada                      │    │    │    │    │    │
│  │  │  │  │  │                                         │    │    │    │    │    │
│  │  │  │  │  │ 🔄 DataGuard Cross-Region              │    │    │    │    │    │
│  │  │  │  │  │    Association                         │    │    │    │    │    │
│  │  │  │  │  └─────────────────────────────────────────┘    │    │    │    │    │
│  │  │  │  └─────────────────────────────────────────────────┘    │    │    │    │
│  │  │  │                                                         │    │    │    │
│  │  │  │  🛡️ Network Security Groups                             │    │    │    │
│  │  │  │  🌉 DRG (Dynamic Routing Gateway)                      │    │    │    │
│  │  │  └─────────────────────────────────────────────────────────┘    │    │    │
│  │  └─────────────────────────────────────────────────────────────────┘    │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │                    VCN REMOTE PEERING CONNECTION                       │    │
│  │                                                                         │    │
│  │  🌉 DRG Frankfurt ←─── OCI Backbone Network ───→ 🌉 DRG Amsterdam      │    │
│  │                                                                         │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP/HTTPS (80/443)
                              │ SSH (22) - Solo Bastión
                              ▼
                         🌐 Internet
```

### 🔄 Diferencias Clave con la Arquitectura 9

| Aspecto | Arquitectura 9 (Local Peering) | Arquitectura 9a (Remote Peering + DataGuard) |
|---------|----------------------------------|-----------------------------------------------|
| **Alcance** | Peering dentro de la misma región | Peering entre regiones diferentes |
| **Base de Datos** | Sin replicación automática | DataGuard cross-region automático |
| **Disaster Recovery** | Sin capacidades de DR | DR completo multi-región |
| **Complejidad** | Configuración moderada | Configuración avanzada |
| **Casos de uso** | Separación de redes locales | Aplicaciones críticas multi-región |
| **Costo** | Menor | Mayor (duplicación de recursos) |

### ✨ Características

- **🔧 Disaster Recovery Multi-Región**: Protección contra fallos de región completa
- **🌍 Alta Disponibilidad**: DataGuard cross-region con failover automático
- **⚖️ Balanceo de Carga**: Load balancer con health checks automáticos
- **🗄️ Base de Datos Oracle**: Primaria y standby con replicación cross-region
- **📁 File Storage Compartido**: Oracle FSS en ambas regiones
- **🌉 VCN Remote Peering**: Conectividad segura entre regiones
- **🛡️ Seguridad Multi-Capa**: NSGs + iptables + bastión
- **⚡ Aprovisionamiento Inteligente**: Ansible con configuración específica por rol
- **📍 Separación de Redes**: Subredes especializadas por función
- **🎨 Páginas Web Diferenciadas**: Cada servidor con información específica

### 🛠️ Recursos Desplegados

| Recurso | Tipo | Descripción |
|---------|------|-------------|
| **Compartimentos (x2)** | `oci_identity_compartment` | Contenedores lógicos por región |
| **VCNs (x2)** | `oci_core_virtual_network` | Redes virtuales por región |
| **Subredes (x4)** | `oci_core_subnet` | Subredes especializadas por función |
| **Internet Gateway** | `oci_core_internet_gateway` | Puerta de enlace para acceso a Internet |
| **NAT Gateway** | `oci_core_nat_gateway` | NAT para acceso a Internet desde subredes privadas |
| **Load Balancer** | `oci_load_balancer_load_balancer` | Balanceador de carga con health checks |
| **Backend Set** | `oci_load_balancer_backend_set` | Configuración de backend servers |
| **Network Security Groups (x6)** | `oci_core_network_security_group` | NSGs para todos los componentes |
| **Host Bastión** | `oci_core_instance` | Instancia para acceso administrativo |
| **Instancias Compute (x2)** | `oci_core_instance` | Servidores web en subred privada |
| **Base de Datos Primaria** | `oci_database_database` | Instancia principal de Oracle DB |
| **Base de Datos Standby** | `oci_database_database` | Instancia standby en región secundaria |
| **DataGuard Association** | `oci_database_data_guard_association` | Configuración de replicación cross-region |
| **File Storage Service (x2)** | `oci_file_storage_file_system` | Sistemas de archivos por región |
| **Mount Targets (x2)** | `oci_file_storage_mount_target` | Puntos de montaje por región |
| **Export Sets (x2)** | `oci_file_storage_export_set` | Configuraciones de exportación |
| **DRGs (x2)** | `oci_core_drg` | Dynamic Routing Gateways por región |
| **DRG Attachments (x2)** | `oci_core_drg_attachment` | Conexiones DRG a VCN |
| **Remote Peering Connection** | `oci_core_remote_peering_connection` | Conexión peering entre regiones |
| **Claves SSH** | `tls_private_key` | Par de claves para acceso SSH |

### 🛡️ Configuración de Seguridad con Network Security Groups

#### 🏰 NSG - Host Bastión (Región Primaria)
- **SSH Ingress**: Puerto 22 desde cualquier IP (0.0.0.0/0)
- **Egress**: Todo el tráfico permitido hacia cualquier destino

#### ⚖️ NSG - Load Balancer (Región Primaria)
- **HTTP Ingress**: Puerto 80 desde cualquier IP (0.0.0.0/0)
- **HTTPS Ingress**: Puerto 443 desde cualquier IP (0.0.0.0/0)
- **Egress**: Tráfico hacia subred privada (10.0.2.0/24)

#### 🖥️ NSG - Servidores Web (Región Primaria)
- **SSH Ingress**: Puerto 22 solo desde subred pública (10.0.1.0/24)
- **HTTP Ingress**: Puerto 80 solo desde load balancer
- **HTTPS Ingress**: Puerto 443 solo desde load balancer
- **NFS Ingress**: Puerto 2049 desde subred FSS (10.0.4.0/24)
- **Egress**: Todo el tráfico permitido hacia cualquier destino

#### 🗄️ NSG - Base de Datos Primaria (Región Primaria)
- **Oracle DB Ingress**: Puerto 1521 solo desde subred privada (10.0.2.0/24)
- **DataGuard Ingress**: Puerto 1521 desde región secundaria
- **SSH Ingress**: Puerto 22 solo desde subred pública (10.0.1.0/24)
- **Egress**: Todo el tráfico permitido hacia cualquier destino

#### 🗄️ NSG - Base de Datos Standby (Región Secundaria)
- **Oracle DB Ingress**: Puerto 1521 solo desde región primaria
- **DataGuard Ingress**: Puerto 1521 hacia región primaria
- **SSH Ingress**: Puerto 22 solo desde región primaria
- **Egress**: Todo el tráfico permitido hacia cualquier destino

#### 📁 NSG - File Storage (Ambas Regiones)
- **NFS Ingress**: Puerto 2049 solo desde subredes autorizadas
- **Egress**: Tráfico de respuesta permitido

#### 🔥 IPTables (Configurado por Ansible)
- **Política por defecto**: DROP (deniega todo excepto lo explícitamente permitido)
- **SSH**: Puerto 22 con conexiones establecidas y nuevas
- **HTTP**: Puerto 80 con conexiones establecidas y nuevas  
- **HTTPS**: Puerto 443 con conexiones establecidas y nuevas
- **NFS**: Puerto 2049 con conexiones establecidas y nuevas
- **Oracle DB**: Puerto 1521 con conexiones establecidas y nuevas
- **DataGuard Cross-Region**: Puerto 1521 entre regiones
- **Loopback**: Tráfico local permitido
- **Conexiones establecidas**: Tráfico de respuesta permitido

### 🎯 Cuándo Usar Esta Arquitectura

**✅ Usar Arquitectura 9a cuando:**
- Necesitas protección contra fallos de región completa
- Trabajas con aplicaciones críticas que no pueden tolerar tiempo de inactividad
- Requieres Disaster Recovery automático multi-región
- Necesitas cumplir con requisitos de RTO/RPO muy estrictos
- Trabajas en entornos regulados que requieren DR
- Quieres implementar principios de "defensa en profundidad" multi-región
- Necesitas replicación automática de datos entre regiones

**❌ Usar Arquitectura 9 cuando:**
- Tu entorno es de desarrollo o pruebas
- No necesitas protección contra fallos de región
- El presupuesto no permite duplicación completa de recursos
- Prefieres configuración más sencilla
- El equipo no tiene experiencia con DataGuard cross-region

---

## 🚀 Métodos de Despliegue

### 🔧 Prerrequisitos

- **Terraform** >= 0.15.0 o **OpenTofu** >= 1.0.0
- **Ansible** >= 2.9 (para aprovisionamiento automático)
- Cuenta activa de Oracle Cloud Infrastructure
- Credenciales de API configuradas
- Cliente Git instalado
- Acceso a múltiples regiones OCI

> 📝 **Nota**: Esta arquitectura usa Ansible para el aprovisionamiento de todos los componentes en ambas regiones, incluyendo la configuración de DataGuard cross-region.

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
export TF_VAR_secondary_region="eu-amsterdam-1"
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
secondary_region        = "eu-amsterdam-1"
```

</details>

---

## 🖥️ Despliegue con Terraform/OpenTofu

### 📥 **1. Clonar el Repositorio**

```bash
git clone https://github.com/usuario/arquitecturas-oci-terraform.git
cd arquitecturas-oci-terraform/09a_peering_vcn_remoto_con_dataguard
```

### ✅ **2. Verificar Prerrequisitos**

Asegúrate de tener:
- Terraform >= 0.15.0 o OpenTofu >= 1.0.0 instalado
- Ansible >= 2.9 instalado
- Credenciales OCI configuradas
- Todos los archivos terraform.tfvars configurados
- Acceso a las regiones especificadas

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

   [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/usuario/arquitecturas-oci-terraform/releases/latest/download/09a_peering_vcn_remoto_con_dataguard.zip)

2. **Iniciar sesión**: Si no has iniciado sesión, introduce las credenciales de tu tenancy y usuario.

3. **Revisar términos**: Acepta los términos y condiciones.

4. **Seleccionar región**: Elige la región primaria donde deseas desplegar el stack.

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
| `BastionPublicIP` | IP pública del host bastión (región primaria) | `130.61.45.123` |
| `LoadBalancerPublicIP` | IP pública del load balancer (región primaria) | `130.61.45.124` |
| `Webserver1PrivateIP` | IP privada del servidor web 1 (región primaria) | `10.0.2.10` |
| `Webserver2PrivateIP` | IP privada del servidor web 2 (región primaria) | `10.0.2.11` |
| `DatabasePrimaryIP` | IP privada de la base de datos primaria | `10.0.3.10` |
| `DatabaseStandbyIP` | IP privada de la base de datos standby (región secundaria) | `172.16.3.10` |
| `FileStorageMountIP` | IP del mount target de FSS (región primaria) | `10.0.4.10` |
| `FileStorageMountIPSecondary` | IP del mount target de FSS (región secundaria) | `172.16.4.10` |

### 🌐 Acceso a los Servicios

Una vez completado el despliegue (generalmente 15-20 minutos):

1. **Aplicación Web**: Visita `http://[IP_LOAD_BALANCER]` en tu navegador
   - Balanceo automático entre servidores web
   - Health checks activos
   - Diseño responsive con información del sistema
   - Acceso a archivos compartidos
   - Indicadores de estado de DataGuard cross-region

2. **Host Bastión**: Conecta usando `ssh -i id_rsa_enterprise ubuntu@[IP_BASTION]`
   - Único punto de entrada SSH
   - Acceso a servidores web y bases de datos
   - Configuración de seguridad reforzada

3. **Servidores Web**: Acceso solo desde bastión
   - `ssh -i id_rsa_enterprise ubuntu@[IP_PRIVADA_SERVIDOR]`
   - File Storage montado en `/mnt/shared`
   - No accesibles directamente desde Internet

4. **Base de Datos Primaria**: Acceso desde servidores web
   - Conexión Oracle en puerto 1521
   - Credenciales configuradas automáticamente
   - Backup automático configurado

5. **Base de Datos Standby**: Monitoreo y administración
   - Replicación automática desde primaria
   - Failover automático en caso de fallo de región
   - Monitoreo de estado de DataGuard cross-region

### 🎨 Características de la Aplicación Web

La aplicación web incluye:
- 🚀 **Header dinámico** con información del load balancer
- 📊 **Cards informativos** con datos del sistema
- 🛠️ **Stack tecnológico** mostrado con badges
- ✅ **Indicadores de estado** del load balancer y backend
- 📱 **Diseño responsive** que se adapta a todos los dispositivos
- 📁 **Información de File Storage** mostrando el montaje compartido
- 🗄️ **Estado de DataGuard Cross-Region** con indicadores de replicación
- 🔄 **Estado de la base de datos** primaria y standby
- 🌉 **Información de VCN Peering** entre regiones
- ⏰ **Timestamp** de despliegue actualizado automáticamente

---

## 🔧 Personalización

### 📝 Variables Configurables

| Variable | Descripción | Valor por Defecto | Ejemplo |
|----------|-------------|-------------------|---------|
| `vcn_cidr` | CIDR de la VCN primaria | `10.0.0.0/16` | `192.168.0.0/16` |
| `vcn_cidr_secondary` | CIDR de la VCN secundaria | `172.16.0.0/16` | `172.20.0.0/16` |
| `public_subnet_cidr` | CIDR de la subred pública | `10.0.1.0/24` | `192.168.1.0/24` |
| `private_subnet_cidr` | CIDR de la subred privada | `10.0.2.0/24` | `192.168.2.0/24` |
| `database_subnet_cidr` | CIDR de la subred de BD primaria | `10.0.3.0/24` | `192.168.3.0/24` |
| `database_subnet_cidr_secondary` | CIDR de la subred de BD secundaria | `172.16.3.0/24` | `172.20.3.0/24` |
| `fss_subnet_cidr` | CIDR de la subred FSS primaria | `10.0.4.0/24` | `192.168.4.0/24` |
| `fss_subnet_cidr_secondary` | CIDR de la subred FSS secundaria | `172.16.4.0/24` | `172.20.4.0/24` |
| `Shape` | Tipo de instancia | `VM.Standard.E3.Flex` | `VM.Standard.E4.Flex` |
| `FlexShapeOCPUS` | Número de CPUs | `1` | `2` |
| `FlexShapeMemory` | Memoria en GB | `2` | `4` |
| `instance_os` | Sistema operativo | `Canonical Ubuntu` | `Oracle Linux` |
| `linux_os_version` | Versión del SO | `22.04` | `20.04` |
| `compute_count` | Número de servidores web | `2` | `3` |
| `database_admin_password` | Contraseña de admin BD | Generada automáticamente | `MiPassword123!` |
| `data_guard_protection_mode` | Modo de protección DataGuard | `MAXIMUM_PERFORMANCE` | `MAXIMUM_AVAILABILITY` |
| `region` | Región primaria | `eu-frankfurt-1` | `us-ashburn-1` |
| `secondary_region` | Región secundaria | `eu-amsterdam-1` | `us-phoenix-1` |

### ⚙️ Ejemplo de Personalización

```hcl
# terraform.tfvars
vcn_cidr = "192.168.0.0/16"
vcn_cidr_secondary = "172.20.0.0/16"
public_subnet_cidr = "192.168.1.0/24"
private_subnet_cidr = "192.168.2.0/24"
database_subnet_cidr = "192.168.3.0/24"
database_subnet_cidr_secondary = "172.20.3.0/24"
fss_subnet_cidr = "192.168.4.0/24"
fss_subnet_cidr_secondary = "172.20.4.0/24"
Shape = "VM.Standard.E4.Flex"
FlexShapeOCPUS = 2
FlexShapeMemory = 4
instance_os = "Oracle Linux"
linux_os_version = "8"
compute_count = 3
database_admin_password = "MiPasswordSegura123!"
data_guard_protection_mode = "MAXIMUM_AVAILABILITY"
region = "us-ashburn-1"
secondary_region = "us-phoenix-1"
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
<summary>🌉 <strong>Error de VCN Remote Peering</strong></summary>

**Problema**: `Error: Remote peering connection failed`

**Solución**:
1. Verifica que ambas regiones estén disponibles: `oci iam region list`
2. Comprueba que los DRGs se hayan creado: `terraform state list | grep drg`
3. Verifica la conectividad de red entre regiones
4. Revisa los logs de Terraform para errores específicos

</details>

<details>
<summary>🗄️ <strong>Error de DataGuard Cross-Region</strong></summary>

**Problema**: `Error: DataGuard cross-region association failed`

**Solución**:
1. Verifica que ambas bases de datos estén running: `oci db database get --database-id [DB_OCID]`
2. Comprueba la conectividad entre regiones: `telnet [DB_STANDBY_IP] 1521`
3. Verifica la configuración de red cross-region
4. Revisa los logs de DataGuard en ambas instancias

</details>

<details>
<summary>🌐 <strong>Error de Network Security Groups</strong></summary>

**Problema**: `Error: Network Security Group not found`

**Solución**:
1. Verifica que los NSGs se hayan creado correctamente: `terraform state list | grep nsg`
2. Comprueba las reglas de los NSGs en la consola de OCI
3. Asegúrate de que las instancias estén asociadas a los NSGs correctos

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

# Verificar conectividad al bastión
ssh -i mi_llave_oci.pem ubuntu@$(terraform output -raw BastionPublicIP)

# Verificar estado de DataGuard cross-region
ssh -i mi_llave_oci.pem ubuntu@$(terraform output -raw BastionPublicIP) "ssh ubuntu@$(terraform output -raw DatabasePrimaryIP) 'sqlplus / as sysdba @check_dataguard_cross_region.sql'"

# Verificar conectividad entre regiones
ssh -i mi_llave_oci.pem ubuntu@$(terraform output -raw BastionPublicIP) "ssh ubuntu@$(terraform output -raw DatabasePrimaryIP) 'telnet $(terraform output -raw DatabaseStandbyIP) 1521'"

# Verificar estado de VCN Remote Peering
oci network remote-peering-connection get --remote-peering-connection-id $(terraform output -raw RemotePeeringConnectionOCID)

# Ver logs de Ansible
tail -f ansible.log

# Verificar estado de las bases de datos
oci db database get --database-id $(terraform output -raw DatabasePrimaryOCID)
oci db database get --database-id $(terraform output -raw DatabaseStandbyOCID)

# Verificar estado de DataGuard Association
oci db data-guard-association get --database-id $(terraform output -raw DatabasePrimaryOCID) --data-guard-association-id $(terraform output -raw DataGuardAssociationOCID)
```

---

## 📚 Recursos Adicionales

### 📖 Documentación

- [Documentación de Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [Guía de Oracle Cloud Infrastructure](https://docs.oracle.com/en-us/iaas/Content/home.htm)
- [Mejores Prácticas de Terraform](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Network Security Groups en OCI](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/networksecuritygroups.htm)
- [Oracle DataGuard](https://docs.oracle.com/en-us/database/oracle/oracle-database/19/sbydb/index.html)
- [VCN Remote Peering](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/remoteVCNpeering.htm)

### 📁 Documentación del Proyecto

- [SECURITY.md](SECURITY.md) - Guía de seguridad y mejores prácticas
- [nsgs.tf](nsgs.tf) - Configuración de Network Security Groups
- [dbsystem.tf](dbsystem.tf) - Configuración de DataGuard cross-region
- [drgs_rpcs.tf](drgs_rpcs.tf) - Configuración de VCN Remote Peering
- [playbook.yml](playbook.yml) - Configuración de Ansible para aprovisionamiento
- [variables.tf](variables.tf) - Variables configurables del proyecto

### 🎓 Próximos Pasos

Después de dominar esta arquitectura, has completado el curso completo de arquitecturas OCI Terraform. Considera:

1. **Implementar en producción** con las configuraciones aprendidas
2. **Personalizar** las arquitecturas para tus necesidades específicas
3. **Contribuir** al proyecto con mejoras y nuevas funcionalidades
4. **Compartir** el conocimiento con la comunidad

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