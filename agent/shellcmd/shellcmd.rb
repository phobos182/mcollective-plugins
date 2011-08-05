module MCollective
 module Agent
  class Shellcmd<RPC::Agent

    metadata    :name        => "Shell Command",
                :description => "Remote execution of bash commands",
                :author      => "Jeremy Carroll",
                :license     => "Apache v.2",
                :version     => "1.0",
                :url         => "http://github.com/phobos182/mcollective-plugins",
                :timeout     => 300

    action "execute" do
        validate :cmd, String

        reply[:output]   = %x[/bin/bash -l -c '#{request[:cmd]}']
        reply[:exitcode] = $?.exitstatus
    end

  end
 end
end
