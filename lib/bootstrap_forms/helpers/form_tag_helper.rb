module BootstrapForms
  module Helpers
    module FormTagHelper
      include BootstrapForms::Helpers::Wrappers
      include BootstrapForms::Helpers::Errors

      FormBuilder::TEXT_FIELDS.each do |method_name|
        define_method("bootstrap_#{method_name}_tag") do |name, *args|
          options = args.extract_options!
          options[:class] = "#{BOOTSTRAP_CLASSES[:form_control]} #{options[:class]}"

          form_group(name, options) do
            label_field(name, options) << input_group(options) do
              extras(options) do
                options[:placeholder] = label_content(name, options) if options[:label] == :placeholder
                send method_name.to_sym, name, *(args << options)
              end
            end
          end
        end
      end

      FormBuilder::SELECT_FIELDS.each do |method_name|
        define_method("bootstrap_#{method_name}_tag") do |(*args), options={}, html_options={}|
          name = args.first
          html_options[:class] = "#{BOOTSTRAP_CLASSES[:form_control]} #{html_options[:class]}"

          form_group(name, options) do
            label_field(name, options) << select_group(options) do
              extras(options) do
                super *args, options, html_options
              end
            end
          end
        end
      end

      def bootstrap_form_tag(*args, &block)
        form_tag *args, &block
      end

      def bootstrap_button_tag(name=nil, *args)
        options = args.extract_options!
        options[:class] ||= 'btn btn-primary'
        button_tag name, *(args << options)
      end

      def bootstrap_submit_tag(name=nil, *args)
        options = args.extract_options!
        options[:class] ||= 'btn btn-primary'
        submit_tag name, *(args << options)
      end
    end
  end
end
