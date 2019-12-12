# Copyright 2019 Lars Eric Scheidler
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'net/http'
require 'singleton'

module AwsImds
  class Query
    include Singleton

    # @!attribute [rw] timeout
    #   @return timout for retrieving data from metadata service
    attr_accessor :timeout

    # @!attribute [rw] open_timeout
    #   @return open timout for retrieving data from metadata service
    attr_accessor :open_timeout

    # aws metadata service url
    METADATA_URL='http://169.254.169.254/latest'

    def initialize
      @timeout      = 1
      @open_timeout = 1
      @token_ttl    = 21600
    end

    def query path
      uri = URI(METADATA_URL + path)
      request = Net::HTTP::Get.new uri
      request['X-aws-ec2-metadata-token'] = token
      res = Net::HTTP.start(uri.hostname, uri.port) {|http|
        http.request(request)
      }
      if res.is_a? Net::HTTPOK
        res.body
      else
        nil
      end
    end

    def token
      if @token_created_at.nil? or (Time.now.to_i-@token_created_at.to_i) >= @token_ttl
        uri = URI(METADATA_URL + '/api/token')
        request = Net::HTTP::Put.new uri
        request['X-aws-ec2-metadata-token-ttl-seconds'] = @token_ttl

        res = Net::HTTP.start(uri.hostname, uri.port) {|http|
          http.request(request)
        }
        @token = res.body
        @token_created_at = Time.now
      end
      @token
    end
  end
end
