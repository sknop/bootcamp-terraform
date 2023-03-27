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
      kafka_brokers =  aws_instance.brokers.*.private_dns
      kafka_broker_azs =  aws_instance.brokers.*.availability_zone
      kafka_connects = aws_instance.connect-cluster.*.private_dns
      ksqls = aws_instance.ksql.*.private_dns
      kafka_rests = aws_instance.rest.*.private_dns
      schema_registries = aws_instance.schema.*.private_dns
      control_centers = aws_instance.control-center.*.private_dns
    }
  )
  filename = var.inventory_file
}

variable "json_templatefile" {
  default = "json.tftpl"
}

variable "json_file" {
  default = "hosts.json"
}

resource "local_file" "hosts_json" {
  content = templatefile("${path.module}/${var.json_templatefile}",
    {
      zookeepers = [
        aws_instance.zookeepers.*.private_dns,
        aws_route53_record.zookeepers.*.name,
        [ for name in aws_route53_record.zookeepers.*.name : "${name}.${data.aws_route53_zone.bootcamp.name}" ]
      ]
      kafka_brokers = [
        aws_instance.brokers.*.private_dns,
        aws_route53_record.brokers.*.name,
        [ for name in aws_route53_record.brokers.*.name : "${name}.${data.aws_route53_zone.bootcamp.name}" ]
      ]
      kafka_connects = [
        aws_instance.connect-cluster.*.private_dns,
        aws_route53_record.connect-cluster.*.name,
        [ for name in aws_route53_record.connect-cluster.*.name : "${name}.${data.aws_route53_zone.bootcamp.name}" ]
      ]
      ksqls = [
        aws_instance.ksql.*.private_dns,
        aws_route53_record.ksql.*.name,
        [ for name in aws_route53_record.ksql.*.name : "${name}.${data.aws_route53_zone.bootcamp.name}" ]
      ]
      kafka_rests = [
        aws_instance.rest.*.private_dns,
        aws_route53_record.rest.*.name,
        [ for name in aws_route53_record.rest.*.name : "${name}.${data.aws_route53_zone.bootcamp.name}" ]
      ]
      schema_registries = [
        aws_instance.schema.*.private_dns,
        aws_route53_record.schema.*.name,
        [ for name in aws_route53_record.schema.*.name : "${name}.${data.aws_route53_zone.bootcamp.name}" ]
      ]
      control_centers = [
        aws_instance.control-center.*.private_dns,
        aws_route53_record.control-center.*.name,
        [ for name in aws_route53_record.control-center.*.name : "${name}.${data.aws_route53_zone.bootcamp.name}" ]
      ]
    }
  )
  filename = var.json_file
}