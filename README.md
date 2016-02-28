name-spotter
============

[![Gem Version][1]][2]
[![Continuous Integration Status][3]][4]
[![Dependency Status][5]][6]


Finds biodiversity scientific names in texts using TaxonFinder
(by Patrick Leary) or NetiNeti (by Lakshmi Manohar Akella) libraries.
This gem works with Ruby >= 2.0

Requirements
------------

* Docker

Installation
------------

Install the gem

    gem install name-spotter

Install and run TaxonFinder and NetiNeti docker containers

```bash
docker pull gnames/netineti
docker pull gnames/taxonfinder
docker run -d -p 0.0.0.0:1234:1234 --name tf gnames/taxonfinder
docker run -d -p 0.0.0.0:6384:6384 --name nn gnames/netineti
```

Usage
-----

If you are using localhost and default ports for NetiNeti and TaxonFinder:

```ruby
require "name-spotter"

neti_client       = NameSpotter::NetiNetiClient.new()
tf_client         = NameSpotter::TaxonFinderClient.new()
neti_name_spotter = NameSpotter.new(neti_client)
tf_name_spotter   = NameSpotter.new(tf_client)

neti_name_spotter.find(your_text)
tf_name_spotter.find(your_text)

# in xml format
neti_name_spotter.find(your_text, "xml")
tf_name_spotter.find(your_text, "xml")

# in json format
neti_name_spotter.find(your_text, "json")
tf_name_spotter.find(your_text, "json")
```

If you have installed NetiNeti and TaxonFinder on a machine
with non-default port:

```ruby
neti_client = NameSpotter::NetiNetiClient.new(host: "example.com",
                                              port: 5555)
#or
neti_client = NameSpotter::NetiNetiClient.new(host: "123.123.123.111",
                                              port: 5555)
```

If you want to get results in JSON or XML formats

```ruby
neti_name_spotter.find(your_text, "json")
neti_name_spotter.find(your_text, "xml")
```

Development
-----------

To run tests start TaxonFinder and NetiNeti on your local machine with
default configurations and run

```
bundle exec rake
```



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

Authors: [Chuck Ha][7], [Anthony Goddard][8], [Dmitry Mozzherin][9],
[David Shorthouse][10]

Copyright (c) 2012-2016 Marine Biological Laboratory. See [LICENSE.txt][11] for
further details.

[1]: https://badge.fury.io/rb/name-spotter.svg
[2]: http://badge.fury.io/rb/name-spotter
[3]: https://secure.travis-ci.org/GlobalNamesArchitecture/name-spotter.svg
[4]: http://travis-ci.org/GlobalNamesArchitecture/name-spotter
[5]: https://gemnasium.com/GlobalNamesArchitecture/name-spotter.svg
[6]: https://gemnasium.com/GlobalNamesArchitecture/name-spotter
[7]: https://github.com/ChuckHa
[8]: https://github.com/agoddard
[9]: https://github.com/dimus
[10]: https://github.com/dshorthouse
[11]: https://raw.githubusercontent.com/GlobalNamesArchitecture/name-spotter/master/LICENSE.txt
