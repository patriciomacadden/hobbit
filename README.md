# Bonsai

A minimalistic microframework built on top of [Rack](http://rack.github.io/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bonsai'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install Bonsai
```

## Features

* DSL inspired by [Sinatra](http://www.sinatrarb.com/).
* Could be extended with standard ruby classes and modules, with no extra logic
(see `Bonsai::Render` module).

## Usage

`Bonsai` applications are just instances of `Bonsai::Base` (see
[the rack specification](http://rack.rubyforge.org/doc/SPEC.html)). See the
classic **Hello World!** example:

In `config.ru`:

```ruby
require 'bonsai'

class App < Bonsai::Base
  get '/' do
    'Hello World!'
  end
end

run App.new
```

### Routes

You can define routes as in [Sinatra](http://www.sinatrarb.com/):

```ruby
class App < Bonsai::Base
  get '/' do
    # route body
  end
end
```

The returned value of the block will be the `body` of your route. The `headers`
and `status code` of the route will be calculated by `Rack::Response`, but you
could modify it.

Aditionally, when a route gets called you have this objects available:

* `env`: The standard rack env variable.
* `request`: a `Rack::Request` instance.
* `response`: a `Rack::Response` instance.

### Rendering

`Bonsai` comes with a module that uses [Tilt](https://github.com/rtomayko/tilt)
for rendering templates. See the example:

In `config.ru`:

```ruby
require 'bonsai'

class App < Bonsai::Base
  include Bonsai::Render

  get '/' do
    render 'views/index.html.erb'
  end
end

run App.new
```

and in `views/index.html.erb`:

```ruby
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

### Redirecting

If you look at Bonsai implementation, you may notice that there is no
`redirect` method (or similar). This is because such functionality is provided
by [Rack::Response](https://github.com/rack/rack/blob/master/lib/rack/response.rb)
and for now we [don't wan't to repeat ourselves](http://en.wikipedia.org/wiki/Don't_repeat_yourself).
So, if you want to redirect to another route, do it like this (in `config.ru`):

```ruby
require 'bonsai'

class App < Bonsai::Base
  get '/' do
    response.redirect '/hi'
  end

  get '/hi' do
    'Hello World!'
  end
end

run App.new
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

See LICENSE.