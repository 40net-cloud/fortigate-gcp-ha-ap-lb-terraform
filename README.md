# FortiGate Terraform module:
## HA Active-Passive cluster (FGCP in load balancer sandwich)

This terraform module can be used to deploy the base part of FortiGate reference architecture consisting of:
- 2 FortiGate VM instances - preconfigured in FGCP Active-Passive cluster
- zonal instance groups to be used later as components of backend services
- internal load balancer resources in trusted (internal) network
- backend service in external network (load balancer without frontends)
- cloud firewall rules opening ALL communication on untrusted and trusted networks
- cloud firewall rules allowing cluster sync and administrative access
- static external IP addresses for management bound to nic3 (port4) of FortiGates
- Cloud NAT to allow traffic initiated by FGTs out

> NOTE: This module currently does NOT create frontends (forwarding rules) for the External Load Balancer

### How to use this module
We assume you have a working root module with proper Google provider configuration. If you don't - start by reading [Google Provider Configuration Reference](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference).

1. Create upfront or in your root terraform module 4 VPC networks with one subnet in each. All subnets must be in the region where you want to deploy FortiGates and their CIDRs cannot overlap
1. Copy license files (*.lic) to the root module folder if you plan to deploy BYOL version. If using BYOL version you also have to change the `image_family` or `image_name` variable
1. Reference this module in your code (eg. main.tf) to use it, eg.:
        module "fgt-ha" {  
          source = "git::github.com/40net-cloud/fortigate-gcp-ha-ap-lb-terraform"  
        }
1. In the above module block provide the variables described in `variables.tf`. Only 1 variable is obligatory (`subnets`), but you might want to provide values also to some others:
    - `region` - name of the region to deploy to (zones will be selected automatically). Defaults to **europe-west1**
    - `zones` - list of 2 zones for FortiGate VMs. Always match these to your production workloads to avoid inter-zone traffic fees. You can skip for proof-of-concept deployments and let the module automatically detect zones in the region.
    - `license_files` - list of paths to 2 license (.lic) files to be applied to the FortiGates. If skipped, VMs will be deployed without license and you will have to apply them manually upon first connection. It is highly recommended to apply BYOL licenses during deployment.
    - `subnets` - list of 4 names of subnets already existing in the region to be used as external, internal, heartbeat and management networks.
    - `prefix` - prefix to be added to the names of all created resources (defaults to "**fgt**")
    - `machine-type` - type of VM to use for deployment. Defaults to **e2-standard-4** which is a good (cheaper) choice for evaluation, but offers lower performance than n2 or c2 families.
    - `image_family` or `image_name` - for selecting different firmware version or different licensing model. Defaults to newest 7.0 image with PAYG licensing (fortigate-70-payg)
1. Run the deployment using the tool of your choice (eg. `terraform init; terraform apply` from command line)

Examples can be found in [examples](examples) directory.

#### Licensing
FortiGates in GCP can be licensed in 3 ways:
1. PAYG - paid per each hour of use via Google Cloud Marketplace after you deploy. This is the default setting for this module and you don't need to change anything to use it.
2. BYOL - pay upfront via Fortinet Reseller. You will receive the license activation code, which needs to be registered in [Fortinet Support Portal](https://support.fortinet.com). After activation you will receive **.lic** license files which you need to add to your terraform deployment code and reference using `license_files` input variable. You will also need to change the `image_family` or `image_name` variable to a byol image.
3. FlexVM (EA) - if you have an Enterprise Agreement with Fortinet and use FlexVM portal, you will have to change the deployed image to BYOL and apply the Flex activation code using FortiGate CLI after deployment. Provisioning of FlexVM during bootstrapping is not yet supported in GCP.

### Customizations
1. add your configuration to fgt-base-config.tpl to have it applied during provisioning
1. all addresses are static but picked automatically from the pool of available addresses for a given subnet. modify addresses.tf to manually indicate addresses you want to assign.
1. Change bootdisk image referenced in `google_compute_instance.fgt-vm` block in [main.tf](main.tf) to explicit image URL if you want to use your private custom FortiGate image. Note that this module will NOT automatically detect use of MULTI_IP_SUBNET feature if your image uses it.
1. Uncomment references to Google Secret Manager at the end of main.tf file to save FortiGate API token to the secret manager.
