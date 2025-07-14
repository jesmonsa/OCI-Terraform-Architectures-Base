# Créditos y Adaptaciones

Este proyecto está basado en el repositorio original de Foggykitchen (https://github.com/mlinxfeld/foggykitchen_tf_oci_course). Incluye adaptaciones y mejoras realizadas por Jesus Montoya, Arquitecto Cloud.

# 🏗️ Arquitecturas de Referencia Terraform OCI

## 📁 Arquitectura 5 - Sistema de Archivos Compartido

### 📋 Descripción General

Esta arquitectura de referencia implementa una solución avanzada de almacenamiento compartido en Oracle Cloud Infrastructure (OCI) que combina todas las características de seguridad de las arquitecturas anteriores con **File Storage Service (FSS)** para proporcionar almacenamiento NFS compartido entre múltiples servidores web. Es ideal para aplicaciones que requieren contenido compartido, sincronización de datos y almacenamiento persistente escalable.

### 🎯 Objetivo

Crear una infraestructura empresarial con almacenamiento compartido que incluye:
- Un compartimento enterprise para organizar los recursos
- Una Red Virtual en la Nube (VCN) con múltiples subnets especializadas
- Servidores web en subnet privada con acceso a almacenamiento compartido
- Un Load Balancer público para distribución de tráfico HTTP
- Un NAT Gateway para salida controlada a internet desde subnets privadas
- Un Bastion Host para acceso SSH seguro a servidores privados
- File Storage Service (FSS) con montaje NFS automático
- Página web moderna que muestra contenido desde almacenamiento compartido
- Aprovisionamiento 100% automático con Ansible

### 🏛️ Arquitectura

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Oracle Cloud Infrastructure                      │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │                      Compartimento                              │ │
│  │                                                                 │ │
│  │  ┌─────────────────────────────────────────────────────────────┐ │ │
│  │  │                  VCN (10.0.0.0/16)                         │ │ │
│  │  │                                                             │ │ │
│  │  │  ┌──────────────────┐ ┌─────────────────┐ ┌────────────────┐ │ │ │
│  │  │  │  Subnet Privada  │ │ Subnet Pública  │ │ Subnet Bastion │ │ │ │
│  │  │  │  (10.0.1.0/24)   │ │  (10.0.2.0/24)  │ │ (10.0.3.0/24)  │ │ │ │
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
│  │  │         📡 Internet Gateway ───┘                             │ │ │
│  │  └─────────────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP (80) - Load Balanced
                              │ SSH (22) - Solo Bastion Host  
                              ▼
                         🌐 Internet
```

### ✨ Características

- **📁 Almacenamiento Compartido**: File Storage Service (FSS) con protocolo NFS
- **🔄 Sincronización Automática**: Contenido compartido entre todos los servidores
- **⚖️ Load Balancing**: OCI Load Balancer con algoritmo Round Robin
- **🔄 Alta Disponibilidad**: Múltiples servidores backend con contenido sincronizado
- **🏰 Acceso Seguro**: Bastion Host como único punto de entrada SSH
- **🌐 Conectividad Controlada**: NAT Gateway para salida segura a internet
- **🔒 Zero Trust Network**: Servidores sin IPs públicas directas
- **⚡ NSGs Granulares**: Control de tráfico a nivel de VNIC
- **🎨 Página Web Avanzada**: Diseño que muestra contenido desde FSS
- **📊 Distribución Automática**: Tráfico HTTP distribuido entre servidores privados

### 🛠️ Recursos Desplegados

| Recurso | Tipo | Descripción |
|---------|------|-------------|
| **Compartimento** | `oci_identity_compartment` | Contenedor lógico para organizar recursos |
| **VCN** | `oci_core_virtual_network` | Red virtual privada (10.0.0.0/16) |
| **Subnet Privada** | `oci_core_subnet` | Subnet para servidores web (10.0.1.0/24) |
| **Subnet LB** | `oci_core_subnet` | Subnet pública para Load Balancer (10.0.2.0/24) |
| **Subnet Bastion** | `oci_core_subnet` | Subnet pública para Bastion Host (10.0.3.0/24) |
| **Internet Gateway** | `oci_core_internet_gateway` | Puerta de enlace para tráfico público |
| **NAT Gateway** | `oci_core_nat_gateway` | Salida a internet para subnets privadas |
| **Load Balancer** | `oci_load_balancer` | Balanceador de carga público flexible |
| **Bastion Host** | `oci_core_instance` | Servidor de salto para acceso SSH |
| **Web Servers** | `oci_core_instance` | VMs Ubuntu 22.04 en subnet privada |
| **File Storage System** | `oci_file_storage_file_system` | Sistema de archivos NFS compartido |
| **Mount Target** | `oci_file_storage_mount_target` | Punto de montaje NFS |
| **Export** | `oci_file_storage_export` | Configuración de exportación NFS |
| **NSGs** | `oci_core_network_security_group` | Grupos de seguridad granulares |
| **Claves SSH** | `tls_private_key` | Par de claves para acceso SSH |

### 📁 Configuración del File Storage Service

#### 🎯 Configuración de FSS
- **Protocolo**: NFS v3 y v4
- **Punto de montaje**: `/shared` en todos los servidores
- **Permisos**: Lectura/escritura para todos los servidores
- **Escalabilidad**: Crecimiento automático según necesidades
- **Alta disponibilidad**: Replicación automática entre ADs

#### 🔧 Montaje Automático
```yaml
# Configuración automática por Ansible
- name: Mount the shared filesystem
  mount:
    path: /shared
    src: "{{ mount_target_ip }}:/sharedfs"
    fstype: nfs
    opts: rw,sync,hard,intr
    state: mounted
```

#### 🔒 Seguridad NFS
- **Puertos NFS**: 2049 (NFS) y 111 (portmapper)
- **Restricción de red**: Solo desde subnet privada
- **Autenticación**: Basada en IP de origen
- **Permisos**: Configuración granular por export

### 🛡️ Configuración de Seguridad Avanzada

#### 🌐 Topología de Red Segura
- **Subnet Privada (10.0.1.0/24)**: Servidores web + FSS Mount Target
- **Subnet Pública LB (10.0.2.0/24)**: Solo Load Balancer
- **Subnet Pública Bastion (10.0.3.0/24)**: Solo Bastion Host
- **Segregación completa**: Cada función en su subnet especializada

#### 🔒 Network Security Groups (NSGs)
**NSG WebServer**:
- SSH (22): Solo desde subnet Bastion (10.0.3.0/24)
- HTTP (80): Solo desde subnet Load Balancer (10.0.2.0/24)
- NFS (2049): Solo desde subnet privada (10.0.1.0/24)
- Portmapper (111): Solo desde subnet privada (10.0.1.0/24)
- Egress: Todo permitido (via NAT Gateway)

**NSG Bastion**:
- SSH (22): Desde IPs autorizadas (configurable)
- ICMP: Ping desde cualquier lugar
- Egress: Todo permitido

#### 🔥 Capa Sistema - IPTables (Configurado por Ansible)
**Servidores Web**:
- SSH (22): Solo desde subnet Bastion
- HTTP (80): Solo desde subnet Load Balancer
- NFS (2049): Solo desde subnet privada
- Política por defecto: DROP

**Bastion Host**:
- SSH (22): Desde IPs autorizadas
- Port forwarding: Configurado para túneles SSH
- Fail2ban: Protección automática contra ataques

---

## 🆕 Diferencias con la Arquitectura 4

### 🔄 Evolución de la Infraestructura

| Aspecto | Arquitectura 4 | Arquitectura 5 |
|---------|---------------|----------------|
| **Almacenamiento** | Local por servidor | Compartido via FSS |
| **Contenido Web** | Individual por servidor | Sincronizado desde FSS |
| **Servidores** | 2 servidores web | 3 servidores web |
| **Persistencia** | Sin persistencia | Almacenamiento persistente |
| **Sincronización** | Manual | Automática via NFS |
| **Escalabilidad** | Limitada | Alta con FSS |
| **Complejidad** | Media | Avanzada con FSS |

### 🎯 Beneficios del Almacenamiento Compartido

- **Contenido unificado**: Todos los servidores muestran el mismo contenido
- **Sincronización automática**: Cambios reflejados inmediatamente
- **Escalabilidad**: Fácil agregar más servidores
- **Persistencia**: Datos sobreviven a reinicios de servidores
- **Backup centralizado**: Un solo punto para respaldos

---

## 🚀 Métodos de Despliegue

### 🔧 Prerrequisitos

- **Terraform** >= 0.15.0 o **OpenTofu** >= 1.0.0
- **Ansible** >= 2.9 (para aprovisionamiento automático)
- Cuenta activa de Oracle Cloud Infrastructure
- Credenciales de API configuradas
- Cliente Git instalado

> 📝 **Nota**: Esta arquitectura requiere configuración avanzada de FSS y manejo de múltiples subnets con Ansible.

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
cd arquitecturas-oci-terraform/05_sistema_archivos_compartido
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
| `load_balancer_public_ip` | IP pública del Load Balancer | `130.61.45.123` |
| `bastion_public_ip` | IP pública del Bastion Host | `130.61.45.124` |
| `webserver1_private_ip` | IP privada del servidor web 1 | `10.0.1.2` |
| `webserver2_private_ip` | IP privada del servidor web 2 | `10.0.1.3` |
| `webserver3_private_ip` | IP privada del servidor web 3 | `10.0.1.4` |
| `fss_mount_target_ip` | IP del Mount Target FSS | `10.0.1.100` |

### 🌐 Acceso a la Infraestructura

Una vez completado el despliegue (generalmente 8-12 minutos):

1. **Página Web**: Visita `http://[LOAD_BALANCER_IP]` en tu navegador
   - Diseño moderno que muestra contenido desde FSS
   - Información del sistema y configuración de almacenamiento
   - Responsive design para móviles y tablets

2. **SSH via Bastion**: Conecta usando:
   ```bash
   # Primero conecta al Bastion Host
   ssh -i id_rsa_enterprise ubuntu@[BASTION_IP]
   
   # Desde el Bastion, conecta a los servidores web
   ssh -i id_rsa_enterprise ubuntu@[WEBSERVER_PRIVATE_IP]
   ```

3. **Verificar FSS**: Desde cualquier servidor web:
   ```bash
   # Verificar montaje
   df -h /shared
   
   # Ver contenido compartido
   ls -la /shared
   
   # Crear archivo de prueba
   echo "Test desde $(hostname)" > /shared/test.txt
   ```

### 🎨 Características de la Página Web

La página web incluye:
- 📁 **Header de FSS** con información del almacenamiento compartido
- 📊 **Cards informativos** con datos de red y FSS
- 🔒 **Indicadores de NSGs** y configuración de firewall
- ✅ **Estado de servicios** del Load Balancer y servidores
- 📱 **Diseño responsive** que se adapta a todos los dispositivos
- ⏰ **Timestamp** de despliegue actualizado automáticamente

---

## 🔧 Personalización

### 📝 Variables Configurables

| Variable | Descripción | Valor por Defecto | Ejemplo |
|----------|-------------|-------------------|---------|
| `vcn_cidr` | CIDR de la VCN | `10.0.0.0/16` | `192.168.0.0/16` |
| `webserver_subnet_cidr` | CIDR subnet servidores web | `10.0.1.0/24` | `192.168.1.0/24` |
| `loadbalancer_subnet_cidr` | CIDR subnet Load Balancer | `10.0.2.0/24` | `192.168.2.0/24` |
| `bastion_subnet_cidr` | CIDR subnet Bastion | `10.0.3.0/24` | `192.168.3.0/24` |
| `webserver_count` | Número de servidores web | `3` | `5` |
| `webserver_shape` | Tipo de instancia servidores | `VM.Standard.E3.Flex` | `VM.Standard.E4.Flex` |
| `bastion_shape` | Tipo de instancia bastion | `VM.Standard.E3.Flex` | `VM.Standard.E4.Flex` |
| `fss_mount_target_ip` | IP del Mount Target FSS | `10.0.1.100` | `10.0.1.200` |

### ⚙️ Ejemplo de Personalización

```hcl
# terraform.tfvars
vcn_cidr = "192.168.0.0/16"
webserver_subnet_cidr = "192.168.1.0/24"
loadbalancer_subnet_cidr = "192.168.2.0/24"
bastion_subnet_cidr = "192.168.3.0/24"
webserver_count = 5
webserver_shape = "VM.Standard.E4.Flex"
bastion_shape = "VM.Standard.E4.Flex"
fss_mount_target_ip = "10.0.1.200"
```

---

## 🆘 Solución de Problemas

### ❌ Problemas Comunes

<details>
<summary>📁 <strong>Error de Montaje FSS</strong></summary>

**Problema**: Los servidores web no pueden montar el FSS

**Solución**:
1. Verifica que el Mount Target esté disponible: `ping [FSS_MOUNT_TARGET_IP]`
2. Comprueba las reglas NSG: NFS (2049) debe estar permitido
3. Verifica la configuración de export: `showmount -e [FSS_MOUNT_TARGET_IP]`
4. Revisa los logs de Ansible: `tail -f ansible.log`

</details>

<details>
<summary>🔐 <strong>Error de Acceso SSH via Bastion</strong></summary>

**Problema**: No se puede conectar a los servidores web desde el Bastion Host

**Solución**:
1. Verifica que el Bastion Host esté funcionando: `ssh -i id_rsa_enterprise ubuntu@[BASTION_IP]`
2. Desde el Bastion, prueba conectividad: `ping [WEBSERVER_PRIVATE_IP]`
3. Verifica las reglas NSG: Asegúrate de que SSH (22) esté permitido desde subnet Bastion
4. Comprueba la configuración de Ansible: Revisa los logs de aprovisionamiento

</details>

<details>
<summary>🌐 <strong>Error de Acceso Web</strong></summary>

**Problema**: No se puede acceder a la página web via Load Balancer

**Solución**:
1. Verifica que el Load Balancer esté funcionando: `curl http://[LOAD_BALANCER_IP]`
2. Comprueba el estado de los backends: Revisa health checks
3. Verifica las reglas NSG: HTTP (80) debe estar permitido desde subnet Load Balancer
4. Revisa los logs de Apache: `ssh -i id_rsa_enterprise ubuntu@[BASTION_IP]`

</details>

### 🔍 Comandos de Diagnóstico

```bash
# Verificar el estado del Load Balancer
oci lb load-balancer get --load-balancer-id $(terraform output -raw load_balancer_id)

# Verificar el estado de los backends
oci lb backend get --load-balancer-id $(terraform output -raw load_balancer_id) --backend-set-name [BACKEND_SET_NAME] --backend-name [BACKEND_NAME]

# Verificar las reglas NSG
oci network nsg get --nsg-id $(terraform output -raw webserver_nsg_id)

# Conectar al Bastion Host
ssh -i id_rsa_enterprise ubuntu@$(terraform output -raw bastion_public_ip)

# Desde el Bastion, verificar conectividad
ping $(terraform output -raw webserver1_private_ip)

# Verificar montaje FSS
df -h /shared
showmount -e $(terraform output -raw fss_mount_target_ip)
```

---

## 📚 Recursos Adicionales

### 📖 Documentación

- [Documentación de Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [Guía de Oracle Cloud Infrastructure](https://docs.oracle.com/en-us/iaas/Content/home.htm)
- [File Storage Service en OCI](https://docs.oracle.com/en-us/iaas/Content/File/Concepts/filestorageoverview.htm)
- [Network Security Groups en OCI](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/networksecuritygroups.htm)

### 📁 Documentación del Proyecto

- [SECURITY.md](SECURITY.md) - Guía de seguridad y mejores prácticas
- [validate_config.sh](validate_config.sh) - Script de validación de configuración
- [playbook.yml](playbook.yml) - Configuración de Ansible para servidores web
- [playbook_bastion.yml](playbook_bastion.yml) - Configuración de Ansible para Bastion Host

### 🎓 Próximos Pasos

Después de dominar esta arquitectura, continúa con:

1. **Arquitectura 6**: Volúmenes de bloque locales
2. **Arquitectura 7**: Sistema de base de datos Oracle
3. **Arquitectura 8**: Peering VCN local

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