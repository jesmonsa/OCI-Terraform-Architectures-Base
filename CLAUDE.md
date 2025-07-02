# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FoggyKitchen Terraform/OpenTofu OCI Course is an educational repository providing 14 progressive lessons for Oracle Cloud Infrastructure (OCI) deployment using Infrastructure as Code. The course teaches OCI resource deployment from basic single webserver setups to complex multi-region configurations with DataGuard.

## Commands

### Terraform/OpenTofu Operations
```bash
# Initialize (run from any lesson directory)
terraform init
# or
tofu init

# Plan deployment
terraform plan
# or 
tofu plan

# Deploy infrastructure
terraform apply
# or
tofu apply

# Destroy resources
terraform destroy
# or
tofu destroy
```

### Environment Setup
```bash
# Copy and configure authentication (run in lesson directory)
cp setup_oci_tf_vars.sh.example setup_oci_tf_vars.sh
# Edit setup_oci_tf_vars.sh with your OCI credentials
source setup_oci_tf_vars.sh

# Alternative: use terraform.tfvars
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your credentials
```

### Block Volume Operations (LESSON6+)
```bash
# For lessons with block volumes, use the included iSCSI attachment script
sudo ./iscsiattach.sh
```

### Validation and Troubleshooting (LESSON7a+)
```bash
# Validate deployment (where available)
./validate_deployment.sh

# Troubleshoot webserver issues (where available)
./troubleshoot_webservers.sh

# Manual FSS fix (where available)
./fix_fss_manually.sh
```

### Initial OCI Setup
```bash
# Use the SETUP_TF_4_OCI directory for initial OCI configuration
cd SETUP_TF_4_OCI
cp setup_oci_tf_vars.sh.example setup_oci_tf_vars.sh
cp terraform.tfvars.example terraform.tfvars
# Edit configuration files with your OCI credentials
```

## Architecture Overview

### Lesson Structure
Each lesson (LESSON1-LESSON9a) is a self-contained Terraform/OpenTofu project with:
- **Standard files**: `provider.tf`, `variables.tf`, `datasources.tf`, `locals.tf`, `outputs.tf`
- **Core infrastructure**: `compartment.tf`, `network.tf`, `compute.tf`, `tls.tf`
- **Advanced components** (later lessons): `loadbalancer.tf`, `nsgs.tf`, `fss.tf`, `block_volume.tf`, `dbsystem.tf`
- **Configuration templates**: `terraform.tfvars.example`, `setup_oci_tf_vars.sh.example`
- **Oracle Resource Manager**: `schema.yaml` for OCI console deployment

### Progressive Complexity Model
1. **LESSON1-2**: Basic compute instances across ADs/FDs
2. **LESSON3**: Load balancer introduction
3. **LESSON4-4a**: Private subnets, NAT Gateway, bastion hosts, Network Security Groups
4. **LESSON5-5a**: File Storage Service (FSS) and shared filesystems
5. **LESSON6**: Block volume storage
6. **LESSON7-7a**: DBSystem with DataGuard across ADs/regions
7. **LESSON8**: VCN local peering
8. **LESSON9-9a**: Cross-region VCN remote peering with DRGs/RPCs

### Key Architecture Patterns

**Provider Configuration**:
- Dual/triple provider setup: region1, region2 (for multi-region), and homeregion (for identity operations)
- Provider aliases used extensively: `provider.region1`, `provider.region2`, `provider.homeregion`
- Required versions: Terraform >= 0.15.0, OCI provider >= 6.21.0
- Supports both Terraform and OpenTofu

**Authentication Methods**:
- Environment variables via `setup_oci_tf_vars.sh`
- Terraform variables via `terraform.tfvars`
- Oracle Resource Manager integration

**Network Architecture**:
- VCN with configurable CIDR (default: 10.0.0.0/16)
- Regional subnets spanning multiple ADs
- Security Lists vs Network Security Groups (NSGs) approaches
- Internet Gateway, NAT Gateway, Service Gateway patterns
- Cross-region connectivity via DRGs and Remote Peering Connections

**Security Patterns**:
- Progressive security model: public → private subnets → bastion hosts
- Two security approaches: Security Lists (subnet-level) vs NSGs (VNIC-level)
- TLS key generation for SSH access
- Validation rules for shapes, CIDR blocks, and regions

**Storage Integration**:
- Block volumes with iSCSI attachment
- File Storage Service (FSS) with NFS mounting
- Shared storage across multiple compute instances

**Database Integration**:
- OCI DBSystem deployment in private subnets
- DataGuard configuration for HA/DR
- Cross-region DataGuard via DRGs

## Development Guidelines

### Working with Lessons
- Each lesson directory is independent - navigate to specific lesson before running commands
- Always use `terraform init` when switching between lessons
- Environment variables or terraform.tfvars must be configured per lesson
- Lessons 9 and 9a require dual-region variables (region1/region2)

### Variable Validation
The codebase includes extensive validation rules:
- CIDR block format validation using regex patterns
- Compute shape compatibility checks with flexible shape detection
- Supported shapes: VM.Standard.E3.Flex, VM.Standard.E4.Flex, VM.Standard.A1.Flex, VM.Optimized3.Flex
- Dynamic shape configuration based on flexible vs fixed shapes using `locals.tf` conditional logic

### Resource Naming Convention
Resources follow FoggyKitchen prefix pattern:
- `FoggyKitchenVCN`, `FoggyKitchenCompartment`
- `FoggyKitchenWebserver1`, `FoggyKitchenWebserver2`
- `FoggyKitchenPublicLoadBalancer`, `FoggyKitchenBastionServer`

### Multi-Region Support
Lessons 9 and 9a support cross-region deployment:
- Primary region: configured via `region`/`region1`
- Secondary region: configured via `region2`
- DRG and RPC resources for inter-region connectivity

## Key Files to Understand

### Core Infrastructure Files (Present in ALL lessons)
- `provider.tf` - OCI provider configuration with dual-region support
- `variables.tf` - Input variables with validation rules and descriptions
- `datasources.tf` - OCI data source queries (ADs, images, shapes)
- `locals.tf` - Computed local values and logic
- `network.tf` - VCN, subnets, gateways, security lists, route tables
- `compute.tf` - VM instances with flexible shapes
- `compartment.tf` - OCI compartment resources
- `tls.tf` - TLS key generation for SSH access
- `remote.tf` - Null provider resources for software provisioning
- `outputs.tf` - Output values for resource attributes

### Configuration Templates (Present in ALL lessons)
- `terraform.tfvars.example` - Example variable values
- `setup_oci_tf_vars.sh.example` - Environment variable setup script
- `schema.yaml` - Oracle Resource Manager integration schema
- `README.md` - Lesson-specific documentation

### Progressive Feature Files (Added as lessons advance)
- `loadbalancer.tf` - Load balancer configuration (LESSON3+)
- `nsgs.tf` - Network Security Groups (LESSON4a, 5a, 7a, 9a)
- `fss.tf` - File Storage Service (LESSON5+)
- `block_volume.tf` - Block storage (LESSON6+)
- `iscsiattach.sh` - iSCSI attachment script (LESSON6+)
- `dbsystem.tf` - Database system (LESSON7+)
- `lpgs.tf` - Local Peering Gateways (LESSON8)
- `drgs_rpcs.tf` - Dynamic Routing Gateways and Remote Peering (LESSON9+)

## Deployment Methods Supported

1. **Local Terraform/OpenTofu**: Direct CLI execution
2. **Environment Variables**: Using setup_oci_tf_vars.sh
3. **Oracle Resource Manager**: Cloud-native OCI console deployment

## Important Implementation Patterns

### Flexible Shape Handling
```hcl
locals {
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex", "VM.Standard.E4.Flex", 
    "VM.Standard.A1.Flex", "VM.Optimized3.Flex"
  ]
  is_flexible_shape = contains(local.compute_flexible_shapes, var.Shape)
}

# Dynamic shape_config block only for flexible shapes
dynamic "shape_config" {
  for_each = local.is_flexible_shape ? [1] : []
  content {
    memory_in_gbs = var.FlexShapeMemory
    ocpus = var.FlexShapeOCPUS
  }
}
```

### Multi-Region Resource Management
- Resources use provider aliases for cross-region deployment
- DRG and RPC resources require careful provider assignment
- Cross-region DataGuard uses region1/region2 provider pattern

### Security Progression Pattern
- **LESSON4**: Security Lists (subnet-level rules)
- **LESSON4a, 5a, 7a, 9a**: Network Security Groups (VNIC-level rules)
- NSGs provide granular security for webserver, bastion, loadbalancer, and FSS roles

## Troubleshooting and Validation

### Common Issues and Solutions
- **SSH connectivity**: All lessons include bastion host patterns for secure access to private resources
- **Service provisioning**: Uses null_resource with remote-exec for automated software installation
- **Database deployment**: DBSystem provisioning typically takes 60+ minutes
- **Cross-region connectivity**: DRG/RPC setup requires proper provider aliases and policy configurations

### Validation Scripts (LESSON7a+)
Some lessons include helper scripts for deployment validation and troubleshooting:
- `validate_deployment.sh` - Tests load balancer connectivity and backend health
- `troubleshoot_webservers.sh` - Diagnoses webserver configuration issues
- `fix_fss_manually.sh` - Manual File Storage Service configuration fixes