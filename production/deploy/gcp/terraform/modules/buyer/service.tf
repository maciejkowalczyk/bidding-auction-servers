/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

################ Common Setup ################

module "networking" {
  source                 = "../../services/networking"
  frontend_service       = "bfe"
  operator               = var.operator
  environment            = var.environment
  regions                = var.regions
  collector_service_name = "collector"
}

module "security" {
  source                 = "../../services/security"
  network_id             = module.networking.network_id
  subnets                = module.networking.subnets
  operator               = var.operator
  environment            = var.environment
  collector_service_port = var.collector_service_port
}

module "autoscaling" {
  source                             = "../../services/autoscaling"
  vpc_id                             = module.networking.network_id
  subnets                            = module.networking.subnets
  mesh_name                          = module.networking.mesh.name
  service_account_email              = var.service_account_email
  environment                        = var.environment
  operator                           = var.operator
  backend_tee_image                  = var.bidding_image
  backend_service_port               = tonumber(var.runtime_flags["BIDDING_PORT"])
  backend_service_name               = "bidding"
  frontend_tee_image                 = var.buyer_frontend_image
  frontend_service_port              = tonumber(var.runtime_flags["BUYER_FRONTEND_PORT"])
  frontend_service_name              = "bfe"
  collector_service_name             = "collector"
  collector_service_port             = var.collector_service_port
  frontend_machine_type              = var.bfe_machine_type
  backend_machine_type               = var.bidding_machine_type
  collector_machine_type             = var.collector_machine_type
  min_replicas_per_service_region    = var.min_replicas_per_service_region
  max_replicas_per_service_region    = var.max_replicas_per_service_region
  vm_startup_delay_seconds           = var.vm_startup_delay_seconds
  cpu_utilization_percent            = var.cpu_utilization_percent
  use_confidential_space_debug_image = var.use_confidential_space_debug_image
  tee_impersonate_service_accounts   = var.tee_impersonate_service_accounts

  runtime_flags                      = var.runtime_flags
}

module "load_balancing" {
  source                             = "../../services/load_balancing"
  environment                        = var.environment
  operator                           = var.operator
  gcp_project_id                     = var.gcp_project_id
  mesh                               = module.networking.mesh
  frontend_ip_address                = module.networking.frontend_address
  frontend_domain_name               = var.frontend_domain_name
  frontend_dns_zone                  = var.frontend_dns_zone
  frontend_domain_ssl_certificate_id = var.frontend_domain_ssl_certificate_id
  frontend_instance_groups           = module.autoscaling.frontend_instance_groups
  frontend_service_name              = "bfe"
  frontend_service_port              = tonumber(var.runtime_flags["BUYER_FRONTEND_PORT"])
  backend_instance_groups            = module.autoscaling.backend_instance_groups
  backend_service_name               = "bidding"
  backend_address                    = var.runtime_flags["BIDDING_SERVER_ADDR"]
  backend_service_port               = tonumber(var.runtime_flags["BIDDING_PORT"])
  collector_ip_address               = module.networking.collector_address
  collector_instance_groups          = module.autoscaling.collector_instance_groups
  collector_service_name             = "collector"
  collector_service_port             = var.collector_service_port
}

module "buyer_dashboard" {
  source      = "../../services/dashboards/buyer_dashboard"
  environment = var.environment
}

resource "google_secret_manager_secret" "runtime_flag_secrets" {
  for_each = var.runtime_flags

  secret_id = "${var.operator}-${var.environment}-${each.key}"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "runtime_flag_secret_values" {
  for_each = google_secret_manager_secret.runtime_flag_secrets

  secret      = each.value.id
  secret_data = var.runtime_flags[split("${var.operator}-${var.environment}-", each.value.id)[1]]
}
