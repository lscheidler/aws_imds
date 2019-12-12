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

require 'json'
require 'ostruct'
require 'restclient'
require 'singleton'

# aws helper
module AWSHelper
  # access to aws metadata
  class Metadata
    include Singleton

    # @!attribute [rw] timeout
    #   @return timout for retrieving data from metadata service
    attr_accessor :timeout

    # @!attribute [rw] open_timeout
    #   @return open timout for retrieving data from metadata service
    attr_accessor :open_timeout

    attr_reader :meta_data

    # aws metadata service url
    METADATA_URL='http://169.254.169.254/latest'

    # initialize Metadata helper
    # Because this is a Singleton, You must use Metadata.instance
    def initialize
      set_defaults
      #create_methods
      @meta_data = get_meta_data
    end

    # set some defaults
    def set_defaults
      @timeout      = 1
      @open_timeout = 1
      @token_ttl = 21600
    end

    def get_meta_data endpoint_url='/meta-data/'
      begin
        # get endpoints from http://169.254.169.254/latest/meta-data/
        endpoints = get(endpoint_url).split("\n").map{|x| endpoint_url + x}

        result = OpenStruct.new

        endpoints.each do |endpoint|
          method = File.basename(endpoint).gsub('-', '_')

          begin
            if endpoint.end_with? '/' # deeper level metadata is at the moment unsupported
              result[method] = get_meta_data endpoint
            else
              result[method] = get(endpoint)
            end
          rescue RestClient::ResourceNotFound
            result[method] = nil
          end
        end
        return result
      rescue RestClient::RequestTimeout
        @failed = true
      end
    end

    # create instance methods for all endpoints, which we can get from AWS Metadata Service
    # see also https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html
    # limitation: deeper level metadata is at the moment unsupported
    def create_methods
      begin
        # get endpoints from http://169.254.169.254/latest/meta-data/
        endpoints = get('/meta-data/').split("\n").map{|x| 'meta-data/' + x}

        endpoints.each do |endpoint|
          # TODO
          next if endpoint.end_with? '/' # deeper level metadata is at the moment unsupported

          # generate ruby variable and method compatible version of endpoint
          method = File.basename(endpoint).gsub('-', '_')

          # define new method <method>
          self.class.send(:define_method, method) do
            # if instance variable @<method> is set, return value
            if instance_variable_defined?('@' + method)
              instance_variable_get('@' + method)
            else
              # if instance variable @<method> is unset, get value from AWS Metadata Service
              instance_variable_set('@' + method, get('/' + endpoint))
            end
          end

          # generate missing class methods (additional to self.instance_id)
          # this class methods exists only, if an instance of AWSHelper::Metadata exists
          if not self.class.respond_to? method
            self.class.send(:define_singleton_method, method) do
              AWSHelper::Metadata.instance.send(method)
            end
          end
        end
      rescue RestClient::RequestTimeout
        @failed = true
      end
    end

    # get user_data and try to parse it as json
    # if no user_data is available, return nil
    # if parsing as json failes return string
    def user_data
      unless @user_data
        begin
          user_data = get('/user-data')
          @user_data = user_data
        rescue RestClient::ResourceNotFound
        end
      end
      @user_data
    end

    # if a expected method is missing, we print a warning and return nil
    # A missing method has different reasons:
    #   1. AWS Metadata Service doesn't respond
    #   2. AWS Metadata Service doesn't return this endpoint
    #   3. AWSHelper::Metadata doesn't support this endpoint at the moment
    def method_missing(method, *args)
      if @failed
        warn('You called ' + self.class.to_s + '::' + method.to_s + ', but initialization failed.')
      else
        warn('You called ' + self.class.to_s + '::' + method.to_s + ', but method is missing.')
      end
      nil
    end

    # class method to get instance_id
    def self.instance_id
      AWSHelper::Metadata.instance.instance_id
    end

    # class method to get user_data
    def self.user_data
      AWSHelper::Metadata.instance.meta_data
    end

    # class method to get user_data
    def self.user_data
      AWSHelper::Metadata.instance.user_data
    end

    private
    # request data from AWS Metadata Service for an endpoint
    def get path
      if @token_created_at.nil? or (Time.now.to_i-@token_created_at.to_i) >= @token_ttl
        @token = RestClient::Request.execute(method: :put, open_timeout: @open_timeout, timeout: @timeout, url: METADATA_URL + '/api/token', headers: {"X-aws-ec2-metadata-token-ttl-seconds" => @token_ttl})
        @token_created_at = Time.now
      end
      result = RestClient::Request.execute(method: :get, open_timeout: @open_timeout, timeout: @timeout, url: METADATA_URL + path, headers: {"X-aws-ec2-metadata-token" => @token})
      begin
        result = JSON::parse(result)
      rescue JSON::ParserError
      end
      result
    end
  end
end
