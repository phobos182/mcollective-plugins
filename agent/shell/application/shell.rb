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
    full_status = 'false'
    mc = rpcclient("shell")
    mc.agent_filter(configuration[:agent])
    mc.discover :verbose => true

    full_status = 'true' if mc.verbose
    mc.execute(:cmd => ARGV.join(" "), :full => full_status).each do |node|
      output = node[:data][:stdout]
      puts "[#{node[:sender]}] exit=#{node[:data][:exitcode]}: #{output}\n"
    end

    mc.disconnect
  end
end
