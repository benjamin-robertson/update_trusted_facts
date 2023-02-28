# @summary PE plan to update trusted facts on a certificate, while preserving existing trusted facts.
#
#
#
plan update_trusted_facts::update_trusted_facts (
  TargetSpec       $targets,
  String           $pe_primary_server,
  Optional[String] $pp_role            = undef,
  Optional[String] $pp_uuid            = undef,
  Optional[String] $pp_environment     = undef,
  Optional[String] $pp_apptier         = undef,
  Optional[String] $pp_department      = undef,
  Optional[String] $pp_datacenter      = undef,
) {
  # get targets
  $full_list = get_targets($targets)

  unless $full_list.empty {
    # Check connection to hosts. run_plan does not exit cleanly if there is a host which doesnt exist or isnt connected, We use this task
    # to check if hosts are valid and have a valid connection to PE. This can be switched to a faster running task to speed up plan 
    # execution as we do not actually use the results from this task.
    $factresults = run_task(facts, $full_list, _catch_errors => true)

    $full_list_failed = $factresults.error_set.names
    $full_list_success = $factresults.ok_set.names

    # Update facts
    without_default_logging() || { run_plan(facts, targets => $full_list_success) }
}
