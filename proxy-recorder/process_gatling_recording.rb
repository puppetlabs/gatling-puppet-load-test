#!/usr/bin/env ruby

TERMINOLOGY = {
  "catalog"                                                 => "catalog",
  "file_metadata[s]?/modules/puppet_enterprise/mcollective" => "filemeta mco plugins",
  "file_metadata[s]?/pluginfacts"                           => "filemeta pluginfacts",
  "file_metadata[s]?/plugins"                               => "filemeta plugins",
  "file_metadata[s]?/modules"                               => "filemeta",
  "file_content/modules"                                    => "file content",
  "static_file_content/modules"                             => "static file content",
  "node"                                                    => "node",
  "report"                                                  => "report",
}

def lookup_request_match(line, prefix)
  TERMINOLOGY.each do |url, rewrite|
    if line.match(prefix + "/" + url)
      return rewrite
    end
  end
end

def comment_line(line)
  "// #{line}"
end

def step1_look_for_inferred_html_resources()
  puts "STEP 1: Look for inferred HTML resources"
  puts "\t(Not yet implemented)"
end

# Step 2
def step2_rename_package(text)
  puts "STEP 2: Renaming package to `com.puppetlabs.gatling.node_simulations`"
  text.gsub!(/^\s*package (.*)/, "package com.puppetlabs.gatling.node_simulations")
end

# Step 3
def step3_add_new_imports(text)
  puts "STEP 3: Adding additional import statements (for SimulationWithScnario and date/time classes)"
  out_text = text.lines.map do |line|
    if line.match(/package com.puppetlabs.gatling.node_simulations$/)
      [line,
        "import com.puppetlabs.gatling.runner.SimulationWithScenario\n",
        "import org.joda.time.LocalDateTime\n",
        "import org.joda.time.format.ISODateTimeFormat\n",
        "import java.util.UUID\n",
      ]
    else
      line
    end
  end

  out_text.flatten.join
end

# Step 4
def step4_remove_unneeded_import(text)
  puts "STEP 4: Removing unused JDBC import"
  text.gsub!(/^\s*(import io\.gatling\.jdbc\.Predef\._)/, '// \1')
end

# Step 5
def step5_update_extends(text)
  puts "STEP 5: Set class to extend `SimulationWithScenario`"
  text.gsub!(/^class (.*) extends Simulation/, 'class \1 extends SimulationWithScenario')
end

# Step 6
def step6_comment_out_http_protocol(text)
  puts "STEP 6: Comment out `httpProtocol` variable"
  begin_comment = false
  end_comment = false

  out_text = text.lines.map do |line|
    retline = ""
    begin_comment = true if line.match(/^.*val httpProtocol/)
    if begin_comment && !end_comment
      retline = comment_line(line)
    else
      retline = line
    end
    # This end check won't work with long chains
    end_comment = true if line.match(/\..*\)/)
    retline
  end
  out_text.flatten.join
end

# Step 7
# TODO define this method
def step7_add_connection_close(text)
  puts "STEP 7: Add 'Connection: close' after report request"
  puts "\t(Not yet implemented)"
end

# Step 8
def step8_comment_out_uri1(text)
  puts "STEP 8: Comment out `uri1` variable"
  text.gsub!(/^\s*(val uri1 = ".*")/, '// \1')
end

# Step 9
def step9_update_expiration(text)
  puts "STEP 9: Update facts expiration date"
  text.gsub!(/(expiration%22%3A%22)(\d{4})/, '\12125')
end

# Step 10
# TODO define this method
def step10_add_dynamic_timestamp(text)
  puts "STEP 10: Use dynamic timestamp and transaction UUID"
  puts "\t(Not yet implemented)"
end

# Step 11
def step11_comment_out_setup(text)
  puts "STEP 11: Comment out SCN setUp call since driver will handle it"
  text.gsub!(/^\s*(setUp\(.*\))/, '// \1')
end

# Step 12
def step12_rename_request_bodies(text)
  puts "STEP 12: Add names for HTTP requests"
  current_replacement = ""
  out_text = ""
  # Here we replace request types according to step 12 in
  # https://github.com/puppetlabs/gatling-puppet-load-test/blob/master/simulation-runner/README-GENERATING-AGENT-SIMULATIONS.md
  text.lines.reverse.each do |line|
    #TODO toggle v3 URLs (Puppet 4) vs Puppet 3 URLs
    if line.match(%r(\.(get|post|put)\("\/puppet\/v3\/))
      if lookup = lookup_request_match(line, "/puppet/v3")
        current_replacement = lookup
      else
        fail "Unrecognized request type. Please add to TERMINOLOGY."
      end
      out_text << line
    elsif line.match(/\.?exec\(http\("request_\d+"\)/) && !current_replacement.empty?
      out_text << line.sub(/request_\d+/, current_replacement)
      current_replacement = ""
    elsif line.match(/\.?exec\(http\("request_\d+"\)/) && current_replacement.empty?
      fail "Unexpected http request. Line: '#{line}' needs some work"
    else
      out_text << line
    end
  end

  out_text
end

def step13_setup_node_feeder()
  puts "STEP 13: Set up ${node} var for feeder"
  puts "\t(Not yet implemented)"
end

def main(infile, outfile)
  # The main event.
  # the input file tends to not end in a newline, which gets messy later
  input = File.read(infile) + "\n"

  puts "Reading input from file '#{infile}'"

  output = input.dup

  step1_look_for_inferred_html_resources()
  step2_rename_package(output)
  output = step3_add_new_imports(output)
  step4_remove_unneeded_import(output)
  step5_update_extends(output)
  output = step6_comment_out_http_protocol(output)
  step7_add_connection_close(output)
  step8_comment_out_uri1(output)
  step9_update_expiration(output)
  step10_add_dynamic_timestamp(output)
  step11_comment_out_setup(output)
  output = step12_rename_request_bodies(output)
  step13_setup_node_feeder()

  puts "All steps completed, writing output to file '#{outfile}'"
  # Dump the reformatted file to disk
  File.open(outfile, 'w').write(output.split("\n").reverse.join("\n"))
end

if $0 == __FILE__
  if ARGV[0] && File.exists?(ARGV[0])
    infile = ARGV[0]
    outfile = infile + ".new"
    main(infile, outfile)
  else
    fail "Input file is a required argument"
  end
end
