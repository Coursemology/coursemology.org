#adapted from: https://github.com/eploko/simple_form-magic_submit

module SimpleForm
  module FormSubmit

    def form_submit_button(*args, &block)
      options = args.extract_options!
      options[:data] ||= {}
      options[:data][:disable_with] ||= translate_key(:disable_with)
      options[:class] = [main_class(options), 'btn-submit', options[:class]].compact
      options[:id] ||= "submit_#{object_scope}"
      options[:autocomplete] ||= :off
      args << options
      template.content_tag :div, :class => "form-actions" do
        if cancel = options.delete(:cancel)
          submit(translate_key, *args, &block) + ' ' +
              template.link_to(I18n.t('simple_form.form_submit.cancel.cancel'), cancel, class: "btn")
        else
          submit(translate_key, *args, &block)
        end
      end.html_safe
    end

    private

    def bound_to_model?
      #  if its a string means that its bound to a model.. but if its a symbol its not...
      self.object_name.is_a?(String)# || self.object.present?
    end

    def main_class(options = {})
      options.fetch(:destructive, false) ? 'btn-destructive' : 'btn-primary'
    end

    def controller_scope
      # falls to default if the model isn't tied to a model
      return "default" unless bound_to_model?

      template.controller.params[:controller].gsub('/', '.')
    end

    def object_scope
      # returns empty string if no model is found to prevent exception
      return "" unless bound_to_model?

      self.object.class.model_name.i18n_key.to_s
    end

    def translate_key(key = nil)

      if bound_to_model?
        key ||= self.object.errors.count > 0 ? :retry : :submit

        I18n.t("simple_form.form_submit.#{controller_scope}.#{object_scope}.#{lookup_action}.#{key}",
               default: [
                   :"simple_form.form_submit.#{controller_scope}.#{lookup_action}.#{key}",
                   :"simple_form.form_submit.default.#{lookup_action}.#{key}",
                   :"helpers.submit.#{lookup_action}"
               ],
               model: self.object.class.model_name.human.titlecase
        ).html_safe
      else
        # we have no model errors... so we test if the post is get or already posted
        key ||= template.request.get? ? :submit : :retry
        I18n.t("simple_form.form_submit.#{controller_scope}.#{object_scope}.#{lookup_action}.#{key}",
               default: [
                   :"simple_form.form_submit.#{controller_scope}.#{lookup_action}.#{key}",
                   :"simple_form.form_submit.default.#{lookup_action}.#{key}",
                   :"helpers.submit.#{lookup_action}"
               ]).html_safe
      end
    end

  end
end

SimpleForm::FormBuilder.send :include, SimpleForm::FormSubmit