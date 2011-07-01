module MCollective
    module Agent
        class Etc_facts<RPC::Agent
              metadata    :name        => "Utility for /etc/facts.txt Fact File",
                          :description => "A conduit to inspect and modify your /etc/facts.txt file.", 
                          :author      => "Gary Larizza <glarizza@me.com>, Jeremy Carroll <phobos182@gmail.com>",
                          :license     => "Apache License, Version 2.0",
                          :version     => "1.1",
                          :url         => "http://marionette-collective.org/",
                          :timeout     => 3
              
              # Search action:  This action will check for a specified value from a specified fact.
              # =>               if either the fact or the value is incorrect, you will be alerted.
              # Variables:
              # =>              fact  => The fact for which we're checking a value
              # =>              value => The value for which we're searching
        
              action "search" do
                 validate :value, String
                 validate :fact, String

                 hash = check_file
                 message = []

                 if hash == "false"
                   reply.fail = "The /etc/facts.txt file was not found."
                 else
                   if hash.size == 0
                     reply[:msg] = "No results"
                   else
                     if hash.has_key?(request[:fact])
                       results = hash[request[:fact]].to_s.split(",")
                       results.each do |val|
                         if val =~ /#{request[:value]}/
                           message = message << "#{val}"
                         end
                         if !(message.nil? || message.empty?)
                           reply[:msg] = "#{message.join(",")}"
                         else
                           reply[:msg] = "No results"
                         end
                       end
                     else
                       reply[:msg] = "No results"
                     end
                   end
                 end
                end # Action end.
 
                # Removevalue action:  This action removes a specified value from the specified fact.  If the
                # =>               value or fact is not found, we return an error.
                # Variables:
                # =>              fact  => The fact for which we're removing a value.
                # =>              value => The value we're removing.
                
                action "removevalue" do
                  
                  validate :value, String
                  validate :fact, String
                  
                  hash = check_file
                  
                  if hash == "false"
                     reply.fail "The /etc/facts.txt file was not found."
                  else
                    if hash.size == 0
                       reply[:msg] = "absent"
                    else
                      if hash.has_key?(request[:fact])
                        if hash[request[:fact]] =~ /,#{request[:value]},/ or hash[request[:fact]] =~ /,#{request[:value]}/
                           hash[request[:fact]][",#{request[:value]}"]= ""
                           write_to_file(hash)
                           reply[:msg] = "removed"
                        elsif hash[request[:fact]] =~ /#{request[:value]},/
                           hash[request[:fact]]["#{request[:value]},"]= ""
                           write_to_file(hash)
                           reply[:msg] = "removed"
                        elsif hash[request[:fact]] == request[:value]
                           hash.delete(request[:fact])
                           write_to_file(hash)
                           reply[:msg] = "removed"
                        else
                           reply[:msg] = "absent"
                        end
                      else
                           reply[:msg] = "absent"
                      end
                    end      
                  end
                end # Action end.
              
                # Removefact action:  This action removes a specified facts.  If the
                # =>                  fact is not found, we return an error.
                # Variables:
                # =>              fact  => The fact for which we're removing.
 
                action "removefact" do
                  
                  validate :fact, String
                  
                  hash = check_file
                  
                  if hash == "false"
                     reply.fail "The /etc/facts.txt file was not found."
                  else
                    if hash.size == 0
                       reply[:msg] = "absent"
                    else
                      if hash.has_key?(request[:fact])
                           hash.delete(request[:fact])
                           write_to_file(hash)
                           reply[:msg] = "removed"
                      else
                           reply[:msg] = "absent"
                      end
                    end      
                  end
                end # Action end.
 
                #  addvalue Action:  This action will add the specified value to the specified fact by simply
                #                     appending it to the end of the list with a comma.
                #  Variables:
                # =>                fact  => The fact to which we're appending a value.
                # =>                value => The actual value we're appending for the specified fact.
                
                action "add" do
                  
                  validate :value, String
                  validate :fact, String
                  
                  hash = check_file
                  
                  if hash == "false"
                     newfile = {}
                     newfile[request[:fact]] = "#{request[:value]}"
                     write_to_file(newfile)
                     reply[:msg] = "added"
                  else 
                    if hash.size == 0
                          hash[request[:fact]] = "#{request[:value]}"
                          write_to_file(hash)
                          reply[:msg] = "added"
                    else
                      if hash.has_key?(request[:fact])
                        if hash[request[:fact]] =~ /#{request[:value]}/
                          reply[:msg] = "exists"
                        else
                          if hash[request[:fact]].nil?
                            hash[request[:fact]] = "#{request[:value]}"
                            write_to_file(hash)
                          reply[:msg] = "added"
                          else
                            hash[request[:fact]] += ",#{request[:value]}"
                            write_to_file(hash)
                            reply[:msg] = "added"
                          end
                        end
                      else
                          hash[request[:fact]] = "#{request[:value]}"
                          write_to_file(hash)
                          reply[:msg] = "added"
                      end
                    end
                  end
                end # Action end.
                
                def check_file
                  h = {}
                  
                  if File.exists?("/etc/facts.txt")
                     File.open("/etc/facts.txt") do |fp|
                        fp.each do |line|
                          key, value = line.chomp.split("=")
                          h[key] = value
                        end
                      end
                      return h
                    else
                      return "false"
                    end
                end # Def end
                
                def write_to_file(h)
                  File.open("/etc/facts.txt", 'w') do |fp|
                    h.each{|key, value| fp.puts "#{key}=#{value}"}
                  end       
                  reply[:facts] = h
                end # Def end
                
                def append_to_file(key, value)
                  File.open("/etc/facts.txt", 'a+') do |fp|
                    fp.puts "#{key}=#{value}"
                  end
                end # Def end
                  
                
        end # Class Etc_facts end
        
  end # Module Agent end
  
end # Module MCollective end
