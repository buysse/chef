#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Copyright:: Copyright (c) 2008, 2011 Opscode, Inc.
# License:: Apache License, Version 2.0
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
#

require 'chef/resource/file'
require 'chef/provider/remote_file'
require 'chef/mixin/securable'

class Chef
  class Resource
    class RemoteFile < Chef::Resource::File
      include Chef::Mixin::Securable

      provides :remote_file, :on_platforms => :all

      def initialize(name, run_context=nil)
        super
        @resource_name = :remote_file
        @action = "create"
        @source = nil
        @provider = Chef::Provider::RemoteFile
      end

      def source(args=nil)
        validate_source(args) unless args.nil?

        set_or_return(
          :source,
          args,
          :kind_of => String
        )
      end

      def checksum(args=nil)
        set_or_return(
          :checksum,
          args,
          :kind_of => String
        )
      end

      def after_created
        validate_source(@source)
      end

      private

      def validate_source(source)
        unless absolute_uri?(source)
          raise Exceptions::InvalidRemoteFileURI,
            "'#{source}' is not a valid `source` parameter for #{resource_name}. `source` must be an absolute URI"
        end
      end

      def absolute_uri?(source)
        URI.parse(source).absolute?
      rescue URI::InvalidURIError
        false
      end

    end
  end
end
