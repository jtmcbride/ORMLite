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
    data = DBConnection.execute2(<<-SQL)[1..-1]
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL
    parse_all(data)
  end

  def self.parse_all(results)
    results.map { |dat| self.new(dat) }
  end

  def self.find(id)
    result = DBConnection.execute2(<<-SQL, id)[1]
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL
    if result
      self.new(result)
    else
      nil
    end
  end

  def initialize(params = {})
    params.each do |k, v|
      column = k.to_sym
      if self.class.columns.include?(column)
        self.send("#{column}=", v)
      else
        raise "unknown attribute '#{column}'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    attributes.values
  end

  def insert
    col_names = attributes.keys.join ", "
    quests = (["?"] * attributes.length).join ","
    DBConnection.execute2(<<-SQL, *self.attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{quests})
      SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    col = attributes.keys.join("= ?,")
    quests = (["?"] * attributes.length).join ","
    DBConnection.execute2(<<-SQL, *self.attribute_values)
      UPDATE
        #{self.class.table_name}
      SET
        #{col} = ?
      WHERE
        id = #{self.id}
      SQL
  end

  def save
    if id.nil?
      insert
    else
      update
    end
  end
end
