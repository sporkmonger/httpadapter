# HTTPAdapter

<dl>
  <dt>Homepage</dt><dd><a href="http://httpadapter.rubyforge.org/">httpadapter.rubyforge.org</a></dd>
  <dt>Author</dt><dd><a href="mailto:bobaman@google.com">Bob Aman</a></dd>
  <dt>Copyright</dt><dd>Copyright © 2010 Google, Inc.</dd>
  <dt>License</dt><dd>Apache 2.0</dd>
</dl>

## Description

A library for translating HTTP request and response objects for various clients
into a common representation.

## Reference

- {HTTPAdapter}

## Adapters

- {HTTPAdapter::NetHTTPAdapter}
- {HTTPAdapter::RackAdapter}
- {HTTPAdapter::TyphoeusAdapter}

## Example Usage

    adapter = HTTPAdapter::NetHTTPAdapter.new
    response = Net::HTTP.start('www.google.com', 80) { |http| http.get('/') }
    # => #<Net::HTTPOK 200 OK readbody=true>
    result = adapter.adapt_response(response)
    # => [
    #   200,
    #   [
    #     ["Expires", "-1"],
    #     ["Content-Type", "text/html; charset=ISO-8859-1"],
    #     ["X-Xss-Protection", "1; mode=block"],
    #     ["Server", "gws"],
    #     ["Date", "Thu, 26 Aug 2010 22:13:03 GMT"],
    #     ["Set-Cookie", "<snip>"],
    #     ["Cache-Control", "private, max-age=0"],
    #     ["Transfer-Encoding", "chunked"]
    #   ],
    #   ["<snip>"]
    # ]

## Install

* sudo gem install httpadapter
