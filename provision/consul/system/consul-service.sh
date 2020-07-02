#!/bin/bash

exec consul agent -config-dir=/var/consul/config/ >>/var/log/consul.log 2>&1