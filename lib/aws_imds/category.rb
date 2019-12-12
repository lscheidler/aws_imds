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

require 'aws_imds/query'

module AwsImds
  class Category
    class << self
      attr_accessor :categories
    end

    def initialize value=nil
      @query_service = Query.instance
    end

    def path
      self.class.path
    end

    def self.path path=nil
      if path
        @path = path
      end
      @path
    end

    def self.category key, name, klass=nil, &block
      @categories ||= {}
      @categories[key] = {name: name, klass: klass}
      
      path = @path

      send(:define_method, key) do
        if instance_variable_defined? "@#{key}"
          instance_variable_get "@#{key}"
        else
          if block
            k = Class.new(Category)
            new_path = File.join([path, '/' + name].compact) + '/'
            value = @query_service.query(new_path)
            k.module_exec() do
              path new_path
            end
            k.module_exec(value) do |v|
              if not block.parameters.empty?
                values = {}
                v.split("\n").each do |e|
                  values[e.gsub(/[-:]/, '_').to_sym] = e
                end

                # FIXME using last parameter in list could cause a bug
                parameter_type, parameter_name = block.parameters.last
                if parameter_type == :opt
                  self.module_exec(values.keys) do |val|
                    define_method(parameter_name) do
                      val
                    end
                  end
                end
              end

              self.module_exec(values, &block)
            end
            instance_variable_set "@#{key}", k.new
          else
            value = @query_service.query("#{path}#{name}")
            if value.nil?
              instance_variable_set "@#{key}", nil
            elsif klass == String
              instance_variable_set "@#{key}", value
            elsif klass == Integer
              instance_variable_set "@#{key}", value.to_i
            elsif klass == Array
              instance_variable_set "@#{key}", value.split("\n")
            elsif klass == JSON
              instance_variable_set "@#{key}", JSON::parse(value)
            else
              instance_variable_set "@#{key}", klass.new(value)
            end
          end
        end
      end
    end

    def to_h
      result = {}
      self.class.categories.each do |category_name, settings|
        value = send(category_name.to_sym)
        if not value.nil? and not value.is_a? Array and value.respond_to? :to_h
          result[category_name] = value.to_h
        else
          result[category_name] = value
        end
      end
      return result
    end
  end
end
