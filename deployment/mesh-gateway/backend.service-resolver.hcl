Kind     = "service-resolver"
Name     = "backend-mesh"

Failover = {
  "*" = {
    Datacenters = ["nyc"]
  }
}
