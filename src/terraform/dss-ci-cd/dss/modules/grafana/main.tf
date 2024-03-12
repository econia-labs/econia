locals {
  api_base_url = "${google_cloud_run_v2_service.grafana.uri}/api"
  # Do not use a space in this name, since the destroy-time provisioner
  # for the data source depends on a URL encode function that uses `+`
  # instead of `%20`, which the relevant API relies on.
  data_source_name = "DSS"
  # SQL migrations define read-only role,
  # compromised password okay for private networking
  grafana_role_pw       = "grafana"
  mock_public_email     = "public@public.com"
  startup_delay_seconds = 120
}

resource "google_cloud_run_v2_service" "grafana" {
  depends_on = [var.migrations_complete]
  location   = var.region
  name       = "grafana"
  template {
    containers {
      image = "grafana/grafana-enterprise"
      env {
        name  = "GF_DATABASE_TYPE"
        value = "postgres"
      }
      env {
        name  = "GF_DATABASE_URL"
        value = var.db_conn_str_private_grafana
      }
      env {
        name  = "GF_SECURITY_ADMIN_PASSWORD"
        value = var.grafana_admin_password
      }
      ports {
        container_port = 3000
      }
    }
    scaling {
      min_instance_count = 1
      max_instance_count = 1
    }
    vpc_access {
      connector = var.sql_vpc_connector_id
      egress    = "ALL_TRAFFIC"
    }

  }
  ingress = "INGRESS_TRAFFIC_ALL"
}

# After Grafana starts, wait until HTTP API is available.
resource "terraform_data" "startup_delay" {
  depends_on = [google_cloud_run_v2_service.grafana]
  provisioner "local-exec" {
    command = "sleep ${local.startup_delay_seconds}"
  }
}

resource "terraform_data" "data_source" {
  depends_on = [terraform_data.startup_delay]
  input = {
    delete_url = join("", [
      "${local.api_base_url}/datasources/name/",
      urlencode(local.data_source_name)
    ])
    admin_password = var.grafana_admin_password
  }
  provisioner "local-exec" {
    command = join(" ", [
      "curl -X 'POST'",
      "${local.api_base_url}/datasources",
      "-H 'accept: application/json'",
      "-H 'Content-Type: application/json'",
      "--user admin:${var.grafana_admin_password}",
      "-d",
      join("", [
        "'",
        jsonencode({
          access    = "proxy"
          isDefault = true
          jsonData = {
            database        = "econia"
            sslmode         = "disable"
            postgresVersion = 1400
          }
          secureJsonData = {
            password = local.grafana_role_pw
          }
          name = local.data_source_name
          type = "postgres"
          url  = var.db_private_ip_and_port
          user = "grafana"
        }),
        "'"
      ])
    ])
  }
  provisioner "local-exec" {
    command = join(" ", [
      "curl -X 'DELETE'",
      self.output.delete_url,
      "-H 'accept: application/json'",
      "--user admin:${self.output.admin_password}",
    ])
    when = destroy
  }
}

resource "terraform_data" "public_user" {
  depends_on = [terraform_data.startup_delay]
  input = {
    admin_password = var.grafana_admin_password
    api_base_url   = local.api_base_url
    email          = urlencode(local.mock_public_email)
  }
  provisioner "local-exec" {
    command = join(" ", [
      "curl -X 'POST'",
      "${local.api_base_url}/admin/users",
      "-H 'accept: application/json'",
      "-H 'Content-Type: application/json'",
      "--user admin:${var.grafana_admin_password}",
      "-d",
      join("", [
        "'",
        jsonencode({
          email    = local.mock_public_email
          login    = "public"
          password = var.grafana_public_password
        }),
        "'"
      ])
    ])
  }
  provisioner "local-exec" {
    command = join(" && ", [
      # Lookup user ID from email.
      join("", [
        "USER_ID=$(",
        join(" ", [
          "curl -X 'GET'",
          join("", [
            "${self.output.api_base_url}/users/lookup?loginOrEmail=",
            self.output.email
          ]),
          "-H 'accept: application/json'",
          "--user admin:${self.output.admin_password}",
          "| jq -r '.id'"
        ]),
        ")"
      ]),
      # Delete specified user ID.
      join(" ", [
        "curl -X 'DELETE'",
        "${self.output.api_base_url}/admin/users/$USER_ID",
        "-H 'accept: application/json'",
        "--user admin:${self.output.admin_password}",
      ])
    ])
    when = destroy
  }
}

resource "google_cloud_run_service_iam_policy" "no_auth_grafana" {
  location    = google_cloud_run_v2_service.grafana.location
  project     = google_cloud_run_v2_service.grafana.project
  service     = google_cloud_run_v2_service.grafana.name
  policy_data = var.no_auth_policy_data
}
