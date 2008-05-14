require 'active_record'

module Multiup
  module Acts #:nodoc:
    module Sluggable #:nodoc:

      def self.append_features(base)
        super
        base.extend(ClassMethods)
      end

      module ClassMethods
        # Generates a URL slug based on provided fields
        #
        #   class Page < ActiveRecord::Base
        #     acts_as_sluggable :source_column => 'title', :target_column => 'url_slug', :scope => :parent
        #   end
        #
        # Configuration options:
        # * <tt>source_column</tt> - specifies the column name used to generate the URL slug
        # * <tt>slug_column</tt> - specifies the column name used to store the URL slug
        # * <tt>scope</tt> - Given a symbol, it'll attach "_id" and use that as the foreign key 
        #   restriction. It's also possible to give it an entire string that is interpolated if 
        #   you need a tighter scope than just a foreign key.
        def acts_as_sluggable(options = {})
          configuration = { :source_column => 'name', :slug_column => 'slug', :scope => nil}
          configuration.update(options) if options.is_a?(Hash)
          
          configuration[:scope] = "#{configuration[:scope]}_id".intern if configuration[:scope].is_a?(Symbol) && configuration[:scope].to_s !~ /_id$/

          if configuration[:scope].is_a?(Symbol)
            scope_condition_method = %(
              def scope_condition
                if #{configuration[:scope].to_s}.nil?
                  "#{configuration[:scope].to_s} IS NULL"
                else
                  "#{configuration[:scope].to_s} = \#{#{configuration[:scope].to_s}}"
                end
              end
            )
          elsif configuration[:scope].nil?
            scope_condition_method = "def scope_condition() \"1 = 1\" end"
          else
            scope_condition_method = "def scope_condition() \"#{configuration[:scope]}\" end"
          end
          
          class_eval <<-EOV
            include Multiup::Acts::Sluggable::InstanceMethods
          
            def acts_as_sluggable_class
              ::#{self.name}
            end

            def source_column
              "#{configuration[:source_column]}"
            end

            def slug_column
              "#{configuration[:slug_column]}"
            end
            
            #{scope_condition_method}
          
            before_validation_on_create :create_slug
            before_validation_on_update :create_slug

            validates_uniqueness_of :#{configuration[:slug_column]}, :scope => '#{configuration[:scope]}'
          EOV
        end
      end

      # Adds instance methods.
      module InstanceMethods #:nodoc:
        private
          def create_slug
            if attribute_present?(slug_column) == false
              test_string = self[source_column]

              test_string = '' if test_string.nil?

              #strip out common punctuation
              proposed_slug = test_string.strip.downcase.gsub(/[\'\"\#\$\,\.\!\?\%\@\(\)]+/, '')

              #replace non-word chars with dashes
              proposed_slug = proposed_slug.gsub(/[\W^-_]+/, '-')

              #remove double dashes
              proposed_slug = proposed_slug.gsub(/\-{2}/, '-')

              suffix = ""
              existing = true
              acts_as_sluggable_class.transaction do
                while existing != nil
                  existing = acts_as_sluggable_class.find(:first, :conditions => ["#{slug_column} = ? and #{scope_condition}",  proposed_slug + suffix])
                  if existing
                    if suffix.empty?
                      suffix = "-0"
                    else
                      suffix.succ!
                    end
                  end
                end
              end               

              update_attribute(slug_column, proposed_slug + suffix)
            end
          end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  include Multiup::Acts::Sluggable
end