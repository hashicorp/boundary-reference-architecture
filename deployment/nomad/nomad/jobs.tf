resource "nomad_job" "boundary" {
  provider = nomad
  jobspec  = file("${path.module}/boundary.hcl")
}

resource "nomad_job" "boundary_init" {
  provider = nomad
  jobspec  = file("${path.module}/boundary-init.hcl")
}

#resource "nomad_job" "mssql" {
#  provider = nomad
#  jobspec  = file("${path.module}/mssql.hcl")
#}
