terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 2.13.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "jenkins_ssh_agent" {
  name         = "jenkins/ssh-agent:alpine"
  keep_locally = false
}

data "local_file" "read_ssh_pub_key" {
  filename = "/var/lib/jenkins/.ssh/jenkins_agent_key.pub"
}

resource "docker_container" "jenkins_agent" {
  count = 2
  image = docker_image.jenkins_ssh_agent.latest
  name  = "agent${count.index + 2}"
  env = [
    "JENKINS_AGENT_SSH_PUBKEY=${data.local_file.read_ssh_pub_key.content}"
  ]
  hostname = "jenkins"
  # rm = true
  ports {
    internal = 22 
    external = "790${count.index}"
  }
}


