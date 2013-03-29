name-spotter
============

Finds biodiversity scientific names in texts using TaxonFinder 
(by Patrick Leary) or NetiNeti (by Lakshmi Manohar Akella) libraries. 
This gem works with ruby >= 1.9.2

Requirements
------------

* Python 2.6/2.7 with NLTK module, http://www.nltk.org/

Installation
------------

Install the gem

    gem install name-spotter

Install and run TaxonFinder in a new terminal window

    wget http://taxon-finder.googlecode.com/files/taxon-finder.tar.gz
    tar zxvf taxon-finder.tar.gz
    cd taxon-finder
    perl server.pl 

Install and run NetiNeti in a new terminal window

    wget https://github.com/mbl-cli/NetiNeti/zipball/master
    unzip master
    cd cd mbl-cli-NetiNeti-*

    #or

    git clone git://github.com/mbl-cli/NetiNeti.git
    cd NetiNeti

    #then
    
    sudo easy_install virtualenv
    sudo easy_install tornado
    python neti_env.py virtualenvs/neti
    cp config/neti_http_config.cfg.example config/neti_http_config.cfg
    python neti_tornado_server.py 

Usage
-----

Fist you have to download TaxonFinder and NetiNeti services.
    
* TaxonFinder: http://code.google.com/p/taxon-finder/
* NetiNeti: https://github.com/mbl-cli/NetiNeti

If you are using localhost and default ports:

    require 'name-spotter'

    neti_client       = NameSpotter::NetiNetiClient.new()
    tf_client         = NameSpotter::TaxonFinderClient.new()
    neti_name_spotter = NameSpotter.new(neti_client)
    tf_name_spotter   = NameSpotter.new(tf_client)

    neti_name_spotter.find(your_text)
    tf_name_spotter.find(your_text)

If you have installed NetiNeti and TaxonFinder on a machine 
with non-default port:

    neti_client = NameSpotter::NetiNetiClient.new(host: "example.com", 
                                                  port: 5555)
    #or
    neti_client = NameSpotter::NetiNetiClient.new(host: '123.123.123.111', 
                                                  port: 5555)

If you want to get results in JSON or XML formats
    
    neti_name_spotter.find(your_text, "json")
    neti_name_spotter.find(your_text, "xml")

Development
-----------

To run tests start TaxonFinder and NetiNeti on your local machine with 
default configurations and run

    rake



Contributing to name-spotter
----------------------------
 
* Check out the latest master to make sure the feature hasn't been implemented 
or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested 
it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a 
future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want 
to have your own version, or is otherwise necessary, that is fine, but please 
isolate to its own commit so I can cherry-pick around it.

Copyright
---------

Authors: Chuck Ha, Anthony Goddard, Dmitry Mozzherin

Copyright (c) 2012-2013 Marine Biological Laboratory. See LICENSE.txt for
further details.

