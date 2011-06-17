module MCollective
  module Agent
    class Yum<RPC::Agent
      metadata :name        => "Yum Agent",
               :description => "Agent to manipulate Yum Updates",
               :author      => "Jeremy Carroll",
               :license     => "Apache v.2",
               :version     => "1.1",
               :url         => "http://www.networkedinsights.com",
               :timeout     => 240

               ["enable","disable","status"].each do |act|
                 action act do
                   validate :repository, :shellsafe
                   case act
                   when "enable"
                     enable()
                   when "disable"
                     disable()
                   when "status"
                     status()
                   end
                 end
               end
               
               def enable()
                 output = augeas("#{request[:repository]}", 1)
                 reply[:status] = output
               end
               
               def disable()
                 output = augeas("#{request[:repository]}", 0)
                 reply[:status] = output
               end
               
               def augeas(repository, boolean)
                 require 'puppet'
                 path = '/files/etc/yum.repos.d/'
                 begin
                   aug = ::Puppet::Type.type("augeas").new(:name => "change" , :context => "#{path}*/#{repository}", :changes => "set enabled #{boolean.to_s}").provider
                   reply = aug.execute_changes
                   aug.close_augeas
                 rescue Exception => e
                   reply.fail e.to_s
                 end
                 return reply.to_s
               end
               def status()
                 output = check_status("#{request[:repository]}")
                 if ! (output[0].empty? || output[0].nil?)
                   reply[:status] = output[0]
                 else
                   reply[:status] = "absent"
                 end
                 if ! (output[1].empty? || output[1].nil?)
                   reply[:packages] = output[1]
                 end
               end

               def check_status(repository)
                 packages = ''
                 status = ''
                 shell = %x[/usr/bin/yum --color=never repolist all]
                 shell.each do |line|
                   repo = line.gsub(/\s\s+/,',')\
                    .split(',')[0]\
                    .to_s.chomp
                   repo_status = line.gsub(/\s\s+/,',')\
                    .split(',')[2]\
                    .to_s.split(":")[0]\
                    .to_s.chomp
                   if "#{repo_status}" == "enabled" || "#{repo_status}" == "disabled"
                     if "#{repo.chomp}" == "#{repository}"
                       status = "#{repo_status}"
                       if "#{status}" == "enabled"
                         packages = line.split(":")[1].gsub(/\s/,"").chomp
                       end
                     end
                   end
                 end
                 return status, packages
               end
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
                     rpmpackage = line.gsub(/\s\s+/,', 1 ').split(',')[0].to_s.chomp
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
                   shellcode = %x[/usr/bin/yum -qy update]
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
                         if !(pkgname.empty?) && !(pkgname.downcase.include? "updated:")
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
                     if File.directory?("/proc/#{pid}/")
                       reply.fail! "Yum is currently in use"
                       return 1
                     else
                       return 0
                     end
                   end
                 end
    end #class Yum<RPC::Agent
  end #module Agent
end #module MCollective