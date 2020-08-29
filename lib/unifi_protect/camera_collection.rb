# frozen_string_literal: true

module UnifiProtect
  class CameraCollection
    attr_reader :cameras

    FILTERS = {
      adopting: :isAdopting,
      adopted: :isAdopted,
      provisioned: :isProvisioned,
      attempting_to_connect: :isAttemptingToConnect,
      managed: :isManaged,
      updating: :isUpdating,
      connected: :isConnected,
      recording: :isRecording,
      rebooting: :isRebooting,
      deleting: :isDeleting,

      # Real-world status
      dark: :isDark,
      motion_detected: :isMotionDetected
    }.freeze

    def initialize(cameras)
      @cameras = cameras
    end

    def respond_to_missing?(method_name, include_private = false)
      return true if FILTERS.include?(method_name)

      @cameras.respond_to?(method_name) || super
    end

    def method_missing(method_name, *args)
      return filter(method_name) if FILTERS.include?(method_name)

      @cameras.send(method_name, *args)
    end

    def match(**attrs)
      CameraCollection.new(
        @cameras.select do |camera|
          attrs.any? { |name, matcher| camera.match(name, matcher) }
        end
      )
    end

    def fetch(id)
      match(id: id).first
    end

    def filter(name)
      return [] if @cameras.empty?
      raise 'unknown filter' unless FILTERS.include?(name.to_sym)

      CameraCollection.new(@cameras.select(&FILTERS.fetch(name.to_sym)))
    end
  end
end
