# 0.5.0 (Unreleased)

* Refactor `Hobbit::Base#halt`. It now sets the status, merges the headers and
writes the body (using `Hobbit::Response#write`) when given a fixnum, a hash or
a string.
* `Hobbit::Response` headers and body are not accessors anymore. This is
because when you set the body directly, the `Content-Length` is not calculated
(it's calculated on `#write`).

# 0.4.4

* Refactor `Hobbit::Response`.

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
