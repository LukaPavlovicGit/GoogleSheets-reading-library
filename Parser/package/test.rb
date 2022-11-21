require_relative './Parser'

parser = Parser.new
tables = parser.load_tables

if tables.count > 6

  # Print table matrices
  k = 0
  tables.each do |table|
    print "table #{k}: \n"
    puts table
    k += 1
  end
  puts

  # Test enumerable
  print 'tables[1] enumeration: '
  tables[1].each do |cell|
    print "#{cell.to_s}, "
  end
  puts

  # Test row
  print 'tables[2].row(3): '
  p tables[2].row(3)

  # Test column
  print "tables[2]['trecaKolona']:"
  puts tables[2]['trecaKolona']
  puts

  print "tables[2].trecaKolona:"
  puts tables[2].trecaKolona
  puts

  print "tables[2].trecaKolona.sum = "
  puts tables[2].trecaKolona.sum
  puts

  print "tables[2].trecaKolona.avg = "
  puts tables[2].trecaKolona.avg
  puts

  print "tables[0].prvaKolona.my_map{ |cell| cell += 1 } = "
  p tables[1].drugaKolona.my_map{ |cell| cell *= 10 }
  puts

  print "tables[0].prvaKolona.my_map = "
  p tables[1].drugaKolona.my_map
  puts

  print "tables[1].drugaKolona.my_select{|num|  num.even? } = "
  p tables[1].drugaKolona.my_select{ |num|  num.even? }
  puts

  print "tables[1].drugaKolona.my_select = "
  p tables[1].drugaKolona.my_select
  puts

  print "tables[4].drugaKolona.my_reduce(0) { |sum, num| sum + num } = "
  p tables[4].drugaKolona.my_reduce(0) { |sum, num| sum + num }
  puts

  # Cell test
  print "tables[2]['trecaKolona'][2] = "
  puts tables[2]['trecaKolona'][2]
  puts

  print "tables[2]['trecaKolona'][2] = 77 -> new value:"
  tables[2]['trecaKolona'][2] = 77
  puts tables[2]['trecaKolona'][2]
  puts

  print "tables[2].trecaKolona.drugaCelija = "
  puts tables[3].trecaKolona.drugaCelija
  puts

  # Test table addition
  puts 'tables[4] = tables[4] + tables[5]:'
  tables[4] = tables[4] + tables[5]
  puts tables[4]
  puts
  # Test table subtraction
  puts 'tables[6] = tables[6] - tables[5]:'
  tables[6] = tables[6] - tables[5]
  puts tables[6]
  puts

end