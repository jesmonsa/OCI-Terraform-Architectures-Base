# LESSON7a - DataGuard Deployment Plan

## Architecture Overview
- **Evolution from LESSON7**: Same proven infrastructure + DataGuard in different AD
- **Primary DB**: AD-1 (us-ashburn-1-AD-1)
- **Standby DB**: AD-2 (us-ashburn-1-AD-2) via DataGuard Association
- **No NSGs**: Only Security Lists (proven approach)
- **Shared Storage**: FSS with fixed NFS v3 configuration

## Key Improvements from LESSON7
1. **FSS Fixed**: NFS v3 forced, repos disabled, systemd daemon-reload
2. **Simple DataGuard**: Using oci_database_data_guard_association only
3. **Clean Security**: VCN-wide TCP + specific DataGuard ports (7000-7999)
4. **Proven Remote-exec**: Same working pattern from LESSON7

## Deployment Timeline
1. **Infrastructure** (5-10 min): VCN, Subnets, Security Lists, Compute
2. **Primary DB System** (90-120 min): Database creation in AD-1
3. **DataGuard Setup** (30-45 min): Standby creation in AD-2
4. **Software Provisioning** (10-15 min): HTTPD + FSS setup
5. **Total**: ~2.5-3 hours

## DataGuard Configuration
- **Protection Mode**: MAXIMUM_PERFORMANCE
- **Transport Type**: ASYNC
- **Creation Type**: NewDbSystem (automatic standby creation)
- **Communication**: Ports 7000-7999 within VCN

## Key Files
- `dbsystem.tf`: Primary DB + DataGuard Association
- `network.tf`: Security Lists with DataGuard ports
- `remote.tf`: Fixed FSS setup from LESSON7 experience
- `outputs.tf`: DataGuard info and status

## Post-Deployment Verification
```bash
# Check outputs
terraform output

# Verify FSS
curl http://$(terraform output -raw FoggyKitchenLoadBalancer_Public_IP)/shared/

# Check DataGuard status in OCI Console
# Database > Data Guard Associations
```

## Ready for Deployment
All configurations tested and verified based on successful LESSON7 experience.