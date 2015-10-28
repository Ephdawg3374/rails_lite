require 'active_support/inflector'
require_relative "searchable"
require_relative "associatable"
require_relative "../db/db_connection"

class SQLObject
  extend Searchable
  extend Associatable

  def self.columns
    query_results = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{@table_name}
    SQL

    cols = query_results.first

    cols.map!{ |col| col.to_sym }
    cols
  end

  def self.finalize!
    self.columns.each do |col|
      define_method(col) { attributes[col] }

      define_method("#{col}=") do |val|
        attributes[col] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.downcase + "s"
  end

  def self.all
    all_records = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{@table_name}
    SQL

    self.parse_all(all_records)
  end

  def self.parse_all(results)
    objects = results.map{ |result| self.new(result) }
    objects
  end

  def self.find(id)
    record = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{@table_name}
      WHERE
        id = ?
    SQL

    record.empty? ? nil : self.new(record.first)
  end

  def initialize(params = {})
    self.class.table_name
    #debugger
    params.each do |attr_name, val|
      attr_name = attr_name.to_sym
      if self.class.columns.include?(attr_name)
        attributes[attr_name] = val
      else
        raise "unknown attribute '#{attr_name}'"
      end
    end

    self.class.finalize!
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    result = self.class.columns.map{ |col| send(col) }
  end

  def insert
    cols = self.class.columns
    values = Array.new(cols.length){"?"}

    cols = "(#{cols.join(",")})"
    values = "(#{values.join(",")})"

    attr_vals = attribute_values

    DBConnection.execute(<<-SQL, *attr_vals)
      INSERT INTO
        #{self.class.table_name} #{cols}
      VALUES
        #{values}
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    cols = self.class.columns

    set_cols = cols.map{ |col| "#{col} = ?"}.join(",")

    attr_vals = attribute_values

    DBConnection.execute(<<-SQL, *attr_vals)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_cols}
      WHERE
        id = #{self.id}
    SQL
  end

  def save
    if self.id.nil?
      insert
    else
      update
    end

  end
end
