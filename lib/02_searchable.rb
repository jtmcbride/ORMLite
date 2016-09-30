require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.keys.join("= ? AND ")
    result = DBConnection.execute2(<<-SQL, params.values)[1..-1]
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_line} = ?
      SQL
    parse_all(result)
  end
end

class SQLObject
  extend Searchable
end
