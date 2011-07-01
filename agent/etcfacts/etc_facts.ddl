metadata    :name        => "Utility for /etc/facts.txt Fact File",
            :description => "A conduit to inspect and modify your /etc/facts.txt file.",
            :author      => "Gary Larizza <glarizza@me.com>, Jeremy Carroll <phobos182@gmail.com>",
            :license     => "Apache License, Version 2.0",
            :version     => "1.1",
            :url         => "http://marionette-collective.org/",
            :timeout     => 3

["search", "add", "removevalue"].each do |act|
    action act, :description => "#{act.capitalize} a fact in /etc/facts.txt" do
        display :always

        input :fact,
            :prompt      => "Fact",
            :description => "Fact to #{act.capitalize}",
            :type        => :string,
            :validation  => '^.+$',
            :optional    => false,
            :maxlength   => 30

        input :value,
            :prompt      => "Value",
            :description => "Value to #{act.capitalize}",
            :type        => :string,
            :validation  => '^.+$',
            :optional    => false,
            :maxlength   => 30

        output :msg,
            :description => "Return message from the command",
            :display_as  => "Message"

    end
end

action "removefact", :description => "Remove a fact" do
    display :always

    input :fact,
          :prompt      => "Fact",
          :description => "The name of the fact you wish to remove",
          :type        => :string,
          :validation  => '^.+$',
          :optional    => false,
          :maxlength   => 30

    output :msg,
           :description => "Return message from the command",
           :display_as  => "Message"

end
