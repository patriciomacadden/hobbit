# Hobbit

[![Build Status](https://travis-ci.org/patriciomacadden/hobbit.png?branch=master)](https://travis-ci.org/patriciomacadden/hobbit)
[![Code Climate](https://codeclimate.com/github/patriciomacadden/hobbit.png)](https://codeclimate.com/github/patriciomacadden/hobbit)
[![Coverage Status](https://coveralls.io/repos/patriciomacadden/hobbit/badge.png?branch=master)](https://coveralls.io/r/patriciomacadden/hobbit)
[![Dependency Status](https://gemnasium.com/patriciomacadden/hobbit.png)](https://gemnasium.com/patriciomacadden/hobbit)
[![Gem Version](https://badge.fury.io/rb/hobbit.png)](http://badge.fury.io/rb/hobbit)

A minimalistic microframework built on top of [Rack](http://rack.github.io/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hobbit'
# or this if you want to use master
# gem 'hobbit', github: 'patriciomacadden/hobbit'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install hobbit
```

## Features

* DSL inspired by [Sinatra](http://www.sinatrarb.com/).
* Extensible with standard ruby classes and modules, with no extra logic (See
the included modules and [hobbit-contrib](https://github.com/patriciomacadden/hobbit-contrib)).
* No configuration needed.
* Encourages the understanding and use of [Rack](http://rack.github.io/) and
its extensions.
* Request and response classes could be injected (Defaults to `Rack::Request`
and `Hobbit::Response`, respectively).

## Usage

`Hobbit` applications are just instances of `Hobbit::Base`, which complies the
[Rack SPEC](http://rack.rubyforge.org/doc/SPEC.html).

Here is a  classic **Hello World!** example (write this code in `config.ru`):

```ruby
require 'hobbit'

class App < Hobbit::Base
  get '/' do
    'Hello World!'
  end
end

run App.new
```

**Note**: In the examples, the classes are written in the `config.ru` file.
However, this is not recommended. Please, **always** follow the coding
standards!

### Routes

You can define routes as in [Sinatra](http://www.sinatrarb.com/):

```ruby
class App < Hobbit::Base
  get '/' do
    'Hello world'
  end

  get '/hi/:name' do
    "Hello #{request.params[:name]}"
  end
end
```

Every route is composed of a verb, a path and a block. When an incoming request
matches a route, the block is executed and a response is sent back to the
client. The return value of the block will be the `body` of the response. The
`headers` and `status code` of the response will be calculated by
`Hobbit::Response`, but you could modify it anyway you want it.

Additionally, when a route gets called you have this methods available:

* `env`: The Rack environment.
* `request`: a `Rack::Request` instance.
* `response`: a `Rack::Response` instance.

#### Available methods

* `delete`
* `get`
* `head`
* `options`
* `patch`
* `post`
* `put`

**Note**: Since most browsers don't support methods other than **GET** and
**POST** you must use the `Rack::MethodOverride` middleware. (See
[Rack::MethodOverride](https://github.com/rack/rack/blob/master/lib/rack/methodoverride.rb)).
Here is an example on how to use it in a RESTful way:

```ruby
require 'hobbit'

class App < Hobbit::Base
  use Rack::MethodOverride

  get '/users' do
    # list the users
  end

  get '/users/new' do
    # render a form for creating an user
  end

  post '/users' do
    # create an user
  end

  get '/users/:id/edit' do
    # render a form for editing an user
  end

  put '/users/:id' do
    # update an user
  end

  get '/users/:id' do
    # show an user
  end

  delete '/users/:id' do
    # delete an user
  end
end

run App.new
```

### Rendering

`Hobbit` comes with a module that uses [Tilt](https://github.com/rtomayko/tilt)
for rendering templates. See the example:

In `config.ru`:

```ruby
require 'hobbit'

class App < Hobbit::Base
  include Hobbit::Render

  get '/' do
    render 'views/index.erb'
  end
end

run App.new
```

and in `views/index.erb`:

```html
<!DOCTYPE html>
<html>
  <head>
    <title>Hello World!</title>
  </head>
  <body>
    <h1>Hello World!</h1>
  </body>
</html>
```

**Note**: If you want to use other template engine than `erb`, you should
require the gem, ie. add the gem to your `Gemfile`.

#### Layout

For now, the `Hobbit::Render` module is pretty simple (just `render`). If you
want to render a template within a layout, you could simply do this:

In `config.ru`:

```ruby
require 'hobbit'

class App < Hobbit::Base
  include Hobbit::Render

  get '/' do
    render 'views/layout.erb' do
      render 'views/index.erb'
    end
  end
end

run App.new
```

In `views/layout.erb`:

```html
<!DOCTYPE html>
<html>
  <head>
    <title>Hello World!</title>
  </head>
  <body>
    <%= yield %>
  </body>
</html>
```

And in `views/index.erb`:

```html
<h1>Hello World!</h1>
```

#### Partials

Partials are just `render` calls:

```ruby
<%= render 'views/_some_partial.erb' %>
```

#### Helpers

Who needs helpers when you have standard ruby methods? All methods defined in
the application can be used in the templates, since the template code is
executed within the scope of the application instance. See an example:

```ruby
require 'hobbit'

class App < Hobbit::Base
  include Hobbit::Render

  def name
    'World'
  end

  get '/' do
    render 'views/index.erb'
  end
end

run App.new
```

and in `views/index.erb`:

```ruby
<!DOCTYPE html>
<html>
  <head>
    <title>Hello <%= name %>!</title>
  </head>
  <body>
    <h1>Hello <%= name %>!</h1>
  </body>
</html>
```

### Redirecting

If you look at Hobbit implementation, you may notice that there is no
`redirect` method (or similar). This is because such functionality is provided
by [Rack::Response](https://github.com/rack/rack/blob/master/lib/rack/response.rb)
and for now we [don't wan't to repeat ourselves](http://en.wikipedia.org/wiki/Don't_repeat_yourself).
So, if you want to redirect to another route, do it like this:

```ruby
require 'hobbit'

class App < Hobbit::Base
  get '/' do
    response.redirect '/hi'
  end

  get '/hi' do
    'Hello World!'
  end
end

run App.new
```

### Built on rack

Each hobbit application is a Rack stack (See this [blog post](http://m.onkey.org/ruby-on-rack-2-the-builder)).

#### Mapping applications

You can mount any Rack application to the stack by using the `map` class
method:

```ruby
require 'hobbit'

class InnerApp < Hobbit::Base
  # gets called when path_info = '/inner'
  get do
    'Hello InnerApp!'
  end
end

class App < Hobbit::Base
  map('/inner') { run InnerApp.new }

  get '/' do
    'Hello App!'
  end
end

run App.new
```

#### Using middleware

You can add any Rack middleware to the stack by using the `use` class method:

```ruby
require 'hobbit'

class App < Hobbit::Base
  include Hobbit::Session
  use Rack::Session::Cookie, secret: SecureRandom.hex(64)
  use Rack::ShowExceptions

  get '/' do
    session[:name] = 'hobbit'
  end

  # more routes...
end

run App.new
```

### Security

By default, `hobbit` (nor Rack) comes without any protection against web
attacks. The use of [Rack::Protection](https://github.com/rkh/rack-protection)
is highly recommended:

```ruby
require 'hobbit'
require 'rack/protection'
require 'securerandom'

class App < Hobbit::Base
  use Rack::Session::Cookie, secret: SecureRandom.hex(64)
  use Rack::Protection

  get '/' do
    'Hello World!'
  end
end

run App.new
```

### Sessions

You can add user sessions using any [Rack session middleware](https://github.com/rack/rack/tree/master/lib/rack/session)
and then access the session through `env['rack.session']`. Fortunately, there
is `Hobbit::Session` which comes with a useful helper:

```ruby
require 'hobbit'
require 'securerandom'

class App < Hobbit::Base
  include Hobbit::Session
  use Rack::Session::Cookie, secret: SecureRandom.hex(64)

  post '/' do
    session[:name] = 'hobbit'
  end

  get '/' do
    session[:name]
  end
end

run App.new
```

### Static files

`Hobbit` does not serve static files like images, javascripts and stylesheets.
However, you can serve static files using the `Rack::Static` middleware. Here
is an example (See [Rack::Static](https://github.com/rack/rack/blob/master/lib/rack/static.rb)
for further details):

In `config.ru`

```ruby
require 'hobbit'

class App < Hobbit::Base
  include Hobbit::Render
  use Rack::Static, root: 'public', urls: ['/javascripts', '/stylesheets']

  get '/' do
    render 'views/index.erb'
  end
end

run App.new
```

In `views/index.erb`:

```ruby
<!DOCTYPE html>
<html>
  <head>
    <title>Hello World!</title>
    <link href="/stylesheets/application.css" rel="stylesheet"/>
    <script src="/javascripts/application.js" type="text/javascript"></script>
  </head>
  <body>
    <h1>Hello World!</h1>
  </body>
</html>
```

In `public/javascripts/application.js`:

```js
alert(1);
```

In `public/stylesheets/application.css`:

```css
h1 { color: blue; }
```

### Testing Hobbit applications

[rack-test](https://github.com/brynary/rack-test) is highly recommended. See
an example:

In `app.rb`:

```ruby
require 'hobbit'

class App < Hobbit::Base
  get '/' do
    'Hello World!'
  end
end

run App.new
```

In `app_spec.rb`:

```ruby
require 'minitest/autorun'
# imagine that app.rb and app_spec.rb are stored in the same directory
require 'app'

describe App do
  include Rack::Test::Methods

  def app
    App.new
  end

  describe 'GET /' do
    it 'must be ok' do
      get '/'
      last_response.must_be :ok?
      last_response.body.must_match /Hello World!/
    end
  end
end
```

Please see the [rack-test](https://github.com/brynary/rack-test) documentation.

## Extending Hobbit

You can extend hobbit by creating modules or classes. See `Hobbit::Render` or
`Hobbit::Session` for examples.

### Hobbit::Contrib

See [hobbit-contrib](https://github.com/patriciomacadden/hobbit-contrib) for
more hobbit extensions!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

See the [LICENSE](https://github.com/patriciomacadden/hobbit/blob/master/LICENSE).