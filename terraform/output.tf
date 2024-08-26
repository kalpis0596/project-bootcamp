output "wp-ip_public_addr" {
  value       = aws_instance.wp-server.public_ip
  description = "The public IP address of the main server instance."
}