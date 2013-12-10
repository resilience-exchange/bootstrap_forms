module BootstrapForms
  module Helpers
    module Errors
      def error_messages
        return '' unless object.try(:errors) and object.errors.full_messages.any?

        attrs_by_message = {}

        object.errors.each do |attr, messages|
          Array(messages).each do |message|
            (attrs_by_message[message] ||= []) << attr.to_s
          end
        end

        messages = attrs_by_message.map do |message, attrs|
          next message if attrs.first == 'base'
          next message unless (97..122).cover?(message.to_s.first.bytes.first)

          attrs.map! { |attr| object.class.human_attribute_name(attr.gsub('.', '_')) }
          attrs.uniq!
          attrs.sort!

          text = "#{attrs.to_sentence} #{message}"
          text << '.' unless text =~ /[!?.]$/
          text
        end.compact.sort { |a, b| b.length <=> a.length }

        content_tag(:div, :class => 'alert alert-block alert-error validation-errors') do
          content_tag(:ul) do
            messages.map do |message|
              content_tag(:li, message.html_safe)
            end.join('').html_safe
          end
        end
      end

    private
      def error_string(name)
        return unless respond_to?(:object) and object.respond_to?(:errors)

        errors = object.errors[name]
        return if errors.blank?

        errors.map do |error|
          next error unless (97..122).cover?(error.to_s.first.bytes.first)
          object.errors.full_message(name, error)
        end.join(', ')
      end
    end      
  end
end
