class MCollective::Application::Shell < MCollective::Application
  description "MCollective Distributed Shell"
  usage <<-EOF
  mco shell <CMD>

  The CMD is a string

  EXAMPLES:
    mco shell uptime
EOF

  def validate_configuration(configuration)
    if MCollective::Util.empty_filter?(options[:filter])
      print "Do you really want to send this command unfiltered? (y/n): "
      STDOUT.flush

      # Only match letter "y" or complete word "yes" ...
      exit! unless STDIN.gets.strip.match(/^(?:y|yes)$/i)
    end
  end

  def main
    $0 = "mco"
    mc = rpcclient("shell")
    mc.agent_filter(configuration[:agent])
    mc.discover :verbose => true
    # If the user sets the verbose flag, we want the full status
    full_status = mc.verbose

    mc.execute(:cmd => ARGV.join(" "), :full => full_status).each do |node|
      output = node[:data][:stdout]
      if full_status and node[:data][:exitcode] != 0
        puts "[#{node[:sender]}] exit=#{node[:data][:exitcode]}"
        puts "\tSTDERR: #{node[:data][:stderr]}"
        puts "\tSTDOUT: #{node[:data][:stdout]}\n"
      else
        puts "[#{node[:sender]}] exit=#{node[:data][:exitcode]}: #{node[:data][:stdout]}"
      end
    end

    mc.disconnect
  end
end
