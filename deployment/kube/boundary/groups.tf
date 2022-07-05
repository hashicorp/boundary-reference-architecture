resource "random_shuffle" "group" {
  input = [
    for o in boundary_user.user : o.id
  ]
  result_count = floor(length(var.users) / 4)
  count        = floor(length(var.users) / 2)
}

resource "random_pet" "group" {
  length = 2
  count  = length(var.users) / 2
}

resource "boundary_group" "group" {
    for_each = {
        for k, v in random_shuffle.group : k => v.id
    }
    name        = random_pet.group[each.key].id
    description = "Group: ${random_pet.group[each.key].id}"
    member_ids = tolist(random_shuffle.group[each.key].result)
    scope_id = boundary_scope.org.id
}
