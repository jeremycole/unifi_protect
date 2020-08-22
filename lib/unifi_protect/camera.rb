module UnifiProtect
  class Camera
    attr_reader :client
    attr_reader :camera

    def initialize(client:, camera:)
      @client = client
      @camera = camera
    end

    def to_s
      "#<#{self.class.name} id=#{camera.id}>"
    end

    def inspect
      to_s
    end

    def respond_to_missing?
      true
    end

    def method_missing(symbol, *args)
      @camera.send(symbol, *args)
    end
  end
end
