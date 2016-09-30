require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      result = DBConnection.execute2(<<-SQL)[1..-1]
      SELECT
        #{source_options.class_name.downcase}s.*
      FROM
        #{through_options.class_name.downcase}s
      JOIN
        #{source_options.class_name.downcase}s ON #{through_options.class_name.downcase}s.#{source_options.foreign_key} = #{source_options.class_name.downcase}s.id
      WHERE
        #{through_options.class_name.downcase}s.#{source_options.primary_key} = #{self.send(through_options.foreign_key)}
      SQL
      Kernel.const_get(source_options.class_name).parse_all(result)[0]
    end
  end
end
