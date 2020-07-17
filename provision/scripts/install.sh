#!/usr/bin/env bash
LOCAL_CONSUL_BINARY=$1
LOCAL_VAULT_BINARY=$2
LOCAL_NOMAD_BINARY=$3

echo "LOCAL_CONSUL_BINARY=$LOCAL_CONSUL_BINARY"
echo "LOCAL_NOMAD_BINARY=$LOCAL_NOMAD_BINARY"
echo "LOCAL_VAULT_BINARY=$LOCAL_VAULT_BINARY"

# Install Keys
curl -sL -s https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

curl -sL -sL 'https://getenvoy.io/gpg' | sudo apt-key add -
sudo add-apt-repository \
"deb [arch=amd64] https://dl.bintray.com/tetrate/getenvoy-deb \
$(lsb_release -cs) \
stable"

sudo apt-get update
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    getenvoy-envoy \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    unzip \
    jq

cat >> ~/.bashrc <<"END"
# Coloring of hostname in prompt to keep track of what's what in demos, blue provides a little emphasis but not too much like red
NORMAL="\[\e[0m\]"
BOLD="\[\e[1m\]"
DARKGRAY="\[\e[90m\]"
BLUE="\[\e[34m\]"
PS1="$DARKGRAY\u@$BOLD$BLUE\h$DARKGRAY:\w\$ $NORMAL"
END

# Download consul
export CONSUL_VERSION=1.7.3
curl -sL https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip -o consul.zip

# Install consul
sudo unzip consul.zip
sudo chmod +x consul
sudo mv consul /usr/bin/consul

# Download consul-template
export CONSUL_TEMPLATE_VERSION=0.24.0
curl -sL https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -o consul-template.zip

# Install consul-template
sudo unzip consul-template.zip
sudo chmod +x consul-template
sudo mv consul-template /usr/bin/consul-template

export ENVCONSUL_VERSION=0.9.0
curl -sL https://releases.hashicorp.com/envconsul/${ENVCONSUL_VERSION}/envconsul_${ENVCONSUL_VERSION}_linux_amd64.zip -o envconsul.zip
sudo unzip envconsul.zip
sudo chmod +x envconsul
sudo mv envconsul /usr/bin/envconsul

export CONSUL_REPLICATE_VERSION=0.4.0
curl -sL https://releases.hashicorp.com/consul-replicate/${CONSUL_REPLICATE_VERSION}/consul-replicate_${CONSUL_REPLICATE_VERSION}_linux_amd64.zip -o consul-replicate.zip
sudo unzip consul-replicate.zip
sudo chmod +x consul-replicate
sudo mv consul-replicate /usr/bin/consul-replicate



# Download nomad
export NOMAD_VERSION=0.11.2
curl -sL https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip -o nomad.zip

# Install nomad
sudo unzip nomad.zip
sudo chmod +x nomad
sudo mv nomad /usr/bin/nomad

# Download terraform
export TERRAFORM_VERSION=0.12.24
curl -sL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip

# Install terraform
sudo unzip terraform.zip
sudo chmod +x terraform
sudo mv terraform /usr/bin/terraform

# Download CNI Plugin
curl -sL -L -o cni-plugins.tgz https://github.com/containernetworking/plugins/releases/download/v0.8.1/cni-plugins-linux-amd64-v0.8.1.tgz

# Install CNI Plugin
sudo mkdir -p /opt/cni/bin
sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz


# Download vault
export VAULT_VERSION=1.2.3
curl -sL https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -o vault.zip

# Install vault
sudo unzip vault.zip
sudo chmod +x vault
sudo mv vault /usr/bin/vault
