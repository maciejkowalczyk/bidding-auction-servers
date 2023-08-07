/**
 * Copyright 2023 Google LLC
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

###############################################################
#
#                         FRONTEND
#
# The frontend service uses HTTP/2 (gRPC) with TLS.
###############################################################

resource "google_compute_instance_template" "frontends" {
  for_each = var.subnets

  region      = each.value.region
  name        = "${var.operator}-${var.environment}-${var.frontend_service_name}-${each.value.region}-it-${substr(replace(uuid(), "/-/", ""), 0, 8)}"
  provider    = google-beta
  description = "This template is used to create confidential compute instances, one service per instance."
  tags        = ["allow-hc", "allow-ssh", "allow-all-egress"]

  disk {
    auto_delete = true
    boot        = true
    device_name = "persistent-disk-0"
    disk_type   = "pd-standard"
    interface   = "NVME"
    mode        = "READ_WRITE"
    type        = "PERSISTENT"

    source_image = "projects/confidential-space-images/global/images/family/${var.use_confidential_space_debug_image ? "confidential-space-debug" : "confidential-space"}"
  }

  labels = {
    environment = var.environment
    operator    = var.operator
    service     = var.frontend_service_name
  }
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "TERMINATE"
    provisioning_model  = "STANDARD"
  }
  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = true
    enable_vtpm                 = true
  }
  confidential_instance_config {
    enable_confidential_compute = true
  }

  can_ip_forward = false
  enable_display = false

  network_interface {
    network    = var.vpc_id
    subnetwork = each.value.id

    # Uncomment below to give instances external IPs:
    # access_config {
    #   network_tier = "PREMIUM"
    # }
  }

  machine_type = var.frontend_machine_type

  service_account {
    email  = var.service_account_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
  metadata = {
    tee-image-reference              = var.frontend_tee_image
    tee-container-log-redirect       = true
    tee-impersonate-service-accounts = var.tee_impersonate_service_accounts
    mesh-name                        = var.mesh_name
    environment                      = var.environment
    operator                         = var.operator
    service                          = var.frontend_service_name
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [ name ]
  }
}

resource "google_compute_region_instance_group_manager" "frontends" {
  for_each = google_compute_instance_template.frontends

  region = each.value.region
  name   = "${var.operator}-${var.environment}-${var.frontend_service_name}-${each.value.region}-mig"
  version {
    instance_template = each.value.id
    name              = "primary"
  }

  named_port {
    name = "grpc"
    port = var.frontend_service_port
  }

  base_instance_name = "${var.frontend_service_name}-${var.environment}-${var.operator}"

  auto_healing_policies {
    health_check      = google_compute_health_check.frontend.id
    initial_delay_sec = var.vm_startup_delay_seconds
  }

  update_policy {
    minimal_action = "REPLACE"
    type = "PROACTIVE"
  }
  wait_for_instances_status = "UPDATED"
  wait_for_instances = true
  timeouts {
    create = "1h"
    delete = "1h"
    update = "1h"
  }
}

resource "google_compute_region_autoscaler" "frontends" {
  for_each = google_compute_region_instance_group_manager.frontends
  name     = "${var.operator}-${var.environment}-${var.frontend_service_name}-${each.value.region}-as"
  region   = each.value.region
  target   = each.value.id

  autoscaling_policy {
    max_replicas    = var.max_replicas_per_service_region
    min_replicas    = var.min_replicas_per_service_region
    cooldown_period = var.vm_startup_delay_seconds

    cpu_utilization {
      target = var.cpu_utilization_percent
    }
  }
}

resource "google_compute_health_check" "frontend" {
  name = "${var.operator}-${var.environment}-${var.frontend_service_name}-auto-heal-hc"
  # gpc_health_check does not support TLS
  # Workaround: use tcp
  # Details: https://cloud.google.com/load-balancing/docs/health-checks#optional-flags-hc-protocol-grpc
  tcp_health_check {
    port_name = "grpc"
    port      = var.frontend_service_port
  }

  timeout_sec         = 30
  check_interval_sec  = 30
  healthy_threshold   = 1
  unhealthy_threshold = 2

  log_config {
    enable = true
  }
}

###############################################################
#
#                         BACKEND
#
# The backend service uses HTTP/2 (gRPC) with no TLS.
###############################################################


resource "google_compute_instance_template" "backends" {
  for_each = var.subnets

  region      = each.value.region
  name        = "${var.operator}-${var.environment}-${var.backend_service_name}-${each.value.region}-it-${substr(replace(uuid(), "/-/", ""), 0, 8)}"
  provider    = google-beta
  description = "This template is used to create confidential compute instances, one service per instance."
  tags        = ["allow-hc", "allow-ssh", "allow-backend-ingress", "allow-all-egress"]

  disk {
    auto_delete  = true
    boot         = true
    device_name  = "persistent-disk-0"
    disk_type    = "pd-standard"
    interface    = "NVME"
    mode         = "READ_WRITE"
    source_image = "projects/confidential-space-images/global/images/family/${var.use_confidential_space_debug_image ? "confidential-space-debug" : "confidential-space"}"
    type         = "PERSISTENT"
  }

  labels = {
    environment = var.environment
    operator    = var.operator
    service     = var.backend_service_name
  }
  scheduling {
    automatic_restart   = true
    on_host_maintenance = "TERMINATE"
    provisioning_model  = "STANDARD"
  }
  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = true
    enable_vtpm                 = true
  }
  confidential_instance_config {
    enable_confidential_compute = true
  }

  can_ip_forward = false
  enable_display = false

  network_interface {
    network    = var.vpc_id
    subnetwork = each.value.id

    # Uncomment below to give instances external IPs:
    # access_config {
    #   network_tier = "PREMIUM"
    # }
  }

  machine_type = var.backend_machine_type

  service_account {
    email  = var.service_account_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
  metadata = {
    tee-image-reference              = var.backend_tee_image
    tee-container-log-redirect       = true
    tee-impersonate-service-accounts = var.tee_impersonate_service_accounts
    operator                         = var.operator
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [ name ]
  }
}

resource "google_compute_region_instance_group_manager" "backends" {
  for_each = google_compute_instance_template.backends

  region = each.value.region
  name   = "${var.operator}-${var.environment}-${var.backend_service_name}-${each.value.region}-mig"
  version {
    instance_template = each.value.id
    name              = "primary"
  }

  named_port {
    name = "grpc"
    port = var.backend_service_port
  }

  base_instance_name = "${var.backend_service_name}-${var.environment}-${var.operator}"

  auto_healing_policies {
    health_check      = google_compute_health_check.backend.id
    initial_delay_sec = var.vm_startup_delay_seconds
  }

  update_policy {
    minimal_action = "REPLACE"
    type = "PROACTIVE"
  }
  wait_for_instances_status = "UPDATED"
  wait_for_instances = true
  timeouts {
    create = "1h"
    delete = "1h"
    update = "1h"
  }
}

resource "google_compute_region_autoscaler" "backends" {
  for_each = google_compute_region_instance_group_manager.backends
  name     = "${var.operator}-${var.environment}-${var.backend_service_name}-${each.value.region}-as"
  region   = each.value.region
  target   = each.value.id

  autoscaling_policy {
    max_replicas    = var.max_replicas_per_service_region
    min_replicas    = var.min_replicas_per_service_region
    cooldown_period = var.vm_startup_delay_seconds

    cpu_utilization {
      target = var.cpu_utilization_percent
    }
  }
}

resource "google_compute_health_check" "backend" {
  name = "${var.operator}-${var.environment}-${var.backend_service_name}-auto-heal-hc"
  grpc_health_check {
    port_name = "grpc"
    port      = var.backend_service_port
  }

  log_config {
    enable = true
  }
}

#################################################################
#
#                         Collector
#
# The collector receives and forwards gRPC OpenTelemetry traffic.
#################################################################

resource "google_compute_instance_template" "collector" {
  for_each = var.subnets

  region      = each.value.region
  name        = "${var.operator}-${var.environment}-${var.collector_service_name}-${each.value.region}-it-${substr(replace(uuid(), "/-/", ""), 0, 8)}"
  provider    = google-beta
  description = "This template is used to create an opentelemetry collector for the region."
  tags        = ["allow-otlp", "allow-hc", "allow-all-egress", ]

  disk {
    auto_delete  = true
    boot         = true
    device_name  = "persistent-disk-0"
    disk_type    = "pd-standard"
    mode         = "READ_WRITE"
    source_image = "debian-cloud/debian-11"
    type         = "PERSISTENT"
  }

  labels = {
    environment = var.environment
    operator    = var.operator
    service     = var.collector_service_name
  }

  network_interface {
    network    = var.vpc_id
    subnetwork = each.value.id


    # Uncomment below to give instances external IPs:
    # access_config {
    #   network_tier = "PREMIUM"
    # }
  }

  machine_type = var.collector_machine_type

  service_account {
    email  = var.service_account_email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
  metadata = {
    operator = var.operator
    startup-script = templatefile("${path.module}/collector_startup.sh", {
      collector_port = var.collector_service_port,
    })
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [ name ]
  }
}

resource "google_compute_region_instance_group_manager" "collector" {
  for_each = google_compute_instance_template.collector

  region = each.value.region
  name   = "${var.operator}-${var.environment}-collector-${each.value.region}-mig"
  version {
    instance_template = each.value.id
    name              = "primary"
  }

  named_port {
    name = "otlp"
    port = var.collector_service_port
  }

  base_instance_name = "${var.collector_service_name}-${var.environment}-${var.operator}"

  auto_healing_policies {
    health_check      = google_compute_health_check.collector.id
    initial_delay_sec = var.vm_startup_delay_seconds
  }

  update_policy {
    minimal_action = "REPLACE"
    type = "PROACTIVE"
  }
  wait_for_instances_status = "UPDATED"
  wait_for_instances = true
  timeouts {
    create = "1h"
    delete = "1h"
    update = "1h"
  }
}

resource "google_compute_region_autoscaler" "collector" {
  for_each = google_compute_region_instance_group_manager.collector
  name     = "${var.operator}-${var.environment}-${var.collector_service_name}-${each.value.region}-as"
  region   = each.value.region
  target   = each.value.id

  autoscaling_policy {
    max_replicas    = var.max_collectors_per_region
    min_replicas    = 1
    cooldown_period = var.vm_startup_delay_seconds

    cpu_utilization {
      target = var.cpu_utilization_percent
    }
  }
}


resource "google_compute_health_check" "collector" {
  name = "${var.operator}-${var.environment}-${var.collector_service_name}-auto-heal-hc"

  tcp_health_check {
    port_name = "otlp"
    port      = var.collector_service_port
  }

  timeout_sec         = 3
  check_interval_sec  = 3
  healthy_threshold   = 2
  unhealthy_threshold = 4

  log_config {
    enable = true
  }
}
