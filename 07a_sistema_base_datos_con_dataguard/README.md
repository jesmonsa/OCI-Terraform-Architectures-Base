# Créditos y Adaptaciones

Este proyecto está basado en el repositorio original de Foggykitchen (https://github.com/foggykitchen/oci-terraform-examples). Incluye adaptaciones y mejoras realizadas por Jesus Montoya, Arquitecto Cloud.

# 🏗️ Arquitecturas de Referencia Terraform OCI

## 🌐 Arquitectura 7a - Sistema de Base de Datos con DataGuard

### 📋 Descripción General

Esta arquitectura de referencia representa una **variante avanzada de la Arquitectura 7**, diseñada para entornos de producción que requieren alta disponibilidad y recuperación ante desastres (DR) para bases de datos Oracle. Combina las funcionalidades básicas de balanceador de carga, base de datos y sistema de archivos compartido con **Oracle DataGuard** para proporcionar replicación automática de datos entre Availability Domains.

La arquitectura implementa Oracle DataGuard Association que crea automáticamente una base de datos standby en un Availability Domain diferente al de la base de datos primaria, proporcionando protección contra fallos de AD completo y capacidades de recuperación ante desastres.

### 🎯 Objetivo

Crear una infraestructura de base de datos de alta disponibilidad que incluye:
- Balanceador de carga con health checks automáticos
- Base de datos Oracle primaria con DataGuard
- Base de datos Oracle standby automática
- Sistema de archivos compartido (FSS) para almacenamiento distribuido
- Network Security Groups para control granular de tráfico
- Host bastión para acceso administrativo seguro
- Aprovisionamiento automático con Ansible

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
│  │  │  │         Subred Pública                  │ │
│  │  │  │         (10.0.1.0/24)                  │ │
│  │  │  │                                         │ │
│  │  │  │  ┌─────────────────────────────────┐    │ │
│  │  │  │  │      🖥️ Host Bastión            │ │
│  │  │  │  │    (Ubuntu 22.04 + SSH)         │ │
│  │  │  │  │         IP Pública              │ │
│  │  │  │  └─────────────────────────────────┘ │ │
│  │  │  └─────────────────────────────────────────┘ │ │
│  │  │                                                 │ │
│  │  │  ┌─────────────────────────────────────────┐    │ │
│  │  │  │         Subred Privada                 │ │
│  │  │  │         (10.0.2.0/24)                  │ │
│  │  │  │                                         │ │
│  │  │  │  ┌────────────────┐  ┌────────────────┐ │ │
│  │  │  │  │🖥️ Servidor Web 1│  │🖥️ Servidor Web 2│ │ │
│  │  │  │  │ Ubuntu 22.04 +  │  │ Ubuntu 22.04 +  │ │ │
│  │  │  │  │    Apache2      │  │    Apache2      │ │ │
│  │  │  │  │   IP Privada    │  │   IP Privada    │ │ │
│  │  │  │  └────────────────┘  └────────────────┘ │ │
│  │  │  └─────────────────────────────────────────┘ │ │
│  │  │                                                 │ │
│  │  │  ┌─────────────────────────────────────────┐    │ │
│  │  │  │         Subred de Base de Datos         │ │
│  │  │  │         (10.0.3.0/24)                  │ │
│  │  │  │                                         │ │
│  │  │  │  ┌────────────────┐  ┌────────────────┐ │ │
│  │  │  │  │🗄️ DB Primaria  │  │🗄️ DB Standby   │ │ │
│  │  │  │  │Oracle 19c (AD1)│  │Oracle 19c (AD2)│ │ │
│  │  │  │  │   IP Privada   │  │   IP Privada   │ │ │
│  │  │  │  │                │  │                │ │ │
│  │  │  │  │ 🔄 DataGuard   │◄─┼─▶ 🔄 DataGuard │ │ │
│  │  │  │  │   Association  │  │   Association  │ │ │
│  │  │  │  └────────────────┘  └────────────────┘ │ │
│  │  │  └─────────────────────────────────────────┘ │ │
│  │  │                                                 │ │
│  │  │  ┌─────────────────────────────────────────┐    │ │
│  │  │  │         Subred de File Storage          │ │
│  │  │  │         (10.0.4.0/24)                  │ │
│  │  │  │                                         │ │
│  │  │  │  ┌─────────────────────────────────┐    │ │
│  │  │  │  │      📁 File Storage Service    │ │
│  │  │  │  │    (Oracle FSS)                 │ │
│  │  │  │  │      Montado en servidores      │ │
│  │  │  │  └─────────────────────────────────┘ │ │
│  │  │  └─────────────────────────────────────────┘ │ │
│  │  │                                                 │ │
│  │  │  🛡️ Network Security Groups                     │ │
│  │  │  📡 Internet Gateway                           │ │
│  │  │  🌐 NAT Gateway                                 │ │
│  │  │  ⚖️ Load Balancer                               │ │
│  │  └─────────────────────────────────────────────────┘ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP/HTTPS (80/443)
                              │ SSH (22) - Solo Bastión
                              ▼
                         🌐 Internet
```

### 🔄 Diferencias Clave con la Arquitectura 7

| Aspecto | Arquitectura 7 (Single DB) | Arquitectura 7a (DataGuard) |
|---------|---------------------------|----------------------------|
| **Base de Datos** | Una sola instancia Oracle | Primaria + Standby automática |
| **Alta Disponibilidad** | Sin replicación automática | DataGuard Association automática |
| **Recuperación ante Desastres** | Manual/Backup | Automática con failover |
| **Availability Domains** | Una sola instancia | Distribución automática entre ADs |
| **Configuración** | Base de datos simple | Configuración DataGuard compleja |
| **Casos de uso** | Entornos de desarrollo/pruebas | Entornos de producción críticos |

### ✨ Características

- **🔧 Alta Disponibilidad**: DataGuard Association automática entre ADs
- **🌍 Recuperación ante Desastres**: Failover automático en caso de fallo
- **⚖️ Balanceo de Carga**: Load balancer con health checks automáticos
- **🗄️ Base de Datos Oracle**: Primaria y standby con replicación automática
- **📁 File Storage Compartido**: Oracle FSS para almacenamiento distribuido
- **🛡️ Seguridad Multi-Capa**: NSGs + iptables + bastión
- **⚡ Aprovisionamiento Inteligente**: Ansible con configuración específica por rol
- **📍 Separación de Redes**: Subredes especializadas por función
- **🎨 Páginas Web Diferenciadas**: Cada servidor con información específica

### 🛠️ Recursos Desplegados

| Recurso | Tipo | Descripción |
|---------|------|-------------|
| **Compartimento** | `oci_identity_compartment` | Contenedor lógico Enterprise |
| **VCN** | `oci_core_virtual_network` | Red virtual privada (10.0.0.0/16) |
| **Subred Pública** | `oci_core_subnet` | Subred para bastión (10.0.1.0/24) |
| **Subred Privada** | `oci_core_subnet` | Subred para servidores web (10.0.2.0/24) |
| **Subred Base de Datos** | `oci_core_subnet` | Subred para Oracle DB (10.0.3.0/24) |
| **Subred File Storage** | `oci_core_subnet` | Subred para FSS (10.0.4.0/24) |
| **Internet Gateway** | `oci_core_internet_gateway` | Puerta de enlace para acceso a Internet |
| **NAT Gateway** | `oci_core_nat_gateway` | NAT para acceso a Internet desde subredes privadas |
| **Load Balancer** | `oci_load_balancer_load_balancer` | Balanceador de carga con health checks |
| **Backend Set** | `oci_load_balancer_backend_set` | Configuración de backend servers |
| **Network Security Groups (x4)** | `oci_core_network_security_group` | NSGs para bastión, load balancer, servidores y FSS |
| **Host Bastión** | `oci_core_instance` | Instancia para acceso administrativo |
| **Instancias Compute (x2)** | `oci_core_instance` | Servidores web en subred privada |
| **Base de Datos Primaria** | `oci_database_database` | Instancia principal de Oracle DB |
| **Base de Datos Standby** | `oci_database_database` | Instancia standby automática |
| **DataGuard Association** | `oci_database_data_guard_association` | Configuración de replicación automática |
| **File Storage Service** | `oci_file_storage_file_system` | Sistema de archivos compartido |
| **Mount Target** | `oci_file_storage_mount_target` | Punto de montaje para FSS |
| **Export Set** | `oci_file_storage_export_set` | Configuración de exportación |
| **Claves SSH** | `tls_private_key` | Par de claves para acceso SSH |

### 🛡️ Configuración de Seguridad con Network Security Groups

#### 🏰 NSG - Host Bastión
- **SSH Ingress**: Puerto 22 desde cualquier IP (0.0.0.0/0)
- **Egress**: Todo el tráfico permitido hacia cualquier destino

#### ⚖️ NSG - Load Balancer
- **HTTP Ingress**: Puerto 80 desde cualquier IP (0.0.0.0/0)
- **HTTPS Ingress**: Puerto 443 desde cualquier IP (0.0.0.0/0)
- **Egress**: Tráfico hacia subred privada (10.0.2.0/24)

#### 🖥️ NSG - Servidores Web
- **SSH Ingress**: Puerto 22 solo desde subred pública (10.0.1.0/24)
- **HTTP Ingress**: Puerto 80 solo desde load balancer
- **HTTPS Ingress**: Puerto 443 solo desde load balancer
- **NFS Ingress**: Puerto 2049 desde subred FSS (10.0.4.0/24)
- **Egress**: Todo el tráfico permitido hacia cualquier destino

#### 🗄️ NSG - Base de Datos
- **Oracle DB Ingress**: Puerto 1521 solo desde subred privada (10.0.2.0/24)
- **DataGuard Ingress**: Puerto 1521 entre bases de datos primaria y standby
- **SSH Ingress**: Puerto 22 solo desde subred pública (10.0.1.0/24)
- **Egress**: Todo el tráfico permitido hacia cualquier destino

#### 📁 NSG - File Storage
- **NFS Ingress**: Puerto 2049 solo desde subredes autorizadas
- **Egress**: Tráfico de respuesta permitido

#### 🔥 IPTables (Configurado por Ansible)
- **Política por defecto**: DROP (deniega todo excepto lo explícitamente permitido)
- **SSH**: Puerto 22 con conexiones establecidas y nuevas
- **HTTP**: Puerto 80 con conexiones establecidas y nuevas  
- **HTTPS**: Puerto 443 con conexiones establecidas y nuevas
- **NFS**: Puerto 2049 con conexiones establecidas y nuevas
- **Oracle DB**: Puerto 1521 con conexiones establecidas y nuevas
- **DataGuard**: Puerto 1521 entre instancias de base de datos
- **Loopback**: Tráfico local permitido
- **Conexiones establecidas**: Tráfico de respuesta permitido

### 🎯 Cuándo Usar Esta Arquitectura

**✅ Usar Arquitectura 7a cuando:**
- Necesitas alta disponibilidad para bases de datos críticas
- Requieres recuperación ante desastres automática
- Trabajas con aplicaciones que no pueden tolerar tiempo de inactividad
- Necesitas protección contra fallos de Availability Domain completo
- Requieres replicación automática de datos
- Quieres implementar principios de "defensa en profundidad"
- Necesitas cumplir con requisitos de RTO/RPO estrictos

**❌ Usar Arquitectura 7 cuando:**
- Tu entorno es de desarrollo o pruebas
- No necesitas alta disponibilidad automática
- El presupuesto no permite duplicación de recursos
- Prefieres configuración más sencilla
- El equipo no tiene experiencia con DataGuard

---

## 🚀 Métodos de Despliegue

### 🔧 Prerrequisitos

- **Terraform** >= 0.15.0 o **OpenTofu** >= 1.0.0
- **Ansible** >= 2.9 (para aprovisionamiento automático)
- Cuenta activa de Oracle Cloud Infrastructure
- Credenciales de API configuradas
- Cliente Git instalado

> 📝 **Nota**: Esta arquitectura usa Ansible para el aprovisionamiento de todos los componentes, incluyendo la configuración de DataGuard y montaje de File Storage Service.

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
cd arquitecturas-oci-terraform/07a_sistema_base_datos_con_dataguard
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

   [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/usuario/arquitecturas-oci-terraform/releases/latest/download/07a_sistema_base_datos_con_dataguard.zip)

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
| `BastionPublicIP` | IP pública del host bastión | `130.61.45.123` |
| `LoadBalancerPublicIP` | IP pública del load balancer | `130.61.45.124` |
| `Webserver1PrivateIP` | IP privada del servidor web 1 | `10.0.2.10` |
| `Webserver2PrivateIP` | IP privada del servidor web 2 | `10.0.2.11` |
| `DatabasePrimaryIP` | IP privada de la base de datos primaria | `10.0.3.10` |
| `DatabaseStandbyIP` | IP privada de la base de datos standby | `10.0.3.11` |
| `FileStorageMountIP` | IP del mount target de FSS | `10.0.4.10` |

### 🌐 Acceso a los Servicios

Una vez completado el despliegue (generalmente 10-15 minutos):

1. **Aplicación Web**: Visita `http://[IP_LOAD_BALANCER]` en tu navegador
   - Balanceo automático entre servidores web
   - Health checks activos
   - Diseño responsive con información del sistema
   - Acceso a archivos compartidos
   - Indicadores de estado de DataGuard

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
   - Failover automático en caso de fallo
   - Monitoreo de estado de DataGuard

### 🎨 Características de la Aplicación Web

La aplicación web incluye:
- 🚀 **Header dinámico** con información del load balancer
- 📊 **Cards informativos** con datos del sistema
- 🛠️ **Stack tecnológico** mostrado con badges
- ✅ **Indicadores de estado** del load balancer y backend
- 📱 **Diseño responsive** que se adapta a todos los dispositivos
- 📁 **Información de File Storage** mostrando el montaje compartido
- 🗄️ **Estado de DataGuard** con indicadores de replicación
- 🔄 **Estado de la base de datos** primaria y standby
- ⏰ **Timestamp** de despliegue actualizado automáticamente

---

## 🔧 Personalización

### 📝 Variables Configurables

| Variable | Descripción | Valor por Defecto | Ejemplo |
|----------|-------------|-------------------|---------|
| `vcn_cidr` | CIDR de la VCN | `10.0.0.0/16` | `192.168.0.0/16` |
| `public_subnet_cidr` | CIDR de la subred pública | `10.0.1.0/24` | `192.168.1.0/24` |
| `private_subnet_cidr` | CIDR de la subred privada | `10.0.2.0/24` | `192.168.2.0/24` |
| `database_subnet_cidr` | CIDR de la subred de BD | `10.0.3.0/24` | `192.168.3.0/24` |
| `fss_subnet_cidr` | CIDR de la subred FSS | `10.0.4.0/24` | `192.168.4.0/24` |
| `Shape` | Tipo de instancia | `VM.Standard.E3.Flex` | `VM.Standard.E4.Flex` |
| `FlexShapeOCPUS` | Número de CPUs | `1` | `2` |
| `FlexShapeMemory` | Memoria en GB | `2` | `4` |
| `instance_os` | Sistema operativo | `Canonical Ubuntu` | `Oracle Linux` |
| `linux_os_version` | Versión del SO | `22.04` | `20.04` |
| `compute_count` | Número de servidores web | `2` | `3` |
| `database_admin_password` | Contraseña de admin BD | Generada automáticamente | `MiPassword123!` |
| `data_guard_protection_mode` | Modo de protección DataGuard | `MAXIMUM_PERFORMANCE` | `MAXIMUM_AVAILABILITY` |

### ⚙️ Ejemplo de Personalización

```hcl
# terraform.tfvars
vcn_cidr = "192.168.0.0/16"
public_subnet_cidr = "192.168.1.0/24"
private_subnet_cidr = "192.168.2.0/24"
database_subnet_cidr = "192.168.3.0/24"
fss_subnet_cidr = "192.168.4.0/24"
Shape = "VM.Standard.E4.Flex"
FlexShapeOCPUS = 2
FlexShapeMemory = 4
instance_os = "Oracle Linux"
linux_os_version = "8"
compute_count = 3
database_admin_password = "MiPasswordSegura123!"
data_guard_protection_mode = "MAXIMUM_AVAILABILITY"
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
<summary>🗄️ <strong>Error de DataGuard</strong></summary>

**Problema**: `Error: DataGuard association failed`

**Solución**:
1. Verifica que ambas bases de datos estén running: `oci db database get --database-id [DB_OCID]`
2. Comprueba la conectividad entre ADs: `telnet [DB_STANDBY_IP] 1521`
3. Verifica la configuración de red entre Availability Domains
4. Revisa los logs de DataGuard en ambas instancias

</details>

<details>
<summary>🗄️ <strong>Error de Base de Datos</strong></summary>

**Problema**: `Error: Database connection failed`

**Solución**:
1. Verifica que la base de datos esté running: `oci db database get --database-id [DB_OCID]`
2. Comprueba la conectividad: `telnet [DB_IP] 1521`
3. Verifica las credenciales en la aplicación
4. Revisa los logs de la base de datos

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

# Verificar estado de DataGuard
ssh -i mi_llave_oci.pem ubuntu@$(terraform output -raw BastionPublicIP) "ssh ubuntu@$(terraform output -raw DatabasePrimaryIP) 'sqlplus / as sysdba @check_dataguard.sql'"

# Verificar conectividad entre bases de datos
ssh -i mi_llave_oci.pem ubuntu@$(terraform output -raw BastionPublicIP) "ssh ubuntu@$(terraform output -raw DatabasePrimaryIP) 'telnet $(terraform output -raw DatabaseStandbyIP) 1521'"

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
- [Oracle DataGuard](https://docs.oracle.com/en/database/oracle/oracle-database/19/sbydb/index.html)

### 📁 Documentación del Proyecto

- [SECURITY.md](SECURITY.md) - Guía de seguridad y mejores prácticas
- [nsgs.tf](nsgs.tf) - Configuración de Network Security Groups
- [dbsystem.tf](dbsystem.tf) - Configuración de DataGuard
- [playbook.yml](playbook.yml) - Configuración de Ansible para aprovisionamiento
- [variables.tf](variables.tf) - Variables configurables del proyecto

### 🎓 Próximos Pasos

Después de dominar esta arquitectura, continúa con:

1. **Arquitectura 8**: Container Engine for Kubernetes
2. **Arquitectura 9**: Peering VCN local
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