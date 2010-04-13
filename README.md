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


Overview
--------

With Defender you can submit documents to Defensio, which will look for
spam and malicious content in the documents.

A document contains content to be analyzed by Defensio, or that has been
analyzed.

Before starting to use Defender, you need to retrieve an API key from
[Defensio][4]. After getting an API key, you need to let Defender know
what it is by doing something like this somewhere in your code (before
doing anything like saving documents):

    Defender.api_key = 'my-api-key'

Submitting documents to Defensio is really easy. Here's a barebones
example:

    require 'defender'
    document = Defender::Document.new
    document.data[:content] = 'Hello World!'
    document.data[:type] = 'comment'
    document.data[:platform] = 'defender'
    document.save

The `document.data` hash can contain a lot of data. The ones you see
here are the only required ones, but you should submit as much data as
you can. Look at the [Defensio API docs][3] for information on the
different data you can submit. Oh, and the keys can be symbols, and you
can use underscores instead of dashes.

After saving the document, Defender will set the `document.allow?`,
`document.spaminess` and
`document.signature` attributes. The first one tells you if you should
display the document or not on your website. The second is a float which
tells you just how spammy the document is. This could be useful for
sorting the documents in an admin panel. The lower the spaminess is, the
less chance is it for it being spam. The last attribute is an unique
identifier you should save with your document in the database. This can
be used for retrieving the status of your document again, and for
retraining purposes.

Did I say retraining? Oh yes, you can retrain Defensio! If some spam
went through the filters, or some legit documents were marked as spam,
tell Defensio by setting the `document.allow` attribute and save the
document again:

    document.allow = true
    document.save

This tells Defensio that the document should've been allowed. Don't have
access to the `document` instance any more you say? No problem, just
retrieve it again using the signature. You did save the signature,
didn't you?

    document = Defender::Document.find(signature)


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

Henrik Hodne :: <dvyjones@binaryhex.com> :: @[dvyjones][5]

[0]: http://defensio.com
[1]: http://help.github.com/forking/
[2]: http://github.com/dvyjones/defender/issues
[3]: http://defensio.com/api
[4]: http://defensio.com/signup/
[5]: http://twitter.com/dvyjones
[sv]: http://semver.org
[cb]: http://wiki.github.com/dvyjones/defender/contributing
