output "app-hostname" {
  value = aws_lb.lb-servian.dns_name
  description = "Try it out :)"
}
