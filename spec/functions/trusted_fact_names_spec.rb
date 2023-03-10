# frozen_string_literal: true

require 'spec_helper'

describe 'update_trusted_facts::trusted_fact_names' do
  # please note that these tests are examples only
  # you will need to replace the params and return value
  # with your expectations
  it { is_expected.to run.and_return(['pp_role', 'pp_uuid', 'pp_environment', 'pp_apptier', 'pp_department', 'pp_datacenter', 'pp_instance_id', 'pp_image_name', 'pp_preshared_key', 'pp_cost_center', 'pp_product', 'pp_project', 'pp_application', 'pp_service', 'pp_employee', 'pp_created_by', 'pp_software_version', 'pp_provisioner', 'pp_cluster', 'pp_region', 'pp_zone', 'pp_network', 'pp_securitypolicy', 'pp_cloudplatform', 'pp_hostname']) }
end
