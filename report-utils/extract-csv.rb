require 'json'
require 'csv'

raise Exception, 'you must provide a result folder' unless ARGV[0]

result_folder_name = ARGV[0].split('/')[ARGV[0].split('/').length - 1]

puts "Creating #{result_folder_name}.csv"

stats_path = ARGV[0] + '/js/stats.json'
stats = JSON.parse(File.open(stats_path).read)

# the 'group' name will be something like 'group_nooptestwithout-9eb19'
group_keys = stats['contents'].keys.select { |key| key.to_s.match(/group/) }
group_node = stats['contents'][group_keys[0]]

MAX = 'maxResponseTime'
MEAN = 'meanResponseTime'
STD = 'standardDeviation'
TOTAL = 'total'

# totals row is in the 'stats' node
totals = group_node['stats']

# transaction rows are in the 'contents' node
contents = group_node['contents']

catalog = contents[contents.keys[4]]['stats']
filemeta_mco_plugins = contents[contents.keys[5]]['stats']
filemeta_plugins = contents[contents.keys[2]]['stats']
filemeta_pluginfacts = contents[contents.keys[1]]['stats']
locales = contents[contents.keys[3]]['stats']
node = contents[contents.keys[0]]['stats']
report = contents[contents.keys[6]]['stats']

CSV.open("./#{result_folder_name}.csv", "wb") do |csv|
  csv << ["Duration","max ms","mean ms","std dev"]
  csv << ["Total", totals[MAX][TOTAL], totals[MEAN][TOTAL], totals[STD][TOTAL]]
  csv << ["catalog", catalog[MAX][TOTAL], catalog[MEAN][TOTAL], catalog[STD][TOTAL]]
  csv << ["filemeta mco plugins", filemeta_mco_plugins[MAX][TOTAL], filemeta_mco_plugins[MEAN][TOTAL], filemeta_mco_plugins[STD][TOTAL]]
  csv << ["filemeta plugins", filemeta_plugins[MAX][TOTAL], filemeta_plugins[MEAN][TOTAL], filemeta_plugins[STD][TOTAL]]
  csv << ["filemeta pluginfacts", filemeta_pluginfacts[MAX][TOTAL], filemeta_pluginfacts[MEAN][TOTAL], filemeta_pluginfacts[STD][TOTAL]]
  csv << ["locales", locales[MAX][TOTAL], locales[MEAN][TOTAL], locales[STD][TOTAL]]
  csv << ["node", node[MAX][TOTAL], node[MEAN][TOTAL], node[STD][TOTAL]]
  csv << ["report", report[MAX][TOTAL], report[MEAN][TOTAL], report[STD][TOTAL]]
end