# Créditos y Adaptaciones

Este proyecto está basado en el repositorio original de Foggykitchen (https://github.com/mlinxfeld/foggykitchen_tf_oci_course). Incluye adaptaciones y mejoras realizadas por Jesus Montoya, Arquitecto Cloud.

# 🏗️ Arquitecturas de Referencia Terraform OCI

## 🌉 Arquitectura 9 - Peering VCN Remoto Cross-Region

### 📋 Descripción General

Esta arquitectura de referencia implementa una **solución avanzada de interconexión multi-región** en Oracle Cloud Infrastructure (OCI) que combina todas las características de las arquitecturas anteriores con **VCN Remote Peering** para conectar redes virtuales en diferentes regiones geográficas. Es ideal para aplicaciones empresariales que requieren distribución geográfica, redundancia cross-region, latencia optimizada para usuarios globales o cumplimiento de regulaciones de residencia de datos.

La arquitectura despliega una VCN principal en Frankfurt con servidores web y base de datos, y una VCN secundaria en Amsterdam con un servidor backend, interconectadas mediante Dynamic Routing Gateways (DRGs) y Remote Peering Connections (RPCs) para proporcionar conectividad segura entre regiones.

### 🎯 Objetivo

Crear una infraestructura empresarial multi-región con interconexión segura que incluye:
- VCN principal en región primaria (eu-frankfurt-1) con aplicación completa
- VCN secundaria en región remota (eu-amsterdam-1) con servidor backend
- Dynamic Routing Gateways (DRGs) para enrutamiento inteligente
- Remote Peering Connection (RPC) para conectividad cross-region
- Load Balancer público para distribución de tráfico HTTP
- NAT Gateway para salida controlada a internet
- Bastion Host para acceso SSH seguro multi-región
- Oracle Database en subnet privada
- File Storage Service (FSS) para contenido compartido
- Network Security Groups (NSGs) para control granular
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
│  │  │  │                VCN Principal (10.0.0.0/16)             │    │    │    │
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
│  │  │  │  │  │      🗄️ Base de Datos Oracle           │    │    │    │    │    │
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
│  │  │  │              VCN Secundaria (172.16.0.0/16)            │    │    │    │
│  │  │  │                                                         │    │    │    │
│  │  │  │  ┌─────────────────────────────────────────────────┐    │    │    │    │
│  │  │  │  │         Subred Backend                          │    │    │    │    │
│  │  │  │  │         (172.16.1.0/24)                         │    │    │    │    │
│  │  │  │  │                                                 │    │    │    │    │
│  │  │  │  │  ┌─────────────────────────────────────────┐    │    │    │    │    │
│  │  │  │  │  │      🖥️ Servidor Backend               │    │    │    │    │    │
│  │  │  │  │  │    (Ubuntu 22.04 + Aplicación)          │    │    │    │    │    │
│  │  │  │  │  │         IP Privada                      │    │    │    │    │    │
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

### 🔄 Diferencias Clave con la Arquitectura 8

| Aspecto | Arquitectura 8 (Local Peering) | Arquitectura 9 (Remote Peering) |
|---------|----------------------------------|----------------------------------|
| **Alcance** | Peering dentro de la misma región | Peering entre regiones diferentes |
| **Latencia** | Latencia muy baja | Latencia de red entre regiones |
| **Costo** | Sin costos de transferencia | Costos de transferencia cross-region |
| **Disaster Recovery** | Limitado a nivel de región | Protección contra fallos de región |
| **Complejidad** | Configuración moderada | Configuración más compleja |
| **Casos de uso** | Separación de redes locales | Distribución geográfica global |

### ✨ Características

- **🔧 Conectividad Cross-Region**: DRGs y RPCs para comunicación entre regiones
- **🌍 Distribución Geográfica**: Servidores distribuidos globalmente
- **⚖️ Balanceo de Carga**: Load balancer con health checks automáticos
- **🗄️ Base de Datos Oracle**: Sistema de base de datos centralizado en región primaria
- **📁 File Storage Compartido**: Oracle FSS para almacenamiento distribuido
- **🌉 VCN Remote Peering**: Conectividad segura a través del backbone de Oracle
- **🛡️ Seguridad Multi-Capa**: NSGs + iptables + bastión
- **⚡ Aprovisionamiento Inteligente**: Ansible con configuración específica por rol
- **📍 Separación de Redes**: Subredes especializadas por función y región
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
| **Network Security Groups (x5)** | `oci_core_network_security_group` | NSGs para todos los componentes |
| **Host Bastión** | `oci_core_instance` | Instancia para acceso administrativo |
| **Instancias Compute (x2)** | `oci_core_instance` | Servidores web en subred privada |
| **Servidor Backend** | `oci_core_instance` | Servidor backend en región secundaria |
| **Base de Datos** | `oci_database_database` | Instancia de Oracle DB |
| **File Storage Service** | `oci_file_storage_file_system` | Sistema de archivos compartido |
| **Mount Target** | `oci_file_storage_mount_target` | Punto de montaje para FSS |
| **Export Set** | `oci_file_storage_export_set` | Configuración de exportación |
| **DRGs (x2)** | `oci_core_drg` | Dynamic Routing Gateways por región |
| **DRG Attachments (x2)** | `oci_core_drg_attachment` | Conexiones DRG a VCN |
| **Remote Peering Connection** | `oci_core_remote_peering_connection` | Conexión peering entre regiones |
| **Claves SSH** | `tls_private_key` | Par de claves para acceso SSH |

### 🌉 Configuración de VCN Remote Peering

#### 🎯 Características del Remote Peering

- **Conexión Segura**: Tráfico cifrado a través del backbone de Oracle
- **Ancho de Banda Alto**: Hasta 10 Gbps entre regiones
- **Latencia Optimizada**: Rutas directas sin pasar por Internet público
- **Enrutamiento Inteligente**: DRGs manejan el enrutamiento automáticamente

#### 🔧 Componentes del Peering

| Componente | Región | Función |
|------------|--------|---------|
| **DRG Frankfurt** | eu-frankfurt-1 | Gateway de enrutamiento dinámico principal |
| **DRG Amsterdam** | eu-amsterdam-1 | Gateway de enrutamiento dinámico secundario |
| **RPC Connection** | Cross-region | Conexión de peering remoto |
| **Route Tables** | Ambas regiones | Enrutamiento entre subredes |

### 🛡️ Configuración de Seguridad con Network Security Groups

#### 🏰 NSG - Host Bastión (Región Primaria)
- **SSH Ingress**: Puerto 22 desde cualquier IP (0.0.0.0/0)
- **Cross-Region SSH**: Puerto 22 hacia región secundaria
- **Egress**: Todo el tráfico permitido hacia cualquier destino

#### ⚖️ NSG - Load Balancer (Región Primaria)
- **HTTP Ingress**: Puerto 80 desde cualquier IP (0.0.0.0/0)
- **HTTPS Ingress**: Puerto 443 desde cualquier IP (0.0.0.0/0)
- **Egress**: Tráfico hacia subred privada (10.0.2.0/24)

#### 🖥️ NSG - Servidores Web (Región Primaria)
- **SSH Ingress**: Puerto 22 solo desde subred pública (10.0.1.0/24)
- **HTTP Ingress**: Puerto 80 solo desde load balancer
- **HTTPS Ingress**: Puerto 443 solo desde load balancer
- **Cross-Region Access**: Conectividad hacia servidor backend
- **Egress**: Todo el tráfico permitido hacia cualquier destino

#### 🗄️ NSG - Base de Datos (Región Primaria)
- **Oracle DB Ingress**: Puerto 1521 solo desde subred privada (10.0.2.0/24)
- **SSH Ingress**: Puerto 22 solo desde subred pública (10.0.1.0/24)
- **Cross-Region Backup**: Conectividad para backup remoto
- **Egress**: Todo el tráfico permitido hacia cualquier destino

#### 🖥️ NSG - Servidor Backend (Región Secundaria)
- **SSH Ingress**: Puerto 22 desde VCN principal (10.0.0.0/16)
- **Application Traffic**: Puertos específicos de aplicación
- **Cross-Region DB Access**: Conectividad hacia base de datos principal
- **Egress**: Todo el tráfico permitido hacia cualquier destino

#### 🔥 IPTables (Configurado por Ansible)
- **Política por defecto**: DROP (deniega todo excepto lo explícitamente permitido)
- **SSH**: Puerto 22 con conexiones establecidas y nuevas
- **HTTP**: Puerto 80 con conexiones establecidas y nuevas  
- **HTTPS**: Puerto 443 con conexiones establecidas y nuevas
- **Oracle DB**: Puerto 1521 con conexiones establecidas y nuevas
- **Cross-Region**: Tráfico entre regiones permitido
- **Loopback**: Tráfico local permitido
- **Conexiones establecidas**: Tráfico de respuesta permitido

### 🎯 Cuándo Usar Esta Arquitectura

**✅ Usar Arquitectura 9 cuando:**
- Necesitas distribución geográfica de aplicaciones
- Requieres cumplimiento de regulaciones de residencia de datos
- Trabajas con usuarios en múltiples regiones (latencia optimizada)
- Necesitas protección contra fallos de región completa
- Requieres integración de sistemas legacy en diferentes ubicaciones
- Quieres implementar estrategias de disaster recovery cross-region
- Necesitas conectividad segura entre centros de datos virtuales

**❌ Usar Arquitectura 8 cuando:**
- Tu aplicación opera en una sola región
- Los costos de transferencia cross-region son prohibitivos
- La latencia adicional entre regiones no es aceptable
- La complejidad de configuración multi-región es innecesaria
- No tienes requisitos de distribución geográfica

---

## 🚀 Métodos de Despliegue

### 🔧 Prerrequisitos

- **Terraform** >= 0.15.0 o **OpenTofu** >= 1.0.0
- **Ansible** >= 2.9 (para aprovisionamiento automático)
- Cuenta activa de Oracle Cloud Infrastructure
- Credenciales de API configuradas
- **Acceso a múltiples regiones** (eu-frankfurt-1 y eu-amsterdam-1)
- Cliente Git instalado

> 📝 **Nota**: Esta arquitectura requiere configuración dual-region y usa Ansible para el aprovisionamiento de todos los componentes, incluyendo la configuración cross-region.

---

## 🔑 Autenticación con OCI

Antes de desplegar los recursos, configura la autenticación con OCI. Esta arquitectura requiere configuración dual-region:

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
export TF_VAR_region2="eu-amsterdam-1"
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
region2                 = "eu-amsterdam-1"
compartment_ocid        = "ocid1.compartment.oc1..*******"
```

</details>

---

## 🖥️ Despliegue con Terraform/OpenTofu

### 📥 **1. Clonar el Repositorio**

```bash
git clone https://github.com/jesmonsa/01-oci-terraform-foundations.git
cd 01-oci-terraform-foundations/09_peering_vcn_remoto
```

### ✅ **2. Verificar Prerrequisitos**

Asegúrate de tener:
- Terraform >= 0.15.0 o OpenTofu >= 1.0.0 instalado
- Ansible >= 2.9 instalado
- Credenciales OCI configuradas para ambas regiones
- Permisos para crear recursos en múltiples regiones
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

> ⏱️ **Tiempo de despliegue**: 15-25 minutos (recursos en múltiples regiones)

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

4. **Seleccionar región**: Elige la región primaria donde deseas desplegar el stack.

5. **Configurar variables**: Asegúrate de configurar ambas regiones (region y region2).

6. **Crear el stack**: Sigue las instrucciones en pantalla.

7. **Planificar**: Haz clic en **Terraform Actions** → **Plan**.

8. **Revisar**: Espera a que se complete el trabajo y revisa el plan.

9. **Aplicar**: Si todo está correcto, haz clic en **Terraform Actions** → **Apply**.

---

## 📊 Salidas del Despliegue

Después de un despliegue exitoso, obtendrás las siguientes salidas:

| Variable | Descripción | Ejemplo |
|----------|-------------|---------| 
| `generated_ssh_private_key` | Clave SSH privada generada | `-----BEGIN RSA PRIVATE KEY-----...` |
| `BastionPublicIP` | IP pública del host bastión | `130.61.45.123` |
| `LoadBalancerPublicIP` | IP pública del load balancer | `130.61.45.124` |
| `Webserver1PrivateIP` | IP privada del servidor web 1 | `10.0.2.10` |
| `Webserver2PrivateIP` | IP privada del servidor web 2 | `10.0.2.11` |
| `DatabasePrivateIP` | IP privada de la base de datos | `10.0.3.10` |
| `BackendServerPrivateIP` | IP privada del servidor backend | `172.16.1.10` |
| `DRGPrimaryID` | ID del DRG en región primaria | `ocid1.drg.oc1.eu-frankfurt-1...` |
| `DRGSecondaryID` | ID del DRG en región secundaria | `ocid1.drg.oc1.eu-amsterdam-1...` |

### 🌐 Acceso a los Servicios

Una vez completado el despliegue (generalmente 15-25 minutos):

1. **Aplicación Web**: Visita `http://[IP_LOAD_BALANCER]` en tu navegador
   - Balanceo automático entre servidores web
   - Health checks activos
   - Diseño responsive con información del sistema
   - Acceso a archivos compartidos
   - Indicadores de conectividad cross-region

2. **Host Bastión**: Conecta usando `ssh -i id_rsa_enterprise ubuntu@[IP_BASTION]`
   - Único punto de entrada SSH
   - Acceso a servidores web y bases de datos
   - Túnel SSH hacia región secundaria
   - Configuración de seguridad reforzada

3. **Servidores Web**: Acceso solo desde bastión
   - `ssh -i id_rsa_enterprise ubuntu@[IP_PRIVADA_SERVIDOR]`
   - File Storage montado en `/mnt/shared`
   - Conectividad hacia servidor backend via VCN peering
   - No accesibles directamente desde Internet

4. **Base de Datos**: Acceso desde servidores web
   - Conexión Oracle en puerto 1521
   - Credenciales configuradas automáticamente
   - Backup automático configurado
   - Accesible desde ambas regiones via peering

5. **Servidor Backend**: Acceso desde bastión via túnel
   - `ssh -i id_rsa_enterprise ubuntu@[IP_BACKEND]` (via bastión)
   - Aplicación backend configurada automáticamente
   - Conectividad hacia base de datos principal
   - Procesamiento distribuido cross-region

### 🎨 Características de la Aplicación Web

La aplicación web incluye:
- 🚀 **Header dinámico** con información del load balancer
- 📊 **Cards informativos** con datos del sistema (IP, hostname, OS)
- 🛠️ **Stack tecnológico** mostrado con badges
- ✅ **Indicadores de estado** del load balancer y backend
- 🌉 **Estado del VCN Peering** con conectividad cross-region
- 📱 **Diseño responsive** que se adapta a todos los dispositivos
- 📁 **Información de File Storage** mostrando el montaje compartido
- 🗄️ **Estado de la base de datos** con métricas de conexión
- ⏰ **Timestamp** de despliegue actualizado automáticamente

---

## 🔧 Personalización

### 📝 Variables Configurables

| Variable | Descripción | Valor por Defecto | Ejemplo |
|----------|-------------|-------------------|---------| 
| `region` | Región primaria | `eu-frankfurt-1` | `us-ashburn-1` |
| `region2` | Región secundaria | `eu-amsterdam-1` | `us-phoenix-1` |
| `vcn_cidr` | CIDR de la VCN principal | `10.0.0.0/16` | `192.168.0.0/16` |
| `vcn2_cidr` | CIDR de la VCN secundaria | `172.16.0.0/16` | `10.1.0.0/16` |
| `public_subnet_cidr` | CIDR de la subred pública | `10.0.1.0/24` | `192.168.1.0/24` |
| `private_subnet_cidr` | CIDR de la subred privada | `10.0.2.0/24` | `192.168.2.0/24` |
| `database_subnet_cidr` | CIDR de la subred de BD | `10.0.3.0/24` | `192.168.3.0/24` |
| `backend_subnet_cidr` | CIDR de la subred backend | `172.16.1.0/24` | `10.1.1.0/24` |
| `Shape` | Tipo de instancia | `VM.Standard.E3.Flex` | `VM.Standard.E4.Flex` |
| `FlexShapeOCPUS` | Número de CPUs | `1` | `2` |
| `FlexShapeMemory` | Memoria en GB | `2` | `4` |
| `compute_count` | Número de servidores web | `2` | `3` |

### ⚙️ Ejemplo de Personalización

```hcl
# terraform.tfvars
region = "us-ashburn-1"
region2 = "us-phoenix-1"
vcn_cidr = "192.168.0.0/16"
vcn2_cidr = "10.1.0.0/16"
public_subnet_cidr = "192.168.1.0/24"
private_subnet_cidr = "192.168.2.0/24"
database_subnet_cidr = "192.168.3.0/24"
backend_subnet_cidr = "10.1.1.0/24"
Shape = "VM.Standard.E4.Flex"
FlexShapeOCPUS = 2
FlexShapeMemory = 4
compute_count = 3
```

---

## 🆘 Solución de Problemas

### ❌ Problemas Comunes

<details>
<summary>🌉 <strong>Error de Remote Peering Connection</strong></summary>

**Problema**: `Error: Remote Peering Connection failed to establish`

**Solución**:
1. Verifica que ambas regiones estén disponibles para tu tenancy
2. Comprueba que los DRGs estén en estado AVAILABLE antes del peering
3. Asegúrate de que no haya conflictos de CIDR entre VCNs:
   ```bash
   terraform console
   > var.vcn_cidr
   > var.vcn2_cidr
   ```
4. Revisa las políticas IAM para operaciones cross-region

</details>

<details>
<summary>🔐 <strong>Error de Conectividad Cross-Region</strong></summary>

**Problema**: `Connection timeout between regions`

**Solución**:
1. Verifica el estado del Remote Peering Connection:
   ```bash
   oci network remote-peering-connection get --remote-peering-connection-id [RPC_OCID]
   ```
2. Comprueba las route tables en ambas regiones
3. Verifica las reglas de NSG para tráfico cross-region
4. Prueba conectividad manual:
   ```bash
   ssh -i mi_llave_oci.pem ubuntu@[BASTION_IP]
   ping [BACKEND_SERVER_IP]
   ```

</details>

<details>
<summary>🌍 <strong>Error de Configuración Multi-Región</strong></summary>

**Problema**: `Error: Provider configuration for multiple regions`

**Solución**:
1. Verifica que ambas regiones estén configuradas en `provider.tf`
2. Asegúrate de que las variables `region` y `region2` estén definidas
3. Comprueba que tengas permisos en ambas regiones
4. Valida la configuración:
   ```bash
   terraform validate
   terraform plan -target=oci_core_vcn.primary
   terraform plan -target=oci_core_vcn.secondary
   ```

</details>

<details>
<summary>🗄️ <strong>Error de Base de Datos Cross-Region</strong></summary>

**Problema**: `Database connection timeout from secondary region`

**Solución**:
1. Verifica que el peering esté completamente establecido
2. Comprueba las reglas de NSG para puerto 1521 entre regiones
3. Valida la conectividad de red:
   ```bash
   telnet [DATABASE_IP] 1521
   ```
4. Revisa los logs de la base de datos en ambas regiones

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

# Verificar conectividad cross-region desde bastión
ssh -i mi_llave_oci.pem ubuntu@$(terraform output -raw BastionPublicIP) "ping $(terraform output -raw BackendServerPrivateIP)"

# Verificar estado de DRGs
oci network drg get --drg-id $(terraform output -raw DRGPrimaryID)
oci network drg get --drg-id $(terraform output -raw DRGSecondaryID)

# Verificar estado del Remote Peering Connection
oci network remote-peering-connection list --compartment-id [COMPARTMENT_OCID]

# Ver logs de Ansible
tail -f ansible.log

# Verificar route tables
terraform state show oci_core_route_table.primary_rt
terraform state show oci_core_route_table.secondary_rt
```

---

## 📚 Recursos Adicionales

### 📖 Documentación

- [Documentación de Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [Guía de Oracle Cloud Infrastructure](https://docs.oracle.com/en-us/iaas/Content/home.htm)
- [VCN Remote Peering en OCI](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/remoteVCNpeering.htm)
- [Dynamic Routing Gateways](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/managingDRGs.htm)
- [Network Security Groups en OCI](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/networksecuritygroups.htm)

### 📁 Documentación del Proyecto

- [drgs_rpcs.tf](drgs_rpcs.tf) - Configuración de DRGs y Remote Peering
- [nsgs.tf](nsgs.tf) - Configuración de Network Security Groups
- [network.tf](network.tf) - Configuración de VCNs y subredes
- [playbook.yml](playbook.yml) - Configuración de Ansible para aprovisionamiento
- [variables.tf](variables.tf) - Variables configurables del proyecto

### 🎓 Próximos Pasos

Después de dominar esta arquitectura, continúa con:

1. **Arquitectura 9a**: VCN Remote Peering con DataGuard cross-region
2. **Mejoras adicionales**: Container Engine for Kubernetes multi-región
3. **Optimizaciones**: Web Application Firewall (WAF) y CDN global

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