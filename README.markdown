Defender
========

Defender is a wrapper for the [Defensio][0] spam filtering API. From
their own site:

> More than just another spam filter, Defensio also eliminates malware
> and other unwanted or risky content to fully protect your blog or Web
> 2.0 application.

Defensio is able to not only find spam, but also filter profanity and
other similarities. It can also see the difference between malicious
material and spammy material.


Development
-----------

Want to help out on Defender?

First, you should clone the repo and run the features and specs:

    git clone git://github.com/dvyjones/defender.git
    cd defender
    rake features
    rake spec

Feel free to ping the mailing list if you have any problems and we'll
try to sort it out.


Contributing
------------

Once you've made your great commits:

1. [Fork][1] defender
2. Create a topic branch - `git checkout -b my_branch`
3. Push to your branch - `git push origin my_branch`
4. Create an [Issue][2] with a link to your branch
5. That's it!

You might want to checkout our [Contributing][cb] wiki page for
information on coding standards, new features, etc.


Mailing List
------------

To join the list simply send an email to <defender@librelist.com>. This
will subscribe you and send you information about your subscription,
include unsubscribe information.

The archive can be found at <http://librelist.com/browser/>.


Meta
----

* Code: `git clone git://github.com/dvyjones/defender.git`
* Home: <http://github.com/dvyjones/defender/>
* Docs: <http://yardoc.org/docs/dvyjones-defender/>
* Bugs: <http://github.com/dvyjones/defender/issues>
* List: <defender@librelist.com>
* Gems: <http://gemcutter.org/gems/defender>

This project uses [Semantic Versioning][sv].


Author
------

Henrik Hodne :: dvyjones@binaryhex.com :: @dvyjones

[0]: http://defensio.com
[1]: http://help.github.com/forking/
[2]: http://github.com/dvyjones/defender/issues
[sv]: http://semver.org
[cb]: http://wiki.github.com/dvyjones/defender/contributing
