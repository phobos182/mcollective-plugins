# MCollective Agents

shell : MCollective agent for remote shell commands
mc-yum : MCollective agent for adding / removing / checking packages using yum
mc-etcfacts : MCollective agent for adding / removing / searching for facts in /etc/facts.txt

## mc-etcfacts

This agent is based around the [etc_facts.rb](https://github.com/ripienaar/facter-facts/blob/master/etcfacts/etc_facts.rb) plugin written by R.I. Pienaar as asll as a blog post from [Gary Larizza](http://glarizza.posterous.com/our-puppet-external-node-infrastructure) regarding his implimentation of the /etc/facts.txt external node classifier. I have modified his code and created a new GitHub repository for his [puppet external node classifier](https://github.com/phobos182/puppet-classifier-etcfacts). The mc-etcfacts program allows modification of the /etc/facts.txt file. I currently use the design pattern of having a local file which I can manipulate to add / remove puppet configurations. Using this MCollective agent I can add a new class to the 'classes' fact, then run puppet with the 'mc-puppetd' agent to pull in the new packages.

### SEARCH
Search all servers /etc/facts.txt file for a class called NTP.

    [root@server ~]# mc-etcfacts search classes ntp
    Do you really want to operate on services unfiltered? (y/n): y
    
    * [ ============================================================> ] 115 / 115
    
    ---- fact summary ----
            Nodes: 115 / 115
            Status: 2 * No results, 111 * ntp, 2 * ntp::server
        Elapsed Time: 0.09 s

### ADD
In this example, search for all nodes with the <tt>snmp</tt> class, and add a paramemter to set a local variable of <tt>community</tt> to <tt>password1</tt>.

     [root@server ~]# mc-etcfacts -C snmp add parameters community:password1
     
      * [ ============================================================> ] 115 / 115
     
     ---- fact summary ----
             Nodes: 115 / 115
             Status: 115 * added
         Elapsed Time: 0.28 s

### REMOVE
In this example I am removing a class from all node names that starts with <tt>unused</tt>. Remove the class <tt>nagios</tt>.

     [root@server ~]# mc-etcfacts -I /unused/ remove classes nagios

      * [ ============================================================> ] 3 / 3
     
     ---- fact summary ----
             Nodes: 3 / 3
             Status: 3 * removed
         Elapsed Time: 0.08 s

## Changes?
========

2011/04/01 - First revision

2011/06/17 - Added Augeas to set a repo status to enabled / disable. Also added Shellsafe checks for variables.

## Roadmap
========
Adding a single execution framework application for yum

## Contact?
========

Jeremy Carroll <phobos182@gmail.com> @jeremy_carroll
