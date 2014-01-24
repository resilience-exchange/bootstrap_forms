module BootstrapForms
  module Helpers
    module Wrappers
      BOOTSTRAP_OPTIONS = [ :group, :label, :help, :error, :success, :warning, :append, :prepend ]
      BOOTSTRAP_CLASSES = {
        form_group: 'form-group',
        form_control: 'form-control',
        label: 'control-label',
        error: 'has-error',
        success: 'has-success',
        warning: 'has-warning',
        select_group: 'select-group',
        input_group: 'input-group',
        input_group_addon: 'input-group-addon',
        input_group_button: 'input-group-btn',
        screen_reader: 'sr-only',
        checkbox: 'checkbox',
        checkbox_inline: 'checkbox-inline',
        radio: 'radio', 
        radio_inline: 'radio-inline'
      }

    private
      def form_group(name, options={}, &block)
        options[:error] = error_string(name)

        content = block.call
        return content if options[:group] == false

        klasses = Set.new
        klasses << BOOTSTRAP_CLASSES[:form_group] unless options[:group] == false

        [:error, :success, :warning].each do |key|
          klasses << BOOTSTRAP_CLASSES[key] if options[key]
        end

        tag_options = {}
        tag_options[:class] = Array(klasses) if klasses.any?
        content_tag(:div, content, tag_options)
      end


      def help_block(content)
        content_tag(:span, content, class: 'help-block') if content.present?
      end

      def input_group(options={}, &block)
        unless options[:append] || options[:prepend]
          markup = yield if block_given?
          return markup
        end

        content_tag(:div, class: BOOTSTRAP_CLASSES[:input_group], &block)
      end

      def select_group(options={}, &block)
        content_tag(:div, class: BOOTSTRAP_CLASSES[:select_group], &block)
      end

      def addon_label(content)
        return unless content

        content = content.call if content.respond_to?(:call)
        klass = content.strip.starts_with?("<button") ? :input_group_button : :input_group_addon

        content_tag(:span, content, class: BOOTSTRAP_CLASSES[klass])
      end


      def label_field(name, options={}, &block)
        if options[:label] == '' || options[:label] == false
          return ''.html_safe
        end

        placeholder = (options[:label] == :placeholder)

        label_options = {}
        label_options[:class] = BOOTSTRAP_CLASSES[:label] unless options[:group] == false
        label_options[:class] = "#{label_options[:class]} #{BOOTSTRAP_CLASSES[:screen_reader]}" if options[:label] == :hide or placeholder

        content = block_given? ? block.call : (options[:label] unless placeholder)
        method  = respond_to?(:object) ? 'label' : 'label_tag'

        send(method, name, content, label_options)
      end



      def label_content(name, options={})
        return options[:label] if options[:label] and options[:label] != :placeholder
        
        object ||= @object
        object_name = @object_name.to_s.gsub(/\[(.*)_attributes\]\[\d\]/, '.\1')
        method_and_value = options[:value].present? ? "#{name}.#{options[:value]}" : name

        if object and object.respond_to?(:to_model)
          key = object.class.model_name.i18n_key
          i18n_default = ["#{key}.#{method_and_value}".to_sym, '']
        end

        i18n_default ||= ""

        content   = I18n.t("#{object_name}.#{method_and_value}", default: i18n_default, scope: 'helpers.label').presence
        content ||= object.class.human_attribute_name(name) if object && object.class.respond_to?(:human_attribute_name)
        content ||= name.to_s.humanize
      end

      # def required_attribute
      #   return {} if options.present? && options.has_key?(:required) && !options[:required]

      #   if respond_to?(:object) and object.respond_to?(:errors) and object.class.respond_to?('validators_on')
      #     return { :required => true } if object.class.validators_on(@name).any? { |v| v.kind_of?( ActiveModel::Validations::PresenceValidator ) && valid_validator?( v ) }
      #   end
      #   {}
      # end

      # def valid_validator?(validator)
      #   !conditional_validators?(validator) && action_validator_match?(validator)
      # end

      # def conditional_validators?(validator)
      #   validator.options.include?(:if) || validator.options.include?(:unless)
      # end

      # def action_validator_match?(validator)
      #   return true if !validator.options.include?(:on)
      #   case validator.options[:on]
      #   when :save
      #     true
      #   when :create
      #     !object.persisted?
      #   when :update
      #     object.persisted?
      #   end
      # end


      # %w(help_inline error success warning help_block append append_button prepend).each do |method_name|
      #   define_method(method_name) do |*args|
      #     return '' unless value = options[method_name.to_sym]

      #     case method_name
      #     when 'help_block'
      #       content_tag(:span, value, :class => 'help-block')
      #     when 'append', 'prepend'
      #       content_tag(:span, value, :class => 'add-on')
      #     when 'append_button'
      #       if value.is_a? Array
      #         buttons_options = value
      #       else
      #         buttons_options = [value]
      #       end

      #       buttons_options.map  do |button_options|
      #         button_options = button_options.dup
      #         value = ''
      #         if button_options.has_key? :icon
      #           value << content_tag(:i, '', { :class => button_options.delete(:icon) })
      #           value << ' '
      #         end

      #         value << ERB::Util.h(button_options.delete(:label))
      #         options = {:type => 'button', :class => 'btn'}.merge(button_options)
      #         content_tag(:button, value, options, false)
      #       end.join
      #     when 'has-error', 'has-success', 'has-warning'
      #       content_tag(:span, value, :class => "help-inline #{method_name}-message")
      #     else
      #       content_tag(:span, value, :class => 'help-inline')
      #     end
      #   end
      # end

      def extras(options={}, &block)
        [ addon_label(options[:prepend]),
          block.call,
          addon_label(options[:append]),
          help_block(options[:error]),
          help_block(options[:help])
        ].join.html_safe
      end

      # def extras(input_append = nil, &block)
      #   case input_append
      #   when nil
      #     [prepend, (yield if block_given?), append, append_button, help_inline, error, success, warning, help_block].join('').html_safe
      #   when true
      #     [prepend, (yield if block_given?), append, append_button].join('').html_safe
      #   when false
      #     [help_inline, error, success, warning, help_block].join('').html_safe
      #   end
      # end

      def objectify_options(options)
        super.except(*BOOTSTRAP_OPTIONS)
      end
    end
  end
end
