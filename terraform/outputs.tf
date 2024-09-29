# Salida que muestra la IP pública de la instancia
output "ec2_instance_public_ip" {
  value = aws_spot_instance_request.k8s_node.public_ip
}

# Output de la clave privada para usarla en el workflow
output "ssh_private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true # Asegura que no se muestre en los logs de Terraform
}

output "ssh_public_key" {
  value = tls_private_key.ssh_key.public_key_openssh
}
# Salida que muestra el ID de la instancia
output "ec2_instance_id" {
  value = aws_spot_instance_request.k8s_node.id
}
