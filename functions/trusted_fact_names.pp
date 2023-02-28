# See https://puppet.com/docs/puppet/latest/lang_write_functions_in_puppet.html
# for more information on native puppet functions.
function update_trusted_facts::trusted_fact_names() >> Hash {
  #$array = ['pp_role','pp_uuid','pp_environment','pp_apptier','pp_department','pp_datacenter']
  $hash = { 'pp_role' => '','pp_uuid' => '','pp_environment' => '','pp_apptier' => '','pp_department' => '','pp_datacenter' => '' }
}
