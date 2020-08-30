# frozen_string_literal: true

module UnifiProtect
  class Client
    attr_reader :api

    def initialize(api: nil, **args)
      @api = api || API.new(**args)
    end

    def bootstrap
      @bootstrap ||= api.bootstrap
    end

    def nvr
      @nvr ||= NVR.new(client: self, nvr: bootstrap.nvr)
    end

    def create_camera_objects
      bootstrap.cameras.map { |camera| Camera.new(client: self, camera: camera) }
    end

    def cameras
      @cameras ||= CameraCollection.new(create_camera_objects)
    end
  end
end
