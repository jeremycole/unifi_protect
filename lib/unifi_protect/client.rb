# frozen_string_literal: true

module UnifiProtect
  class Client
    attr_reader :api

    def initialize(host:, port: 7443, username:, password:)
      @api = API.new(host: host, port: port, username: username, password: password)
    end

    def bootstrap
      @bootstrap ||= api.bootstrap
    end

    def create_camera_objects
      bootstrap['cameras'].map { |camera| Camera.new(client: self, camera: camera) }
    end

    def cameras
      @cameras ||= CameraCollection.new(create_camera_objects)
    end
  end
end
