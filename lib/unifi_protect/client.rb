module UnifiProtect
  class Client
    attr_reader :api
    attr_reader :bearer_token

    def initialize(host:, port: 7443, username:, password:)
      @api = API.new(host: host, port: port, username: username, password: password)
    end

    def bootstrap
      @bootstrap ||= api.bootstrap
    end

    def create_camera_objects
      bootstrap['cameras'].each_with_object({}) do |camera, cameras|
        cameras[camera.id] = Camera.new(client: self, camera: camera)
      end
    end

    def cameras
      @cameras ||= create_camera_objects
    end
  end
end
