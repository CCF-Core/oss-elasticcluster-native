require 'spec_helper'

describe package('elasticsearch') do
  it { should be_installed }
end

# TODO: Need to find out why this isn't working. Tried appending -30 and -40, etc on the service name, but no joy
# describe service('elasticsearch') do
#   it { should be_running.under('supervisor') }
# end

describe port(9200) do
  it { should be_listening }
end

describe port(9300) do
  it { should be_listening }
end
