Kind = "service-resolver"
Name = "database-splitter"

Failover = {
  "*" = {
    Datacenters = ["nyc"]
  }
}
