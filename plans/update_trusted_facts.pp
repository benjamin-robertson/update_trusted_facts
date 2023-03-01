# @summary PE plan to update trusted facts on a certificate, while preserving existing trusted facts.
#
#
#
plan update_trusted_facts::update_trusted_facts (
  TargetSpec       $targets,
  String           $pe_primary_server,
  Boolean          $preserve_existing_facts = true,
  Boolean          $noop                    = false,
  Optional[String] $pp_role                 = undef,
  Optional[String] $pp_uuid                 = undef,
  Optional[String] $pp_environment          = undef,
  Optional[String] $pp_apptier              = undef,
  Optional[String] $pp_department           = undef,
  Optional[String] $pp_datacenter           = undef,
  Optional[String] $pp_instance_id          = undef,
  Optional[String] $pp_image_name           = undef,
  Optional[String] $pp_preshared_key        = undef,
  Optional[String] $pp_cost_center          = undef,
  Optional[String] $pp_product              = undef,
  Optional[String] $pp_project              = undef,
  Optional[String] $pp_application          = undef,
  Optional[String] $pp_service              = undef,
  Optional[String] $pp_employee             = undef,
  Optional[String] $pp_created_by           = undef,
  Optional[String] $pp_software_version     = undef,
  Optional[String] $pp_cluster              = undef,
  Optional[String] $pp_provisioner          = undef,
  Optional[String] $pp_region               = undef,
  Optional[String] $pp_zone                 = undef,
  Optional[String] $pp_network              = undef,
  Optional[String] $pp_securitypolicy       = undef,
  Optional[String] $pp_cloudplatform        = undef,
  Optional[String] $pp_hostname             = undef,
) {
  # get targets
  $full_list = get_targets($targets)

  # Create array of trusted facts
  $trusted_fact_names = update_trusted_facts::trusted_fact_names()

  unless $full_list.empty {
    # Check connection to hosts. run_plan does not exit cleanly if there is a host which doesnt exist or isnt connected, We use this task
    # to check if hosts are valid and have a valid connection to PE. This can be switched to a faster running task to speed up plan 
    # execution as we do not actually use the results from this task.
    $factresults = run_task(facts, $full_list, _catch_errors => true)

    $full_list_failed = $factresults.error_set.names
    $full_list_success = $factresults.ok_set.names

    # Update facts
    without_default_logging() || { run_plan(facts, targets => $full_list_success) }

    # supported platforms
    $supported_platforms = ['Debian', 'RedHat', 'windows']

    $supported_targets = get_targets($full_list_success).filter | $target | {
      $target.facts['os']['family'] in $supported_platforms
    }

    out::message("Supported targets are ${supported_targets}")

    out::message("Trusted facts are ${trusted_fact_names}")

    # Create hash with trusted facts
    $new_trusted = $trusted_fact_names.reduce({}) | $memo, $value | {
      if getvar($value) != undef {
        $fact_value = getvar($value)
        $memo + { $value => $fact_value }
      } else {
        $memo
      }
    }

    out::message("Trusted facts are ${new_trusted}")

    # Run task to generate csr_attributes
    $set_csr_attriubes_results = run_task('update_trusted_facts::set_csr_attributes', $supported_targets,
                                          'trusted_facts'           => $new_trusted,
                                          'preserve_existing_facts' => $preserve_existing_facts,
                                          '_catch_errors'           => true )
    $set_csr_attriubes_done = $set_csr_attriubes_results.ok_set
    $set_csr_attriubes_done_names = $set_csr_attriubes_results.ok_set.names
    $set_csr_attriubes_failed = $set_csr_attriubes_results.error_set.names
    $set_csr_attriubes_successful_targets = $supported_targets - get_targets(set_csr_attriubes_failed)

    # Regen agent certificate
    $nodes_to_regen_cert = $set_csr_attriubes_done_names.reduce | String $memo, String $node | { "${memo},${node}" }
    out::message("Nodes to regen certs on ${nodes_to_regen_cert}")
    if $nodes_to_regen_cert != undef {
      if $noop != true {
        run_command("puppet infrastructure run regenerate_agent_certificate agent=${nodes_to_regen_cert}", $pe_primary_server)
      }
    }
  }
}
