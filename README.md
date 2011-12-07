# Defender

[![Build Status](https://secure.travis-ci.org/dvyjones/defender.png?branch=version3)](http://travis-ci.org/dvyjones/defender)

Defender is an spam filtering plugin for ActiveModel. It allows you to easily
implement spam filtering to your Rails app or any other project using
ActiveModel. It interacts with the [Defensio][defensio] API to provide accurate
spam filtering.

## Installing

In **Rails 3** or any other project using **bundler**, add this to your Gemfile
and run the `bundle` command.

```ruby
gem 'defender'
```

If you want to live on the bleeding edge, you can use the git repo. YMMV.

```ruby
gem 'defender', git: 'git://github.com/dvyjones/defender.git', branch: 'version3'
```

For any other project, install the `defender` gem and `require 'defender'`.

## Getting Started

After installing the gem, you'll need an API key. Head on over to
[Defensio][defensio] and sign up for one.

Then, tell Defender what your API key is by putting the following in
`application.rb`:

```ruby
config.defender.api_key = 'your api key'
```

Defender requires you to put three columns in your model. To generate a migration
for them run

  $ rails generate defender:migration model_name

Replace `model_name` with the name of your model (of course). Next up, you just
need to include Defender in your model.

```ruby
class Comment < ActiveRecord::Base
  include Defender::Model
end
```

Defender will try and guess what your column names are, but if you want to be
explicit about it, you can tell Defender what columns to submit.

```ruby
class Comment < ActiveRecord::Base
  include Defender::Model

  def defender_data
    {
      content: self.body,
      author_email: self.author.email,
      author_trusted: self.author.admin?
    }
  end
end
```

Defensio accepts **a lot** of data. Here are all the things you can send it:

* **content**: The body of the document. This is the only required thing to
  send.
* **type**: The type of content to be analyzed. This is required too, but
  falls back on `comment` if you don't specify anything. Accepted
  values are `comment`, `trackback`, `pingback`, `article`, `wiki`,
  `forum`, `other`, `test`.
* **author_email**: The email address of the author of the document.
* **author_ip**: The IP address of the author of the document.
* **author_logged_in**: Whether or not the user posting the document is logged
  onto your Web site, either through your own
  authentication mechanism or through OpenID.
* **author_name**: The name of the author of the document.
* **author_openid**: The OpenID URL of the logged-on user. This will
  automatically set **author_logged_in** to `true`.
* **author_trusted**: Whether or not the user is an administrator, moderator or
  editor of your Web site. Pass `true` only if you can
  guarantee that the user has been authenticated, has a
  role of responsibility, and can be trusted as a good Web
  citizen.
* **author_url**: The URL of the person posting the document.
* **browser_cookies**: Whether or not cookies are enabled by the web browser
  used to post the document.
* **browser_javascript**: Whether or not JavaScript is enabled on the web
  browser used to post the document.
* **document_permalink**: The URL of the document being posted.
* **http_headers**: The Hash of headers sent with the request to your server.
  The more you provide the better.
* **parent_document_date**: The date the parent document was posted. For
  threaded comments, this means the article, NOT the parent comment. Use
  "YYYY-MM-DD" if passing a string.
* **parent_document_permalink**: The URL of the parent document.
* **referrer**: The value of the HTTP_REFERER (sic) header.
* **title**: The title of the document being sent.

## Contributing

1. Fork it.
2. Create a branch (`git checkout -b add-resque-support`)
3. Make your changes
4. Commit your changes (`git commit -am "Added support for Resque"`)
5. Push to the branch (`git push origin add-resque-support`)
6. Create a [Pull Request](http://help.github.com/pull-requests/) from your branch.
7. Promote it. Get others to drop in and +1 it.


[defensio]: http://defensio.com

