# Example Serverspec check that ensires sshd is installed and the server is listening on port 22

require 'spec_helper'

describe package('openssh-server'), :if => os[:family] == 'redhat' do
  it { should be_installed }
end

describe package('sshd'), :if => os[:family] == 'ubuntu' do
  it { should be_installed }
end

describe service('sshd') do
  it { should be_enabled }
  it { should be_running }
end

describe port(22) do
  it { should be_listening }
end
