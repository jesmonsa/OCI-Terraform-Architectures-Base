# Backend configuration for OCI Object Storage
# Uncomment and configure the following lines to enable remote state management

# terraform {
#   backend "oci" {
#     bucket         = "tf-state-lesson7-enterprise"
#     namespace      = "<OBJECT_STORAGE_NAMESPACE>"
#     region         = "us-ashburn-1"  # Change to your region
#     prefix         = "terraform/lesson7/"
#     encryption_key = "<OCID_KMS_KEY>"  # Optional: KMS key for encryption
#   }
# }

# Instructions for setup:
# 1. Create an Object Storage bucket in OCI Console
# 2. Replace <OBJECT_STORAGE_NAMESPACE> with your tenancy namespace
# 3. Replace <OCID_KMS_KEY> with your KMS key OCID (optional)
# 4. Uncomment the terraform block above
# 5. Run: terraform init -migrate-state

# Benefits of remote state:
# - State locking to prevent concurrent modifications
# - Team collaboration with shared state
# - State versioning and backup
# - Encrypted state storage