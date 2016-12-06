# Example Serverspec check that ensires sshd is installed and the server is listening on port 22

require 'spec_helper'

describe package('collectd') do
  it { should be_installed }
end

describe service('collectd') do
  it { should be_enabled }
  it { should be_running }
end
