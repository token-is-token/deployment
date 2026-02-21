variable "prometheus_version" {
  description = "Prometheus Helm chart version"
  type        = string
  default     = "25.8.0"
}

variable "grafana_version" {
  description = "Grafana Helm chart version"
  type        = string
  default     = "6.58.9"
}

variable "metrics_server_version" {
  description = "Metrics Server Helm chart version"
  type        = string
  default     = "3.12.0"
}

variable "ingress_nginx_version" {
  description = "Ingress NGINX Helm chart version"
  type        = string
  default     = "4.8.3"
}

variable "prometheus_config" {
  description = "Prometheus configuration"
  type        = string
  default     = <<-EOT
    global:
      scrape_interval: 15s
    scrape_configs:
      - job_name: 'kubernetes-nodes'
        kubernetes_sd_configs:
          - role: node
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
          - role: pod
      - job_name: 'kubernetes-services'
        kubernetes_sd_configs:
          - role: service
  EOT
}

variable "grafana_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
  default     = ""
}
