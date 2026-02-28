terraform plan -out=tfplan.binary -no-color && terraform show -json tfplan.binary > tfplan.json

terraform plan -out=tfplan.binary -no-color > /dev/null && terraform show -json tfplan.binary | jq -r '
.resource_changes[] |
[
  .address,
  (if (.change.actions | index("create") and index("delete")) then "replace"
   elif (.change.actions | index("create")) then "create"
   elif (.change.actions | index("delete")) then "destroy"
   elif (.change.actions | index("update")) then "update"
   else (.change.actions | join(",")) end),
  (.change.after.id // .change.before.id // "n/a")
] | @tsv' | column -t
