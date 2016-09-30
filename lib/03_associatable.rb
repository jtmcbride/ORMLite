require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    class_name.to_s.camelcase.downcase + "s"
  end
end

class BelongsToOptions < AssocOptions
  attr_reader :foreign_key, :primary_key, :class_name
  def initialize(name, options = {})
    name
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.capitalize
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    name = name.camelcase.singularize.underscore
    @foreign_key = options[:foreign_key] || "#{self_class_name.camelcase.underscore}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.capitalize
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    belong_options = BelongsToOptions.new(name, options)
    puts "empty reulst feiaore \n\n\n\n\n #{belong_options}"
    define_method(name) do
      return nil unless self.send(belong_options.foreign_key)
      result = DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          #{belong_options.table_name}
        WHERE
          #{belong_options.primary_key} = #{self.send(belong_options.foreign_key)}
        SQL
      foreign_class = Kernel.const_get(belong_options.class_name)
      foreign_class.parse_all(result[1..-1])[0]
    end
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
