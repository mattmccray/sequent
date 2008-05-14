
module RenderedColumn

  def self.included(klass)
    klass.extend(ClassMethods)
  end
  
  def self.render_text( text, format, preprocess, options, &block )
    return "" if text.nil? or text.blank?
    
    processor = options.delete :processor
    record = options.delete :record
    if preprocess
      text = if processor == :erb
          ERB.new(text).result
        else
          block ||= Proc.new {}
          ctx = Liquid::Context.new
          block.call(record, ctx) 
          Liquid::Template.parse(text).render(ctx)
      end
    end
    
    case format
    when 'textile'
      RedCloth.new(text, options).to_html
    when 'markdown'
      BlueCloth.new(text, options).to_html
    when 'smartypants'
      RubyPants.new(text).to_html
    when 'rdoc'
      # Coming soon...
      text
    else
      # Unknown format!!!
      text
    end
  end
  
  # Calls required on the various types... It will through a LoadError if 
  # a format is referenced but not available.
  def self.ensure_format(format)
    case format
    when 'textile'
      require 'redcloth'
    when 'markdown'
      require 'bluecloth'
    when 'smartypants'
      require 'rubypants'
    when 'rdoc'
      # Coming soon...
    else
      # Unknown format!!!
    end
  end

  module ClassMethods
    
    def rendered_column( field, options={}, &block )
      options = {
        :postfix=>'',
        :cache_result=>false,
        :prefix=>'rendered_',
        :format=>'textile',
        :preprocess=>true,
        :options=>{
          :processor=>'liquid',
          :record=>nil
        }
      }.merge(options)
      
      block ||= Proc.new {|a,b|}
      
      RenderedColumn.ensure_format options[:format]
      
      # Optionally cache rendered results to a table column...
      if options[:cache_result]
        before_save do |record|
          rendered_field_name = "#{options[:prefix]}#{field.to_s}#{options[:postfix]}"
          options[:options][:record] = record
          record[rendered_field_name] = RenderedColumn.render_text( record[field], options[:format], options[:preprocess], options[:options], &block )
        end
      end
      
      define_method "#{field}_rendered".to_sym do
        options[:options][:record] = self
        RenderedColumn.render_text( self[field], options[:format], options[:preprocess], options[:options], &block )
      end
    end
    
  end
  
end