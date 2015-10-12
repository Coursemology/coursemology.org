# For issue rails#12579
ActionView::PartialRenderer.class_eval do
  private

  def setup_with_formats(context, options, block)
    formats = Array(options[:formats])
    @lookup_context.formats = formats | @lookup_context.formats
    setup_without_formats(context, options, block)
  end

  alias_method_chain :setup, :formats
end
