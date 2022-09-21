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

### How to use this module
1. Clone or download this GitHub repository and copy this module directory to your terraform source code
1. Create upfront or in your root terraform module 4 VPC networks with one subnet in each. All subnets must be in the region where you want to deploy FortiGates and their CIDRs cannot overlap
1. Copy license files (*.lic) to the root module folder if you plan to deploy BYOL version. If using BYOL version you also have to change the `image_family` or `image_name` variable
1. Prepare your root module to reference this module, eg.:
    module "fgt-ha" {  
      source = "./fgcp-ha-ap-lb"  
    }
1. In the above module block provide the variables described in `variables.tf`. Only 1 variable is obligatory (`subnets`), but you might want to provide values also to some others:
    - `region` - name of the region to deploy to (zones will be selected automatically). Defaults to **europe-west1**
    - `zones` - list of 2 zones for FortiGate VMs. Always match these to your production workloads to avoid inter-zone traffic fees. You can skip for proof-of-concept deployments and let the module automatically detect zones in the region.
    - `license_files` - list of paths to 2 license (.lic) files to be applied to the FortiGates. If skipped, VMs will be deployed without license and you will have to apply them manually upon first connection. It is highly recommended to apply BYOL licenses during deployment.
    - `subnets` - list of 4 names of subnets already existing in the region to be used as external, internal, heartbeat and management networks.
    - `prefix` - prefix to be added to the names of all created resources (defaults to "**fgt**")
    - `machine-type` - type of VM to use for deployment. Defaults to **e2-standard-4** which is a good (cheaper) choice for evaluation, but offers lower performance than n2 or c2 families.
    - `image_family` or `image_name` - for selecting different firmware version or different licensing model. Defaults to newest 7.0 image with PAYG licensing (fortigate-70-payg)
1. If not running from Cloud Shell - configure the google and google-beta providers. Consult [Google Provider Configuration Reference](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference) for details
1. Run the deployment using the tool of your choice (eg. `terraform init; terraform apply` from command line)

### Customizations
1. add your configuration to fgt-base-config.tpl to have it applied during provisioning
1. modify google_compute_disk.logdisk in main.tf to change logdisk parameters (by default 30GB pd-ssd)
1. all addresses are static but picked automatically from the pool of available addresses for a given subnet. modify addresses.tf to manually indicated addresses you want to assign.
1. Uncomment references to Google Secret Manager at the end of main.tf file to save FortiGate API token to the secret manager.
