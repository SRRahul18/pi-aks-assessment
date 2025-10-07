resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${var.environment}-${var.prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  kubernetes_version  = "1.32.6"
  dns_prefix          = "aks-${var.environment}-${var.prefix}"
  workload_identity_enabled = true
  oidc_issuer_enabled = true
  role_based_access_control_enabled = true
  local_account_disabled = true
  automatic_channel_upgrade = "stable"

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  azure_active_directory_role_based_access_control {
    managed = true
    azure_rbac_enabled = true
    admin_group_object_ids = [var.admin_group_object_id]
    tenant_id = var.tenant_id
  }
  azure_policy_enabled = true
  image_cleaner_enabled = true

  default_node_pool {
    name                = "systempool"
    node_count          = 2
    vm_size             = "Standard_D2s_v3"
    vnet_subnet_id      = var.vnet_system_subnet_id
    max_pods            = 50
    only_critical_addons_enabled = true
    enable_host_encryption = true
    os_disk_type = "Ephemeral"
    node_labels = {
      "nodepool-type" = "system"
    }
    tags = {
      "pool" = "system"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  oms_agent {
    msi_auth_for_monitoring_enabled = true
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }
  
  workload_autoscaler_profile {
    keda_enabled = true
  }

  network_profile {
    network_plugin    = "azure"
    network_plugin_mode = "overlay"
    network_policy = "cilium"
    network_data_plane = "cilium"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
    service_cidr = "172.16.200.0/23"
    dns_service_ip = "172.16.200.10"
  }

  tags = {
    environment = "prod"
  }
}

# Additional User Node Pool (Worker Pool)
resource "azurerm_kubernetes_cluster_node_pool" "workerpool" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_D4s_v3"
  node_count            = 3
  max_pods              = 50
  vnet_subnet_id        = var.vnet_worker_subnet_id
  orchestrator_version  = azurerm_kubernetes_cluster.aks.kubernetes_version
  

  mode = "User" # ensures this pool is for workloads, not system

  node_labels = {
    "nodepool-type" = "user"
  }

  tags = {
    environment = "prod"
    pool        = "user"
  }
}