#! /usr/bin/env ruby
#
#  check-es-node-status
#
# DESCRIPTION:
#   This plugin checks the ElasticSearch node status, using its API.
#   Tested with ES 2.x, but should work for all versions
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: rest-client
#
# USAGE:
#   check-es-node-status --help
#
# NOTES:
#
# LICENSE:
#   Copyright 2012 Sonian, Inc <chefs@sonian.net>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#
#   modified 03/04/2016 by Chris Chandler (chrchand@cisco.com) to work with ES 2.x
#   as ES Node API does not return "status" in it's response. We use HTTP response
#   code, instead.
#

require 'sensu-plugin/check/cli'
require 'rest-client'
require 'json'
require 'base64'

class ESNodeStatus < Sensu::Plugin::Check::CLI
  option :host,
         description: 'Elasticsearch host',
         short: '-h HOST',
         long: '--host HOST',
         default: 'localhost'

  option :port,
         description: 'Elasticsearch port',
         short: '-p PORT',
         long: '--port PORT',
         proc: proc(&:to_i),
         default: 9200

  option :timeout,
         description: 'Sets the connection timeout for REST client',
         short: '-t SECS',
         long: '--timeout SECS',
         proc: proc(&:to_i),
         default: 30

  option :user,
         description: 'Elasticsearch User',
         short: '-u USER',
         long: '--user USER'

  option :password,
         description: 'Elasticsearch Password',
         short: '-P PASS',
         long: '--password PASS'

  def get_es_resource(resource)
    headers = {}
    if config[:user] && config[:password]
      auth = 'Basic ' + Base64.encode64("#{config[:user]}:#{config[:password]}").chomp
      headers = { 'Authorization' => auth }
    end
    r = RestClient::Resource.new("http://#{config[:host]}:#{config[:port]}#{resource}", timeout: config[:timeout], headers: headers)
    # JSON.parse(r.get)
    r.get.code
  rescue Errno::ECONNREFUSED
    critical 'Connection refused'
  rescue RestClient::RequestTimeout
    critical 'Connection timed out'
  rescue Errno::ECONNRESET
    critical 'Connection reset by peer'
  end

  def run
    node_status = get_es_resource('/')

    if node_status == 200
      ok "Alive #{(node_status)}"
    else
      critical "Dead (#{node_status})"
    end
  end
end
