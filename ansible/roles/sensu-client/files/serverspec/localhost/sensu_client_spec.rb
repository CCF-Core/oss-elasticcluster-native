# Example Serverspec check that ensires sshd is installed and the server is listening on port 22

require 'spec_helper'

describe package('sensu') do
  it { should be_installed }
end

describe file('/etc/sensu/conf.d/client.json') do
  it { should exist }
end

describe service('sensu-client') do
  it { should be_enabled }
  it { should be_running }
end

