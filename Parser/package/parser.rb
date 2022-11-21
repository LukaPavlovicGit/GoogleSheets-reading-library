require 'google_drive'
require 'yaml'

# Creates a session. This will prompt the credential via command line for the
# first time and save it to config.json file for later usages.
# See this document to learn how to create config.json:
# https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.md
session = GoogleDrive::Session.from_config('config.json')

# First worksheet of
# https://docs.google.com/spreadsheet/ccc?key=pz7XtlQC-PYx-jrVMJErTcg
# Or https://docs.google.com/a/someone.com/spreadsheets/d/pz7XtlQC-PYx-jrVMJErTcg/edit?usp=drive_web

$spread_sheet = session.spreadsheet_by_key('1IMYGBbXuObl1sPmPWDoVOUp87GXyXV3hp4BBQJENecA')


# documentation
class Parser

  def load_tables
    tables = []
    $spread_sheet.worksheets.count.times do |ws_idx|
      tables.append(read_table(ws_idx))
    end
    tables
  end

  private

  def read_table(ws_idx)
    worksheet = $spread_sheet.worksheets[ws_idx]
    upper_left_point = upper_left_point(worksheet)
    down_right_point = down_right_point(worksheet)

    first_col_idx = upper_left_point[1]
    last_col_idx = down_right_point[1] + 1
    first_row_idx = upper_left_point[0]
    last_row_idx = down_right_point[0] + 1

    columns = []
    total_keyword_coordinates = total_keyword_coordinates(worksheet)
    subtotal_keyword_coordinates = subtotal_keyword_coordinates(worksheet)
    (first_col_idx...last_col_idx).each do |col_idx|
      next if total_keyword_coordinates[1] == col_idx || subtotal_keyword_coordinates[1] == col_idx

      col_cells = []
      (first_row_idx...last_row_idx).each do |row_idx|
        next if total_keyword_coordinates[0] == row_idx || subtotal_keyword_coordinates[0] == row_idx

        col_cells.append(Cell.new(ws_idx, worksheet[row_idx, col_idx], col_idx, row_idx))
      end
      col_name = worksheet[first_row_idx, col_idx]
      columns.append(Column.new(ws_idx, col_name, col_cells))
    end
    Table.new(ws_idx, columns, upper_left_point, down_right_point)
  end

  def upper_left_point(worksheet)
    (1..worksheet.num_cols).each do |col_idx|
      (1..worksheet.num_rows).each do |row_idx|
        return [row_idx, col_idx] unless worksheet[row_idx, col_idx].empty?
      end
    end
    [-1, -1]
  end

  def down_right_point(worksheet)
    worksheet.num_cols.downto(1) do |col_idx|
      worksheet.num_rows.downto(1) do |row_idx|
        return [row_idx, col_idx] unless worksheet[row_idx, col_idx].empty?
      end
    end
    [-1, -1]
  end

  def empty_rows
    nil
  end

  def total_keyword_coordinates(worksheet)
    (1..worksheet.num_cols).each do |col_idx|
      (1..worksheet.num_rows).each do |row_idx|
        return [row_idx, col_idx] if worksheet[row_idx, col_idx].casecmp('total').zero?
      end
    end
    [-1, -1]
  end

  def subtotal_keyword_coordinates(worksheet)
    (1..worksheet.num_cols).each do |col_idx|
      (1..worksheet.num_rows).each do |row_idx|
        return [row_idx, col_idx] if worksheet[row_idx, col_idx].casecmp('subtotal').zero?
      end
    end
    [-1, -1]
  end

end

# documentation
class Table

  attr_accessor :ws_idx, :sheet_name, :columns, :rows, :header, :upper_left_point, :down_right_point

  include Enumerable

  def initialize(ws_idx, columns, upper_left_point, down_right_point)
    @ws_idx = ws_idx
    @columns = columns
    @upper_left_point = upper_left_point
    @down_right_point = down_right_point
    build_header
    discard_empty_rows
    define_column_methods
  end

  def matrix
    matrix = []
    @columns.each do |col|
      matrix.append(col.cells.collect(&:value))
    end
    matrix.transpose
  end

  def row(index)
    matrix[index]
  end

  def each(&block)
    matrix.each do |row|
      row.each do |cell|
        block.call(cell)
      end
    end
  end

  def [](parameter)
    return return_column_step_one(parameter) if parameter.is_a?(String)
    return return_column_step_two(parameter) if parameter.is_a?(Integer)

    nil
  end

  def +(other)
    return nil if @header != other.header

    row_idx = down_right_point[0] + 1
    @columns.count.times do |i|
      curr_col_idx = upper_left_point[1] + i
      curr_row_idx = row_idx
      other.columns[i].cells.each do |cell|
        next if other.header.include?(cell.value) # probaj da odradis bolje

        cell = Cell.new(ws_idx, cell.value, curr_col_idx, curr_row_idx)
        cell.column = @columns[i]
        curr_row_idx += 1
        @columns[i].cells.append(cell)
        cell.write_myself
      end
    end
    down_right_point[0] += other.columns[0].cells.count - 1
    $spread_sheet.worksheets[ws_idx].save
    self
  end

  def -(other)
    return nil if @header != other.header

    (1..@columns[0].cells.count - 1).each do |i|
      self_row_cells = row_cells(self, upper_left_point[0] + i)
      (1..other.columns[0].cells.count - 1).each do |j|
        other_row_cells = row_cells(other, other.upper_left_point[0] + j)

        next if other_row_cells.collect(&:value) == @header
        next if self_row_cells.collect(&:value) != other_row_cells.collect(&:value)

        # potential RESOURCE_EXHAUSTED exception, nothing to with code
        delete_row(self_row_cells)
      end
    end
    self
  end

  def to_s
    mat = matrix
    string = ''
    mat.to_a.each do |line|
      string += "#{line.to_s}\n"
    end
    string
  end

  private

  def build_header
    @header = []
    @columns.each do |col|
      col.table = self
      @header << (col.name)
    end
  end

  def define_column_methods
    @columns.each do |col|
      define_singleton_method(col.name.gsub(/[^a-zA-z0-9]/, '_')) do
        return col
      end
    end
  end

  def discard_empty_rows
    num_of_empty_rows = 0
    (1..@columns[0].cells.count - 1).each do |i|
      row_cells = row_cells(self, upper_left_point[0] + i)
      is_empty_row = row_cells.all? { |cell| cell.value.empty? }
      num_of_empty_rows += 1 if is_empty_row
      # yield does not work for some reason
      discard_row(is_empty_row, row_cells, num_of_empty_rows)
    end
    down_right_point[0] -= num_of_empty_rows if num_of_empty_rows.positive?
  end

  def discard_row(is_empty_row, row_cells, num_of_empty_rows)
    row_cells.each { |cell| cell.column.cells.delete(cell) } if is_empty_row
    if !is_empty_row && num_of_empty_rows.positive?
      row_cells.each { |cell| cell.row_idx = cell.row_idx - num_of_empty_rows }
    end
  end

  def return_column_step_one(column_name)
    @columns.each do |col|
      return col if col.name == column_name
    end
    nil
  end

  def return_column_step_two(index)
    return @columns[index] if index < @columns.count

    nil
  end

  def delete_row(row)
    row.each(&:delete_myself)
  end

  def row_cells(table, row_idx)
    row = []
    table.columns.each do |col|
      col.cells.each do |cell|
        row.append(cell) if cell.row_idx.eql? row_idx
      end
    end
    row
  end

end

# documentation
class Column

  attr_accessor :ws_idx, :name, :values, :table, :cells, :cell_values

  include Enumerable

  def initialize(ws_idx, name, cells)
    @ws_idx = ws_idx
    @name = name
    @cells = cells

    @cells.each do |cell|
      cell.column = self
    end

    @values = []
    define_cell_methods
  end

  def [](index)
    return return_cell_step_one(index) if index.is_a?(String)
    return return_cell_step_two(index) if index.is_a?(Integer)

    nil
  end

  def []=(index, parameter)
    cell = nil
    cell = return_cell_step_one(index) if index.is_a?(String)
    cell = return_cell_step_two(index) if index.is_a?(Integer)
    return if cell.nil?

    cell.value =  parameter.to_s
    worksheet = $spread_sheet.worksheets[ws_idx]
    worksheet[cell.row_idx.to_i, cell.col_idx.to_i] = parameter.to_s
    worksheet.save
  end

  def sum
    sum = 0
    cells.each do |cell|
      next unless cell.value.to_i.is_a? (Numeric)

      sum += cell.value.to_i
    end
    sum
  end

  def avg
    sum = 0
    cnt = 0
    cells.each do |cell|
      next unless cell.value.to_i.is_a? (Numeric)

      sum += cell.value.to_i
      cnt += 1
    end
    sum / cnt
  end

  def each(&block)
    @cells.each do |cell|
      block.call(cell)
    end
  end

  def define_cell_methods
    @cells.each do |cell|
      define_singleton_method(cell.name.gsub(/[^a-zA-z0-9]/, '_')) do
        return cell
      end
    end
  end

  def to_s
    cells.collect(&:to_s).to_s
  end

  def method_missing(name, *args, &block)
    return my_map(&block) if name.start_with?('my_map')
    return my_select(&block) if name.start_with?('my_select')
    return my_reduce(*args, &block) if name.start_with?('my_reduce')

    nil
  end

  def respond_to_missing?(method_name, include_private = false)
    method_name.to_s.start_with?('map') || super
  end

  def respond_to?(method_name, include_private = false)
    method_name.to_s.start_with?('map') || super
  end

  private

  def my_map(&block)
    return array_of_col_cells_without_header unless block_given?

    arr = []
    (1..@cells.count - 1).each do |i|
      cell = @cells[i]
      val = 0
      val = cell.to_s.to_i if cell.to_s.to_i.is_a? (Numeric)
      arr << block.call(val)
    end
    arr
  end

  def my_select(&block)
    return array_of_col_cells_without_header unless block_given?

    arr = []
    (1..@cells.count - 1).each do |i|
      cell = @cells[i]
      val = 0
      val = cell.to_s.to_i if cell.to_s.to_i.is_a? (Numeric)
      arr << val if block.call(val)
    end
    arr
  end

  def my_reduce(*args, &block)
    return -1 unless block_given?

    args[0] = 0 if args.empty?
    ans = 0
    (1..@cells.count - 1).each do |i|
      cell = @cells[i]
      val = 0
      val = cell.to_s.to_i if cell.to_s.to_i.is_a? (Numeric)
      ans += block.call(*args, val)
    end
    ans
  end

  def array_of_col_cells_without_header
    arr = []
    (1..@cells.count - 1).each do |i|
      arr << @cells[i].to_s
    end
    arr
  end

  def return_cell_step_one(cell_name)
    @cells.each do |cell|
      return cell if cell.name == cell_name
    end
    nil
  end

  def return_cell_step_two(index)
    return @cells[index] if index < @cells.count

    nil
  end

end

# documentation
class Cell

  attr_accessor :ws_idx, :column, :name, :value, :col_idx, :row_idx

  include Enumerable

  def initialize(ws_idx, value, col_idx, row_idx)
    @ws_idx = ws_idx
    @name = value
    @value = value
    @col_idx = col_idx
    @row_idx = row_idx
  end

  def write_myself
    worksheet = $spread_sheet.worksheets[ws_idx]
    worksheet[@row_idx.to_i, @col_idx.to_i] = @value.to_s
    worksheet.save
  end

  def delete_myself
    @column.cells.delete(self)
    @value = ''
    worksheet = $spread_sheet.worksheets[ws_idx]
    worksheet[@row_idx.to_i, @col_idx.to_i] = ''
    worksheet.save
  end

  def to_s
    value
  end

end
