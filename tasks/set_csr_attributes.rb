#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

# Task whichs lookups existing csr_attributes on a system. And merges the existing trusted facts 
#
#

require 'yaml'

def csr_attribute_location
  if Gem.win_platform?
    'C:/ProgramData/PuppetLabs/puppet/etc/csr_attributes.yaml'
  else
    '/etc/puppetlabs/puppet/csr_attributes.yaml'
  end
end

def get_existing_csr(csr_attr_file_location)
  if File.exists?(csr_attr_file_location)
    data = YAML.safe_load(File.read(csr_attr_file_location))
  else
    nil
  end
end

def merge_facts(existing_csr, new_trusted_facts)
  if existing_csr.keys.include?('extension_requests')
    combined_facts = existing_csr['extension_requests'].merge(new_trusted_facts)
    existing_csr['extension_requests'] = combined_facts
    existing_csr
  else
    existing_csr['extension_requests'] = {}
    combined_facts = existing_csr['extension_requests'].merge(new_trusted_facts)
    existing_csr['extension_requests'] = combined_facts
    existing_csr
  end
end

# Get csr file location
csr_attr_file_location = csr_attribute_location

# Load existing rules
existing_csr = get_existing_csr(csr_attr_file_location)

new_trusted_facts = params['trusted_facts']
# new_trusted_facts = {'pp_role' => 'doge', 'pp_environment' => 'dog', 'pp_department' => 'blah', 'pp_datacenter' => 'louie'}

puts "Existing facts are #{existing_csr}"
puts "New facts are #{new_trusted_facts}"

# preserve_existing_csr = false

# Merge the hash
if existing_csr == nil or preserve_existing_csr == false
  merged_csr = { 'extension_requests' => new_trusted_facts }
else
  merged_csr = merge_facts(existing_csr, new_trusted_facts)
end

puts "Combined hash is #{merged_csr}"

File.write(csr_attr_file_location, merged_csr.to_yaml)