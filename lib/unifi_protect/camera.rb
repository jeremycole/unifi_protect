# frozen_string_literal: true

module UnifiProtect
  class Camera
    attr_reader :camera

    def initialize(client:, camera:)
      @client = client
      @camera = camera
    end

    def to_s
      "#<#{self.class.name} id=#{@camera.id.inspect} name=#{@camera.name.inspect}>"
    end

    def inspect
      to_s
    end

    def respond_to_missing?(method_name, include_private = false)
      @camera.respond_to?(method_name) || super
    end

    def method_missing(method_name, *args)
      @camera.send(method_name, *args)
    end

    def match(name, matcher)
      return matcher.match(send(name)) if matcher.is_a?(Regexp)
      return send(name) == matcher if matcher.is_a?(String)

      if matcher.is_a?(Hash)
        value = send(name).send(matcher.first[0])
        pattern = matcher.first[1]
        return pattern.match(value)
      end

      false
    end

    def snapshot(local_file: nil)
      @client.api.camera_snapshot(camera: id, local_file: local_file)
    end

    def video_export(start_time:, end_time:, local_file: nil)
      @client.api.video_export(camera: id, start_time: start_time, end_time: end_time, local_file: local_file)
    end
  end
end
