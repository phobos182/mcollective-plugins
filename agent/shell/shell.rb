module MCollective
 module Agent
  class Shell<RPC::Agent

    metadata    :name        => "Shell Command",
                :description => "Remote execution of bash commands",
                :author      => "Jeremy Carroll",
                :license     => "Apache v.2",
                :version     => "1.0",
                :url         => "http://github.com/phobos182/mcollective-plugins",
                :timeout     => 300

    action "execute" do
        validate :cmd, String
        validate :full, :bool

        out = []
        err = ""

        begin
          status = run("#{request[:cmd]}", :stdout => out, :stderr => err, :chomp => false)
        rescue Exception => e
          reply.fail e.to_s
        end

        reply[:exitcode] = status
        # If status set to true, then return all output
        if request[:full].to_s =~ /(true|t|yes|y|1)$/i
          reply[:stdout] = out.join(" ")
        else
          reply[:stdout] = out[0][0..76] + " ..."
        end
        reply.fail err if status != 0
    end

  end
 end
end
