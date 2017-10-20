# frozen_string_literal: true

RSpec.describe Jekyll::RemoteTheme do
  it "returns the version" do
    expect(subject::VERSION).to match(%r!\d+\.\d+\.\d+!)
  end
end
