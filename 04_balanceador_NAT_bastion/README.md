# Créditos y Adaptaciones

Este proyecto está basado en el repositorio original de Foggykitchen (https://github.com/foggykitchen/oci-terraform-examples). Incluye adaptaciones y mejoras realizadas por Jesus Montoya, Arquitecto Cloud.

# 🏗️ Arquitecturas de Referencia Terraform OCI

## 🛡️ Arquitectura 4 - Load Balancer + NAT Gateway + Bastion Host

### 📋 Descripción General

Esta arquitectura de referencia implementa una solución de alta seguridad en Oracle Cloud Infrastructure (OCI) que combina un balanceador de carga con servidores web en subnets privadas, protegidos por un NAT Gateway para salida a internet y un Bastion Host para acceso SSH seguro. Es ideal para aplicaciones empresariales que requieren alta disponibilidad, escalabilidad y máxima seguridad siguiendo las mejores prácticas de cloud security.

### 🎯 Objetivo

Crear una infraestructura empresarial segura y escalable que incluye:
- Un compartimento enterprise para organizar los recursos
- Una Red Virtual en la Nube (VCN) con múltiples subnets especializadas
- Servidores web en subnet privada sin acceso directo desde internet
- Un Load Balancer público para distribución de tráfico HTTP
- Un NAT Gateway para salida controlada a internet desde subnets privadas
- Un Bastion Host para acceso SSH seguro a servidores privados
- Network Security Groups (NSGs) para control granular de tráfico
- Página web moderna que refleja la arquitectura de seguridad implementada
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

- **🛡️ Seguridad Multi-Capa**: Subnets privadas + NSGs + Bastion Host + NAT Gateway
- **⚖️ Load Balancing**: OCI Load Balancer con algoritmo Round Robin
- **🔄 Alta Disponibilidad**: Múltiples servidores backend en subnet privada
- **🏰 Acceso Seguro**: Bastion Host como único punto de entrada SSH
- **🌐 Conectividad Controlada**: NAT Gateway para salida segura a internet
- **🔒 Zero Trust Network**: Servidores sin IPs públicas directas
- **⚡ NSGs Granulares**: Control de tráfico a nivel de VNIC
- **🎨 Página Web Avanzada**: Diseño que refleja la arquitectura de seguridad
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
| **NSGs** | `oci_core_network_security_group` | Grupos de seguridad granulares |
| **Claves SSH** | `tls_private_key` | Par de claves para acceso SSH |

### 🛡️ Configuración de Seguridad Avanzada

#### 🌐 Topología de Red Segura
- **Subnet Privada (10.0.1.0/24)**: Servidores web sin IPs públicas
- **Subnet Pública LB (10.0.2.0/24)**: Solo Load Balancer
- **Subnet Pública Bastion (10.0.3.0/24)**: Solo Bastion Host
- **Segregación completa**: Cada función en su subnet especializada

#### 🔒 Network Security Groups (NSGs)
**NSG WebServer**:
- SSH (22): Solo desde subnet Bastion (10.0.3.0/24)
- HTTP (80): Solo desde subnet Load Balancer (10.0.2.0/24)
- Egress: Todo permitido (via NAT Gateway)

**NSG Bastion**:
- SSH (22): Desde IPs autorizadas (configurable)
- ICMP: Ping desde cualquier lugar
- Egress: Todo permitido

#### 🔥 Capa Sistema - IPTables (Configurado por Ansible)
**Servidores Web**:
- SSH (22): Solo desde subnet Bastion
- HTTP (80): Solo desde subnet Load Balancer
- Política por defecto: DROP

**Bastion Host**:
- SSH (22): Desde IPs autorizadas
- Port forwarding: Configurado para túneles SSH
- Fail2ban: Protección automática contra ataques

#### 🌐 Control de Salida a Internet
- **NAT Gateway**: Única salida para servidores privados
- **Internet Gateway**: Solo para Load Balancer y Bastion
- **Rutas controladas**: Tráfico dirigido según política de seguridad

### ⚖️ Configuración del Load Balancer

#### 🎯 Backend Set Configuration
- **Política**: Round Robin (distribución equitativa)
- **Health Check**: HTTP en puerto 80, path "/"
- **Backends**: Servidores en subnet privada
- **Timeout**: 3 segundos por check
- **SSL Ready**: Preparado para certificados SSL

---

## 🆕 Diferencias con la Arquitectura 3

### 🔄 Evolución de la Infraestructura

| Aspecto | Arquitectura 3 | Arquitectura 4 |
|---------|---------------|----------------|
| **Acceso SSH** | Directo a servidores | Solo via Bastion Host |
| **IPs Públicas** | Servidores con IPs públicas | Servidores sin IPs públicas |
| **Seguridad** | Security Lists básicas | NSGs granulares + NAT Gateway |
| **Subnets** | 1 subnet pública | 3 subnets especializadas |
| **Salida Internet** | Directa via Internet Gateway | Controlada via NAT Gateway |
| **Arquitectura** | Simple | Enterprise-grade security |
| **Complejidad** | Básica | Avanzada con múltiples capas |

### 🎯 Beneficios de Seguridad

- **Aislamiento completo**: Servidores web no accesibles directamente
- **Control granular**: NSGs permiten reglas específicas por VNIC
- **Auditoría SSH**: Todos los accesos pasan por Bastion Host
- **Protección contra ataques**: Fail2ban en Bastion Host
- **Cumplimiento**: Arquitectura compatible con estándares enterprise

---

## 🚀 Métodos de Despliegue

### 🔧 Prerrequisitos

- **Terraform** >= 0.15.0 o **OpenTofu** >= 1.0.0
- **Ansible** >= 2.9 (para aprovisionamiento automático)
- Cuenta activa de Oracle Cloud Infrastructure
- Credenciales de API configuradas
- Cliente Git instalado

> 📝 **Nota**: Esta arquitectura requiere configuración avanzada de NSGs y manejo de múltiples subnets con Ansible.

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
cd arquitecturas-oci-terraform/04_balanceador_NAT_bastion
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

   [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/usuario/arquitecturas-oci-terraform/releases/latest/download/04_balanceador_NAT_bastion.zip)

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

### 🌐 Acceso a la Infraestructura

Una vez completado el despliegue (generalmente 5-8 minutos):

1. **Página Web**: Visita `http://[LOAD_BALANCER_IP]` en tu navegador
   - Diseño moderno que refleja la arquitectura de seguridad
   - Información del sistema y configuración de red
   - Responsive design para móviles y tablets

2. **SSH via Bastion**: Conecta usando:
   ```bash
   # Primero conecta al Bastion Host
   ssh -i id_rsa_enterprise ubuntu@[BASTION_IP]
   
   # Desde el Bastion, conecta a los servidores web
   ssh -i id_rsa_enterprise ubuntu@[WEBSERVER_PRIVATE_IP]
   ```

### 🎨 Características de la Página Web

La página web incluye:
- 🛡️ **Header de seguridad** con información de la arquitectura
- 📊 **Cards informativos** con datos de red y seguridad
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
| `webserver_count` | Número de servidores web | `2` | `3` |
| `webserver_shape` | Tipo de instancia servidores | `VM.Standard.E3.Flex` | `VM.Standard.E4.Flex` |
| `bastion_shape` | Tipo de instancia bastion | `VM.Standard.E3.Flex` | `VM.Standard.E4.Flex` |

### ⚙️ Ejemplo de Personalización

```hcl
# terraform.tfvars
vcn_cidr = "192.168.0.0/16"
webserver_subnet_cidr = "192.168.1.0/24"
loadbalancer_subnet_cidr = "192.168.2.0/24"
bastion_subnet_cidr = "192.168.3.0/24"
webserver_count = 3
webserver_shape = "VM.Standard.E4.Flex"
bastion_shape = "VM.Standard.E4.Flex"
```

---

## 🆘 Solución de Problemas

### ❌ Problemas Comunes

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

<details>
<summary>🔒 <strong>Error de NSGs</strong></summary>

**Problema**: Los Network Security Groups no están funcionando correctamente

**Solución**:
1. Verifica la configuración de NSGs en `nsgs.tf`
2. Comprueba que los VNICs estén asociados a los NSGs correctos
3. Revisa las reglas de ingress y egress
4. Usa el comando de diagnóstico: `oci network nsg get --nsg-id [NSG_ID]`

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
```

---

## 📚 Recursos Adicionales

### 📖 Documentación

- [Documentación de Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [Guía de Oracle Cloud Infrastructure](https://docs.oracle.com/en-us/iaas/Content/home.htm)
- [Network Security Groups en OCI](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/networksecuritygroups.htm)
- [NAT Gateway en OCI](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/NATgateway.htm)

### 📁 Documentación del Proyecto

- [SECURITY.md](SECURITY.md) - Guía de seguridad y mejores prácticas
- [validate_config.sh](validate_config.sh) - Script de validación de configuración
- [playbook.yml](playbook.yml) - Configuración de Ansible para servidores web
- [playbook_bastion.yml](playbook_bastion.yml) - Configuración de Ansible para Bastion Host

### 🎓 Próximos Pasos

Después de dominar esta arquitectura, continúa con:

1. **Arquitectura 5**: Sistema de archivos compartido con FSS
2. **Arquitectura 6**: Volúmenes de bloque locales
3. **Arquitectura 7**: Sistema de base de datos Oracle

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