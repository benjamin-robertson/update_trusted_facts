# update_trusted_facts

Module contains a plan to update trusted facts on nodes in Puppet Enterprise via the console. 

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with update_trusted_facts](#setup)
    * [What update_trusted_facts affects](#what-update_trusted_facts-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with update_trusted_facts](#beginning-with-update_trusted_facts)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

The built in method to update trusted facts in Puppet enterprise requires root shell access to the Puppet primary server. This level of access is generally not available for all users in an organisation and provides significant more access that what should be granted to perform this tasks. 

By using this module, fine grained access can be granted to specific users to update trusted facts via the **update_trusted_facts** plan from the console.

Furthermore this plan preserves all existing facts on an agent certificate and does not rely on the csr_attributes.yaml file being present with the correct data.

## Setup

### What update_trusted_facts affects **OPTIONAL**

This module affects the following

* Updates the csr_attributes.yaml file on systems. Taking the existing trusted facts from agent certificate and merging the proposed changes set in the plan. Existing values in csr_attributes.yaml will be replaced during this process **This occurs when the plan is run in noop**
* Regenerates the agent certificate using the *puppet infrastructure run regenerate_agent_certificate* **Does not perform this step in noop**

### Beginning with update_trusted_facts

Include the module within your Puppetfile. 

## Usage

Run the plan **update_trusted_facts::update_trusted_facts** from the Puppet Enterprise console. 

Required parameters
- pe_primary_server (FQDN)
- targets (TargetSpec - see https://www.puppet.com/docs/bolt/latest/bolt_types_reference.html#targetspec)

Targets can be specified as a comma separated list to run the plan on multiple host at a time.

Optional parameters
- preserve_existing_facts (Boolean - whether to keep existing facts. Running the plan with this option set to true and no facts set will clear all trusted facts)
- 


## Limitations

In the Limitations section, list any incompatibilities, known issues, or other
warnings.

## Development

In the Development section, tell other users the ground rules for contributing
to your project and how they should submit their work.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should
consider using changelog). You can also add any additional sections you feel are
necessary or important to include here. Please use the `##` header.

[1]: https://puppet.com/docs/pdk/latest/pdk_generating_modules.html
[2]: https://puppet.com/docs/puppet/latest/puppet_strings.html
[3]: https://puppet.com/docs/puppet/latest/puppet_strings_style.html
