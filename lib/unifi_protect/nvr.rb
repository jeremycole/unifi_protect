# frozen_string_literal: true

module UnifiProtect
  class NVR
    TIME_FIELDS = %i[upSince].freeze

    attr_reader :nvr

    def initialize(client:, nvr:)
      @client = client
      @nvr = nvr
    end

    def to_s
      "#<#{self.class.name} id=#{@nvr.id.inspect} name=#{@nvr.name.inspect}>"
    end

    def inspect
      to_s
    end

    def respond_to_missing?(method_name, include_private = false)
      @nvr.respond_to?(method_name) || super
    end

    def method_missing(method_name, *args)
      value = @nvr.send(method_name, *args)
      return Time.at(value / 1000) if value && TIME_FIELDS.include?(method_name)

      value
    end
  end
end
