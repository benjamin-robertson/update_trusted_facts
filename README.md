# update_trusted_facts

Module containing a plan to update trusted facts on nodes via the Puppet Enterprise console. 

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with update_trusted_facts](#setup)
    * [What update_trusted_facts affects](#what-update_trusted_facts-affects)
    * [Beginning with update_trusted_facts](#beginning-with-update_trusted_facts)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

The built in method to update trusted facts in Puppet enterprise requires root shell access to the Puppet primary server. This level of access is generally not available to most users in an organisation and provides significant more access than required for this task. 

By using this module, fine grained access can be granted to specific users to update trusted facts via the **update_trusted_facts** plan from the console.

Furthermore this plan preserves all existing facts on an agent certificate and does not rely on the csr_attributes.yaml file being present on a host.

## Setup

### What update_trusted_facts affects

This module affects the following

* Updates the csr_attributes.yaml file on systems. Taking the existing trusted facts from agent certificate and merging the proposed changes set in the plan. Existing values in csr_attributes.yaml will be replaced during this process **This also occurs when the plan is run in noop**
* Regenerates the agent certificate using the *puppet infrastructure run regenerate_agent_certificate* **Does not perform this step in noop**

### Beginning with update_trusted_facts

Include the module within your Puppetfile. 

## Usage

Run the plan **update_trusted_facts::update_trusted_facts** from the Puppet Enterprise console. 

**Note:** If you restrict access to plans via RBAC and only grant users permission to run this plan; you will also need to grant users access to *enterprise_tasks::agent_cert_regen* plan. 

**Required parameters**
- pe_primary_server (FQDN)
- targets (TargetSpec - [see here](https://www.puppet.com/docs/bolt/latest/bolt_types_reference.html#targetspec))

Targets can be specified as a comma separated list to run the plan on multiple host at a time.

**Optional parameters**
- preserve_existing_facts (Boolean - whether to keep existing facts. If set to false all existing facts will be wiped and replace with those set in the plan)
- ignore_infra_status_error (Boolean - Ignore errors from *puppet infrastructure status* command. May allow the plan to operate if some Puppet infrastructure components are failing)
- noop (Boolean - Run the plan in noop. csr_attributes.yaml will still generated however certificates will not be resigned.)

**Trusted facts supported**
The following trusted facts are supported by the plan. All are optional parameters, set as required. All accept String as input.
- pp_role
- pp_uuid
- pp_environment
- pp_apptier
- pp_department
- pp_datacenter
- pp_instance_id
- pp_image_name
- pp_preshared_key
- pp_cost_center
- pp_product
- pp_project
- pp_application
- pp_service
- pp_employee 
- pp_created_by
- pp_software_version
- pp_cluster
- pp_provisioner
- pp_region
- pp_zone
- pp_network
- pp_securitypolicy
- pp_cloudplatform
- pp_hostname

## Limitations

Tested with the following combinations. Expected to work for all Windows, Enterprise Linux, Debian, Ubuntu versions. 

Puppet Enterprise
- 2021.7.2 

Puppet Nodes
- Windows 2019
- RHEL 8

To support legacy version of Puppet Enterprise (Before changing naming standard to Primary server from master.) You must set the support_legacy_pe parameter to true.

## Development

If you find any issues with this module, please log them in the issues register of the GitHub project. [Issues][1]

[1]: https://github.com/benjamin-robertson/update_trusted_facts/issues