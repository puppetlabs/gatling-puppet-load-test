# TODO: move to perf_results_helper.rb
# TODO: update to call csv2html

require "json"
require "csv"

raise Exception, "you must provide a results directory" unless ARGV[0]
results_dir = ARGV[0]
results_name = File.basename(results_dir)
output_path = "#{results_dir}/#{results_name}.csv"

stats_path = "#{results_dir}/js/stats.json"

puts "Examining Gatling data: #{stats_path}"
puts

stats = JSON.parse(File.open(stats_path).read)

# the 'group' name will be something like 'group_nooptestwithout-9eb19'
group_keys = stats["contents"].keys.select { |key| key.to_s.match(/group/) }
group_node = stats["contents"][group_keys[0]]

MAX = "maxResponseTime"
MEAN = "meanResponseTime"
STD = "standardDeviation"
TOTAL = "total"

# totals row is in the 'stats' node
totals = group_node["stats"]

# transaction rows are in the 'contents' node
contents = group_node["contents"]

# TODO: verify each key
puts "There are #{contents.keys.length} keys"
puts

for i in 0..contents.keys.length - 1 do
  name = contents[contents.keys[i]]["name"]
  puts "key #{i}: #{name}"
end

node = contents[contents.keys[0]]["stats"]
filemeta_pluginfacts = contents[contents.keys[1]]["stats"]
filemeta_plugins = contents[contents.keys[2]]["stats"]
locales = contents[contents.keys[3]]["stats"]
catalog = contents[contents.keys[4]]["stats"]
report = contents[contents.keys[5]]["stats"]

puts "Creating #{output_path}"
puts

CSV.open(output_path, "wb") do |csv|
  csv << ["Duration","max ms","mean ms","std dev"]
  csv << ["Total", totals[MAX][TOTAL], totals[MEAN][TOTAL], totals[STD][TOTAL]]
  csv << ["catalog", catalog[MAX][TOTAL], catalog[MEAN][TOTAL], catalog[STD][TOTAL]]
  csv << ["filemeta plugins", filemeta_plugins[MAX][TOTAL], filemeta_plugins[MEAN][TOTAL], filemeta_plugins[STD][TOTAL]]
  csv << ["filemeta pluginfacts", filemeta_pluginfacts[MAX][TOTAL], filemeta_pluginfacts[MEAN][TOTAL], filemeta_pluginfacts[STD][TOTAL]]
  csv << ["locales", locales[MAX][TOTAL], locales[MEAN][TOTAL], locales[STD][TOTAL]]
  csv << ["node", node[MAX][TOTAL], node[MEAN][TOTAL], node[STD][TOTAL]]
  csv << ["report", report[MAX][TOTAL], report[MEAN][TOTAL], report[STD][TOTAL]]
end
