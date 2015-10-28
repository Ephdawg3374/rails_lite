module Searchable
  def where(params)
    search_values = params.values

    where_clause_conditions = params.keys.map{ |col| "#{col} = ?"}.join(" AND ")

    query_results = DBConnection.execute(<<-SQL, *search_values)
      SELECT
        *
      FROM
        #{@table_name}
      WHERE
        #{where_clause_conditions}
    SQL

    query_results.map{ |result| self.new(result) }
  end
end
