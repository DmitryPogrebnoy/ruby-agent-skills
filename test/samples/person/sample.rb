# frozen_string_literal: true

class Person
  attr_reader :name

  def initialize(name:)
    @name = name
  end

  def name=(name)
    @name = name
  end
end
