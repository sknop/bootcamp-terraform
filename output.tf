// Output

output "zookeeper_private_dns" {
  value = [aws_instance.zookeepers.*.private_dns]
}

output "zookeeper_alternate_dns" {
  value = [aws_route53_record.zookeepers.*.name]
}

output "broker_private_dns" {
  value = [aws_instance.brokers.*.private_dns]
}

output "broker_alternate_dns" {
  value = [aws_route53_record.brokers.*.name]
}

output "connect_private_dns" {
  value = [aws_instance.connect-cluster.*.private_dns]
}

output "connect_alternate_dns" {
  value = [aws_route53_record.connect-cluster.*.name]
}

output "schema_private_dns" {
  value = [aws_instance.schema.*.private_dns]
}

output "schema_alternate_dns" {
  value = [aws_route53_record.schema.*.name]
}

output "control_center_private_dns" {
  value = [aws_instance.control-center.*.private_dns]
}

output "control_center_alternate_dns" {
  value = [aws_route53_record.control-center.*.name]
}

output "rest_private_dns" {
  value = [aws_instance.rest.*.private_dns]
}

output "rest_alternate_dns" {
  value = [aws_route53_record.rest.*.name]
}

output "ksql_private_dns" {
  value = [aws_instance.ksql.*.private_dns]
}

output "ksql_alternate_dns" {
  value = [aws_route53_record.ksql.*.name]
}

output "prometheus_private_dns" {
  value = [aws_instance.prometheus.*.private_dns]
}

output "prometheus_alternate_dns" {
  value = [aws_route53_record.prometheus.*.name]
}

output "grafana_private_dns" {
  value = [aws_instance.grafana.*.private_dns]
}

output "grafana_alternate_dns" {
  value = [aws_route53_record.grafana.*.name]
}

# cluster data
output "cluster_data" {
  value = {
    "ssh_username" = var.linux-user
    "ssh_key" = var.key-name
  }
}

