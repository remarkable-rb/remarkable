# module Remarkable # :nodoc:
#   module Controller # :nodoc:
#     module Matchers # :nodoc:
#       class MetadataMatcher < Remarkable::Matcher::Base
#         include Remarkable::Controller::Helpers
#         include Test::Unit::Assertions
#         include ActionController::Assertions::SelectorAssertions
#         
#         def initialize(options)
#           @options = options
#         end
# 
#         def matches?(subject)
#           @subject = subject
#           
#           assert_matcher_for(@options) do |option|
#             @key, @value = option
#             body_is_blank? && has_metatag?
#           end
#         end
# 
#         def description
#           "have metatag #{@options.inspect}"
#         end
#         
#         private
#         
#         def body_is_blank?
#           return true unless @response.body.strip.empty?
#           
#           @missing = "response.body is empty, integrate_views was included in your spec?"
#           false
#         end
#         
#         def has_metatag?
#           begin          
#             if @key.to_sym == :title
#               return true if assert_select("title", @value)
#             else
#               return true if assert_select("meta[name=?][content#{"*" if @value.is_a?(Regexp)}=?]", @key, @value)
#             end
#           rescue
#             @missing = "Expected metatag #{@key} matching \"#{@value}\", not found."
#             return false
#           end
#         end
#         
#         def html_document
#           xml = @response.content_type =~ /xml$/
#           @html_document ||= HTML::Document.new(@response.body, false, xml)
#         end
#                 
#         def expectation
#           "have metatag #{@key}"
#         end
#       end
# 
#       def render_page_with_metadata(options)
#         MetadataMatcher.new(options)
#       end
#     end
#   end
# end
