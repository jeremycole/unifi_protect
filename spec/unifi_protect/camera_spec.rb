# frozen_string_literal: true

RSpec.describe UnifiProtect::Camera do
  let(:u) { mock_unifi_protect_client }
  let(:c) { u.cameras.fetch(name: 'Barn towards House') }
  let(:d) { u.cameras.fetch(name: 'Front Door') }

  context 'delegating to @camera' do
    it 'delegates the #name method' do
      expect(c).to respond_to(:name).with(0).arguments
    end
  end

  it 'implements the #match method' do
    expect(c).to respond_to(:match).with(2).arguments
  end

  context 'using the #match method' do
    it 'does not match undefined arguments' do
      expect(c.match(:foo, 'bar')).to be_falsey
    end

    it 'supports matching by string' do
      expect(c.match(:name, 'Barn towards House')).to be_truthy
    end

    it 'supports matching by array of strings' do
      expect(c.match(:name, ['Barn towards House', 'Front Door'])).to be_truthy
    end

    it 'supports matching by array of regular expression' do
      expect(c.match(:name, [/barn/i, /moat/])).to be_truthy
    end
  end

  it 'implements the #snapshot method' do
    expect(c).to respond_to(:snapshot)
  end

  it 'implements the #video_export method' do
    expect(c).to respond_to(:video_export)
  end
end
