require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    if @columns
      return @columns
    else
      names = DBConnection.execute2(<<-SQL)[0]
        SELECT
          *
        FROM
          #{table_name}
      SQL
    end
    @columns = names.map(&:to_sym)
  end

  def self.finalize!
    columns.each do |column|
      define_method(column) do
        instance_variable_get("@#{column}")
        if attributes
          return attributes[column]
        end
      end
      define_method("#{column}=") do |val|
        #instance_variable_set("@#{column}", val)
        if attributes
          attributes[column] = val
        end
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= "#{self}".tableize
  end

  def self.all
    # ...
  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    # ...
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
