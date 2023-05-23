# frozen_string_literal: true

module Jets
  # Built-in Health Check Endpoint
  #
  # \Jets also comes with a built-in health check endpoint that is reachable at
  # the +/up+ path. This endpoint will return a 200 status code if the app has
  # booted with no exceptions, and a 500 status code otherwise.
  #
  # In production, many applications are required to report their status upstream,
  # whether it's to an uptime monitor that will page an engineer when things go
  # wrong, or a load balancer or Kubernetes controller used to determine a pod's
  # health. This health check is designed to be a one-size fits all that will work
  # in many situations.
  #
  # While any newly generated \Jets applications will have the health check at
  # +/up+, you can configure the path to be anything you'd like in your
  # <tt>"config/routes.rb"</tt>:
  #
  #   Jets.application.routes.draw do
  #     get "healthz" => "jets/health#show", as: :jets_health_check
  #   end
  #
  # The health check will now be accessible via the +/healthz+ path.
  #
  # NOTE: This endpoint does not reflect the status of all of your application's
  # dependencies, such as the database or redis cluster. Replace
  # <tt>"jets/health#show"</tt> with your own controller action if you have
  # application specific needs.
  #
  # Think carefully about what you want to check as it can lead to situations
  # where your application is being restarted due to a third-party service going
  # bad. Ideally, you should design your application to handle those outages
  # gracefully.
  class HealthController < Jets::Controller::Base
    rescue_from(Exception) { render_down }

    def show
      render_up
    end

    private
      def render_up
        render html: html_status(color: "green")
      end

      def render_down
        render html: html_status(color: "red"), status: 500
      end

      def html_status(color:)
        %(<!DOCTYPE html><html><body style="background-color: #{color}"></body></html>).html_safe
      end
  end
end
