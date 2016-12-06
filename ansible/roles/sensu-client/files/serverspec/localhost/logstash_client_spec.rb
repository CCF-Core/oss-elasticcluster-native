# Example Serverspec check that ensires sshd is installed and the server is listening on port 22

require 'spec_helper'

describe package('logstash') do
  it { should be_installed }
end

# This doesn't work reliably since there's an issue of parity
# between systemd and init.d
#
# describe service('logstash') do
#  it { should be_enabled }
#  it { should be_running }
# end

describe command(%Q\ps aux | grep "logstash/runner.rb agent" | grep -v grep\) do
  its(:exit_status) { should eq 0 }
end
