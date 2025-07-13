# 🗄️ Enterprise Database Architecture - Deployment Guide

## 📋 Arquitectura 07: Sistema Base de Datos Enterprise

Esta arquitectura implementa un sistema completo enterprise con Oracle Database 19c, incluyendo:

- **🔒 6 Subnets** con segmentación enterprise
- **🛡️ Network Security Groups (NSGs)** en lugar de Security Lists
- **🗄️ Oracle Database 19c** en subnet privada dedicada
- **📁 File Storage System (FSS)** compartido
- **💾 Block Volumes** locales por servidor
- **⚖️ Load Balancer** flexible con health checks
- **🏰 Bastion Host** para acceso seguro
- **🤖 Ansible Automation** para configuración

## 🚀 Instrucciones de Despliegue

### 1. ⚙️ Preparación del Entorno

```bash
# Navegar al directorio
cd 07_sistema_base_datos

# Configurar credenciales OCI (si no están configuradas)
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars con tus credenciales OCI
```

### 2. 🔐 Configurar Password Segura

```bash
# IMPORTANTE: Nunca hardcodear passwords en archivos
export TF_VAR_db_admin_password="YourSecurePassword123!"

# Verificar que esté configurada
echo $TF_VAR_db_admin_password
```

### 3. 🚀 Ejecutar Despliegue

```bash
# Opción A: Usar script automatizado (RECOMENDADO)
./deploy.sh

# Opción B: Pasos manuales
terraform init
terraform validate  
terraform plan -out=tfplan
terraform apply tfplan
```

### 4. ✅ Verificar Despliegue

```bash
# Verificar outputs
terraform output

# Probar conectividad al Load Balancer
curl -I http://$(terraform output -raw load_balancer_ip)

# Probar health check
curl -I http://$(terraform output -raw load_balancer_ip)/healthz
```

## 🏗️ Componentes de la Arquitectura

### Red (VCN: 10.0.0.0/16)
- **Web Subnet**: `10.0.1.0/24` (private) - Servidores web
- **LB Subnet**: `10.0.2.0/24` (public) - Load balancer
- **Bastion Subnet**: `10.0.3.0/24` (public) - Bastion host
- **FSS Subnet**: `10.0.4.0/24` (private) - File Storage System
- **DB Subnet**: `10.0.5.0/24` (private) - Oracle Database

### Seguridad
- **NSG Web**: Permite HTTP/HTTPS desde LB, SSH desde Bastion
- **NSG LB**: Permite HTTP/HTTPS desde Internet, salida a Web
- **NSG Bastion**: Permite SSH desde IPs permitidas
- **NSG FSS**: Permite NFS desde Web servers
- **NSG DB**: Permite Oracle (1521) SOLO desde Web NSG, SSH desde Bastion

### Base de Datos
- **Oracle 19c Standard Edition** (Enterprise Edition para producción)
- **256GB storage** con redundancia normal
- **Backup automático** 30 días de retención
- **Subnet privada** sin IPs públicas

## 🛠️ Personalización

### Variables Principales (terraform.tfvars)

```hcl
# Número de servidores web (1-3)
ComputeCount = 3

# Shapes (para optimizar costos usar A1.Flex)
WebserverShape = "VM.Standard.A1.Flex"
BastionShape   = "VM.Standard.A1.Flex"

# Base de datos
db_edition = "STANDARD_EDITION"  # o "ENTERPRISE_EDITION"
db_data_storage_size_in_gb = 256

# Load Balancer
flex_lb_min_shape = 10   # Mbps mínimo
flex_lb_max_shape = 100  # Mbps máximo
```

### Variables de Entorno Seguras

```bash
# Password de admin de BD (REQUERIDO)
export TF_VAR_db_admin_password="SecurePassword123!"

# Opcional: SSH key custom
export TF_VAR_ssh_private_key_filename="my_custom_key"
```

## 🔧 Troubleshooting

### Problema: "terraform: command not found"
```bash
# Instalar Terraform si no está disponible
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

### Problema: Error de password
```bash
# Asegurar que la variable esté configurada
export TF_VAR_db_admin_password="YourPassword"
echo $TF_VAR_db_admin_password
```

### Problema: Health check falla
```bash
# Verificar que el endpoint /healthz responde
curl -v http://$(terraform output -raw load_balancer_ip)/healthz
```

### Problema: SSH no conecta
```bash
# Verificar permisos de clave
chmod 600 id_rsa_enterprise

# Probar conexión via bastion
ssh -i id_rsa_enterprise ubuntu@$(terraform output -raw bastion_public_ip)
```

## 🗂️ Estructura del Proyecto

```
07_sistema_base_datos/
├── backend.tf              # Remote state configuration
├── block_volume.tf          # Block volumes para web servers
├── compartment.tf           # OCI compartment
├── compute.tf              # Web servers + bastion + provisioning
├── datasources.tf          # Data sources (ADs, images)
├── dbsystem.tf             # Oracle Database 19c
├── fss.tf                  # File Storage System
├── loadbalancer.tf         # Load balancer con health checks
├── locals.tf               # Local computed values
├── network.tf              # VCN + 6 subnets + routing
├── nsgs.tf                 # Network Security Groups
├── outputs.tf              # Outputs con try() functions
├── playbook.yml            # Ansible para web servers
├── playbook_bastion.yml    # Ansible para bastion
├── provider.tf             # OCI provider configuration
├── tls.tf                  # SSH key generation
├── variables.tf            # Variable definitions
├── terraform.tfvars        # Your actual values
├── terraform.tfvars.example # Template sin datos sensibles
└── deploy.sh               # Script de despliegue automatizado
```

## 🏷️ Tags y Governance

Todos los recursos incluyen tags consistentes:

```hcl
freeform_tags = {
  project = "lesson7"
  env     = "dev"
  owner   = "yisus"
  # tags específicos por recurso
}
```

## 🚨 Importante: Limpieza

```bash
# Destruir todos los recursos cuando no los necesites
terraform destroy

# La base de datos tarda ~15 minutos en destruirse
# Los backups automáticos se retienen según configuración
```

## 📊 Costos Estimados

- **Shapes A1.Flex (ARM)**: ~$6-10/mes por instancia
- **Oracle DB Standard**: ~$200-300/mes
- **Load Balancer Flexible**: ~$20/mes
- **Storage**: ~$5-10/mes por 100GB

**Total estimado: ~$250-350/mes** para el ambiente completo

---

✅ **La arquitectura está lista para producción** con todas las mejores prácticas enterprise implementadas.