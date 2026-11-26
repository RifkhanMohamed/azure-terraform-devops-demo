output "resource_group_name" {
  description = "Azure Resource Group"
  value       = azurerm_resource_group.main.name
}

output "acr_login_server" {
  description = "Azure Container Registry login server"
  value       = azurerm_container_registry.main.login_server
}

output "application_url" {
  description = "Public application URL"
  value = var.deploy_app ? (
    "https://${azurerm_container_app.main[0].ingress[0].fqdn}"
  ) : null
}