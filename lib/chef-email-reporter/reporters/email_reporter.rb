# Copyright 2014, Jeff Shantz
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

require 'chef/event_dispatch/base'
require 'chef/formatters/error_mapper'
require 'erb'
require 'mail'
require 'ostruct'

module ChefEmailReporter

  module Reporters

    class EmailReporter < ::Chef::EventDispatch::Base

      def initialize
        @errors = []
      end

      def run_started(run_status)
        @run_status = run_status
      end

      def run_failed(exception)

        error_description = ::ChefEmailReporter::Formatters::MultipartOutputStream.new

        @errors.each do |desc|
          desc.display(error_description)
        end

        namespace = OpenStruct.new({
          node_name: @run_status.node[:name],
          node_fqdn: @run_status.node[:fqdn],
          run_id: @run_status.run_id,
          start_time: @run_status.start_time
        })

        namespace.error = error_description.text_part
        text_template = File.read(File.expand_path("../../templates/email.text.erb", __FILE__))
        text_body = ERB.new(text_template).result(namespace.instance_eval { binding })

        namespace.error = error_description.html_part
        html_template = File.read(File.expand_path("../../templates/email.html.erb", __FILE__))
        html_body = ERB.new(html_template).result(namespace.instance_eval { binding })

        subject_line = "chef-client run failed (#{@run_status.node[:fqdn]})"

        Mail.deliver do

          from    ::Chef::Config[:email_sender]
          to      ::Chef::Config[:email_recipient]
          subject subject_line

          text_part do
            body text_body
          end

          html_part do
            body html_body
          end

        end

      end

      def resource_failed(new_resource, action, exception)
        description = ::Chef::Formatters::ErrorMapper.resource_failed(new_resource, action, exception)
        @errors << description
      end

      def run_list_expand_failed(node, exception)
        description = ::Chef::Formatters::ErrorMapper.run_list_expand_failed(node, exception)
        @errors << description
      end

      def cookbook_resolution_failed(expanded_run_list, exception)
        description = ::Chef::Formatters::ErrorMapper.cookbook_resolution_failed(expanded_run_list, exception)
        @errors << description
      end

      def cookbook_sync_failed(cookbooks, exception)
        description = ::Chef::Formatters::ErrorMapper.cookbook_sync_failed(cookbooks, exception)
        @errors << description
      end

    end

  end

end
