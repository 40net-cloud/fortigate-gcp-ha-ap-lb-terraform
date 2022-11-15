resource "google_compute_address" "elb_eip" {
  name = "fgt-example-eip-${var.region_short}"
  region = var.region
}

resource "google_compute_forwarding_rule" "elb_frule" {
  name = "fgt-example-fwdrule-${var.region_short}"
  region = var.region
  ip_address = google_compute_address.elb_eip.self_link
  ip_protocol = "L3_DEFAULT"
  all_ports = true
  load_balancing_scheme = "EXTERNAL"
  backend_service = module.fgt_ha.elb_bes
}

output elb_frontend_ip {
  value = google_compute_address.elb_eip.address
}
