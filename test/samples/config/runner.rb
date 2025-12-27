# frozen_string_literal: true

class Runner
  def initialize(config)
    @config = config
  end

  def run
    config.client.chat(
      messages: [{
                   role: config.role,
                   content: config.prompt
                 }]
    ).chat_completion
  end

  private

  attr_reader :config
end