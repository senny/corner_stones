module CornerStones
  class FlashMessages

    class FlashMessageMissingError < StandardError; end

    include Capybara::DSL

    def initialize(options = {})
      @options = options
    end

    def message(type, text)
      messages[type].detect {|message| message[:text] == text}
    end

    def messages
      message_types.inject(Hash.new {|hash, key| hash[key] = []}) do |present_messages, type|
        all(".#{type} p").map do |message|
          present_messages[type] << {:text => message.text}
        end
        present_messages
      end
    end

    def message_types
      @options.fetch(:message_types) { [:notice, :error, :alert] }
    end

    def assert_flash_is_present(type, message)
      unless message(type, message)
        raise FlashMessageMissingError, "the flash message: '#{message}' with type: #{type} was not found.\nThe following messages were present:\n#{formatted_present_messages}\n"
      end
    end

    def formatted_present_messages
      present_messages = messages.map { |type, messages|
        messages.map {|message| "- #{type}: #{message[:text]}"}
      }.flatten.join("\n")
    end
    private :formatted_present_messages
  end
end
