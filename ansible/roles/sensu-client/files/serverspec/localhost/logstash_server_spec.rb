require 'spec_helper'

# Make sure Logstash server config is present
describe file('/etc/logstash/conf.d/logstash-server.conf') do
  it { should exist }
end
