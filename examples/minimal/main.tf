module "fgt_ha" {
  source        = "git::github.com/40net-cloud/fortigate-gcp-ha-ap-lb-terraform?ref=v1.0.0"

  region        = "us-central1"
  subnets       = [ "external", "internal", "hasync", "mgmt" ]
}
