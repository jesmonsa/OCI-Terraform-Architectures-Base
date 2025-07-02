# ============================================
# PARÁMETROS OBLIGATORIOS - REEMPLAZA ESTOS VALORES
# ============================================
tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaat65hqrreghdbi2yitpss4otjwsnqt67wyx77chcwk4inw7xovyga"
user_ocid        = "ocid1.user.oc1..aaaaaaaam5ou5z2wn2imc3ft4723od5jwuau2lvylrg5czf5amthfcnamlva"
fingerprint      = "c5:1c:54:32:5e:88:c9:ea:f6:b5:eb:70:36:9a:8a:9e"
private_key_path = "/home/opc/.oci/oci_api_key.pem"
region           = "us-ashburn-1"
compartment_ocid = "ocid1.tenancy.oc1..aaaaaaaat65hqrreghdbi2yitpss4otjwsnqt67wyx77chcwk4inw7xovyga"

# ============================================
# CONFIGURACIÓN DE RED
# ============================================
VCN-CIDR            = "10.0.0.0/16"
PrivateSubnet-CIDR  = "10.0.1.0/24"
LBSubnet-CIDR       = "10.0.2.0/24"
BastionSubnet-CIDR  = "10.0.3.0/24"
DBSystemSubnet-CIDR = "10.0.4.0/24"
bastion_allowed_ip  = "0.0.0.0/0"  # Restringe esto a tu IP pública

# ============================================
# CONFIGURACIÓN DE COMPUTE
# ============================================
ComputeCount             = 3
WebserverShape           = "VM.Standard.E4.Flex"
WebserverFlexShapeOCPUS  = 1
WebserverFlexShapeMemory = 2
BastionShape             = "VM.Standard.E4.Flex"
BastionFlexShapeOCPUS    = 1
BastionFlexShapeMemory   = 2

# ============================================
# CONFIGURACIÓN DEL SISTEMA OPERATIVO
# ============================================
instance_os    = "Oracle Linux"
linux_os_version = "8"

# ============================================
# CONFIGURACIÓN DEL BALANCEADOR DE CARGA
# ============================================
lb_shape          = "flexible"
flex_lb_min_shape = 10
flex_lb_max_shape = 100

# ============================================
# CONFIGURACIÓN DE LA BASE DE DATOS
# ============================================
DBNodeCount         = 1
DBNodeShape         = "VM.Standard.E4.Flex"
DBStandbyNodeShape  = "VM.Standard.E4.Flex"
CPUCoreCount        = 1
DBEdition           = "ENTERPRISE_EDITION"
DBAdminPassword     = "BEstrO0ng_#11"  # Cambia esto por una contraseña segura
DBName              = "FOGGYDB"
DBVersion          = "19.25.0.0"
DBDisplayName      = "FoggyDB"
DBDataStorageSizeInGB = 256
DBDiskRedundancy    = "HIGH"
DBSystemDisplayName = "FoggyKitchenDBSystem"
DBNodeDomainName   = "FoggyKitchenN4.FoggyKitchenVCN.oraclevcn.com"
HostUserName       = "opc"
NCharacterSet      = "AL16UTF16"
CharacterSet       = "AL32UTF8"
DBWorkload        = "OLTP"
PDBName           = "FKPDB1"
DBLicenseModel     = "LICENSE_INCLUDED"
DBHomeDisplayName  = "FoggyDBHome"
DBStandbySystemDisplayName = "FoggyKitchenDBStandbySystem"
DBNodeHostName     = "foggydbpri"
DBStandbyNodeHostName = "foggydbstb"

# ============================================
# CONFIGURACIÓN DE PUERTOS
# ============================================
webservice_ports = [80, 443]
ssh_ports       = [22]
sqlnet_ports    = [1521]
