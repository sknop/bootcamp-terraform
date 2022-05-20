// Output

output "zookeeper_private_dns" {
  value = [aws_instance.zookeepers.*.private_dns]
}

output "broker_private_dns" {
  value = [aws_instance.brokers.*.private_dns]
}

output "connect_private_dns" {
  value = [aws_instance.connect-cluster.*.private_dns]
}

output "schema_private_dns" {
  value = [aws_instance.schema.*.private_dns]
}

output "control_center_private_dns" {
  value = [aws_instance.control-center.*.private_dns]
}

output "rest_private_dns" {
  value = [aws_instance.rest.*.private_dns]
}

output "ksql_private_dns" {
  value = [aws_instance.ksql.*.private_dns]
}


# cluster data
output "cluster_data" {
  value = {
    "ssh_username" = var.linux-user
    "ssh_key" = var.key-name
  }
}
