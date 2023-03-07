variable "hosts_templatefile" {
  default = "hosts.tftpl"
}

variable "inventory_file" {
  default = "hosts.yml"
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/${var.hosts_templatefile}",
    {
      zookeepers = aws_instance.zookeepers.*.private_dns
      kafka_brokers = aws_instance.brokers.*.private_dns
      kafka_connects = aws_instance.connect-cluster.*.private_dns
      ksqls = aws_instance.ksql.*.private_dns
      kafka_rests = aws_instance.rest.*.private_dns
      schema_registries = aws_instance.schema.*.private_dns
      control_centers = aws_instance.control-center.*.private_dns
    }
  )
  filename = var.inventory_file
}
