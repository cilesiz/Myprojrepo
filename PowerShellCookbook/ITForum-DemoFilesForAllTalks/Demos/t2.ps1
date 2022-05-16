cmdlet get-foo -SupportsShouldProcess
{
if ($cmdlet.shouldprocess("foo","Action"))
{
  "FOO ACTION"
}
}

get-foo -whatif
get-foo -verbose
get-foo -confirm

