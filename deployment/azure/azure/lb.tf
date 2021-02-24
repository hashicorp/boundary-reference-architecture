# Create a public IP address for the load balancer
# The domain label is based on the resource group name
resource "azurerm_public_ip" "boundary" {
  name                = local.pip_name
  resource_group_name = azurerm_resource_group.boundary.name
  location            = azurerm_resource_group.boundary.location
  allocation_method   = "Static"
  domain_name_label   = lower(azurerm_resource_group.boundary.name)
  sku                 = "Standard"
}

# Create a load balancer for the workers and controllers to use
resource "azurerm_lb" "boundary" {
  name                = local.lb_name
  location            = azurerm_resource_group.boundary.location
  resource_group_name = azurerm_resource_group.boundary.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.boundary.id
  }
}

# Create two address pools for workers and controllers
resource "azurerm_lb_backend_address_pool" "pools" {
  for_each        = toset(["controller", "worker"])
  loadbalancer_id = azurerm_lb.boundary.id
  name            = each.key
}

# Associate all controller NICs with the backend pool
resource "azurerm_network_interface_backend_address_pool_association" "controller" {
  count                   = var.controller_vm_count
  backend_address_pool_id = azurerm_lb_backend_address_pool.pools["controller"].id
  ip_configuration_name   = "internal"
  network_interface_id    = azurerm_network_interface.controller[count.index].id
}

# Associate all worker NICs with their backend pool
resource "azurerm_network_interface_backend_address_pool_association" "worker" {
  count                   = var.controller_vm_count
  backend_address_pool_id = azurerm_lb_backend_address_pool.pools["worker"].id
  ip_configuration_name   = "internal"
  network_interface_id    = azurerm_network_interface.worker[count.index].id
}

# All health probe for controller nodes
resource "azurerm_lb_probe" "controller_9200" {
  resource_group_name = azurerm_resource_group.boundary.name
  loadbalancer_id     = azurerm_lb.boundary.id
  name                = "port-9200"
  port                = 9200
}

# All health probe for worker nodes
resource "azurerm_lb_probe" "worker_9202" {
  resource_group_name = azurerm_resource_group.boundary.name
  loadbalancer_id     = azurerm_lb.boundary.id
  name                = "port-9202"
  port                = 9202
}

# Add LB rule for the controllers
resource "azurerm_lb_rule" "controller" {
  resource_group_name            = azurerm_resource_group.boundary.name
  loadbalancer_id                = azurerm_lb.boundary.id
  name                           = "Controller"
  protocol                       = "Tcp"
  frontend_port                  = 9200
  backend_port                   = 9200
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.controller_9200.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.pools["controller"].id
}

# Add LB rule for the workers
resource "azurerm_lb_rule" "worker" {
  resource_group_name            = azurerm_resource_group.boundary.name
  loadbalancer_id                = azurerm_lb.boundary.id
  name                           = "Worker"
  protocol                       = "Tcp"
  frontend_port                  = 9202
  backend_port                   = 9202
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.worker_9202.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.pools["worker"].id
}

# Add an NAT rule for the controller node using port 2022 
# This is so you can SSH into the controller to troubleshoot 
# deployment issues.
resource "azurerm_lb_nat_rule" "controller" {
  resource_group_name            = azurerm_resource_group.boundary.name
  loadbalancer_id                = azurerm_lb.boundary.id
  name                           = "ssh-controller"
  protocol                       = "Tcp"
  frontend_port                  = 2022
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
}

# Associate the NAT rule with the first controller VM
resource "azurerm_network_interface_nat_rule_association" "controller" {
  network_interface_id  = azurerm_network_interface.controller[0].id
  ip_configuration_name = "internal"
  nat_rule_id           = azurerm_lb_nat_rule.controller.id
}

# Add an NAT rule for the worker node using port 2023 
# This is so you can SSH into the controller to troubleshoot 
# deployment issues.
resource "azurerm_lb_nat_rule" "worker" {
  resource_group_name            = azurerm_resource_group.boundary.name
  loadbalancer_id                = azurerm_lb.boundary.id
  name                           = "ssh-worker"
  protocol                       = "Tcp"
  frontend_port                  = 2023
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
}

# Associate the NAT rule with the first worker VM
resource "azurerm_network_interface_nat_rule_association" "worker" {
  network_interface_id  = azurerm_network_interface.worker[0].id
  ip_configuration_name = "internal"
  nat_rule_id           = azurerm_lb_nat_rule.worker.id
}
