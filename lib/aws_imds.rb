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

require "aws_imds/version"
require "aws_imds/meta_data"

require 'net/http'

module AwsImds
  class Error < StandardError; end

  def self.meta_data
    @meta_data ||= AwsImds::MetaData.new
    @meta_data.meta_data
  end

  def self.user_data
    @meta_data ||= AwsImds::MetaData.new
    user_data = @meta_data.user_data
    begin
      user_data = JSON::parse(user_data)
    rescue JSON::ParserError
    end
    user_data
  end
end
