# Copyright 2013 Google Inc. All Rights Reserved.
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
require "fog"
require "log4r"
require 'pry'

module VagrantPlugins
  module Google
    module Action
      # This action connects to Google, verifies credentials work, and
      # puts the Google connection object into the `:google_compute` key
      # in the environment.
      class ConnectGoogle
        def initialize(app, env)
          @app    = app
          @logger = Log4r::Logger.new("vagrant_google::action::connect_google")
        end

        def call(env)
          provider_config = env[:machine].provider_config
          # Get the zone we're going to booting up in
          zone = provider_config.zone

          # Get the configs
          zone_config     = provider_config.get_zone_config(zone)

          # Build the fog config
          fog_config = {
            :provider            => :google,
            :zone                => zone
          }
          fog_config[:google_client_email] = provider_config.google_client_email
          fog_config[:google_key_location] = provider_config.google_key_location
          fog_config[:google_project] = provider_config.google_project_id

          fog_config[:image] = zone_config.image if zone_config.image
          fog_config[:machine_type] = zone_config.machine_type if zone_config.machine_type
          fog_config[:network] = zone_config.network if zone_config.network

          @logger.info("Connecting to Google...")
	  binding.pry
          env[:google_compute] = Fog::Compute.new(fog_config)

          @app.call(env)
          @logger.info("...Connected!")
        end
      end
    end
  end
end
