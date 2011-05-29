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

To use Defender, you need to retrieve an API key from
[Defensio][4]. Then add Defender (`gem 'defender'`) to your Gemfile and run
`bundle install`. To set up Defender, open your Comment class and include
Defender::Spammable, and configure it by adding your API key. Your comment
class should look something like this:

    class Comment < ActiveRecord::Base
      include Defender::Spammable
      configure_defender :api_key => '0123456789abcdef'
    end

Now you need to add a few fields to your model. Defender requires a boolean
field named "spam" (this will be `true` for comments marked as spam, and
`false otherwise`), and a string field named "defensio_sig" (this will include
a unique identifier so you can later mark false positives and negatives).
Defender will also set the spaminess field if it exists (the spaminess field
should be a float that can range between 0.00 and 1.00, where 0.00 is the
least spammy and 1.00 is the most spammy). After you've done this, you're
probably done setting up Defender, although you should read on as there's some
more things you should know.

Defender will automatically get the comment body, author name, email, IP and
URL if you have them in your comment class with "standard names". Defender
will look for fields named "body", "content" and "comment" (in that order) for
the comment content, "author_name", "author" for the author name,
"author_email", "email" for the author email, "author_ip", "ip" for the author
IP, "author_url", "url" for the author URL. Only the comment content is the
required one of these. If you're not using those attribute names, look further
down in the readme under "Defining your own attribute names".

Not using ActiveRecord? No problem, Defender supports all libraries that
support ActiveModel, including Mongoid, MongoMapper and DataMapper. The syntax
is the exact same, just use the method your library uses to set up the fields
needed.


Defining your own attribute names
---------------------------------

Defensio supports a large amount of attributes you can send to it, and the 
more you send the more accurately it can determine whether it's spam or not.
For some of these attributes, Defender will use conventions and try to find
the attribute, but not all are set up (look at 
Defender::Spammable::DEFENSIO_KEYS for the exact keys it uses). If you are 
using other attribute names, or want to add more to get more accurate spam
evaluation, you do that in the `configure_defender` method. Pass in another
option called `:keys`, which should be a hash of defensio key names and
attribute names. The list of defensio key names are after the code example,
and the attribute name is just a symbol. So if your comment content field is
called "the_comment_itself", your comment class should look like this:

    class Comment
      include Defender::Spammable
      configure_defender :api_key => '0123456789abcdef', :keys => { 'content' => :the_comment_itself }
    end

If you don't want to store all the information in the database, you can also
use the `defensio_data` method. In the model, before saving, call
`defensio_data` with a hash containing the data you want to send. The keys
should be strings, you can see all the possible values listed below. The
`defensio_data` method can be called several times with more data.

Putting the API key in every single module could be tedious, and definitely
repetitive, so there is another way to do it. Create an initializer file
(`config/initializers/defensio.rb` works), and put the following code in it:

  Defender.api_key = '0123456789abcdef'

Obviously, you should replace 0123456789abcdef with your actual API key. This
way you don't have to pass the `:api_key` attribute to `configure_defender`
all the time.

These are the keys defensio supports (at the time of writing, see
http://defensio.com/api for a completely up-to-date list):

* **author-email**: The email address of the author of the document.
* **author-ip**: The IP address of the author of the document.
* **author-logged-in**: Whether or not the user posting the document is logged
    onto your Web site, either through your own authentication method or
    through OpenID.
* **author-name**: The name of the author of the document.
* **author-openid**: The OpenID URL of the logged-on user. Must be used in
    conjunction with user-logged-in=true.
* **author-trusted**: Whether or not the user is an administrator, moderator,
    or editor of your Web site. Pass true only if you can guarantee that the
    user has been authenticated, has a role of responsibility, and can be
    trusted as a good Web citizen.
* **author-url**: The URL of the person posting the document.
* **browser-cookies**: Whether or not the Web browser used to post the
    document (ie. the comment) has cookies enabled. If no such detection has
    been made, leave this value empty.
* **browser-javascript**: Whether or not the Web browser used to post the
    document (ie. the comment) has JavaScript enabled. If no such detection
    has been made, leave this value empty.
* **document-permalink**: The URL to the document being posted.
* **http-headers**: Contains the HTTP headers sent with the request. You can
    send a few values or all values. Because this information helps Defensio
    determine if a document is innocent or not, the more headers you send, the
    better. The format of this value is one key/value pair per line, each line
    starting with the key followed by a colon and then the value.
* **parent-document-date**: The date the parent document was posted. For
    example, on a blog, this would be the date the article related to the
    comment (document) was posted. If you're using threaded comments, send the
    date the article was posted, not the date the parent comment was posted.
* **parent-document-permalink**: The URL of the parent document. For example,
    on a blog, this would be the URL the article related to the comment
    (document) was posted.
* **referrer**: Provide the value of the HTTP_REFERER (note spelling) in this
    field.
* **title**: Provide the title of the document being sent. For example, this
    might be the title of a blog article.


Development
-----------

Want to help out on Defender?

First, you should clone the repo and run the features and specs:

    git clone git://github.com/dvyjones/defender.git
    cd defender
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
* Docs: <http://rubydoc.info/github/dvyjones/defender/master/frames>
* Bugs: <http://github.com/dvyjones/defender/issues>
* List: <defender@librelist.com>
* Gems: <http://rubygems.org/gems/defender>

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
