require 'csv'

def diff(a, b)
  result = ( (b.to_f - a.to_f) / a.to_f ) * 100
  "#{result.round(2).to_s}%"
end

raise Exception, 'you must provide two csv files to compare' unless ARGV[1]

result_a_name = ARGV[0].split('/')[ARGV[0].split('/').length - 1].gsub('.csv','')
result_b_name = ARGV[1].split('/')[ARGV[1].split('/').length - 1].gsub('.csv','')
comp_name = "#{result_a_name}_vs_#{result_b_name}.csv"

puts "Comparing #{result_a_name} and #{result_b_name}"
puts "Creating #{comp_name}"

result_a = CSV.read(ARGV[0])
result_b = CSV.read(ARGV[1])

CSV.open("./#{comp_name}", "wb") do |csv|
  csv << ['','A', '', '', 'B', '', '']
  csv << ["Duration", "max ms", "mean ms", "std dev", "max ms", "mean ms", "std dev", "% (mean) diff"]

  csv << ["Total", result_a[1][1], result_a[1][2], result_a[1][3], result_b[1][1], result_b[1][2], result_b[1][3], diff(result_a[1][2], result_b[1][2])]
  csv << ["catalog", result_a[2][1], result_a[2][2], result_a[2][3], result_b[2][1], result_b[2][2], result_b[2][3], diff(result_a[2][2], result_b[2][2])]
  csv << ["filemeta mco plugins", result_a[3][1], result_a[3][2], result_a[3][3], result_b[3][1], result_b[3][2], result_b[3][3], diff(result_a[3][2], result_b[3][2])]
  csv << ["filemeta plugins", result_a[4][1], result_a[4][2], result_a[4][3], result_b[4][1], result_b[4][2], result_b[4][3], diff(result_a[4][2], result_b[4][2])]
  csv << ["filemeta pluginfacts", result_a[5][1], result_a[5][2], result_a[5][3], result_b[5][1], result_b[5][2], result_b[5][3], diff(result_a[5][2], result_b[5][2])]
  csv << ["locales", result_a[1][1], result_a[6][2], result_a[6][3], result_b[6][1], result_b[6][2], result_b[6][3], diff(result_a[6][2], result_b[6][2])]
  csv << ["node", result_a[7][1], result_a[7][2], result_a[7][3], result_b[7][1], result_b[7][2], result_b[7][3], diff(result_a[7][2], result_b[7][2])]
  csv << ["report", result_a[8][1], result_a[8][2], result_a[8][3], result_b[8][1], result_b[8][2], result_b[8][3], diff(result_a[8][2], result_b[8][2])]
end
