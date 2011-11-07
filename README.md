# Defender

[![Click here to lend your support to: Defender - A Ruby wrapper for Defensio and make a donation at www.pledgie.com](http://www.pledgie.com/campaigns/16244.png?skin_name=chrome)](http://www.pledgie.com/campaigns/16244)

Defender is a wrapper for the [Defensio](http://defensio.com) spam filtering 
API. From their own site:

> More than just another spam filter, Defensio also eliminates malware and
> other unwanted or risky content to fully protect your blog or Web 2.0
> application.

## Getting Started

I'm going to assume that you already have a comment model. The comment model
is required to have at least a content or body field.

### 1. Create an initializer

You need to provide Defender with your API key. The preferred way of doing
this is with an initializer file. Create a file in the `config/initializers`
folder, and put the following line in it.

    Defender.api_key = 'YOUR_API_KEY'

### 2. Add the required fields to your model

You need to add a boolean field named `spam`, and a string field named
`defensio_sig` to your model. You should also add a float field named
`spaminess`, although this isn't required. Here's an example migration for
Active Record:

```ruby
class AddDefenderFieldsToComments < ActiveRecord::Migration
  def change
    add_column :comments, :spam, :boolean
    add_column :comments, :defensio_sig, :string
    add_column :comments, :spaminess, :float
  end
end
````

### 3. Configure the model

In your model, `include Defender::Spammable`. If the model attributes match up
with what Defender autodetects (check the wiki), you are now good to go! The
`spam` attribute will be automatically updated by Defender when you save the
model.

If you need to change any of the attributes, you can pass `configure_defender`
the mappings, like this:

```ruby
class Comment < ActiveRecord::Base
    include Defender::Spammable
    configure_defender :keys => { 'content' => :data }
end
```

In this example, `'content'` is the Defensio field, and `:data` is the model
attribute.

## Installation

In **Rails 3**, add this to your Gemfile and run the `bundle` command.

    gem 'defender'

If you want to live on the bleeding edge, you can use the git repo. YMMV.

    gem 'defender', :git => 'git://github.com/dvyjones/defender.git'

For any other kind of web framework, just install the `defender` gem, and
`require 'defender'` somewhere in your code.

## Contributing

1. Fork it.
2. Create a branch (`git checkout -b add-resque-support`)
3. Make your changes
4. Commit your changes (`git commit -am "Added support for Resque"`)
5. Push to the branch (`git push origin add-resque-support`)
6. Create a [Pull Request](http://help.github.com/pull-requests/) from your branch.
7. Promote it. Get others to drop in and +1 it.
