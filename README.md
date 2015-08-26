# Brakefast

[![Gem Version](https://badge.fury.io/rb/brakefast.png)](http://badge.fury.io/rb/brakefast)
[![Build Status](https://secure.travis-ci.org/flyerhzm/brakefast.png)](http://travis-ci.org/flyerhzm/brakefast)
[![Coverage Status](https://coveralls.io/repos/flyerhzm/brakefast/badge.png?branch=master)](https://coveralls.io/r/flyerhzm/brakefast)
<a href="https://codeclimate.com/github/flyerhzm/brakefast"><img src="https://codeclimate.com/github/flyerhzm/brakefast.png" /></a>
[![Coderwall Endorse](http://api.coderwall.com/flyerhzm/endorsecount.png)](http://coderwall.com/flyerhzm)

The Brakefast gem is designed to help you reduce your application's vulnerability. It will watch your code with using [brakeman](http://brakemanscanner.org) while you develop your application and notify you when you use vulnerable code.

Best practice is to use Brakefast in development mode or custom mode (staging, profile, etc.). The last thing you want is your clients getting alerts about how lazy you are.

## Install

You can install it as a gem:

```
gem install brakefast
```

or add it into a Gemfile (Bundler):


```ruby
gem "brakefast", :group => "development"
```

## Configuration

Brakefast won't do ANYTHING unless you tell it to explicitly. Append to
`config/environments/development.rb` initializer with the following code:

```ruby
config.after_initialize do
  Brakefast.enable = true
  Brakefast.alert = true
  Brakefast.brakefast_logger = true
  Brakefast.console = true
  Brakefast.growl = true
  Brakefast.xmpp = { :account  => 'brakefasts_account@jabber.org',
                  :password => 'brakefasts_password_for_jabber',
                  :receiver => 'your_account@jabber.org',
                  :show_online_status => true }
  Brakefast.rails_logger = true
  Brakefast.honeybadger = true
  Brakefast.bugsnag = true
  Brakefast.airbrake = true
  Brakefast.rollbar = true
  Brakefast.add_footer = true
  Brakefast.stacktrace_includes = [ 'your_gem', 'your_middleware' ]
  Brakefast.slack = { webhook_url: 'http://some.slack.url', foo: 'bar' }
end
```

The notifier of Brakefast is a wrap of [uniform_notifier](https://github.com/flyerhzm/uniform_notifier)

The code above will enable all seven of the Brakefast notification systems:
* `Brakefast.enable`: enable Brakefast gem, otherwise do nothing
* `Brakefast.alert`: pop up a JavaScript alert in the browser
* `Brakefast.brakefast_logger`: log to the Brakefast log file (Rails.root/log/brakefast.log)
* `Brakefast.rails_logger`: add warnings directly to the Rails log
* `Brakefast.honeybadger`: add notifications to Honeybadger
* `Brakefast.bugsnag`: add notifications to bugsnag
* `Brakefast.airbrake`: add notifications to airbrake
* `Brakefast.rollbar`: add notifications to rollbar
* `Brakefast.console`: log warnings to your browser's console.log (Safari/Webkit browsers or Firefox w/Firebug installed)
* `Brakefast.growl`: pop up Growl warnings if your system has Growl installed. Requires a little bit of configuration
* `Brakefast.xmpp`: send XMPP/Jabber notifications to the receiver indicated. Note that the code will currently not handle the adding of contacts, so you will need to make both accounts indicated know each other manually before you will receive any notifications. If you restart the development server frequently, the 'coming online' sound for the Brakefast account may start to annoy - in this case set :show_online_status to false; you will still get notifications, but the Brakefast account won't announce it's online status anymore.
* `Brakefast.raise`: raise errors, useful for making your specs fail unless they have optimized queries
* `Brakefast.add_footer`: adds the details in the bottom left corner of the page
* `Brakefast.stacktrace_includes`: include paths with any of these substrings in the stack trace, even if they are not in your main app
* `Brakefast.slack`: add notifications to slack

Brakefast also allows you to disable any of its detectors.

```ruby
# Each of these settings defaults to true

# Detect errors
Brakefast.errors              = false

# Detect controller warnings
Brakefast.controller_warnings = false

# Detect generic warnings
Brakefast.generic_warnings    = false

# Detect model warnings
Brakefast.model_warnings      = false
```

TODO: update below

## Whitelist

Sometimes Brakefast may notify you of query problems you don't care to fix, or
which come from outside your code. You can whitelist these to ignore them:

```ruby
Brakefast.add_whitelist :type => :n_plus_one_query, :class_name => "Post", :association => :comments
Brakefast.add_whitelist :type => :unused_eager_loading, :class_name => "Post", :association => :comments
Brakefast.add_whitelist :type => :counter_cache, :class_name => "Country", :association => :cities
```

If you want to skip brakefast in some specific controller actions, you can
do like

```ruby
class ApplicationController < ActionController::Base
  around_action :skip_brakefast

  def skip_brakefast
    Brakefast.enable = false
    yield
  ensure
    Brakefast.enable = true
  end
end
```

## Log

The Brakefast log `log/brakefast.log` will look something like this:

* N+1 Query:

```
2009-08-25 20:40:17[INFO] N+1 Query: PATH_INFO: /posts;    model: Post => associations: [comments]·
Add to your finder: :include => [:comments]
2009-08-25 20:40:17[INFO] N+1 Query: method call stack:·
/Users/richard/Downloads/test/app/views/posts/index.html.erb:11:in `_run_erb_app47views47posts47index46html46erb'
/Users/richard/Downloads/test/app/views/posts/index.html.erb:8:in `each'
/Users/richard/Downloads/test/app/views/posts/index.html.erb:8:in `_run_erb_app47views47posts47index46html46erb'
/Users/richard/Downloads/test/app/controllers/posts_controller.rb:7:in `index'
```

The first two lines are notifications that N+1 queries have been encountered. The remaining lines are stack traces so you can find exactly where the queries were invoked in your code, and fix them.

* Unused eager loading:

```
2009-08-25 20:53:56[INFO] Unused eager loadings: PATH_INFO: /posts;    model: Post => associations: [comments]·
Remove from your finder: :include => [:comments]
```

These two lines are notifications that unused eager loadings have been encountered.

* Need counter cache:

```
2009-09-11 09:46:50[INFO] Need Counter Cache
  Post => [:comments]
```

## Growl, XMPP/Jabber and Airbrake Support

see [https://github.com/flyerhzm/uniform_notifier](https://github.com/flyerhzm/uniform_notifier)

## Important

If you find Brakefast does not work for you, *please disable your browser's cache*.

## Advanced

### Profile a job

The Brakefast gem uses rack middleware to profile requests. If you want to use Brakefast without an http server, like to profile a job, you can use use profile method and fetch warnings

```ruby
Brakefast.profile do
  # do anything

  warnings = Brakefast.warnings
end
```

### Work with sinatra

Configure and use `Brakefast::Rack`

```ruby
configure :development do
  Brakefast.enable = true
  Brakefast.brakefast_logger = true
  use Brakefast::Rack
end
```

### Run in tests

First you need to enable Brakefast in test environment.

```ruby
# config/environments/test.rb
config.after_initialize do
  Brakefast.enable = true
  Brakefast.brakefast_logger = true
  Brakefast.raise = true # raise an error if n+1 query occurs
end
```

Then wrap each test in Brakefast api.

```ruby
# spec/spec_helper.rb
if Brakefast.enable?
  config.before(:each) do
    Brakefast.start_request
  end

  config.after(:each) do
    Brakefast.perform_out_of_channel_notifications if Brakefast.notification?
    Brakefast.end_request
  end
end
```

## Debug Mode

Brakefast outputs some details info, to enable debug mode, set
`BRAKEFAST_DEBUG=true` env.

## Contributors

[https://github.com/flyerhzm/brakefast/contributors](https://github.com/flyerhzm/brakefast/contributors)

## Demo

Brakefast is designed to function as you browse through your application in development. To see it in action, follow these steps to create, detect, and fix example query problems.

1\. Create an example application

```
$ rails new test_brakefast
$ cd test_brakefast
$ rails g scaffold post name:string
$ rails g scaffold comment name:string post_id:integer
$ bundle exec rake db:migrate
```

2\. Change `app/model/post.rb` and `app/model/comment.rb`

```ruby
class Post < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :post
end
```

3\. Go to `rails c` and execute

```ruby
post1 = Post.create(:name => 'first')
post2 = Post.create(:name => 'second')
post1.comments.create(:name => 'first')
post1.comments.create(:name => 'second')
post2.comments.create(:name => 'third')
post2.comments.create(:name => 'fourth')
```

4\. Change the `app/views/posts/index.html.erb` to produce a N+1 query

```
<% @posts.each do |post| %>
  <tr>
    <td><%= post.name %></td>
    <td><%= post.comments.map(&:name) %></td>
    <td><%= link_to 'Show', post %></td>
    <td><%= link_to 'Edit', edit_post_path(post) %></td>
    <td><%= link_to 'Destroy', post, :confirm => 'Are you sure?', :method => :delete %></td>
  </tr>
<% end %>
```

5\. Add the `brakefast` gem to the `Gemfile`

```ruby
gem "brakefast"
```

And run

```
bundle install
```

6\. enable the Brakefast gem in development, add a line to
`config/environments/development.rb`

```ruby
config.after_initialize do
  Brakefast.enable = true
  Brakefast.alert = true
  Brakefast.brakefast_logger = true
  Brakefast.console = true
#  Brakefast.growl = true
  Brakefast.rails_logger = true
  Brakefast.add_footer = true
end
```

7\. Start the server

```
$ rails s
```

8\. Visit `http://localhost:3000/posts` in browser, and you will see a popup alert box that says

```
The request has unused preload associations as follows:
None
The request has N+1 queries as follows:
model: Post => associations: [comment]
```

which means there is a N+1 query from the Post object to its Comment association.

In the meanwhile, there's a log appended into `log/brakefast.log` file

```
2010-03-07 14:12:18[INFO] N+1 Query in /posts
  Post => [:comments]
  Add to your finder: :include => [:comments]
2010-03-07 14:12:18[INFO] N+1 Query method call stack
  /home/flyerhzm/Downloads/test_brakefast/app/views/posts/index.html.erb:14:in `_render_template__600522146_80203160_0'
  /home/flyerhzm/Downloads/test_brakefast/app/views/posts/index.html.erb:11:in `each'
  /home/flyerhzm/Downloads/test_brakefast/app/views/posts/index.html.erb:11:in `_render_template__600522146_80203160_0'
  /home/flyerhzm/Downloads/test_brakefast/app/controllers/posts_controller.rb:7:in `index'
```

The generated SQL is:

```
Post Load (1.0ms)   SELECT * FROM "posts"
Comment Load (0.4ms)   SELECT * FROM "comments" WHERE ("comments".post_id = 1)
Comment Load (0.3ms)   SELECT * FROM "comments" WHERE ("comments".post_id = 2)
```

9\. To fix the N+1 query, change `app/controllers/posts_controller.rb` file

```ruby
def index
  @posts = Post.includes(:comments)

  respond_to do |format|
    format.html # index.html.erb
    format.xml  { render :xml => @posts }
  end
end
```

10\. Refresh `http://localhost:3000/posts`. Now there's no alert box and nothing new in the log.

The generated SQL is:

```
Post Load (0.5ms)   SELECT * FROM "posts"
Comment Load (0.5ms)   SELECT "comments".* FROM "comments" WHERE ("comments".post_id IN (1,2))
```

N+1 query fixed. Cool!

11\. Now simulate unused eager loading. Change
`app/controllers/posts_controller.rb` and
`app/views/posts/index.html.erb`

```ruby
def index
  @posts = Post.includes(:comments)

  respond_to do |format|
    format.html # index.html.erb
    format.xml  { render :xml => @posts }
  end
end
```

```
<% @posts.each do |post| %>
  <tr>
    <td><%= post.name %></td>
    <td><%= link_to 'Show', post %></td>
    <td><%= link_to 'Edit', edit_post_path(post) %></td>
    <td><%= link_to 'Destroy', post, :confirm => 'Are you sure?', :method => :delete %></td>
  </tr>
<% end %>
```

12\. Refresh `http://localhost:3000/posts`, and you will see a popup alert box that says

```
The request has unused preload associations as follows:
model: Post => associations: [comment]
The request has N+1 queries as follows:
None
```

Meanwhile, there's a line appended to `log/brakefast.log`

```
2009-08-25 21:13:22[INFO] Unused preload associations: PATH_INFO: /posts;    model: Post => associations: [comments]·
Remove from your finder: :include => [:comments]
```

13\. Simulate counter_cache. Change `app/controllers/posts_controller.rb`
and `app/views/posts/index.html.erb`

```ruby
def index
  @posts = Post.all

  respond_to do |format|
    format.html # index.html.erb
    format.xml  { render :xml => @posts }
  end
end
```

```
<% @posts.each do |post| %>
  <tr>
    <td><%= post.name %></td>
    <td><%= post.comments.size %></td>
    <td><%= link_to 'Show', post %></td>
    <td><%= link_to 'Edit', edit_post_path(post) %></td>
    <td><%= link_to 'Destroy', post, :confirm => 'Are you sure?', :method => :delete %></td>
  </tr>
<% end %>
```

14\. Refresh `http://localhost:3000/posts`, then you will see a popup alert box that says

```
Need counter cache
  Post => [:comments]
```

Meanwhile, there's a line appended to `log/brakefast.log`

```
2009-09-11 10:07:10[INFO] Need Counter Cache
  Post => [:comments]
```

Copyright (c) 2009 - 2015 Richard Huang (flyerhzm (at) gmail.com), released under the MIT license in bullet original sentences

Copyright (c) 2015 -  Sho Hashimoto (sho.hsmt (at) gmail.com), released under the MIT license in brakefast sentences