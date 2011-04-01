# MCollective Agents

mc-yum : MCollective agent for adding / removing / checking packages using yum

mc-etcfacts : MCollective agent for adding / removing / searching for facts in /etc/facts.txt

## Description

mc-etcfacts

This agent is based around the [etc_facts.rb](https://github.com/ripienaar/facter-facts/blob/master/etcfacts/etc_facts.rb) plugin written by R.I. Pienaar as asll as a blog post from [Gary Larizza](http://glarizza.posterous.com/our-puppet-external-node-infrastructure) regarding his implimentation of the /etc/facts.txt external node classifier. I have modified his code and created a new GitHub repository for his [external node classifier](https://github.com/phobos182/mcollective-etcfacts). The mc-etcfacts program allows modification of the /etc/facts.txt file. I currently use the design pattern of having a local file which I can manipulate to add / remove puppet configurations. Using this MCollective agent I can add a new class to the 'classes' fact, then run puppet with the 'mc-puppetd' agent to pull in the new packages.

## Changes?
========

2011/04/01 - First revision

## Contact?
========

Jeremy Carroll <phobos182@gmail.com> @jeremy_carroll
