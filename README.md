# OceanRoar.jl: Running Oceananigans on Aurora

## ECCO credentials

The file `ecco_credentials.jl` should contain your `https://ecco.jpl.nasa.gov/drive/` API credentials.

```julia
ENV["ECCO_USERNAME"] = "your_username"
ENV["ECCO_PASSWORD"] = "your_password"
```
