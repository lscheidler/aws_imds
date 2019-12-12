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

require 'optparse'

module AwsImds
  class CLI
    def initialize
      parse_arguments
      case @action
      when :show_meta_data
        output = AwsImds.meta_data.to_h
        if @filter
          filter = @filter.split(".")
          filter.each do |f|
            output = output[f] || output[f.to_sym]
          end
        end
        if not @force_json and output.is_a? String
          puts output
        else
          puts JSON::dump(output)
        end
      when :show_user_data
        output = AwsImds.user_data
        puts output
      when :show_categories
        if @filter.nil?
          puts AwsImds.meta_data.class.categories.keys
        else
          output = AwsImds.meta_data
          filter = @filter.split(".")
          filter.each do |f|
            output = output.send(f.to_sym)
          end

          puts output.class.categories.keys
        end
      end
    end

    def parse_arguments
      @options = OptionParser.new do |opts|
        opts.on('-c', '--categories [EXPRESSION]', 'show available categories') do |filter|
          @action = :show_categories
          @filter = filter
        end

        opts.on('-f', '--filter EXPRESSION', 'filter output') do |filter|
          @filter = filter
        end

        opts.on('-j', '--json', 'force json output') do
          @force_json = true
        end

        opts.on('-m', '--meta-data', 'show meta data') do
          @action = :show_meta_data
        end

        opts.on('-u', '--user-data', 'show user data') do
          @action = :show_user_data
        end

        opts.separator "
Examples:

  # return meta data as json
  #{File.basename $0} -m

  # return ami_id
  #{File.basename $0} -m -f ami_id

  # return available categories
  #{File.basename $0} -c

  # return available categories for iam
  #{File.basename $0} -c iam

  # return user data
  #{File.basename $0} -u
        "
      end
      @options.parse!
    end
  end
end
