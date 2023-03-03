# @summary PE plan to update trusted facts on a certificate via Puppet enterprise console, while preserving existing trusted facts.
#
# lint:ignore:140chars:2sp_soft_tabs-check
# 
# This plans allows for the easy modification of trusted facts on already deployed nodes via the Puppet Enterprise console.
# It will preserve the existing trusted facts by reading the existing certificate and merging any proposed changes over existing. This behaviour can be changed by setting the preserve_existing_facts parameter to false
# We require the Puppet Primary to be specified when runing the plan due to limitations of running plans in orchestor. 
#
# To learn more about Puppet plans, see documentation:
# - http://pup.pt/bolt-puppet-plans
# - https://www.puppet.com/docs/pe/2021.7/plans_limitations.html
#
# @param targets The targets to run on (note this must match the certnames used by Puppet / shown in PE console).
# @param pe_primary_server The Puppet Enterprise primary server in your PE installation. 
# @param preserve_existing_facts Whether to preserve existing facts from the nodes. If set to false all existing facts will be wiped and replace with those set in the plan. Default: true
# @param ignore_infra_status_error Ignore errors from 'puppet infrastructure status' command. This is used to verify the primary server. Can be use to still allow the plan the run when some PE components a unavaliable. Default: false
# @param noop Run the plan noop. csr_attributes.yaml will still generated however certificates will not be resigned. Default: false
# @param pp_role Set the pp_role trusted fact. Default: undef
# @param pp_uuid Set the pp_uuid trusted fact. Default: undef
# @param pp_environment Set the pp_environment trusted fact. Default: undef
# @param pp_apptier Set the pp_apptier trusted fact. Default: undef
# @param pp_department Set the pp_department trusted fact. Default: undef
# @param pp_datacenter Set the pp_datacenter trusted fact. Default: undef
# @param pp_instance_id Set the pp_instance_id trusted fact. Default: undef
# @param pp_image_name Set the pp_image_name trusted fact. Default: undef
# @param pp_preshared_key Set the pp_preshared_key trusted fact. Default: undef
# @param pp_cost_center Set the pp_cost_center trusted fact. Default: undef
# @param pp_product Set the pp_product trusted fact. Default: undef
# @param pp_project Set the pp_project trusted fact. Default: undef
# @param pp_application Set the pp_application trusted fact. Default: undef
# @param pp_service Set the pp_service trusted fact. Default: undef
# @param pp_employee Set the pp_employee trusted fact. Default: undef
# @param pp_created_by Set the pp_created_by trusted fact. Default: undef
# @param pp_software_version Set the pp_software_version trusted fact. Default: undef
# @param pp_cluster Set the pp_cluster trusted fact. Default: undef
# @param pp_provisioner Set the pp_provisioner trusted fact. Default: undef
# @param pp_region Set the pp_region trusted fact. Default: undef
# @param pp_zone Set the pp_zone trusted fact. Default: undef
# @param pp_network Set the pp_network trusted fact. Default: undef
# @param pp_securitypolicy Set the pp_securitypolicy trusted fact. Default: undef
# @param pp_cloudplatform Set the pp_cloudplatform trusted fact. Default: undef
# @param pp_hostname Set the pp_hostname trusted fact. Default: undef
#
plan update_trusted_facts::update_trusted_facts (
  TargetSpec       $targets,
  Stdlib::Fqdn     $pe_primary_server,
  Boolean          $preserve_existing_facts   = true,
  Boolean          $ignore_infra_status_error = false,
  Boolean          $noop                      = false,
  Optional[String] $pp_role                   = undef,
  Optional[String] $pp_uuid                   = undef,
  Optional[String] $pp_environment            = undef,
  Optional[String] $pp_apptier                = undef,
  Optional[String] $pp_department             = undef,
  Optional[String] $pp_datacenter             = undef,
  Optional[String] $pp_instance_id            = undef,
  Optional[String] $pp_image_name             = undef,
  Optional[String] $pp_preshared_key          = undef,
  Optional[String] $pp_cost_center            = undef,
  Optional[String] $pp_product                = undef,
  Optional[String] $pp_project                = undef,
  Optional[String] $pp_application            = undef,
  Optional[String] $pp_service                = undef,
  Optional[String] $pp_employee               = undef,
  Optional[String] $pp_created_by             = undef,
  Optional[String] $pp_software_version       = undef,
  Optional[String] $pp_cluster                = undef,
  Optional[String] $pp_provisioner            = undef,
  Optional[String] $pp_region                 = undef,
  Optional[String] $pp_zone                   = undef,
  Optional[String] $pp_network                = undef,
  Optional[String] $pp_securitypolicy         = undef,
  Optional[String] $pp_cloudplatform          = undef,
  Optional[String] $pp_hostname               = undef,
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
    # remove any pe servers from targets, we dont support updating facts on puppet enterprise
    $remove_any_pe_targets = get_targets($supported_targets).filter | $target | {
      $target.facts['is_pe'] == false
    }

    out::message("Supported targets are ${remove_any_pe_targets}")

    $pe_server_target = get_target($pe_primary_server)

    # Confirm the pe_primary_server is the primary server. This can only be run on the primary server.
    $confirm_pe_primary_server_results = run_task('update_trusted_facts::confirm_primary_server', $pe_server_target,
                                                  'pe_primary_server'         => $pe_server_target.name,
                                                  'ignore_infra_status_error' => $ignore_infra_status_error,
                                                  '_catch_errors'             => true )
    $ok_set_length = length("${confirm_pe_primary_server_results.ok_set}")
    if length("${confirm_pe_primary_server_results.ok_set}") <= 2 {
      fail_plan("Primary server provided not the primary server for this Puppet Enterprise installation: ${pe_server_target.name} ")
    }

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
    $set_csr_attriubes_results = run_task('update_trusted_facts::set_csr_attributes', $remove_any_pe_targets,
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
# lint:endignore
