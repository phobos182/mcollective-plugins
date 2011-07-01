class MCollective::Application::Yum<MCollective::Application
    description "Yum Manager"
    usage "Usage: mc yum [options] action (package|repository)"
    
    def post_option_parser(configuration)
      configuration[:action] = ARGV.shift
      unless configuration[:action] =~ /^(enable|disable|status|check|update)$/
        puts("Action has to be enable, disable, stats, check, or update")
        exit 1
      end

      case ARGV.length
      when 1
        case configuration[:action]
        when "enable","disable","status"
          configuration[:repository] = ARGV.shift
        when "update"
          configuration[:excludes] = ARGV.shift
        else
          puts "Invalid argument for action"
          exit 1
        end
      when 0
        unless (configuration[:action] == 'check' || configuration[:action] == 'update')
          puts("Missing argument for action")
          exit 1
        end
      else
        puts("Invalid number of arguments for action")
        usage
        exit 1
      end
    end

    def validate_configuration(configuration)
        if MCollective::Util.empty_filter?(options[:filter])
            print("Do you really want to operate on packages unfiltered? (y/n): ")
            STDOUT.flush

            exit unless STDIN.gets.chomp =~ /^y$/
        end
    end

    def summarize(stats, results)
        puts("\n---- yum agent summary ----")
        puts("           Nodes: #{stats[:discovered]} / #{stats[:responses]}")
        print("        results: ")

        puts results.keys.sort.map {|s| "#{results[s]} * #{s}" }.join(", ")

        printf("    Elapsed Time: %.2f s\n\n", stats[:blocktime])
    end

    def main
        yum = rpcclient("yum", :options => options)

        results = {}
        case configuration[:action]
        when "enable","disable","status"
          yum.send(configuration[:action], {:repository => configuration[:repository]}).each do |resp|
            if resp[:statuscode] == 0
              status = resp[:data][:status]
              name = resp[:data][:name]
              printf("%-40s status = %s%s\n", resp[:sender], name, status)
              results.include?(status) ? results[status] += 1 : results[status] = 1
            else
                printf("%-40s error = %s\n", resp[:sender], resp[:statusmsg])
            end
          end
        when "check", "update"
          yum.send(configuration[:action]).each do |resp|
            package_name = ''
            if resp[:statuscode] == 0
              status = resp[:data][:statusmsg]
              updated = resp[:data][:packages]
              if resp[:data].has_key?(:versions)
                resp[:data][:versions].to_s.chomp.split(" ").each do |v|
                  package_name += " #{v.split("=")[0]}"
                end
              end
              printf("%-40s status = %s -%s\n", resp[:sender], updated, package_name)
              results.include?(updated) ? results[updated] += 1 : results[updated] = 1
            else
                printf("%-40s error = %s\n", resp[:sender], resp[:statusmsg])
            end
          end
        end
        summarize(yum.stats, results)
      end
end
