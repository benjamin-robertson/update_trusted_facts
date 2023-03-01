#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

require 'open3'
require 'puppet'
require 'openssl'
require 'yaml'

def get_cert_location
  if Gem.win_platform?
    command = '/opt/puppetlabs/bin/puppet config print hostcert' # need to set for windows
  else
    command = '/opt/puppetlabs/bin/puppet config print hostcert'
  end
  output, status = Open3.capture2(command)
  if status.exitstatus != 0
    puts "failed to get cert location from puppet config command #{status}"  
    exit 1
  end
  output.lstrip!
  output.rstrip!
end

def read_trusted_facts(cert_location, trusted_facts_oid)
  trusted_fact_results = {}
  cert_data = File.open cert_location
  certificate = OpenSSL::X509::Certificate.new cert_data
  certificate.extensions.each do | element | 
    trusted_facts_oid.each { | name, oid | 
      if element.oid == name or element.oid == oid
        trusted_fact_results[name] = element.value.to_s.gsub(/^\.\n/, '').gsub(/^\../, '')
      end
    }
  end
  trusted_fact_results
end

trusted_facts_oid = { 'pp_uuid' => '1.3.6.1.4.1.34380.1.1.1', 'pp_instance_id' => '1.3.6.1.4.1.34380.1.1.2', 'pp_image_name' => '1.3.6.1.4.1.34380.1.1.3', 'pp_preshared_key' => '1.3.6.1.4.1.34380.1.1.4', 'pp_cost_center' => '1.3.6.1.4.1.34380.1.1.5', 'pp_product' => '1.3.6.1.4.1.34380.1.1.6', 'pp_project' => '1.3.6.1.4.1.34380.1.1.7', 'pp_application' => '1.3.6.1.4.1.34380.1.1.8', 'pp_service' => '1.3.6.1.4.1.34380.1.1.9', 'pp_employee' => '1.3.6.1.4.1.34380.1.1.10', 'pp_created_by' => '1.3.6.1.4.1.34380.1.1.11', 'pp_environment' => '1.3.6.1.4.1.34380.1.1.12', 'pp_role' => '1.3.6.1.4.1.34380.1.1.13', 'pp_software_version' => '1.3.6.1.4.1.34380.1.1.14', 'pp_department' => '1.3.6.1.4.1.34380.1.1.15', 'pp_cluster' => '1.3.6.1.4.1.34380.1.1.16', 'pp_provisioner' => '1.3.6.1.4.1.34380.1.1.17', 'pp_region' => '1.3.6.1.4.1.34380.1.1.18', 'pp_datacenter' => '1.3.6.1.4.1.34380.1.1.19', 'pp_zone' => '1.3.6.1.4.1.34380.1.1.20', 'pp_network' => '1.3.6.1.4.1.34380.1.1.21', 'pp_securitypolicy' => '1.3.6.1.4.1.34380.1.1.22', 'pp_cloudplatform' => '1.3.6.1.4.1.34380.1.1.23', 'pp_apptier' => '1.3.6.1.4.1.34380.1.1.24', 'pp_hostname' => '1.3.6.1.4.1.34380.1.1.25' }

cert_location = get_cert_location

trusted_facts = read_trusted_facts(cert_location, trusted_facts_oid)

puts "Trusted facts are #{trusted_facts}"

