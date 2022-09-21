module "fgt_ha" {
  source        = "git::github.com/40net-cloud/fortigate-gcp-ha-ap-lb-terraform"

  prefix        = "fgt-example-byol"
  license_files = ["dummy_lic1.lic", "dummy_lic2.lic"]
  image_family  = "fortigate-70-byol"
  subnets       = [ var.subnet_external, var.subnet_internal, var.subnet_hasync, var.subnet_mgmt]
}
