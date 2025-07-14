# Créditos y Adaptaciones

Este proyecto está basado en el repositorio original de Foggykitchen (https://github.com/mlinxfeld/foggykitchen_tf_oci_course). Incluye adaptaciones y mejoras realizadas por Jesus Montoya, Arquitecto Cloud.

# 🏗️ Arquitecturas de Referencia Terraform OCI

## 🌐 Arquitectura 2 - Segundo Servidor Web en Otro AD

### 📋 Descripción General

Esta arquitectura de referencia representa la evolución natural de la **Arquitectura 1**, implementando alta disponibilidad mediante el despliegue de dos servidores web distribuidos en diferentes Dominios de Disponibilidad (Availability Domains). Es el siguiente paso lógico para comprender la distribución geográfica de recursos y la redundancia en Oracle Cloud Infrastructure.

### 🎯 Objetivo

Crear una infraestructura de alta disponibilidad que incluye:
- Dos servidores web distribuidos en diferentes Availability Domains
- Red compartida con subred regional que abarca múltiples ADs
- Configuración de seguridad avanzada con Network Security Groups
- Aprovisionamiento automático optimizado con Ansible

### 🏛️ Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                    Oracle Cloud Infrastructure              │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                  Compartimento Enterprise               │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────┐    │ │
│  │  │                VCN (10.0.0.0/16)               │    │ │
│  │  │                                                 │    │ │
│  │  │  ┌─────────────────────────────────────────┐    │    │ │
│  │  │  │         Subred Regional Pública         │    │    │ │
│  │  │  │         (10.0.1.0/24)                  │    │    │ │
│  │  │  │                                         │    │    │ │
│  │  │  │  ┌────────────────┐  ┌────────────────┐ │    │    │ │
│  │  │  │  │🖥️ Servidor Web 1│  │🖥️ Servidor Web 2│ │    │    │ │
│  │  │  │  │      (AD-1)     │  │      (AD-2)     │ │    │    │ │
│  │  │  │  │ Ubuntu 22.04 +  │  │ Ubuntu 22.04 +  │ │    │    │ │
│  │  │  │  │    Apache2      │  │    Apache2      │ │    │    │ │
│  │  │  │  │   IP: x.x.x.1   │  │   IP: x.x.x.2   │ │    │    │ │
│  │  │  │  └────────────────┘  └────────────────┘ │    │    │ │
│  │  │  └─────────────────────────────────────────┘    │    │ │
│  │  │                                                 │    │ │
│  │  │  🛡️ Network Security Group                     │    │ │
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

- **🔧 Alta Disponibilidad**: Dos servidores distribuidos en ADs diferentes para redundancia
- **🌍 Acceso Público**: Ambos servidores accesibles directamente desde Internet
- **🛡️ Seguridad Multi-Capa**: Network Security Groups + iptables automático 
- **⚡ Aprovisionamiento Inteligente**: Ansible paralelo con retry logic (3-5 minutos)
- **📍 Distribución Multi-AD**: Redundancia geográfica real automática
- **🎨 Páginas Web Diferenciadas**: Cada servidor con diseño único y colores distintivos
- **🔄 Despliegue Paralelo**: Configuración simultánea de ambos servidores
- **📊 Información Específica**: Cada página muestra su AD y rol (Primario/Secundario)

### 🛠️ Recursos Desplegados

| Recurso | Tipo | Descripción |
|---------|------|-------------|
| **Compartimento** | `oci_identity_compartment` | Contenedor lógico Enterprise |
| **VCN** | `oci_core_virtual_network` | Red virtual privada (10.0.0.0/16) |
| **Subred Regional** | `oci_core_subnet` | Subred que abarca múltiples ADs (10.0.1.0/24) |
| **Internet Gateway** | `oci_core_internet_gateway` | Puerta de enlace para acceso a Internet |
| **Tabla de Rutas** | `oci_core_route_table` | Enrutamiento del tráfico hacia Internet Gateway |
| **Network Security Group** | `oci_core_network_security_group` | Reglas de firewall granulares |
| **Instancias Compute (x2)** | `oci_core_instance` | Máquinas virtuales distribuidas en ADs |
| **Claves SSH** | `tls_private_key` | Par de claves para acceso SSH |

### 🛡️ Configuración de Seguridad Multi-Capa

#### 🌐 Capa OCI - Network Security Groups (NSG)
- **SSH**: Puerto 22 desde cualquier IP (0.0.0.0/0) con control granular
- **HTTP**: Puerto 80 desde cualquier IP (0.0.0.0/0) 
- **HTTPS**: Puerto 443 desde cualquier IP (0.0.0.0/0)
- **Tráfico interno**: Permitido entre instancias del mismo NSG
- **Flexibilidad**: Control a nivel de VNIC (más granular que Security Lists)

#### 🔥 Capa Sistema - IPTables (Configurado por Ansible)
- **Política por defecto**: DROP (deniega todo excepto lo explícitamente permitido)
- **SSH**: Puerto 22 con conexiones establecidas y nuevas
- **HTTP**: Puerto 80 con conexiones establecidas y nuevas  
- **HTTPS**: Puerto 443 con conexiones establecidas y nuevas
- **Loopback**: Tráfico local permitido
- **Conexiones establecidas**: Tráfico de respuesta permitido

#### 🔧 Características de Seguridad Avanzadas
- ✅ **Doble protección** - NSG + iptables para máxima seguridad
- ✅ **Configuración automatizada** - Sin intervención manual
- ✅ **Reglas persistentes** - Sobreviven a reinicios
- ✅ **Sin bloqueos SSH** - Orden de reglas optimizado
- ✅ **Logs de auditoría** - Eventos de seguridad registrados

> ⚠️ **Nota de Seguridad**: Esta configuración permite acceso SSH desde cualquier IP para fines educativos. En entornos de producción, se recomienda:
> - Implementar bastion hosts para acceso SSH
> - Usar allowlists de IPs específicas
> - Configurar autenticación multi-factor
> - Implementar monitoreo de accesos SSH

---

## 🆕 Diferencias con la Arquitectura 1

### 🔄 Evolución de la Infraestructura

| Aspecto | Arquitectura 1 | Arquitectura 2 |
|---------|---------------|----------------|
| **Servidores** | 1 servidor web | 2 servidores web paralelos |
| **Disponibilidad** | Single-AD | Multi-AD (AD-1, AD-2) |
| **Redundancia** | Sin redundancia | Alta disponibilidad real |
| **Seguridad** | Security Lists | Network Security Groups + iptables |
| **Aprovisionamiento** | Ansible (1 instancia) | Ansible (2 instancias paralelas) |
| **Contenido Web** | Página única | Páginas diferenciadas con colores únicos |
| **Experiencia Visual** | Diseño estándar | Servidor 1 (azul) vs Servidor 2 (rosa) |
| **Información mostrada** | Datos básicos | AD específico + rol primario/secundario |

### 🎯 Beneficios Adicionales

- **Tolerancia a fallos**: Si un AD falla, el otro sigue funcionando
- **Distribución de carga**: Posibilidad de distribuir tráfico manualmente
- **Preparación para Load Balancer**: Base para implementar balanceeo automático
- **Experiencia de usuario**: Contenido personalizado por servidor

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
cd arquitecturas-oci-terraform/02_segundo_servidor_web_en_otro_AD
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
| `EnterpriseWebserver1PublicIP` | IP pública del servidor web 1 | `130.61.45.123` |
| `EnterpriseWebserver2PublicIP` | IP pública del servidor web 2 | `130.61.45.124` |

### 🌐 Acceso a los Servidores Web

Una vez completado el despliegue (generalmente 5-7 minutos para ambos servidores):

1. **Servidor Web 1 (Primario - AD-1)**: Visita `http://[IP_PUBLICA_1]`
   - 🎨 **Diseño azul** con gradientes específicos del servidor primario
   - 🏷️ **Badge "SERVIDOR WEB 1"** prominente en la parte superior
   - 📍 **Indicador "AD-1 (Primario)"** con fondo verde
   - 📊 **Información específica** del sistema y ubicación

2. **Servidor Web 2 (Secundario - AD-2)**: Visita `http://[IP_PUBLICA_2]`
   - 🎨 **Diseño rosa** con gradientes específicos del servidor secundario  
   - 🏷️ **Badge "SERVIDOR WEB 2"** prominente en la parte superior
   - 📍 **Indicador "AD-2 (Secundario)"** con fondo naranja
   - 📊 **Información específica** del sistema y ubicación

3. **SSH a cualquier servidor**: `ssh -i id_rsa_enterprise ubuntu@[IP_PUBLICA]`
   - Usuario: `ubuntu` (no `opc`)
   - Clave: `id_rsa_enterprise` (generada automáticamente)

### 🎨 Características Únicas de las Páginas Web

Cada servidor muestra:
- 🚀 **Animaciones diferenciadas** - Efectos únicos por servidor
- 🎯 **Identificación clara** - Número de servidor y AD visible
- 📊 **Información del AD** - Primario vs Secundario claramente marcado
- 🛠️ **Stack tecnológico** - Multi-AD deployment badges
- ✅ **Estado de alta disponibilidad** - Indicadores de redundancia activa
- 📱 **Diseño responsive** - Optimizado para todos los dispositivos

---

## 🔧 Personalización

### 📝 Variables Configurables

| Variable | Descripción | Valor por Defecto | Ejemplo |
|----------|-------------|-------------------|---------|
| `VCN-CIDR` | CIDR de la VCN | `10.0.0.0/16` | `192.168.0.0/16` |
| `Subnet-CIDR` | CIDR de la subred | `10.0.1.0/24` | `192.168.1.0/24` |
| `ComputeCount` | Número de servidores | `2` | `3` |
| `Shape` | Tipo de instancia | `VM.Standard.E4.Flex` | `VM.Standard.E3.Flex` |
| `FlexShapeOCPUS` | Número de CPUs | `1` | `2` |
| `FlexShapeMemory` | Memoria en GB | `2` | `4` |

### ⚙️ Ejemplo de Personalización

```hcl
# terraform.tfvars
VCN-CIDR = "192.168.0.0/16"
Subnet-CIDR = "192.168.1.0/24"
ComputeCount = 3
Shape = "VM.Standard.E3.Flex"
FlexShapeOCPUS = 2
FlexShapeMemory = 4
```

---

## 🔍 Verificación del Despliegue

### 🎯 Script de Verificación Automática

```bash
# Ejecutar verificación completa
./verify_deployment.sh
```

Este script verifica:
- ✅ Conectividad SSH a ambos servidores
- ✅ Estado del servicio Apache en cada servidor
- ✅ Respuesta HTTP de las páginas web
- ✅ Contenido diferenciado en cada servidor
- ✅ Configuración de firewall

### 🧪 Verificación Manual

```bash
# Ver las IPs de salida
terraform output

# Probar conectividad SSH
ssh -i id_rsa_enterprise ubuntu@$(terraform output -raw EnterpriseWebserver1PublicIP)
ssh -i id_rsa_enterprise ubuntu@$(terraform output -raw EnterpriseWebserver2PublicIP)

# Probar páginas web
curl http://$(terraform output -raw EnterpriseWebserver1PublicIP)
curl http://$(terraform output -raw EnterpriseWebserver2PublicIP)

# Verificar servicios
ssh -i id_rsa_enterprise ubuntu@IP_SERVIDOR "sudo systemctl status apache2"
```

---

## 🆘 Solución de Problemas

### ❌ Problemas Comunes

<details>
<summary>🔍 <strong>Error en Despliegue de Múltiples Instancias</strong></summary>

**Problema**: `Error: timeout while waiting for state to become 'RUNNING'`

**Solución**:
1. Verifica límites de servicio: Las regiones tienen límites en el número de instancias
2. Comprueba la disponibilidad del shape en múltiples ADs
3. Usa shapes diferentes si hay limitaciones: `VM.Standard.E3.Flex`, `VM.Standard.A1.Flex`
4. Considera usar shapes fijos si los flexibles no están disponibles

</details>

<details>
<summary>🔐 <strong>Error de Ansible en Múltiples Servidores</strong></summary>

**Problema**: `UNREACHABLE! Connection timed out during banner exchange`

**Solución**:
1. Ejecuta el script de diagnóstico: `./debug_ssh.sh`
2. Verifica que ambas instancias estén completamente desplegadas
3. Comprueba los inventarios temporales: `ls -la inventory_*`
4. Ejecuta Ansible manualmente en cada servidor:
   ```bash
   ansible-playbook -i inventory_1 playbook.yml
   ansible-playbook -i inventory_2 playbook.yml
   ```

</details>

<details>
<summary>🌐 <strong>Error de Network Security Groups</strong></summary>

**Problema**: `Error: 409-IncorrectState, Network Security Group rules`

**Solución**:
1. Espera unos minutos y vuelve a intentar (a veces es temporal)
2. Verifica que no haya reglas conflictivas
3. Destruye y recrea los NSG si es necesario:
   ```bash
   terraform destroy -target=oci_core_network_security_group.EnterpriseNSG
   terraform apply
   ```

</details>

<details>
<summary>🏠 <strong>Error de Distribución Multi-AD</strong></summary>

**Problema**: `Error: no available availability domain found`

**Solución**:
1. Verifica que tu región tenga múltiples ADs disponibles
2. Ajusta el cálculo de distribución en `compute.tf`
3. Considera usar Fault Domains si los ADs son limitados
4. Revisa la configuración en `datasources.tf`

</details>

### 🔍 Comandos de Diagnóstico

```bash
# Verificar el estado de ambas instancias
terraform state list | grep oci_core_instance

# Mostrar información detallada de las instancias
terraform show | grep -A 20 "oci_core_instance"

# Verificar la distribución de ADs
terraform console
> data.oci_identity_availability_domains.ADs.availability_domains

# Verificar conectividad a ambos servidores
for ip in $(terraform output -json | jq -r '.[].value'); do
  echo "Testing $ip"
  curl -I http://$ip --connect-timeout 5
done

# Ver logs detallados de Ansible
tail -f ansible.log

# Diagnóstico SSH específico para múltiples servidores
./debug_ssh.sh
```

---

## 🎓 Próximos Pasos

Después de dominar esta arquitectura, continúa con:

### 🚀 Arquitectura 3 - Load Balancer
- Implementar balanceador de carga automático
- Ocultar los servidores detrás del load balancer
- Configurar health checks y distribución de tráfico

### 🏗️ Mejoras Adicionales
- **Monitoreo**: Implementar métricas y alertas
- **Backup**: Configurar snapshots automáticos
- **Escalabilidad**: Preparar para auto-scaling
- **Seguridad**: Implementar Web Application Firewall (WAF)

---

## 📚 Recursos Adicionales

### 📖 Documentación

- [Documentación de Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [Guía de Oracle Cloud Infrastructure](https://docs.oracle.com/en-us/iaas/Content/home.htm)
- [Network Security Groups en OCI](https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/networksecuritygroups.htm)
- [Availability Domains y Fault Domains](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm)

### 📁 Documentación del Proyecto

- [CONFIGURACION_FINAL.md](CONFIGURACION_FINAL.md) - Detalles técnicos de la configuración
- [MEJORAS_DEPLOYMENT.md](MEJORAS_DEPLOYMENT.md) - Mejoras implementadas en el despliegue
- [REVISION_FINAL_COMPLETA.md](REVISION_FINAL_COMPLETA.md) - Revisión completa del proyecto
- [verify_deployment.sh](verify_deployment.sh) - Script de verificación automática
- [test_deployment.sh](test_deployment.sh) - Tests automatizados

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