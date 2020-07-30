Kind   = "service-splitter"
Name   = "backend-splitter"

Splits = [
  {
    Weight = 50
    ServiceSubset = "green"
  },
  {
    Weight = 50
    ServiceSubset = "blue"
  }
]
