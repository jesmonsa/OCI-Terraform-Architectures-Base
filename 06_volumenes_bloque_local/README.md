# Créditos y Adaptaciones

Este proyecto está basado en el repositorio original de Foggykitchen (https://github.com/mlinxfeld/foggykitchen_tf_oci_course). Incluye adaptaciones y mejoras realizadas por Jesus Montoya, Arquitecto Cloud.

# 🏗️ Arquitecturas de Referencia Terraform OCI

## 💾 Arquitectura 6 - Volúmenes de Bloque Local

### 📋 Descripción General

Esta arquitectura de referencia demuestra la implementación de **volúmenes de bloque locales** en Oracle Cloud Infrastructure (OCI), extendiendo la funcionalidad de almacenamiento de las arquitecturas anteriores. Es ideal para aplicaciones que requieren almacenamiento persistente de alto rendimiento, como bases de datos, aplicaciones empresariales o sistemas que necesitan espacio adicional para datos, logs o aplicaciones.

### 🎯 Objetivo

Crear una infraestructura con almacenamiento persistente que incluye:
- Un compartimento enterprise para organizar los recursos
- Una Red Virtual en la Nube (VCN) con subred pública optimizada
- Un Load Balancer público para distribución de tráfico
- Un Bastion Host para acceso SSH seguro
- Un volumen de bloque de 100GB asociado al servidor web principal
- Configuración automática del volumen (partición, formateo, montaje)
- Página web moderna que muestra información del almacenamiento
- Aprovisionamiento 100% automático con Ansible

### 🏛️ Arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│                    Oracle Cloud Infrastructure                  │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                    Compartimento                            │ │
│  │                                                             │ │
│  │  ┌─────────────────────────────────────────────────────────┐ │ │
│  │  │                VCN (10.0.0.0/16)                       │ │ │
│  │  │                                                         │ │ │
│  │  │  ┌─────────────────────────────────────────────────┐    │ │ │
│  │  │  │          Subred Pública (10.0.1.0/24)          │    │ │ │
│  │  │  │                                                 │    │ │ │
│  │  │  │  ⚖️  [Load Balancer OCI]                      │    │ │ │
│  │  │  │      Flexible Shape                            │    │ │ │
│  │  │  │      Health Checks                             │    │ │ │
│  │  │  │            │                                   │    │ │ │
│  │  │  │            ▼                                   │    │ │ │
│  │  │  │  ┌─────────────────────────────────────────┐    │    │ │ │
│  │  │  │  │  🖥️ WebServer1 (Con Volumen de Bloque) │    │    │ │ │
│  │  │  │  │ Ubuntu + Apache + 100GB Block Volume   │    │    │ │ │
│  │  │  │  │ VM.Standard.A1 + /u01 (montado)        │    │    │ │ │
│  │  │  │  │   Backend Pool                          │    │    │ │ │
│  │  │  │  └─────────────────────────────────────────┘    │    │ │ │
│  │  │  │                                                 │    │ │ │
│  │  │  │  🏰 [Bastion Host]                             │    │ │ │
│  │  │  │      Acceso SSH Seguro                        │    │ │ │
│  │  │  └─────────────────────────────────────────────────┘    │ │ │
│  │  │                                                         │ │ │
│  │  │  📡 Internet Gateway                                   │ │ │
│  │  └─────────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP (80) - Load Balanced
                              │ SSH (22) - Via Bastion Host
                              ▼
                         🌐 Internet
```

### ✨ Características

- **💾 Almacenamiento Persistente**: Volumen de bloque de 100GB con alta disponibilidad
- **⚖️ Load Balancing**: OCI Load Balancer con algoritmo Round Robin
- **🔄 Alta Disponibilidad**: Servidor web con almacenamiento persistente
- **🏰 Acceso Seguro**: Bastion Host como único punto de entrada SSH
- **🔒 Seguridad Multi-Capa**: Security Lists + iptables configurado automáticamente
- **⚡ Aprovisionamiento Inteligente**: Ansible con configuración automática del volumen
- **🎨 Página Web Moderna**: Diseño responsive que muestra información del almacenamiento
- **📊 Monitoreo de Almacenamiento**: Información en tiempo real del volumen montado

### 🛠️ Recursos Desplegados

| Recurso | Tipo | Descripción |
|---------|------|-------------|
| **Compartimento** | `oci_identity_compartment` | Contenedor lógico para organizar recursos |
| **VCN** | `oci_core_virtual_network` | Red virtual privada (10.0.0.0/16) |
| **Subred Pública** | `oci_core_subnet` | Subred con acceso a Internet (10.0.1.0/24) |
| **Internet Gateway** | `oci_core_internet_gateway` | Puerta de enlace para acceso a Internet |
| **Load Balancer** | `oci_load_balancer` | Balanceador de carga público flexible |
| **Bastion Host** | `oci_core_instance` | Servidor de salto para acceso SSH |
| **Web Server** | `oci_core_instance` | VM Ubuntu 22.04 con Apache2 |
| **Volumen de Bloque** | `oci_core_volume` | Volumen de 100GB para almacenamiento persistente |
| **Attachment** | `oci_core_volume_attachment` | Conexión del volumen al servidor |
| **Security Lists** | `oci_core_security_list` | Reglas de firewall |
| **Claves SSH** | `tls_private_key` | Par de claves para acceso SSH |

### 💾 Configuración del Volumen de Bloque

#### 🎯 Características del Volumen
- **Tamaño**: 100GB (configurable)
- **Tipo**: Block Volume de alto rendimiento
- **Punto de montaje**: `/u01` (estándar para aplicaciones Oracle)
- **Sistema de archivos**: ext4 (formateado automáticamente)
- **Persistencia**: Montaje automático en `/etc/fstab`

#### 🔧 Configuración Automática
El volumen se configura automáticamente mediante Ansible:

```yaml
- name: Discover and configure iSCSI disk
  shell: |
    # Descubrir el dispositivo iSCSI
    sudo iscsiadm -m node -o new -T {{ iqn }} -p {{ ip }}:3260
    sudo iscsiadm -m node -o update -T {{ iqn }} -n node.startup -v automatic
    sudo iscsiadm -m node -T {{ iqn }} -p {{ ip }}:3260 -l
    
    # Crear partición y formatear
    sudo parted /dev/sdb mklabel gpt
    sudo parted /dev/sdb mkpart primary ext4 0% 100%
    sudo mkfs.ext4 /dev/sdb1
    
    # Montar y configurar persistencia
    sudo mkdir -p /u01
    sudo mount /dev/sdb1 /u01
    echo "/dev/sdb1 /u01 ext4 defaults,_netdev 0 0" | sudo tee -a /etc/fstab
```

### ⚖️ Configuración del Load Balancer

#### 🎯 Backend Set Configuration
- **Política**: Round Robin (distribución equitativa)
- **Health Check**: HTTP en puerto 80, path "/"
- **Intervalo**: Cada 10 segundos
- **Timeout**: 3 segundos por check
- **Reintentos**: 3 antes de marcar como down

### 🛡️ Configuración de Seguridad Multi-Capa

#### 🌐 Capa OCI - Security Lists
- **SSH**: Puerto 22 desde cualquier IP (0.0.0.0/0)
- **HTTP**: Puerto 80 desde cualquier IP (0.0.0.0/0)
- **HTTPS**: Puerto 443 desde cualquier IP (0.0.0.0/0)
- **Load Balancer**: Puerto 80 hacia backends
- **Egress**: Todo el tráfico permitido hacia cualquier destino

#### 🔥 Capa Sistema - IPTables (Configurado por Ansible)
- **SSH**: Puerto 22 con conexiones establecidas y nuevas
- **HTTP**: Puerto 80 con conexiones establecidas y nuevas
- **HTTPS**: Puerto 443 con conexiones establecidas y nuevas
- **Política por defecto**: DROP en INPUT (deniega todo excepto lo permitido)
- **Loopback**: Tráfico local permitido

> ⚠️ **Nota de Seguridad**: Esta configuración permite acceso SSH desde cualquier IP para fines educativos. En entornos de producción, se recomienda:
> - Usar el bastion host para acceso SSH
> - Restringir SSH a IPs específicas
> - Implementar autenticación multi-factor
> - Usar Network Security Groups para control granular

---

## 🆕 Diferencias con la Arquitectura 5

### 🔄 Evolución de la Infraestructura

| Aspecto | Arquitectura 5 | Arquitectura 6 |
|---------|---------------|----------------|
| **Almacenamiento** | FSS compartido (NFS) | Volumen de bloque local |
| **Servidores** | 3 servidores web | 1 servidor web principal |
| **Persistencia** | Compartida entre servidores | Local al servidor |
| **Protocolo** | NFS (red) | iSCSI (bloque) |
| **Rendimiento** | Bueno para archivos | Excelente para aplicaciones |
| **Escalabilidad** | Alta (múltiples servidores) | Media (servidor único) |
| **Complejidad** | Alta con FSS | Media con volúmenes |

### 🎯 Beneficios del Volumen de Bloque

- **Alto rendimiento**: Acceso directo a nivel de bloque
- **Persistencia**: Datos sobreviven a reinicios
- **Flexibilidad**: Fácil redimensionamiento
- **Compatibilidad**: Ideal para bases de datos y aplicaciones
- **Backup**: Fácil integración con OCI Backup

---

## 🚀 Métodos de Despliegue

### 🔧 Prerrequisitos

- **Terraform** >= 0.15.0 o **OpenTofu** >= 1.0.0
- **Ansible** >= 2.9 (para aprovisionamiento automático)
- Cuenta activa de Oracle Cloud Infrastructure
- Credenciales de API configuradas
- Cliente Git instalado

> 📝 **Nota**: Esta arquitectura usa Ansible para configurar automáticamente el volumen de bloque, incluyendo descubrimiento iSCSI, particionado y montaje.

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
cd arquitecturas-oci-terraform/06_volumenes_bloque_local
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
| `webserver_private_ip` | IP privada del servidor web | `10.0.1.2` |
| `block_volume_id` | ID del volumen de bloque | `ocid1.volume.oc1...` |

### 🌐 Acceso a la Infraestructura

Una vez completado el despliegue (generalmente 5-8 minutos):

1. **Página Web**: Visita `http://[LOAD_BALANCER_IP]` en tu navegador
   - Diseño moderno que muestra información del volumen de bloque
   - Información del sistema y configuración de almacenamiento
   - Responsive design para móviles y tablets

2. **SSH via Bastion**: Conecta usando:
   ```bash
   # Primero conecta al Bastion Host
   ssh -i id_rsa_enterprise ubuntu@[BASTION_IP]
   
   # Desde el Bastion, conecta al servidor web
   ssh -i id_rsa_enterprise ubuntu@[WEBSERVER_PRIVATE_IP]
   ```

3. **Verificar Volumen**: Desde el servidor web:
   ```bash
   # Verificar montaje
   df -h /u01
   
   # Ver información del volumen
   lsblk
   
   # Crear archivo de prueba
   echo "Test desde $(hostname)" > /u01/test.txt
   ```

### 🎨 Características de la Página Web

La página web incluye:
- 💾 **Header de almacenamiento** con información del volumen de bloque
- 📊 **Cards informativos** con datos de red y almacenamiento
- 🔒 **Indicadores de seguridad** y configuración de firewall
- ✅ **Estado de servicios** del Load Balancer y servidor
- 📱 **Diseño responsive** que se adapta a todos los dispositivos
- ⏰ **Timestamp** de despliegue actualizado automáticamente

---

## 🔧 Personalización

### 📝 Variables Configurables

| Variable | Descripción | Valor por Defecto | Ejemplo |
|----------|-------------|-------------------|---------|
| `vcn_cidr` | CIDR de la VCN | `10.0.0.0/16` | `192.168.0.0/16` |
| `subnet_cidr` | CIDR de la subred | `10.0.1.0/24` | `192.168.1.0/24` |
| `webserver_shape` | Tipo de instancia servidor | `VM.Standard.E3.Flex` | `VM.Standard.E4.Flex` |
| `bastion_shape` | Tipo de instancia bastion | `VM.Standard.E3.Flex` | `VM.Standard.E4.Flex` |
| `block_volume_size` | Tamaño del volumen en GB | `100` | `200` |
| `mount_point` | Punto de montaje del volumen | `/u01` | `/data` |

### ⚙️ Ejemplo de Personalización

```hcl
# terraform.tfvars
vcn_cidr = "192.168.0.0/16"
subnet_cidr = "192.168.1.0/24"
webserver_shape = "VM.Standard.E4.Flex"
bastion_shape = "VM.Standard.E4.Flex"
block_volume_size = 200
mount_point = "/data"
```

---

## 🆘 Solución de Problemas

### ❌ Problemas Comunes

<details>
<summary>💾 <strong>Error de Montaje del Volumen</strong></summary>

**Problema**: El volumen de bloque no se monta correctamente

**Solución**:
1. Verifica que el volumen esté adjunto: `lsblk`
2. Comprueba la configuración iSCSI: `sudo iscsiadm -m session`
3. Verifica el formateo: `sudo fdisk -l /dev/sdb`
4. Revisa los logs de Ansible: `tail -f ansible.log`

</details>

<details>
<summary>🔐 <strong>Error de Acceso SSH via Bastion</strong></summary>

**Problema**: No se puede conectar al servidor web desde el Bastion Host

**Solución**:
1. Verifica que el Bastion Host esté funcionando: `ssh -i id_rsa_enterprise ubuntu@[BASTION_IP]`
2. Desde el Bastion, prueba conectividad: `ping [WEBSERVER_PRIVATE_IP]`
3. Verifica las reglas Security List: Asegúrate de que SSH (22) esté permitido
4. Comprueba la configuración de Ansible: Revisa los logs de aprovisionamiento

</details>

<details>
<summary>🌐 <strong>Error de Acceso Web</strong></summary>

**Problema**: No se puede acceder a la página web via Load Balancer

**Solución**:
1. Verifica que el Load Balancer esté funcionando: `curl http://[LOAD_BALANCER_IP]`
2. Comprueba el estado de los backends: Revisa health checks
3. Verifica las reglas Security List: HTTP (80) debe estar permitido
4. Revisa los logs de Apache: `ssh -i id_rsa_enterprise ubuntu@[BASTION_IP]`

</details>

### 🔍 Comandos de Diagnóstico

```bash
# Verificar el estado del Load Balancer
oci lb load-balancer get --load-balancer-id $(terraform output -raw load_balancer_id)

# Verificar el estado de los backends
oci lb backend get --load-balancer-id $(terraform output -raw load_balancer_id) --backend-set-name [BACKEND_SET_NAME] --backend-name [BACKEND_NAME]

# Conectar al Bastion Host
ssh -i id_rsa_enterprise ubuntu@$(terraform output -raw bastion_public_ip)

# Desde el Bastion, verificar conectividad
ping $(terraform output -raw webserver_private_ip)

# Verificar montaje del volumen
df -h /u01
lsblk
sudo iscsiadm -m session
```

---

## 📚 Recursos Adicionales

### 📖 Documentación

- [Documentación de Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [Guía de Oracle Cloud Infrastructure](https://docs.oracle.com/en-us/iaas/Content/home.htm)
- [Block Volumes en OCI](https://docs.oracle.com/en-us/iaas/Content/Block/Concepts/overview.htm)
- [iSCSI en OCI](https://docs.oracle.com/en-us/iaas/Content/Block/Tasks/connectingtoavolume.htm)

### 📁 Documentación del Proyecto

- [validate_config.sh](validate_config.sh) - Script de validación de configuración
- [playbook.yml](playbook.yml) - Configuración de Ansible para servidor web
- [playbook_bastion.yml](playbook_bastion.yml) - Configuración de Ansible para Bastion Host

### 🎓 Próximos Pasos

Después de dominar esta arquitectura, continúa con:

1. **Arquitectura 7**: Sistema de base de datos Oracle
2. **Arquitectura 8**: Peering VCN local
3. **Arquitectura 9**: Peering VCN remoto

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