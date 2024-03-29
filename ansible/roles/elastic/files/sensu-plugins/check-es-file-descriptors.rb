#! /usr/bin/env ruby
#
#   check-es-file-descriptors
#
# DESCRIPTION:
#   This plugin checks the ElasticSearch file descriptor usage, using its API.
#   Works with ES 2.x, will not work with ES versions prior to that
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
#   #YELLOW
#
# NOTES:
#
# LICENSE:
#   Author: S. Zachariah Sprackett <zac@sprackett.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#
#   modified 03/04/2016 by Chris Chandler (chrchand@cisco.com) to work with ES 2.x
#   as max_file_descriptors is found at a different API endpoint
#

require 'sensu-plugin/check/cli'
require 'rest-client'
require 'json'
require 'base64'

#
# ES File Descriptiors
#
class ESFileDescriptors < Sensu::Plugin::Check::CLI
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

  option :critical,
         description: 'Critical percentage of FD usage',
         short: '-c PERCENTAGE',
         proc: proc(&:to_i),
         default: 90

  option :warning,
         description: 'Warning percentage of FD usage',
         short: '-w PERCENTAGE',
         proc: proc(&:to_i),
         default: 80

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
    JSON.parse(r.get)
  rescue Errno::ECONNREFUSED
    warning 'Connection refused'
  rescue RestClient::RequestTimeout
    warning 'Connection timed out'
  end

  def acquire_open_fds
    stats = get_es_resource('/_nodes/_local/stats?process=true')
    begin
      keys = stats['nodes'].keys
      stats['nodes'][keys[0]]['process']['open_file_descriptors'].to_i
    rescue NoMethodError
      warning 'Failed to retrieve open_file_descriptors'
    end
  end

  def acquire_max_fds
    info = get_es_resource('/_nodes/_local/stats?process=true')
    begin
      keys = info['nodes'].keys
      info['nodes'][keys[0]]['process']['max_file_descriptors'].to_i
    rescue NoMethodError
      warning 'Failed to retrieve max_file_descriptors'
    end
  end

  def run
    open = acquire_open_fds
    max = acquire_max_fds
    used_percent = ((open.to_f / max.to_f) * 100).to_i

    if used_percent >= config[:critical]
      critical "fd usage #{used_percent}% exceeds #{config[:critical]}% (#{open}/#{max})"
    elsif used_percent >= config[:warning]
      warning "fd usage #{used_percent}% exceeds #{config[:warning]}% (#{open}/#{max})"
    else
      ok "fd usage at #{used_percent}% (#{open}/#{max})"
    end
  end
end
