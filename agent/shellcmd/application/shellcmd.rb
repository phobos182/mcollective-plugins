class MCollective::Application::Shellcmd<MCollective::Application
    description "Remote shell command"

    usage "mco shellcmd [options] [filters] --cmd=<command>"

    option :cmd,
        :description    => "Command to pass to agent",
        :arguments      => ["--cmd", "--command COMMAND"]

    option :action,
        :description    => "Action to pass to the agent",
        :arguments      => ["-a", "--action ACTION"],
        :type           => :string,
        :default        => "execute"

    def validate_configuration(configuration)
        if MCollective::Util.empty_filter?(options[:filter])
            print "Do you really want to operate on " +
                "shellcmds unfiltered? (y/n): "

            STDOUT.flush

            # Only match letter "y" or complete word "yes" ...
            exit! unless STDIN.gets.strip.match(/^(?:y|yes)$/i)
        end
    end

    def main
        #
        # We have to change our process name in order to hide name of the
        # shellcmd we are looking for from our execution arguments.  Puppet
        # provider will look at the process list for the name of the shellcmd
        # it wants to manage and it might find us with our arguments there
        # which is not what we really want ...
        #
        $0 = "mco"
        exitcode = 0

        mc = rpcclient("shellcmd")

        mc.agent_filter(configuration[:agent])
        mc.discover :verbose => false

        mc.send(configuration[:action], { :cmd => configuration[:cmd] }).each do |node|
            output   = node[:data][:output]
            exitcode = node[:data][:exitcode]

            if mc.verbose
                puts "[#{node[:sender]}] exit=#{exitcode}:\n#{output}\n"
            else
                if output.length > 80
                    output = output[0..80] + " ..."
                end
                puts "[#{node[:sender]}] exit=#{exitcode}: #{output.chomp}"
            end
        end

        mc.disconnect
        exit exitcode
    end
end
