# ulimit settings
default['cluster']['filehandle_limit'] = 10_000

# Default gc_thresh values for performance at scale
default['cluster']['sysctl']['ipv4']['gc_thresh1'] = 0
default['cluster']['sysctl']['ipv4']['gc_thresh2'] = 15_360
default['cluster']['sysctl']['ipv4']['gc_thresh3'] = 16_384

# ArmPL
default['conditions']['arm_pl_supported'] = arm_instance?

# NVidia
default['cluster']['nvidia']['enabled'] = 'no'
default['cluster']['nvidia']['driver_version'] = '470.182.03'

# DCV
default['cluster']['dcv']['authenticator']['user'] = "dcvextauth"
default['cluster']['dcv']['authenticator']['user_id'] = node['cluster']['reserved_base_uid'] + 3
default['cluster']['dcv']['authenticator']['group'] = node['cluster']['dcv']['authenticator']['user']
default['cluster']['dcv']['authenticator']['group_id'] = node['cluster']['dcv']['authenticator']['user_id']
default['cluster']['dcv']['authenticator']['user_home'] = "/home/#{node['cluster']['dcv']['authenticator']['user']}"
default['cluster']['dcv']['authenticator']['certificate'] = "#{node['cluster']['etc_dir']}/ext-auth-certificate.pem"
default['cluster']['dcv']['authenticator']['private_key'] = "#{node['cluster']['etc_dir']}/ext-auth-private-key.pem"
default['cluster']['dcv']['version'] = '2023.0-15022'
default['cluster']['dcv_port'] = 8443
default['cluster']['dcv']['installed'] = 'yes'

default['cluster']['dcv']['server']['version'] = '2023.0.15022-1'
default['cluster']['dcv']['xdcv']['version'] = '2023.0.547-1'
default['cluster']['dcv']['gl']['version'] = '2023.0.1027-1'
default['cluster']['dcv']['web_viewer']['version'] = '2023.0.15022-1'

# OpenSSH settings for AWS ParallelCluster instances
default['openssh']['server']['protocol'] = '2'
default['openssh']['server']['syslog_facility'] = 'AUTHPRIV'
default['openssh']['server']['permit_root_login'] = 'forced-commands-only'
default['openssh']['server']['password_authentication'] = 'no'
default['openssh']['server']['gssapi_authentication'] = 'yes'
default['openssh']['server']['gssapi_clean_up_credentials'] = 'yes'
default['openssh']['server']['ciphers'] = 'aes128-cbc,aes192-cbc,aes256-cbc,aes128-ctr,aes192-ctr,aes256-ctr,aes128-gcm@openssh.com,aes256-gcm@openssh.com'
default['openssh']['server']['m_a_cs'] = 'hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256'
default['openssh']['client']['gssapi_authentication'] = 'yes'
default['openssh']['client']['match'] = 'exec "ssh_target_checker.sh %h"'
# Disable StrictHostKeyChecking for target host in the cluster VPC
default['openssh']['client']['  _strict_host_key_checking'] = 'no'
# Do not store server key in the know hosts file to avoid scaling clashing
# that is when an new host gets the same IP of a previously terminated host
default['openssh']['client']['  _user_known_hosts_file'] = '/dev/null'
