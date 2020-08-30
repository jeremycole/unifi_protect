# frozen_string_literal: true

RSpec.describe UnifiProtect::Client do
  let(:u) { mock_unifi_protect_client }

  it 'can be mocked' do
    expect(u).to be_an_instance_of(UnifiProtect::Client)
  end

  it 'implements #bootstrap' do
    expect(u.bootstrap).to be_an_instance_of(OpenStruct)
  end

  it 'implements #nvr' do
    expect(u.nvr).to be_an_instance_of(UnifiProtect::NVR)
  end

  it 'implements #cameras' do
    expect(u.cameras).to be_an_instance_of(UnifiProtect::CameraCollection)
  end
end
