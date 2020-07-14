#!/bin/bash

. /etc/environment

if [ "$CONSUL_SSL" == "true" ]; then
  SSL="--cacert ${CONSUL_CACERT}"
  echo "SSL Enabled"
fi

function wait_for_consul {
  local endpoint=v1/status/leader
  while true; do
    leader=$(curl -s $SSL "$CONSUL_HTTP_ADDR/$endpoint" | sed 's/\"//g')
    if [ "$leader" != "" ]; then
      echo "Consul leader already selected [$leader]."
      break
    fi
    echo "Waiting for consul cluster leader..."
    sleep 10
  done
}

function bootstrap_consul {
  local endpoint=v1/acl/bootstrap
  echo "Bootstrap Consul ACL System"
  rootToken=$(curl -s $SSL -X PUT "$CONSUL_HTTP_ADDR/$endpoint" | jq .SecretID | sed s/\"//g)

  echo "Setting Consul Root Token"
  CONSUL_HTTP_TOKEN="$rootToken" consul acl set-agent-token default "$rootToken"

  echo "Storing Consul Root Token"
  echo "consul kv put cluster/consul/rootToken $rootToken"
  CONSUL_HTTP_TOKEN="$rootToken" consul kv put cluster/consul/rootToken "$rootToken"

  sed -i '/CONSUL_HTTP_TOKEN/d' /etc/environment
  echo -e "\nexport CONSUL_HTTP_TOKEN=$rootToken\n" | sudo tee -a /etc/environment > /dev/null

  # Consul anonymous policy rootToken
  consul acl policy create -name anonymous -rules - <<EOF
    key "cluster/consul/rootToken" {
     policy = "read" 
    }
EOF

  consul acl token update -policy-name=anonymous -id=00000000-0000-0000-0000-000000000002
}

wait_for_consul
bootstrap_consul
