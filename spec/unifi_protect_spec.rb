# frozen_string_literal: true

RSpec.describe UnifiProtect do
  it 'has a version number' do
    expect(UnifiProtect::VERSION).not_to be nil
  end

  it 'is a module' do
    expect(UnifiProtect).to be_an_instance_of(Module)
  end
end
