metadata :name        => "Yum Agent",
        :description => "Agent to manipulate Yum",
        :author      => "Jeremy Carroll",
        :license     => "Apache v.2",
        :version     => "1.0",
        :url         => "http://www.networkedinsights.com",
        :timeout     => 120

action "repo", :description => "Check yum repository status" do
    display :always

    input :repository,
          :prompt      => "Repository",
          :description => "The name of the yum repository to check",
          :type        => :string,
          :validation  => '^.+$',
          :optional    => false,
          :maxlength   => 30

    output :status,
           :description => "Status of the repository (enabled|disabled)",
           :display_as  => "Status"
end

action "check", :description => "Check if updates are available" do
    display :never

    output :packages,
           :description => "Packages marked to be updated",
           :display_as  => "Packages"

end

action "update", :description => "Update packages on a system" do 
    display :always

    input :package,
          :prompt      => "Package",
          :description => "The name of the yum package to update",
          :type        => :string,
          :validation  => '^.+$',
          :optional    => true,
          :maxlength   => 30

    output :updated,
           :description => "Packages that were updated",
           :display_as  => "Updated"

end
