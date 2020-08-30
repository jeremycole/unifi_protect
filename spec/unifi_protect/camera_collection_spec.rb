# frozen_string_literal: true

RSpec.describe UnifiProtect::CameraCollection do
  let(:u) { mock_unifi_protect_client }
  let(:c) { u.cameras }

  context 'delegating to @cameras' do
    it 'delegates the #count method' do
      expect(c).to respond_to(:count).with(0).arguments
      expect(c.count).to eq(17)
    end
  end

  it 'implements the #match method' do
    expect(c).to respond_to(:match).with_any_keywords
    expect(c.match).to be_an_instance_of(UnifiProtect::CameraCollection)
  end

  context 'using the #match method' do
    it 'supports matching with no filters' do
      expect(c.match.count).to eq(c.count)
    end

    it 'supports matching by name' do
      m = c.match(name: /barn/i)

      expect(m).to be_an_instance_of(UnifiProtect::CameraCollection)
      expect(m.count).to eq(2)
    end

    it 'supports chaining matches' do
      m = c.match(name: /barn/i).match(name: /house/i)

      expect(m).to be_an_instance_of(UnifiProtect::CameraCollection)
      expect(m.count).to eq(1)
    end
  end

  it 'implements the #fetch method' do
    expect(c).to respond_to(:fetch).with_any_keywords
    expect(c.fetch).to be_an_instance_of(UnifiProtect::Camera)
  end

  context 'using the #fetch method' do
    it 'supports fetching with no filters' do
      expect(c.fetch).to eq(c.first)
    end

    it 'returns the first match' do
      m = c.match(name: /house/i)
      f = c.fetch(name: /house/i)

      expect(m.count).to eq(3)
      expect(m.first).to eq(f)
    end
  end
end
