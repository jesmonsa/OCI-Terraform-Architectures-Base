# Créditos y Adaptaciones

Este proyecto está basado en el repositorio original de Foggykitchen (https://github.com/mlinxfeld/foggykitchen_tf_oci_course). Incluye adaptaciones y mejoras realizadas por Jesus Montoya, Arquitecto Cloud.

# 🏗️ Arquitecturas de Referencia Terraform OCI

## ⚖️ Arquitectura 3 - Balanceador de Carga

### 📋 Descripción General

Esta arquitectura de referencia demuestra la implementación de un balanceador de carga en Oracle Cloud Infrastructure (OCI) que distribuye automáticamente el tráfico entre múltiples servidores web. Es ideal para aplicaciones que requieren alta disponibilidad, escalabilidad y distribución de carga, proporcionando una base sólida para aplicaciones web resilientes y de alto rendimiento.

### 🎯 Objetivo

Crear una infraestructura escalable y de alta disponibilidad que incluye:
- Un compartimento enterprise para organizar los recursos
- Una Red Virtual en la Nube (VCN) con subred pública optimizada
- Un Load Balancer público de OCI para distribución de tráfico
- Múltiples instancias de servidores web Ubuntu con Apache
- Health checks automáticos para garantizar disponibilidad
- Página web moderna con diseño responsive que muestra información del load balancing
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
│  │  │  │      Round Robin                               │    │ │ │
│  │  │  │            │                                   │    │ │ │
│  │  │  │            ├─────────────┬─────────────┐        │    │ │ │
│  │  │  │            ▼             ▼             ▼        │    │ │ │
│  │  │  │  ┌─────────────────┐ ┌─────────────────┐ ...   │    │ │ │
│  │  │  │  │  🖥️ WebServer1   │ │  🖥️ WebServer2   │     │    │ │ │
│  │  │  │  │ Ubuntu + Apache │ │ Ubuntu + Apache │     │    │ │ │
│  │  │  │  │ VM.Standard.A1  │ │ VM.Standard.A1  │     │    │ │ │
│  │  │  │  │   Backend Pool  │ │   Backend Pool  │     │    │ │ │
│  │  │  │  └─────────────────┘ └─────────────────┘     │    │ │ │
│  │  │  └─────────────────────────────────────────────────┘    │ │ │
│  │  │                                                         │ │ │
│  │  │  📡 Internet Gateway                                   │ │ │
│  │  └─────────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP (80) - Load Balanced
                              │ SSH (22) - Direct to servers
                              ▼
                         🌐 Internet
```

### ✨ Características

- **⚖️ Load Balancing**: OCI Load Balancer con algoritmo Round Robin
- **🔄 Alta Disponibilidad**: Múltiples servidores backend distribuidos automáticamente
- **💓 Health Checks**: Monitoreo automático de salud de servidores backend
- **🌍 Acceso Público**: Load balancer público con IP estática
- **🔒 Seguridad Multi-Capa**: Security Lists + iptables configurado automáticamente
- **⚡ Aprovisionamiento Inteligente**: Ansible con retry logic y error handling
- **🎨 Página Web Moderna**: Diseño responsive que muestra información del load balancing
- **📊 Distribución Automática**: Tráfico distribuido equitativamente entre servidores

### 🛠️ Recursos Desplegados

| Recurso | Tipo | Descripción |
|---------|------|-------------|
| **Compartimento** | `oci_identity_compartment` | Contenedor lógico para organizar recursos |
| **VCN** | `oci_core_virtual_network` | Red virtual privada (10.0.0.0/16) |
| **Subred Pública** | `oci_core_subnet` | Subred con acceso a Internet (10.0.1.0/24) |
| **Internet Gateway** | `oci_core_internet_gateway` | Puerta de enlace para acceso a Internet |
| **Load Balancer** | `oci_load_balancer` | Balanceador de carga público flexible |
| **Backend Set** | `oci_load_balancer_backendset` | Pool de servidores backend |
| **Listener** | `oci_load_balancer_listener` | Listener HTTP en puerto 80 |
| **Backends** | `oci_load_balancer_backend` | Servidores web individuales |
| **Instancias Compute** | `oci_core_instance` | VMs Ubuntu 22.04 con Apache2 |
| **Claves SSH** | `tls_private_key` | Par de claves para acceso SSH |

### ⚖️ Configuración del Load Balancer

#### 🎯 Backend Set Configuration
- **Política**: Round Robin (distribución equitativa)
- **Health Check**: HTTP en puerto 80, path "/"
- **Intervalo**: Cada 10 segundos
- **Timeout**: 3 segundos por check
- **Reintentos**: 3 antes de marcar como down

#### 🔄 Características Avanzadas
- ✅ **Flexible Shape** - Escalado automático de ancho de banda
- ✅ **Session Persistence** - Opcional (cookie-based)
- ✅ **SSL Termination** - Ready para certificados SSL
- ✅ **Backend Health Monitoring** - Exclusión automática de servidores no saludables

### 🛡️ Configuración de Seguridad Multi-Capa

#### 🌐 Capa OCI - Security Lists
- **SSH**: Puerto 22 desde cualquier IP (0.0.0.0/0)
- **HTTP**: Puerto 80 desde cualquier IP (0.0.0.0/0)
- **Load Balancer**: Puerto 80 hacia backends
- **Egress**: Todo el tráfico permitido hacia cualquier destino

#### 🔥 Capa Sistema - IPTables (Configurado por Ansible)
- **SSH**: Puerto 22 con conexiones establecidas y nuevas
- **HTTP**: Puerto 80 con conexiones establecidas y nuevas
- **Política por defecto**: DROP en INPUT (deniega todo excepto lo permitido)
- **Loopback**: Tráfico local permitido

> ⚠️ **Nota de Seguridad**: Los servidores web tienen IPs públicas para simplificar el acceso SSH en este ejemplo educativo. En producción, se recomienda usar subnets privadas con bastion host.

---

## 🚀 Métodos de Despliegue

### 🔧 Prerrequisitos

- **Terraform** >= 0.15.0 o **OpenTofu** >= 1.0.0
- **Ansible** >= 2.9 (para aprovisionamiento automático)
- Cuenta activa de Oracle Cloud Infrastructure
- Credenciales de API configuradas
- Cliente Git instalado

> 📝 **Nota**: Esta arquitectura usa Ansible con inventario dinámico para configurar múltiples servidores de forma eficiente.

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
cd arquitecturas-oci-terraform/03_balanceador_de_carga
```

### 🔄 **2. Inicializar el Proyecto**

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

### 📋 **3. Planificar el Despliegue**

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

### ✅ **4. Aplicar los Cambios**

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

### 🧹 **5. Limpiar Recursos**

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

5. **Configurar variables**: Ajusta el número de servidores, shapes, y otros parámetros.

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
| `EnterpriseWebserver_Public_IPs_Formatted` | IPs públicas de servidores web | `{"EnterpriseWebServer1": "130.61.45.123", "EnterpriseWebServer2": "140.21.35.89"}` |
| `load_balancer_ip` | IP pública del Load Balancer | `143.47.107.80` |
| `load_balancer_url` | URL del Load Balancer | `http://143.47.107.80` |
| `load_balancer_health_url` | URL para health checks | `http://143.47.107.80/` |

### 🌐 Acceso a la Infraestructura

Una vez completado el despliegue (generalmente 5-8 minutos):

1. **Load Balancer**: Visita `http://[LOAD_BALANCER_IP]` en tu navegador
   - Páginas web modernas con información del load balancing
   - Refresh múltiples veces para ver la distribución entre servidores
   - Diseño responsive que muestra qué servidor responde

2. **Servidores Individuales**: Conecta vía SSH a cada servidor
   ```bash
   ssh -i id_rsa_enterprise ubuntu@[WEBSERVER_IP]
   ```

3. **Pruebas de Load Balancing**: 
   ```bash
   # Múltiples requests para ver distribución
   for i in {1..10}; do curl http://[LOAD_BALANCER_IP]; done
   ```

### 🎨 Características de las Páginas Web

Las páginas web incluyen:
- 🚀 **Header específico** con información del load balancing
- ⚖️ **Indicadores de load balancer** (badges con Round Robin, Alta Disponibilidad, etc.)
- 📊 **Cards informativos** mostrando IP, hostname, y rol en el backend pool
- 🛠️ **Stack tecnológico** con badges de OCI, Terraform, Ansible, Apache2, Load Balancer
- ✅ **Estado del backend pool** con indicadores de health check
- 📱 **Diseño responsive** consistente con otras arquitecturas

---

## 🔧 Personalización

### 📝 Variables Configurables

| Variable | Descripción | Valor por Defecto | Ejemplo |
|----------|-------------|-------------------|---------|
| `VCN-CIDR` | CIDR de la VCN | `10.0.0.0/16` | `192.168.0.0/16` |
| `Subnet-CIDR` | CIDR de la subred | `10.0.1.0/24` | `192.168.1.0/24` |
| `ComputeCount` | Número de servidores | `2` | `4` |
| `Shape` | Tipo de instancia | `VM.Standard.A1.Flex` | `VM.Standard.E4.Flex` |
| `FlexShapeOCPUS` | Número de CPUs | `1` | `2` |
| `FlexShapeMemory` | Memoria en GB | `6` | `8` |
| `lb_shape` | Shape del Load Balancer | `flexible` | `100Mbps` |
| `flex_lb_min_shape` | Ancho de banda mínimo | `10` | `100` |
| `flex_lb_max_shape` | Ancho de banda máximo | `100` | `1000` |

### ⚙️ Ejemplo de Personalización

```hcl
# terraform.tfvars
VCN-CIDR = "192.168.0.0/16"
Subnet-CIDR = "192.168.1.0/24"
ComputeCount = 4
Shape = "VM.Standard.E4.Flex"
FlexShapeOCPUS = 2
FlexShapeMemory = 8
lb_shape = "flexible"
flex_lb_min_shape = 100
flex_lb_max_shape = 1000
```

---

## 🔍 Monitoreo y Diagnóstico

### 📊 Health Checks del Load Balancer

Verificar el estado de los backends:

```bash
# Ver estado de health checks
curl -I http://[LOAD_BALANCER_IP]

# Verificar backend individual
curl http://[WEBSERVER_IP]

# Monitorear logs de Apache en servidor
ssh -i id_rsa_enterprise ubuntu@[WEBSERVER_IP]
sudo tail -f /var/log/apache2/access.log
```

### 🔧 Comandos de Diagnóstico

```bash
# Verificar el plan sin aplicar
terraform plan

# Mostrar el estado actual
terraform show

# Ver las salidas incluyendo IPs
terraform output

# Verificar distribución de carga
for i in {1..20}; do 
  echo "Request $i: $(curl -s http://[LOAD_BALANCER_IP] | grep -o 'EnterpriseWebServer[0-9]')"
done

# Verificar conectividad individual
terraform output -json EnterpriseWebserver_Public_IPs_Formatted | jq -r '.[]' | while read ip; do
  echo "Testing $ip: $(curl -s -o /dev/null -w "%{http_code}" http://$ip)"
done
```

---

## 🆘 Solución de Problemas

### ❌ Problemas Comunes

<details>
<summary>⚖️ <strong>Load Balancer No Responde</strong></summary>

**Problema**: `curl: (7) Failed to connect to [LB_IP] port 80`

**Solución**:
1. Verifica que el Load Balancer esté en estado "ACTIVE": `terraform output`
2. Comprueba que los backends estén "HEALTHY" en la consola OCI
3. Verifica Security Lists: puerto 80 debe estar abierto
4. Asegúrate de que Apache esté corriendo en todos los servidores

</details>

<details>
<summary>💔 <strong>Backends Marcados como Unhealthy</strong></summary>

**Problema**: Health checks fallan en la consola OCI

**Solución**:
1. Verifica que Apache esté corriendo: `ssh -i id_rsa_enterprise ubuntu@[SERVER_IP] "sudo systemctl status apache2"`
2. Comprueba que el puerto 80 esté abierto: `telnet [SERVER_IP] 80`
3. Revisa iptables: `ssh -i id_rsa_enterprise ubuntu@[SERVER_IP] "sudo iptables -L"`
4. Verifica la página web: `curl http://[SERVER_IP]`

</details>

<details>
<summary>🔄 <strong>Distribución de Carga Desigual</strong></summary>

**Problema**: Un servidor recibe más tráfico que otros

**Solución**:
1. El algoritmo Round Robin puede parecer desigual con pocos requests
2. Haz múltiples requests para ver la distribución: `for i in {1..50}; do curl -s http://[LB_IP]; done`
3. Verifica que todos los backends estén "HEALTHY"
4. Revisa la configuración del backend set en la consola OCI

</details>

---

## 📚 Recursos Adicionales

### 📖 Documentación

- [OCI Load Balancer Documentation](https://docs.oracle.com/en-us/iaas/Content/Balance/Concepts/balanceoverview.htm)
- [Terraform OCI Load Balancer Resources](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/load_balancer)
- [Load Balancer Best Practices](https://docs.oracle.com/en-us/iaas/Content/Balance/Reference/bestpractices.htm)

### 🎓 Próximos Pasos

Después de dominar esta arquitectura, continúa con:

1. **Arquitectura 4**: NAT Gateway y host bastión para mayor seguridad
2. **Arquitectura 5**: File Storage Service (FSS) compartido
3. **Arquitectura 6**: Block volumes para almacenamiento persistente

---

## 🤝 Contribución

Este proyecto es de código abierto. ¡Envía tus contribuciones haciendo fork del repositorio y enviando un pull request!

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