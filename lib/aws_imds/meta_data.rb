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

require 'aws_imds/category'

module AwsImds
  class MetaData < Category
    category :meta_data, "meta-data" do
      category :ami_id,               "ami-id",               String
      category :ami_launch_index,     "ami-launch-index",     Integer
      category :ami_manifest_path,    "ami-manifest-path",    String
      category :ancestor_ami_ids,     "ancestor-ami-ids",     Array

      category :block_device_mapping, "block-device-mapping" do |devices|
        devices.each do |key, device|
          category key, device, String
        end
      end

      # TODO category :elastic_gpus,         "elastic-gpus" do
      # end
      # TODO category :elastic_inference,    "elastic-inference" do
      # end

      category :events, "events" do
        category :maintenance, "maintenance" do
          category :history, "history", JSON
          category :scheduled, "scheduled", JSON
        end
      end

      category :hostname, "hostname", String

      category :iam, "iam" do
        category :info, "info", JSON
        category :security_credentials, "security-credentials" do |roles|
          roles.each do |key, security_credential|
            category key, security_credential, JSON
          end
        end
      end

      category :instance_action,      "instance-action",      String
      category :instance_id,          "instance-id",          String
      category :instance_type,        "instance-type",        String
      category :kernel_id,            "kernel-id",            String
      category :local_hostname,       "local-hostname",       String
      category :local_ipv4,           "local-ipv4",           String
      category :mac,                  "mac",                  String

      category :network, "network" do
        category :interfaces, "interfaces" do
          category :macs, "macs" do |macs|
            macs.each do |key, mac|
              category 'mac_' + key.to_s.delete('/'), mac do
                category :device_number, "device-number", String
                category :interface_id, "interface-id", String
                category :local_hostname, "local-hostname", String
                category :local_ipv4s, "local-ipv4s", Array
                category :mac, "mac", String
                category :owner_id, "owner-id", String
                category :security_group_ids, "security-group-ids", Array
                category :security_groups, "security-groups", Array
                category :subnet_id, "subnet-id", String
                category :vpc_id, "vpc-id", String
                category :subnet_ipv4_cidr_block, "subnet-ipv4-cidr-block", String
                category :vpc_ipv4_cidr_block, "vpc-ipv4-cidr-block", String
                category :vpc_ipv4_cidr_blocks, "vpc-ipv4-cidr-blocks", Array
                category :ipv6s, "ipv6s", Array
                category :subnet_ipv6_cidr_blocks, "subnet-ipv6-cidr-blocks", Array
                category :vpc_ipv6_cidr_blocks, "vpc-ipv6-cidr-blocks", Array
              end
            end
          end
        end
      end

      category :placement, "placement" do
        category :availability_zone, "availability-zone", String
      end

      category :product_codes,    "product-codes",        String
      category :public_hostname,  "public-hostname",      String
      category :public_ipv4,      "public-ipv4",          String

      # TODO
      # category :public_keys, "public-keys" do
      # end

      category :ramdisk_id,       "ramdisk-id",           String
      category :reservation_id,   "reservation-id",       String
      category :security_groups,  "security-groups",      Array

      category :services, "services" do
        category :domain,     "domain",     String
        category :partition,  "partition",  String
      end

      # TODO 
      # category :spot, "spot" do
      # end
    end

    category :user_data, "/user-data", String
  end
end
