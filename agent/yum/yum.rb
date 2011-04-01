module MCollective
     module Agent
          class Yum<RPC::Agent
               metadata :name        => "Yum Agent",
                        :description => "Agent to manipulate Yum Updates",
                        :author      => "Jeremy Carroll",
                        :license     => "Apache v.2",
                        :version     => "1.0",
                        :url         => "http://www.networkedinsights.com",
                        :timeout     => 120

               action "repo" do
                    validate :repository, String

                    # Check yum status
                    yumstatus = yum_status
                    reply.fail! "Yum is currently in use" unless yumstatus.nil?

                    repofound = 0
                    shellcode = %x[/usr/bin/yum --color=never repolist all]
                    shellcode.each { |line|
                        yumrepo = line.gsub(/\s\s+/,',').split(',')[0].to_s.chomp
                        repostatus = line.gsub(/\s\s+/,',').
                            split(',')[2].
                            to_s.split(":")[0].
                            to_s.chomp
                        if "#{repostatus}" == "enabled" || "#{repostatus}" == "disabled"
                            if "#{yumrepo.chomp}" == "#{request[:repository]}"
                                reply[:status] = "#{repostatus}"
                                repofound = 1
                            end #if
                        end #if
                    } #shellcode.each
                    if repofound.to_i == 0
                        reply[:status] = "absent"
                    end #if
               end #action repo

               action "check" do
                    # Check yum status
                    yumstatus = yum_status
                    reply.fail! "Yum is currently in use" unless yumstatus.nil?

                    updatenum = 0
                    # clean the expires cache before checking for updates
                    shellcode = %x[/usr/bin/yum -q clean expire-cache]
                    shellcode = %x[/usr/bin/yum -q check-update]
                    shellcode.each { |line|
                        rpmpackage = ''
                        version = ''
                        rpmpackage = line.gsub(/\s\s+/,',').split(',')[0].to_s.chomp
                        version = line.gsub(/\s\s+/,',').split(',')[1].to_s.chomp
                        if version.to_s.include? ":"
                            version = version.to_s.split(":")[1].to_s.chomp
                        end #if
                        if !(rpmpackage.empty?)
                            reply[:packages] = "#{reply[:packages]}" + " #{rpmpackage}=#{version}"
                            updatenum = updatenum.to_i + 1
                        end #if
                    } #shellcode.each
                    reply[:updates] = updatenum
                    if updatenum == 0
                        reply[:packages] = "UPDATED"
                    end
               end #action repo

               action "update" do
                    validate :package, String
                    
                    # Check yum status
                    yumstatus = yum_status
                    reply.fail! "Yum is currently in use" unless yumstatus.nil?

                    updatedpkgs = {}
                    rpmsupdated = 0
                    collect = 0
                    version = ''
                    pkgname = ''
                    # clean the expires cache before updating
                    shellcode = %x[/usr/bin/yum -q clean expire-cache]
                    shellcode = %x[/usr/bin/yum -qy update #{request[:package]}]
                    shellcode.each { |line|
                        if line.downcase.include? "updated:"
                            if line.downcase.split(":")[0].to_s == "updated"
                                collect = 1
                                next
                            end #if
                        end #if
                        if line.downcase.include? "complete"
                            collect = 0
                        end #if
                        if collect == 1
                            line = line.chomp.gsub(/\s\s+/,',')
                            updatepackage = line.gsub(/\s\s+/,',').split(',')
                            updatepackage.each { |pkgname|
                                if !(pkgname.empty?)  && !(pkgname.downcase.include? "updated:")
                                    version = pkgname.split(" ")[1].to_s
                                    pkgname = pkgname.split(" ")[0].to_s
                                    if version.to_s.include? ":"
                                        version = version.to_s.split(":")[1].to_s.chomp
                                    end #if
                                    reply[:updated] = "#{reply[:updated]}" + " #{pkgname}=#{version}"
                                    rpmsupdated = rpmsupdated + 1
                                end #if
                            } #updatepackage.each
                        end #if
                    } #shellcode.each
                    if rpmsupdated == 0
                        reply[:updated] = "none"
                    else
			reply[:updated] = rpmsupdated
                    end #if
               end #action update

               def yum_status()
                   if File.exists?("/var/run/yum.pid")
                       pid = File.read("/var/run/yum.pid")
                       status = %x[ps -aux | grep #{pid} | grep -v grep]
                       if !(status.nil? || status.empty?)
                           return 1
                       else
                           return 0
                       end
                    end
               end

          end #class Yum<RPC::Agent
     end #module Agent
end #module MCollective
