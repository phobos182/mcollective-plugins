metadata :name        => "Yum Agent",
         :description => "Agent to manipulate Yum",
         :author      => "Jeremy Carroll",
         :license     => "Apache v.2",
         :version     => "1.1",
         :url         => "http://www.networkedinsights.com",
         :timeout     => 240

["enable","disable","status"].each do |act|
  action act, :description => "#{act.capitalize} a repository" do
    input :repository,
          :prompt      => "Repository",
          :description => "The name of the yum repository to #{act}",
          :type        => :string,
          :validation  => '^.+$',
          :optional    => false,
          :maxlength   => 30
          
    output :name,
           :description => "Display name of the repository",
           :display_as  => "Name"
           
    output :status,
           :description => "Status of the repository",
           :display_as  => "Status"
           
    output :packages,
           :description => "Packages available in repository",
           :display_as  => "Packages"
  end
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
          :maxlength   => 90
          
    input :excludes,
          :prompt      => "Excludes",
          :description => "Packages to exclude from updating",
          :type        => :string,
          :validation  => '^.+$',
          :optional    => true,
          :maxlength   => 90


    output :updated,
           :description => "Packages that were updated",
           :display_as  => "Updated"

end
