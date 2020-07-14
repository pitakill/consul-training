#!/bin/bash

. /etc/environment

if [ "$CONSUL_SSL" == "true" ]; then
  SSL="--cacert ${CONSUL_CACERT}"
  echo "SSL Enabled"
fi

endpoint=v1/kv/cluster/consul/rootToken
echo "Bootstrap Secondary Consul System"
rootToken=$(curl -s $SSL "$CONSUL_HTTP_ADDR_PRINCIPAL/$endpoint" | jq  -r '.[].Value'| base64 -d -)

sed -i '/CONSUL_HTTP_TOKEN/d' /etc/environment
echo -e "\nexport CONSUL_HTTP_TOKEN=$rootToken\n" | sudo tee -a /etc/environment > /dev/null
