output "instance_ids" {
  value = aws_instance.this.*.id
}


#output "instance_ids" {
#  description = "IDs of EC2 instances"
#  value       = aws_instance.app.*.id
#}
