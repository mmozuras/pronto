# frozen_string_literal: true

require 'cgi'
require 'erb'
require 'ostruct'
require 'base64'

module Pronto
  module Formatter
    class HtmlFormatter < Base
      TEMPLATE_PATH =
        File.expand_path('../assets/output.html.erb', __dir__)

      Color = Struct.new(:red, :green, :blue, :alpha) do
        def to_s
          "rgba(#{values.join(', ')})"
        end

        def fade_out(amount)
          dup.tap do |color|
            color.alpha -= amount
          end
        end
      end

      attr_reader :files, :summary

      def format(messages, _, _)
        render_html(messages)
      end

      def render_html(messages)
        context = ERBContext.new(messages)

        template = File.read(TEMPLATE_PATH, encoding: Encoding::UTF_8)

        erb = if RUBY_VERSION >= '2.6'
                ERB.new(template, trim_mode: '-')
              else
                ERB.new(template, nil, '-')
              end
        html = erb.result(context.binding)

        html
      end

      # This class provides helper methods used in the ERB template.
      class ERBContext

        attr_reader :files

        def initialize(messages)
          @files = messages.group_by(&:path)
        end

        # Make Kernel#binding public.
        def binding
          super
        end

        def decorated_message(msg)
          msg.gsub(/`(.+?)`/) do
            "<code>#{Regexp.last_match(1)}</code>"
          end.force_encoding('UTF-8')
        end

        def pluralize(number, thing, options = {})
          if number.zero? && options[:no_for_zero]
            "no #{thing}s"
          elsif number == 1
            "1 #{thing}"
          else
            "#{number} #{thing}s"
          end
        end

        def escape(string)
          CGI.escapeHTML(string)
        end
      end
    end
  end
end

