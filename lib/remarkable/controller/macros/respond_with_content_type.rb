module Remarkable
  module Syntax

    module RSpec
      # Macro that creates a test asserting that the response content type was 'content_type'.
      # Example:
      #
      #   should_respond_with_content_type 'application/rss+xml'
      #   should_respond_with_content_type :rss
      #   should_respond_with_content_type /rss/
      # 
      def respond_with_content_type(content_type)
        simple_matcher "respond with content type of #{content_type}" do
          content_type = Mime::EXTENSION_LOOKUP[content_type.to_s].to_s if content_type.is_a? Symbol
          if content_type.is_a? Regexp
            response.content_type =~ content_type
          else
            response.content_type == content_type
          end
        end
      end
    end

    module Shoulda
      # Macro that creates a test asserting that the response content type was 'content_type'.
      # Example:
      #
      #   should_respond_with_content_type 'application/rss+xml'
      #   should_respond_with_content_type :rss
      #   should_respond_with_content_type /rss/
      # 
      def should_respond_with_content_type(content_type)
        it "should respond with content type of #{content_type}" do
          content_type = Mime::EXTENSION_LOOKUP[content_type.to_s].to_s if content_type.is_a? Symbol
          if content_type.is_a? Regexp
            response.content_type.should match(content_type)
          else
            response.content_type.should == content_type
          end
        end
      end
    end
    
  end
end
