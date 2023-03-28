module "fgt_ha" {
  source        = "git::github.com/40net-cloud/fortigate-gcp-ha-ap-lb-terraform"

  region        = "us-central1"
  subnets       = [ "external", "internal", "hasync", "mgmt" ]

  flexvm_tokens = ["", ""] 
  image_family  = "fortigate-70-byol"
}
