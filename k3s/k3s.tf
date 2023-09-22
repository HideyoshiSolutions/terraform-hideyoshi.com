module "k3s" {
  source  = "xunleii/k3s/module"
  version = "3.3.0"
  k3s_version = "v1.21.4+k3s1"

  cluster_domain = "civo_k3s"

  drain_timeout            = "60s"
  managed_fields           = ["label"]
  generate_ca_certificates = true

  global_flags = [for instance in civo_instance.node_instances : "--tls-san ${instance.public_ip}"]

  servers = {
    # The node name will be automatically provided by
    # the module using the field name... any usage of
    # --node-name in additional_flags will be ignored

    for instance in civo_instance.node_instances :
    instance.hostname => {
      ip = instance.private_ip
      connection = {
        timeout  = "60s"
        type     = "ssh"
        host     = instance.public_ip
        password = instance.initial_password
        user     = "root"
      }

      labels = { "node.kubernetes.io/type" = "master" }
    }
  }
}

output "kube_config" {
  value     = module.k3s.kube_config
  sensitive = true
}