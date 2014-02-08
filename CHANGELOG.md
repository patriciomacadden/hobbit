# 0.4.3

* Calculate the `Content-Length` of a `Hobbit::Response` using `#bytesize`
instead of `#size`.

# 0.4.2

* Add `Hobbit::Response#redirect`, that was missing since `Hobbit::Response`
isn't a `Rack::Response` subclass.

# 0.4.1

* `Hobbit::Response` now returns the `Content-Length` header as a string.

# 0.4.0

* Add halt method.

# 0.3.1

* Remove unused `attr_accessor` (`:length`) from `Hobbit::Response`.

# 0.3.0

* `Hobbit::Response` is no longer a subclass of `Rack::Response`.
* Forward `#map` and `#use` methods to `Rack::Builder` instead of define these
methods.
