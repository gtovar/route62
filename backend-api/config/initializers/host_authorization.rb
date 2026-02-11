# frozen_string_literal: true

allowed_hosts = ENV.fetch("RAILS_ALLOWED_HOSTS", "")
                   .split(",")
                   .map(&:strip)
                   .reject(&:empty?)

allowed_hosts.each do |host|
  Rails.application.config.hosts << host
end
