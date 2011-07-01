class MCollective::Application::Etcfacts<MCollective::Application
    description "Etcfacts Manager"
    usage "Usage: mc etcfacts [options] <add|remove|search> <fact> (value)"
    
    def post_option_parser(configuration)
      action = ARGV.shift
      unless action =~ /^(add|remove|search)$/
        puts("Action has to be add, remove, or search")
        exit 1
      end
      case action
        when "remove"
          if ARGV.length == 1
            configuration[:action] = "removefact"
            configuration[:fact] = ARGV.shift
          else
            configuration[:action] = "removevalue"
            configuration[:fact] = ARGV.shift
            configuration[:value] = ARGV.shift
          end
        else
          if ARGV.length != 2
            puts "Invalid Arguments"
            exit 1
          else
            configuration[:action] = action
            configuration[:fact] = ARGV.shift
            configuration[:value] = ARGV.shift
          end
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
        puts("\n---- etcfacts agent summary ----")
        puts("           Nodes: #{stats[:discovered]} / #{stats[:responses]}")
        print("        results: ")

        puts results.keys.sort.map {|s| "#{results[s]} * #{s}" }.join(", ")

        printf("    Elapsed Time: %.2f s\n\n", stats[:blocktime])
    end

    def main
        etcfacts = rpcclient("etc_facts", :options => options)

        results = {}
        case configuration[:action]
        when "add","removefact","removevalue","search"
          etcfacts.send(configuration[:action], {:fact => configuration[:fact], :value => configuration[:value]}).each do |resp|
            if resp[:statuscode] == 0
              message = resp[:data][:msg]
              printf("%-40s status = %s\n", resp[:sender], message)
              results.include?(message) ? results[message] += 1 : results[message] = 1
            else
                printf("%-40s error = %s\n", resp[:sender], resp[:statusmsg])
            end
          end
        summarize(etcfacts.stats, results)
      end
    end
end
