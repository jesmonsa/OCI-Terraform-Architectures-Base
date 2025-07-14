# Créditos y Adaptaciones

Este proyecto está basado en el repositorio original de Foggykitchen (https://github.com/mlinxfeld/foggykitchen_tf_oci_course). Incluye adaptaciones y mejoras realizadas por Jesus Montoya, Arquitecto Cloud.

# 🏗️ Arquitecturas de Referencia Terraform OCI

## 🌐 Arquitectura 4a - Balanceador + NAT Gateway + Bastion + Network Security Groups

### 📋 Descripción General

Esta arquitectura de referencia representa una **variante avanzada de la Arquitectura 4**, diseñada para entornos de producción que requieren máxima seguridad y control granular del tráfico de red. Combina las funcionalidades básicas de balanceador de carga y NAT Gateway con **Network Security Groups (NSGs)** para proporcionar seguridad a nivel de instancia, superando las limitaciones de las Security Lists tradicionales.

La arquitectura implementa un patrón de seguridad de "defensa en profundidad" con múltiples capas de protección, incluyendo un host bastión para acceso administrativo seguro y Network Security Groups para control granular del tráfico.

### 🎯 Objetivo

Crear una infraestructura de producción segura que incluye:
- Balanceador de carga con health checks automáticos
- NAT Gateway para acceso a Internet desde subredes privadas
- Host bastión para acceso administrativo seguro
- Network Security Groups para control granular de tráfico
- Subredes separadas para diferentes tipos de recursos
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

### 🔄 Diferencias Clave con la Arquitectura 4

| Aspecto | Arquitectura 4 (Security Lists) | Arquitectura 4a (Network Security Groups) |
|---------|----------------------------------|--------------------------------------------|
| **Seguridad** | Security Lists a nivel de subred | NSGs a nivel de instancia |
| **Granularidad** | Control por subred completa | Control por instancia individual |
| **Flexibilidad** | Reglas aplicadas a toda la subred | Reglas específicas por instancia |
| **Escalabilidad** | Menos flexible para microservicios | Ideal para arquitecturas complejas |
| **Complejidad** | Configuración más simple | Configuración más granular |
| **Casos de uso** | Entornos básicos | Entornos de producción avanzados |

### ✨ Características

- **🔧 Alta Seguridad**: Network Security Groups para control granular
- **🌍 Acceso Controlado**: Host bastión como único punto de entrada SSH
- **⚖️ Balanceo de Carga**: Load balancer con health checks automáticos
- **🌐 NAT Gateway**: Acceso a Internet desde subredes privadas
- **🛡️ Seguridad Multi-Capa**: NSGs + iptables + bastión
- **⚡ Aprovisionamiento Inteligente**: Ansible con configuración específica por rol
- **📍 Separación de Redes**: Subredes públicas y privadas
- **🎨 Páginas Web Diferenciadas**: Cada servidor con información específica

### 🛠️ Recursos Desplegados

| Recurso | Tipo | Descripción |
|---------|------|-------------|
| **Compartimento** | `oci_identity_compartment` | Contenedor lógico Enterprise |
| **VCN** | `oci_core_virtual_network` | Red virtual privada (10.0.0.0/16) |
| **Subred Pública** | `oci_core_subnet` | Subred para bastión (10.0.1.0/24) |
| **Subred Privada** | `oci_core_subnet` | Subred para servidores web (10.0.2.0/24) |
| **Internet Gateway** | `oci_core_internet_gateway` | Puerta de enlace para acceso a Internet |
| **NAT Gateway** | `oci_core_nat_gateway` | NAT para acceso a Internet desde subred privada |
| **Load Balancer** | `oci_load_balancer_load_balancer` | Balanceador de carga con health checks |
| **Backend Set** | `oci_load_balancer_backend_set` | Configuración de backend servers |
| **Network Security Groups (x3)** | `oci_core_network_security_group` | NSGs para bastión, load balancer y servidores |
| **Host Bastión** | `oci_core_instance` | Instancia para acceso administrativo |
| **Instancias Compute (x2)** | `oci_core_instance` | Servidores web en subred privada |
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
- **Egress**: Todo el tráfico permitido hacia cualquier destino

#### 🔥 IPTables (Configurado por Ansible)
- **Política por defecto**: DROP (deniega todo excepto lo explícitamente permitido)
- **SSH**: Puerto 22 con conexiones establecidas y nuevas
- **HTTP**: Puerto 80 con conexiones establecidas y nuevas  
- **HTTPS**: Puerto 443 con conexiones establecidas y nuevas
- **Loopback**: Tráfico local permitido
- **Conexiones establecidas**: Tráfico de respuesta permitido

### 🎯 Cuándo Usar Esta Arquitectura

**✅ Usar Arquitectura 4a cuando:**
- Necesitas control granular de seguridad por instancia
- Trabajas con microservicios o arquitecturas complejas
- Requieres máxima seguridad en entornos de producción
- Necesitas separación clara entre acceso público y privado
- Quieres implementar principios de "defensa en profundidad"

**❌ Usar Arquitectura 4 cuando:**
- Tu entorno es simple y no requiere control granular
- Prefieres configuración más sencilla
- No necesitas separación avanzada de redes
- El equipo no tiene experiencia con NSGs

---

## 🚀 Métodos de Despliegue

### 🔧 Prerrequisitos

- **Terraform** >= 0.15.0 o **OpenTofu** >= 1.0.0
- **Ansible** >= 2.9 (para aprovisionamiento automático)
- Cuenta activa de Oracle Cloud Infrastructure
- Credenciales de API configuradas
- Cliente Git instalado

> 📝 **Nota**: Esta arquitectura usa Ansible para el aprovisionamiento de todos los componentes, proporcionando configuración específica para cada rol (bastión, servidores web).

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
cd arquitecturas-oci-terraform/04a_balanceador_NAT_bastion_grupos_seguridad
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
| `BastionPublicIP` | IP pública del host bastión | `130.61.45.123` |
| `LoadBalancerPublicIP` | IP pública del load balancer | `130.61.45.124` |
| `Webserver1PrivateIP` | IP privada del servidor web 1 | `10.0.2.10` |
| `Webserver2PrivateIP` | IP privada del servidor web 2 | `10.0.2.11` |

### 🌐 Acceso a los Servicios

Una vez completado el despliegue (generalmente 5-7 minutos):

1. **Aplicación Web**: Visita `http://[IP_LOAD_BALANCER]` en tu navegador
   - Balanceo automático entre servidores web
   - Health checks activos
   - Diseño responsive con información del sistema

2. **Host Bastión**: Conecta usando `ssh -i id_rsa_enterprise ubuntu@[IP_BASTION]`
   - Único punto de entrada SSH
   - Acceso a servidores web desde bastión
   - Configuración de seguridad reforzada

3. **Servidores Web**: Acceso solo desde bastión
   - `ssh -i id_rsa_enterprise ubuntu@[IP_PRIVADA_SERVIDOR]`
   - No accesibles directamente desde Internet
   - Configuración específica para cada rol

### 🎨 Características de la Aplicación Web

La aplicación web incluye:
- 🚀 **Header dinámico** con información del load balancer
- 📊 **Cards informativos** con datos del sistema
- 🛠️ **Stack tecnológico** mostrado con badges
- ✅ **Indicadores de estado** del load balancer y backend
- 📱 **Diseño responsive** que se adapta a todos los dispositivos
- ⚖️ **Información de balanceo** mostrando el servidor que responde
- ⏰ **Timestamp** de despliegue actualizado automáticamente

---

## 🔧 Personalización

### 📝 Variables Configurables

| Variable | Descripción | Valor por Defecto | Ejemplo |
|----------|-------------|-------------------|---------|
| `vcn_cidr` | CIDR de la VCN | `10.0.0.0/16` | `192.168.0.0/16` |
| `public_subnet_cidr` | CIDR de la subred pública | `10.0.1.0/24` | `192.168.1.0/24` |
| `private_subnet_cidr` | CIDR de la subred privada | `10.0.2.0/24` | `192.168.2.0/24` |
| `Shape` | Tipo de instancia | `VM.Standard.E3.Flex` | `VM.Standard.E4.Flex` |
| `FlexShapeOCPUS` | Número de CPUs | `1` | `2` |
| `FlexShapeMemory` | Memoria en GB | `2` | `4` |
| `instance_os` | Sistema operativo | `Canonical Ubuntu` | `Oracle Linux` |
| `linux_os_version` | Versión del SO | `22.04` | `20.04` |
| `compute_count` | Número de servidores web | `2` | `3` |

### ⚙️ Ejemplo de Personalización

```hcl
# terraform.tfvars
vcn_cidr = "192.168.0.0/16"
public_subnet_cidr = "192.168.1.0/24"
private_subnet_cidr = "192.168.2.0/24"
Shape = "VM.Standard.E4.Flex"
FlexShapeOCPUS = 2
FlexShapeMemory = 4
instance_os = "Oracle Linux"
linux_os_version = "8"
compute_count = 3
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
<summary>🌐 <strong>Error de Network Security Groups</strong></summary>

**Problema**: `Error: Network Security Group not found`

**Solución**:
1. Verifica que los NSGs se hayan creado correctamente: `terraform state list | grep nsg`
2. Comprueba las reglas de los NSGs en la consola de OCI
3. Asegúrate de que las instancias estén asociadas a los NSGs correctos

</details>

<details>
<summary>⚖️ <strong>Error de Load Balancer</strong></summary>

**Problema**: `Error: Load balancer health check failed`

**Solución**:
1. Verifica que los servidores web estén funcionando: `ssh -i id_rsa_enterprise ubuntu@[IP_BASTION]`
2. Comprueba el estado de Apache: `sudo systemctl status apache2`
3. Verifica la configuración del backend set en la consola de OCI

</details>

<details>
<summary>🌐 <strong>Error de NAT Gateway</strong></summary>

**Problema**: `Error: NAT Gateway not available`

**Solución**:
1. Verifica que el NAT Gateway esté creado: `terraform state list | grep nat`
2. Comprueba la tabla de rutas de la subred privada
3. Asegúrate de que los servidores web puedan acceder a Internet

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

# Verificar conectividad a servidores web desde bastión
ssh -i mi_llave_oci.pem ubuntu@$(terraform output -raw BastionPublicIP) "ssh ubuntu@$(terraform output -raw Webserver1PrivateIP) 'curl -I http://localhost'"

# Ver logs de Ansible
tail -f ansible.log

# Verificar estado del load balancer
oci lb load-balancer get --load-balancer-id $(terraform output -raw LoadBalancerOCID)
```

---

## 📚 Recursos Adicionales

### 📖 Documentación

- [Documentación de Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [Guía de Oracle Cloud Infrastructure](https://docs.oracle.com/en-us/iaas/Content/home.htm)
- [Mejores Prácticas de Terraform](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Network Security Groups en OCI](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/networksecuritygroups.htm)

### 📁 Documentación del Proyecto

- [SECURITY.md](SECURITY.md) - Guía de seguridad y mejores prácticas
- [nsgs.tf](nsgs.tf) - Configuración de Network Security Groups
- [playbook.yml](playbook.yml) - Configuración de Ansible para aprovisionamiento
- [variables.tf](variables.tf) - Variables configurables del proyecto

### 🎓 Próximos Pasos

Después de dominar esta arquitectura, continúa con:

1. **Arquitectura 5**: Sistema de archivos compartido
2. **Arquitectura 6**: Volúmenes de bloque locales
3. **Arquitectura 7**: Sistema de base de datos

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