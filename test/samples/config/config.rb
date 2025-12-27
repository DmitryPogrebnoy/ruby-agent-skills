# frozen_string_literal: true

class Config
  def self.configure(&block)
    new.tap(&block)
  end

  %w[client role prompt].each do
    attr_accessor _1.to_sym
  end
end
