module BootstrapForms
  class FormBuilder < ::ActionView::Helpers::FormBuilder
    require_relative 'helpers/wrappers'
    require_relative 'helpers/errors'
    include BootstrapForms::Helpers::Wrappers
    include BootstrapForms::Helpers::Errors

    delegate :capture, :content_tag, :hidden_field_tag, :check_box_tag, :radio_button_tag, :button_tag, :link_to, to: :@template

    TEXT_FIELDS = %w(
      color_field
      date_field
      datetime_field
      datetime_local_field
      email_field
      month_field
      number_field
      password_field
      phone_field
      range_field
      search_field
      telephone_field
      text_area
      text_field
      time_field
      url_field
      week_field
    )

    SELECT_FIELDS = %w(
      date_select
      datetime_select
      time_select
      time_zone_select
      select
    )
  
    TEXT_FIELDS.each do |method_name|
      define_method(method_name) do |name, *args|
        options = args.extract_options!
        options[:class] = "#{BOOTSTRAP_CLASSES[:form_control]} #{options[:class]}"

        form_group(name, options) do
          label_field(name, options) << input_group(options) do
            extras(options) do
              options[:placeholder] = label_content(name, options) if options[:label] == :placeholder
              super name, *(args << options)
            end
          end
        end
      end
    end

    SELECT_FIELDS.each do |method_name|
      define_method(method_name) do |name, choices=nil, options={}, html_options={}|
        html_options[:class] = "#{BOOTSTRAP_CLASSES[:form_control]} #{html_options[:class]}"

        form_group(name, options) do
          label_field(name, options) << select_group(options) do
            extras(options) do
              super name, choices, options, html_options
            end
          end
        end
      end
    end

    def collection_select(name, collection, value_method, text_method, options={}, html_options={})
      html_options[:class] = "#{BOOTSTRAP_CLASSES[:form_control]} #{html_options[:class]}"

      form_group(name, options) do
        label_field(name, options) << select_group(options) do
          extras(options) do
            super
          end
        end
      end
    end

    def check_box(name, options={}, checked_value='1', unchecked_value='0')
      return super if options[:bare]

      content_tag(:div, class: BOOTSTRAP_CLASSES[:checkbox]) do
        label_field(name, options.merge(group: false)) do
          super(name, options, checked_value, unchecked_value) <<
          label_content(name, options)
        end
      end
    end

    def check_boxes(name, items={}, options={})
      return inline_check_boxes(name, items={}, options={}) if options[:inline]
        
      items.map do |text, values|
        content_tag(:div, class: BOOTSTRAP_CLASSES[:checkbox]) do
          label("#{name}_#{values[:checked]}") do
            check_box(name, options.merge(bare: true), values[:checked], values[:unchecked]) + text
          end
        end
      end.join
    end

    def inline_check_boxes(name, items={}, options={})
      form_group(name, options) do
        extras(options) do
          items.map do |text, values|
            label("#{name}_#{values[:checked]}", class: BOOTSTRAP_CLASSES[:checkbox_inline]) do
              check_box(name, options.merge(bare: true), values[:checked], values[:unchecked]) + text
            end
          end.join
        end
      end
    end


    def radio_button(name, value, options = {})
      return super if options[:bare]

      content_tag(:div, class: BOOTSTRAP_CLASSES[:radio]) do
        label_field(name, options.merge(group: false)) do
          super(name, value, options) <<
          label_content(name, options)
        end
      end
    end

    def radio_buttons(name, items={}, options={})
      return inline_radio_buttons(name, items, options) if options[:inline]
        
      items.map do |text, value|
        content_tag(:div, class: BOOTSTRAP_CLASSES[:radio]) do
          label("#{name}_#{value}") do
            radio_button(name, value, options.merge(bare: true)) + text
          end
        end
      end.join.html_safe
    end

    def inline_radio_buttons(name, items={}, options={})
      form_group(name, options) do
        extras(options) do
          items.map do |text, value|
            label("#{name}_#{value}", class: BOOTSTRAP_CLASSES[:radio_inline]) do
              radio_button(name, value, options.merge(bare: true)) + text
            end
          end.join
        end
      end
    end

    # def collection_check_boxes(attribute, records, record_id, record_name, args = {})
    #   @name = attribute
    #   @field_options = field_options(args)
    #   @args = args

    #   control_group_div do
    #     label_field + input_div do
    #       options = @field_options.except(*BOOTSTRAP_OPTIONS).merge(required_attribute)
    #       # Since we're using check_box_tag() we may have to lookup the instance ourselves
    #       instance = object || @template.instance_variable_get("@#{object_name}")
    #       boxes = records.collect do |record|
    #         options[:id] = "#{object_name}_#{attribute}_#{record.send(record_id)}"
    #         checkbox = check_box_tag("#{object_name}[#{attribute}][]", record.send(record_id), [instance.send(attribute)].flatten.include?(record.send(record_id)), options)

    #         content_tag(:label, :class => ['checkbox', ('inline' if @field_options[:inline])].compact) do
    #           checkbox + record.send(record_name)
    #         end
    #       end.join('')
    #       boxes << extras
    #       boxes.html_safe
    #     end
    #   end
    # end

    def collection_radio_buttons(name, collection, value_method, text_method, options={}, html_options={})
      values = {}
      collection.each { |item| values[item.send(text_method)] = item.send(value_method) }
      radio_buttons(name, values, options)
    end

    def button(*args)
      options = args.extract_options!
      options[:class] ||= 'btn btn-primary'
      super(args.first, options)
    end

    def submit(*args)
      options = args.extract_options!
      options[:class] ||= 'btn btn-primary'
      super(args.first, options)
    end
  end
end
