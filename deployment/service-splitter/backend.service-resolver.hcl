Kind = "service-resolver"
Name = "backend-splitter"

DefaultSubset = "green"
Subsets = {
  "green" = {
    Filter = "Service.Meta.type == green"
  }
  "blue" = {
    Filter = "Service.Meta.type == blue"
  }
}

Failover = {
  "*" = {
    Datacenters = ["nyc"]
  }
}
