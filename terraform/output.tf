output "wp-ip_public_addr" {
  value       = aws_instance.wp-server.public_ip
  description = "The public IP address of the main server instance."
}

output "cloudflare_zone_id" {
  value       = data.cloudflare_zone.wp-zone.id
  description = "The ID of the selected Cloudflare zone."
}

output "cloudflare_zone" {
  value       = data.cloudflare_zone.wp-zone.name
  description = "The name of the selected Cloudflare zone."
}

output "cloudflare_record_hostname" {
  value = cloudflare_record.wp-record.hostname
  description = "The hostname of the DNS record for the main server instance."
}