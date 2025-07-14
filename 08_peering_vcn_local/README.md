# Créditos y Adaptaciones

Este proyecto está basado en el repositorio original de Foggykitchen (https://github.com/mlinxfeld/foggykitchen_tf_oci_course). Incluye adaptaciones y mejoras realizadas por Jesus Montoya, Arquitecto Cloud.

# 🏗️ Arquitecturas de Referencia Terraform OCI

## 🔗 Arquitectura 8 - Peering VCN Local

### 📋 Descripción General

Esta arquitectura de referencia implementa una **solución avanzada de interconexión de redes** en Oracle Cloud Infrastructure (OCI) que combina todas las características de las arquitecturas anteriores con **VCN Local Peering** para conectar dos redes virtuales completamente separadas. Es ideal para aplicaciones empresariales que requieren separación de entornos, microservicios distribuidos o integración de sistemas legacy con nuevas aplicaciones.

### 🎯 Objetivo

Crear una infraestructura empresarial con interconexión de redes que incluye:
- Dos compartimentos enterprise completamente separados
- Dos Redes Virtuales en la Nube (VCN) con CIDRs diferentes
- Servidores web en la VCN principal con acceso a base de datos
- Un servidor backend en la VCN secundaria (isla aislada)
- Local Peering Gateway (LPG) para interconexión de VCNs
- Load Balancer público para distribución de tráfico HTTP
- NAT Gateway para salida controlada a internet
- Bastion Host para acceso SSH seguro
- Oracle Database en subnet privada
- File Storage Service (FSS) para contenido compartido
- Network Security Groups (NSGs) para control granular
- Página web moderna que muestra información del sistema interconectado
- Aprovisionamiento 100% automático con Ansible

### 🏛️ Arquitectura

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Oracle Cloud Infrastructure                      │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │                Compartimento Principal                           │ │
│  │                                                                 │ │
│  │  ┌─────────────────────────────────────────────────────────────┐ │ │
│  │  │              VCN Principal (10.0.0.0/16)                   │ │ │
│  │  │                                                             │ │ │
│  │  │  ┌──────────────────┐ ┌─────────────────┐ ┌────────────────┐ │ │ │
│  │  │  │  Subnet Web      │ │ Subnet LB       │ │ Subnet Bastion │ │ │ │
│  │  │  │  (10.0.1.0/24)   │ │ (10.0.2.0/24)   │ │ (10.0.3.0/24)  │ │ │ │
│  │  │  │                  │ │                 │ │                │ │ │ │
│  │  │  │ 🖥️ WebServer1    │ │ ⚖️ Load Balancer│ │ 🏰 Bastion Host│ │ │ │
│  │  │  │ 🖥️ WebServer2    │ │   (Público)     │ │   (Público)    │ │ │ │
│  │  │  │ 🖥️ WebServer3    │ │                 │ │                │ │ │ │
│  │  │  │   (Privados)     │ │                 │ │                │ │ │ │
│  │  │  │                  │ │                 │ │                │ │ │ │
│  │  │  │      ▲           │ │        ▲        │ │       ▲        │ │ │ │
│  │  │  │      │ SSH via   │ │        │ HTTP   │ │       │ SSH    │ │ │ │
│  │  │  │      │ Bastion   │ │        │        │ │       │        │ │ │ │
│  │  │  │      │           │ │        │        │ │       │        │ │ │ │
│  │  │  └──────┼───────────┘ └────────┼────────┘ └───────┼────────┘ │ │ │
│  │  │         │                      │                  │          │ │ │
│  │  │         │ ◄─────── Load Balance ──────────────────┘          │ │ │
│  │  │         │                      │                             │ │ │
│  │  │  ┌──────▼─────────────────┐    │                             │ │ │
│  │  │  │    🌐 NAT Gateway       │    │                             │ │ │
│  │  │  │  (Salida Internet)     │    │                             │ │ │
│  │  │  └────────────────────────┘    │                             │ │ │
│  │  │                                │                             │ │ │
│  │  │  ┌────────────────────────┐    │                             │ │ │
│  │  │  │    📁 FSS Mount Target │    │                             │ │ │
│  │  │  │   (Almacenamiento      │    │                             │ │ │
│  │  │  │    Compartido NFS)     │    │                             │ │ │
│  │  │  └────────────────────────┘    │                             │ │ │
│  │  │                                │                             │ │ │
│  │  │  ┌────────────────────────┐    │                             │ │ │
│  │  │  │    🗄️ Subnet DB        │    │                             │ │ │
│  │  │  │    (10.0.4.0/24)       │    │                             │ │ │
│  │  │  │                        │    │                             │ │ │
│  │  │  │  🗄️ Oracle DB 19c     │    │                             │ │ │
│  │  │  │  (Privado)             │    │                             │ │ │
│  │  │  └────────────────────────┘    │                             │ │ │
│  │  │                                │                             │ │ │
│  │  │  🔗 LPG Principal              │                             │ │ │
│  │  │  ┌────────────────────────┐    │                             │ │ │
│  │  │  │    🔗 LPG Connection   │    │                             │ │ │
│  │  │  │    (Local Peering)     │    │                             │ │ │
│  │  │  └────────────────────────┘    │                             │ │ │
│  │  │                                │                             │ │ │
│  │  │         📡 Internet Gateway ───┘                             │ │ │
│  │  └─────────────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────┘ │ │
│                                                                     │ │
│  ┌─────────────────────────────────────────────────────────────────┐ │ │
│  │              Compartimento Externo                              │ │ │
│  │                                                                 │ │ │
│  │  ┌─────────────────────────────────────────────────────────────┐ │ │ │
│  │  │              VCN Externa (192.168.0.0/16)                  │ │ │ │
│  │  │                                                             │ │ │ │
│  │  │  ┌─────────────────────────────────────────────────────┐    │ │ │ │
│  │  │  │         Subnet Backend (192.168.1.0/24)            │    │ │ │ │
│  │  │  │                                                 │    │ │ │ │
│  │  │  │  🖥️ Backend Server                              │    │ │ │ │
│  │  │  │  Ubuntu + Aplicación Backend                    │    │ │ │ │
│  │  │  │  VM.Standard.E3.Flex (Privado)                  │    │ │ │ │
│  │  │  │                                                 │    │ │ │ │
│  │  │  │  🔗 LPG Externo                                  │    │ │ │ │
│  │  │  │  ┌─────────────────────────┐                     │    │ │ │ │
│  │  │  │  │    🔗 LPG Connection    │                     │    │ │ │ │
│  │  │  │  │    (Local Peering)      │                     │    │ │ │ │
│  │  │  │  └─────────────────────────┘                     │    │ │ │ │
│  │  │  └─────────────────────────────────────────────────────┘    │ │ │ │
│  │  └─────────────────────────────────────────────────────────────┘ │ │ │
│  └─────────────────────────────────────────────────────────────────┘ │ │
└─────────────────────────────────────────────────────────────────────┘ │
                              │
                              │ HTTP (80) - Load Balanced
                              │ SSH (22) - Solo Bastion Host  
                              ▼
                         🌐 Internet
```

### ✨ Características

- **🔗 VCN Local Peering**: Interconexión de dos VCNs completamente separadas
- **🏢 Compartimentos Separados**: Aislamiento organizacional completo
- **🗄️ Base de Datos Oracle 19c**: Sistema de base de datos empresarial
- **🛡️ Seguridad Zero-Trust**: Network Security Groups sin Security Lists
- **⚖️ Load Balancing**: OCI Load Balancer con health checks avanzados
- **🔄 Alta Disponibilidad**: Múltiples servidores backend con base de datos
- **🏰 Acceso Seguro**: Bastion Host como único punto de entrada SSH
- **🌐 Conectividad Controlada**: NAT Gateway para salida segura a internet
- **🔒 Aislamiento Completo**: Servicios distribuidos en VCNs separadas
- **⚡ NSGs Granulares**: Control de tráfico a nivel de VNIC
- **📁 Almacenamiento Compartido**: FSS para contenido web
- **🎨 Página Web Avanzada**: Diseño que muestra información del sistema interconectado
- **📊 Monitoreo Integrado**: Health checks y logs centralizados

### 🛠️ Recursos Desplegados

| Recurso | Tipo | Descripción |
|---------|------|-------------|
| **Compartimento Principal** | `oci_identity_compartment` | Compartimento para VCN principal |
| **Compartimento Externo** | `oci_identity_compartment` | Compartimento para VCN externa |
| **VCN Principal** | `oci_core_virtual_network` | Red virtual principal (10.0.0.0/16) |
| **VCN Externa** | `oci_core_virtual_network` | Red virtual externa (192.168.0.0/16) |
| **Subnet Web** | `oci_core_subnet` | Subnet para servidores web (10.0.1.0/24) |
| **Subnet LB** | `oci_core_subnet` | Subnet pública para Load Balancer (10.0.2.0/24) |
| **Subnet Bastion** | `oci_core_subnet` | Subnet pública para Bastion Host (10.0.3.0/24) |
| **Subnet DB** | `oci_core_subnet` | Subnet privada para base de datos (10.0.4.0/24) |
| **Subnet FSS** | `oci_core_subnet` | Subnet privada para FSS (10.0.5.0/24) |
| **Subnet Backend** | `oci_core_subnet` | Subnet privada para backend (192.168.1.0/24) |
| **Internet Gateway** | `oci_core_internet_gateway` | Puerta de enlace para tráfico público |
| **NAT Gateway** | `oci_core_nat_gateway` | Salida a internet para subnets privadas |
| **Load Balancer** | `oci_load_balancer` | Balanceador de carga público flexible |
| **Bastion Host** | `oci_core_instance` | Servidor de salto para acceso SSH |
| **Web Servers** | `oci_core_instance` | VMs Ubuntu 22.04 en subnet privada |
| **Backend Server** | `oci_core_instance` | VM Ubuntu 22.04 en VCN externa |
| **Oracle Database** | `oci_database_db_system` | Oracle Database 19c Standard Edition |
| **File Storage System** | `oci_file_storage_file_system` | Sistema de archivos NFS compartido |
| **Mount Target** | `oci_file_storage_mount_target` | Punto de montaje NFS |
| **LPG Principal** | `oci_core_local_peering_gateway` | Gateway de peering en VCN principal |
| **LPG Externo** | `oci_core_local_peering_gateway` | Gateway de peering en VCN externa |
| **NSGs** | `oci_core_network_security_group` | Grupos de seguridad granulares |
| **Claves SSH** | `tls_private_key` | Par de claves para acceso SSH |

### 🔗 Configuración de VCN Local Peering

#### 🎯 Características del Peering
- **Tipo**: Local Peering Gateway (LPG)
- **Alcance**: Misma región, diferentes VCNs
- **Rutas**: Configuración automática de rutas entre VCNs
- **Seguridad**: Control granular con NSGs
- **Latencia**: Mínima (misma región)

#### 🔧 Configuración Automática
El peering se configura automáticamente con:

```hcl
# LPG en VCN Principal
resource "oci_core_local_peering_gateway" "EnterpriseLPG1" {
  compartment_id = oci_identity_compartment.EnterpriseCompartment.id
  vcn_id         = oci_core_virtual_network.EnterpriseVCN.id
  display_name   = "EnterpriseLPG1"
  peer_id        = oci_core_local_peering_gateway.EnterpriseLPG2.id
}

# LPG en VCN Externa
resource "oci_core_local_peering_gateway" "EnterpriseLPG2" {
  compartment_id = oci_identity_compartment.ExternalCompartment.id
  vcn_id         = oci_core_virtual_network.EnterpriseVCN2.id
  display_name   = "EnterpriseLPG2"
  peer_id        = oci_core_local_peering_gateway.EnterpriseLPG1.id
}
```

#### 🔒 Seguridad de Peering
- **Aislamiento**: VCNs completamente separadas
- **Acceso**: Controlado por NSGs y rutas
- **Auditoría**: Logs de tráfico entre VCNs
- **Políticas**: IAM policies para control de acceso

### 🗄️ Configuración de Oracle Database

#### 🎯 Características de la Base de Datos
- **Versión**: Oracle Database 19c Standard Edition
- **Shape**: VM.Standard.E3.Flex (configurable)
- **Almacenamiento**: 256GB con backups automáticos
- **Retención**: 30 días de backups
- **Subnet**: Privada (10.0.4.0/24) sin acceso directo
- **Seguridad**: Solo accesible desde subnet web

### ⚖️ Configuración del Load Balancer

#### 🎯 Backend Set Configuration
- **Política**: Round Robin (distribución equitativa)
- **Health Check**: HTTP en puerto 80, path "/healthz"
- **Backends**: Servidores en subnet privada
- **Timeout**: 3 segundos por check
- **SSL Ready**: Preparado para certificados SSL

### 🛡️ Configuración de Seguridad Zero-Trust

#### 🌐 Topología de Red Segura
- **VCN Principal (10.0.0.0/16)**: Infraestructura principal
  - Subnet Web (10.0.1.0/24): Servidores web sin IPs públicas
  - Subnet LB (10.0.2.0/24): Solo Load Balancer
  - Subnet Bastion (10.0.3.0/24): Solo Bastion Host
  - Subnet DB (10.0.4.0/24): Solo Oracle Database
  - Subnet FSS (10.0.5.0/24): Solo File Storage System
- **VCN Externa (192.168.0.0/16)**: Infraestructura externa
  - Subnet Backend (192.168.1.0/24): Servidor backend aislado

#### 🔒 Network Security Groups (NSGs)
**NSG WebServer**:
- SSH (22): Solo desde subnet Bastion (10.0.3.0/24)
- HTTP (80): Solo desde subnet Load Balancer (10.0.2.0/24)
- Oracle DB (1521): Solo hacia subnet DB (10.0.4.0/24)
- Backend (8080): Solo hacia VCN externa (192.168.1.0/24)
- NFS (2049): Solo desde subnet FSS (10.0.5.0/24)
- Egress: Todo permitido (via NAT Gateway)

**NSG Backend**:
- SSH (22): Solo desde VCN principal (10.0.0.0/16)
- HTTP (8080): Solo desde VCN principal (10.0.0.0/16)
- Egress: Limitado a VCN principal

**NSG Database**:
- Oracle DB (1521): Solo desde subnet Web (10.0.1.0/24)
- SSH (22): Solo desde subnet Bastion (10.0.3.0/24)
- Egress: Limitado a subnet Web

---

## 🆕 Diferencias con la Arquitectura 7

### 🔄 Evolución de la Infraestructura

| Aspecto | Arquitectura 7 | Arquitectura 8 |
|---------|---------------|----------------|
| **VCNs** | 1 VCN principal | 2 VCNs separadas |
| **Compartimentos** | 1 compartimento | 2 compartimentos |
| **Interconexión** | Sin peering | Local Peering Gateway |
| **Servidor Backend** | Sin backend separado | Backend en VCN externa |
| **CIDRs** | 10.0.0.0/16 | 10.0.0.0/16 + 192.168.0.0/16 |
| **Complejidad** | Alta | Muy alta |
| **Aislamiento** | Por subnets | Por VCNs completas |

### 🎯 Beneficios del VCN Peering

- **Aislamiento completo**: VCNs completamente separadas
- **Flexibilidad organizacional**: Diferentes compartimentos
- **Seguridad avanzada**: Control granular entre VCNs
- **Escalabilidad**: Fácil agregar más VCNs
- **Cumplimiento**: Separación de entornos por políticas

---

## 🚀 Métodos de Despliegue

### 🔧 Prerrequisitos

- **Terraform** >= 0.15.0 o **OpenTofu** >= 1.0.0
- **Ansible** >= 2.9 (para aprovisionamiento automático)
- Cuenta activa de Oracle Cloud Infrastructure
- Credenciales de API configuradas
- Cliente Git instalado

> 📝 **Nota**: Esta arquitectura requiere configuración avanzada de VCN peering y manejo de múltiples compartimentos con Ansible.

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
export TF_VAR_db_admin_password="TuContraseñaSegura123!"
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
db_admin_password       = "TuContraseñaSegura123!"
```

</details>

---

## 🖥️ Despliegue con Terraform/OpenTofu

### 📥 **1. Clonar el Repositorio**

```bash
git clone https://github.com/usuario/arquitecturas-oci-terraform.git
cd arquitecturas-oci-terraform/08_peering_vcn_local
```

### ✅ **2. Validar Configuración**

```bash
# Ejecutar script de validación completa
./validate.sh
```

Este script verificará:
- Instalación de Terraform/OpenTofu
- Instalación de Ansible
- Configuración de variables OCI
- Presencia de todos los archivos necesarios
- Sintaxis de Ansible
- Variables de base de datos

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
| `load_balancer_public_ip` | IP pública del Load Balancer | `130.61.45.123` |
| `bastion_public_ip` | IP pública del Bastion Host | `130.61.45.124` |
| `webserver1_private_ip` | IP privada del servidor web 1 | `10.0.1.2` |
| `webserver2_private_ip` | IP privada del servidor web 2 | `10.0.1.3` |
| `webserver3_private_ip` | IP privada del servidor web 3 | `10.0.1.4` |
| `database_private_ip` | IP privada de la base de datos | `10.0.4.2` |
| `backend_private_ip` | IP privada del servidor backend | `192.168.1.2` |
| `fss_mount_target_ip` | IP del Mount Target FSS | `10.0.5.100` |

### 🌐 Acceso a la Infraestructura

Una vez completado el despliegue (generalmente 25-35 minutos):

1. **Página Web**: Visita `http://[LOAD_BALANCER_IP]` en tu navegador
   - Diseño moderno que muestra información del sistema interconectado
   - Información del sistema, base de datos y backend
   - Responsive design para móviles y tablets

2. **SSH via Bastion**: Conecta usando:
   ```bash
   # Primero conecta al Bastion Host
   ssh -i id_rsa_enterprise ubuntu@[BASTION_IP]
   
   # Desde el Bastion, conecta a los servidores web
   ssh -i id_rsa_enterprise ubuntu@[WEBSERVER_PRIVATE_IP]
   
   # Desde el Bastion, conecta a la base de datos
   ssh -i id_rsa_enterprise opc@[DATABASE_PRIVATE_IP]
   
   # Desde el Bastion, conecta al servidor backend
   ssh -i id_rsa_enterprise ubuntu@[BACKEND_PRIVATE_IP]
   ```

3. **Verificar Peering**: Desde un servidor web:
   ```bash
   # Verificar conectividad a la base de datos
   telnet [DATABASE_PRIVATE_IP] 1521
   
   # Verificar conectividad al backend
   telnet [BACKEND_PRIVATE_IP] 8080
   
   # Verificar montaje FSS
   df -h /shared
   
   # Ver información del sistema
   free -h
   df -h
   ```

### 🎨 Características de la Página Web

La página web incluye:
- 🔗 **Header de peering** con información del sistema interconectado
- 📊 **Cards informativos** con datos de red, DB y backend
- 🔒 **Indicadores de NSGs** y configuración de firewall
- ✅ **Estado de servicios** del Load Balancer, servidores, DB y backend
- 📱 **Diseño responsive** que se adapta a todos los dispositivos
- ⏰ **Timestamp** de despliegue actualizado automáticamente

---

## 🔧 Personalización

### 📝 Variables Configurables

| Variable | Descripción | Valor por Defecto | Ejemplo |
|----------|-------------|-------------------|---------|
| `vcn_cidr` | CIDR de la VCN principal | `10.0.0.0/16` | `172.16.0.0/16` |
| `vcn2_cidr` | CIDR de la VCN externa | `192.168.0.0/16` | `10.1.0.0/16` |
| `webserver_subnet_cidr` | CIDR subnet servidores web | `10.0.1.0/24` | `172.16.1.0/24` |
| `loadbalancer_subnet_cidr` | CIDR subnet Load Balancer | `10.0.2.0/24` | `172.16.2.0/24` |
| `bastion_subnet_cidr` | CIDR subnet Bastion | `10.0.3.0/24` | `172.16.3.0/24` |
| `database_subnet_cidr` | CIDR subnet base de datos | `10.0.4.0/24` | `172.16.4.0/24` |
| `fss_subnet_cidr` | CIDR subnet FSS | `10.0.5.0/24` | `172.16.5.0/24` |
| `backend_subnet_cidr` | CIDR subnet backend | `192.168.1.0/24` | `10.1.1.0/24` |
| `webserver_count` | Número de servidores web | `3` | `5` |
| `webserver_shape` | Tipo de instancia servidores | `VM.Standard.E3.Flex` | `VM.Standard.E4.Flex` |
| `backend_shape` | Tipo de instancia backend | `VM.Standard.E3.Flex` | `VM.Standard.E4.Flex` |
| `database_shape` | Tipo de instancia base de datos | `VM.Standard.E3.Flex` | `VM.Standard.E4.Flex` |
| `db_data_storage_size_in_gb` | Tamaño almacenamiento DB | `256` | `512` |

### ⚙️ Ejemplo de Personalización

```hcl
# terraform.tfvars
vcn_cidr = "172.16.0.0/16"
vcn2_cidr = "10.1.0.0/16"
webserver_subnet_cidr = "172.16.1.0/24"
loadbalancer_subnet_cidr = "172.16.2.0/24"
bastion_subnet_cidr = "172.16.3.0/24"
database_subnet_cidr = "172.16.4.0/24"
fss_subnet_cidr = "172.16.5.0/24"
backend_subnet_cidr = "10.1.1.0/24"
webserver_count = 5
webserver_shape = "VM.Standard.E4.Flex"
backend_shape = "VM.Standard.E4.Flex"
database_shape = "VM.Standard.E4.Flex"
db_data_storage_size_in_gb = 512
```

---

## 🆘 Solución de Problemas

### ❌ Problemas Comunes

<details>
<summary>🔗 <strong>Error de Peering VCN</strong></summary>

**Problema**: No se puede conectar entre las VCNs

**Solución**:
1. Verifica que los LPGs estén conectados: `oci network local-peering-gateway get --local-peering-gateway-id [LPG_ID]`
2. Comprueba las rutas en ambas VCNs: `oci network route-table get --rt-id [ROUTE_TABLE_ID]`
3. Verifica las políticas IAM: Asegúrate de tener permisos para peering
4. Revisa los logs de Ansible: `tail -f ansible.log`

</details>

<details>
<summary>🗄️ <strong>Error de Base de Datos</strong></summary>

**Problema**: La base de datos no se puede conectar o no está disponible

**Solución**:
1. Verifica que la DB esté en estado "AVAILABLE": `oci db system get --db-system-id [DB_ID]`
2. Comprueba conectividad desde servidores web: `telnet [DB_IP] 1521`
3. Verifica las reglas NSG: Puerto 1521 debe estar permitido desde subnet Web
4. Revisa los logs de la base de datos: `ssh -i id_rsa_enterprise opc@[DB_IP]`

</details>

<details>
<summary>🔐 <strong>Error de Acceso SSH via Bastion</strong></summary>

**Problema**: No se puede conectar a los servidores desde el Bastion Host

**Solución**:
1. Verifica que el Bastion Host esté funcionando: `ssh -i id_rsa_enterprise ubuntu@[BASTION_IP]`
2. Desde el Bastion, prueba conectividad: `ping [WEBSERVER_PRIVATE_IP]`
3. Verifica las reglas NSG: Asegúrate de que SSH (22) esté permitido desde subnet Bastion
4. Comprueba la configuración de Ansible: Revisa los logs de aprovisionamiento

</details>

### 🔍 Comandos de Diagnóstico

```bash
# Verificar el estado de los LPGs
oci network local-peering-gateway get --local-peering-gateway-id $(terraform output -raw lpg1_id)
oci network local-peering-gateway get --local-peering-gateway-id $(terraform output -raw lpg2_id)

# Verificar las rutas en ambas VCNs
oci network route-table get --rt-id $(terraform output -raw vcn1_route_table_id)
oci network route-table get --rt-id $(terraform output -raw vcn2_route_table_id)

# Verificar el estado del Load Balancer
oci lb load-balancer get --load-balancer-id $(terraform output -raw load_balancer_id)

# Verificar el estado de la base de datos
oci db system get --db-system-id $(terraform output -raw database_id)

# Conectar al Bastion Host
ssh -i id_rsa_enterprise ubuntu@$(terraform output -raw bastion_public_ip)

# Desde el Bastion, verificar conectividad
ping $(terraform output -raw webserver1_private_ip)
ping $(terraform output -raw database_private_ip)
ping $(terraform output -raw backend_private_ip)

# Verificar conectividad entre VCNs
telnet $(terraform output -raw backend_private_ip) 8080
```

---

## 📚 Recursos Adicionales

### 📖 Documentación

- [Documentación de Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [Guía de Oracle Cloud Infrastructure](https://docs.oracle.com/en-us/iaas/Content/home.htm)
- [VCN Peering en OCI](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/VCNpeering.htm)
- [Local Peering Gateway en OCI](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/localVCNpeering.htm)
- [Network Security Groups en OCI](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/networksecuritygroups.htm)

### 📁 Documentación del Proyecto

- [validate.sh](validate.sh) - Script de validación de configuración
- [playbook.yml](playbook.yml) - Configuración de Ansible para servidores web
- [playbook_bastion.yml](playbook_bastion.yml) - Configuración de Ansible para Bastion Host

### 🎓 Próximos Pasos

Después de dominar esta arquitectura, continúa con:

1. **Arquitectura 9**: Peering VCN remoto
2. **Arquitectura 7a**: Sistema de base de datos con DataGuard
3. **Arquitectura 9a**: Peering VCN remoto con DataGuard

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