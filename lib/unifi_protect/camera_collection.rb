# frozen_string_literal: true

require 'forwardable'

module UnifiProtect
  class CameraCollection
    extend Forwardable

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
      motion_detected: :isMotionDetected,
    }.freeze

    def initialize(cameras = [])
      @cameras = cameras
    end

    def_delegator :@cameras, :to_a
    def_delegator :@cameras, :count
    def_delegator :@cameras, :empty?
    def_delegator :@cameras, :first
    def_delegator :@cameras, :last
    def_delegator :@cameras, :[]
    def_delegator :@cameras, :each
    def_delegator :@cameras, :each_index
    def_delegator :@cameras, :each_slice
    def_delegator :@cameras, :each_with_index
    def_delegator :@cameras, :each_with_object
    def_delegator :@cameras, :map

    def respond_to_missing?(method_name, include_private = false)
      return true if FILTERS.include?(method_name)

      super
    end

    def method_missing(method_name, *args)
      return filter(method_name, *args) if FILTERS.include?(method_name)

      super
    end

    def match(**attrs)
      return CameraCollection.new(cameras) if attrs.empty?

      CameraCollection.new(
        @cameras.select do |camera|
          attrs.any? { |name, matcher| camera.match(name, matcher) }
        end
      )
    end

    def fetch(**attrs)
      match(**attrs).first
    end

    def filter(name, value = true)
      return CameraCollection.new if @cameras.empty?
      raise 'unknown filter' unless FILTERS.include?(name.to_sym)

      CameraCollection.new(@cameras.select { |c| c.send(FILTERS.fetch(name.to_sym)) == value })
    end
  end
end
