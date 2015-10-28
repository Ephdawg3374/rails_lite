require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    @class_name.underscore + "s"
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    @class_name = options[:class_name] || "#{name.to_s.camelize}"
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || "#{self_class_name.underscore}_id".to_sym
    @class_name = options[:class_name] || "#{name.to_s.singularize.camelize}"
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)

    define_method(name) do
      @foreign_key = send(options.foreign_key)
      @class_name = options.model_class

      params = {
        options.primary_key => @foreign_key
      }

      @class_name.where(params).first
    end

  end

  def has_many(name, options = {})
    #debugger

    options = HasManyOptions.new(name, self.to_s, options)

    define_method(name) do
      #debugger
      @class_name = options.model_class
      @foreign_key = send(options.primary_key)

      params = {
        options.foreign_key => @foreign_key
      }

      @class_name.where(params)
    end

  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end

  def has_one_through(name, through_name, source_name)
    # ...
  end
end
