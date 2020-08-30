# frozen_string_literal: true

RSpec.describe UnifiProtect::NVR do
  let(:u) { mock_unifi_protect_client }
  let(:n) { u.nvr }

  context 'delegating to @nvr' do
    it 'delegates the #name method' do
      expect(n).to respond_to(:name).with(0).arguments
    end
  end
end
