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

# Step 2
def rename_package(text)
  text.gsub!(/^\s*package (.*)/, "package com.puppetlabs.gatling.node_simulations")
end

# Step 3
def add_new_imports(text)
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
def remove_unneeded_import(text)
  text.gsub!(/^\s*(import io\.gatling\.jdbc\.Predef\._)/, '// \1')
end

# Step 5
def update_extends(text)
  text.gsub!(/^class (.*) extends Simulation/, 'class \1 extends SimulationWithScenario')
end

# Step 6
def comment_out_http_protocol(text)
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
def add_connection_close(text)
end

# Step 8
def comment_out_uri1(text)
  text.gsub!(/^\s*(val uri1 = ".*")/, '// \1')
end

# Step 9
def update_expiration(text)
  text.gsub!(/(expiration%22%3A%22)(\d{4})/, '\12025')
end

# Step 10
# TODO define this method
def add_dynamic_timestamp(text)
end

# Step 11
def comment_out_setup(text)
  text.gsub!(/^\s*(setUp\(.*\))/, '// \1')
end

# Step 12
def rename_request_bodies(text)
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

def main(infile, outfile)
  # The main event.
  # the input file tends to not end in a newline, which gets messy later
  input = File.read(infile) + "\n"

  output = input.dup

  rename_package(output)
  output = add_new_imports(output)
  remove_unneeded_import(output)
  update_extends(output)
  output = comment_out_http_protocol(output)
  add_connection_close(output)
  comment_out_uri1(output)
  update_expiration(output)
  add_dynamic_timestamp(output)
  comment_out_setup(output)
  output = rename_request_bodies(output)

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
