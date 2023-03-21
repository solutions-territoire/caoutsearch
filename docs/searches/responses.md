---
title: Responses
order: -9
---

After the request has been sent by calling a method such as `load`, `response` or `hits`, the results is wrapped in a `Response::Response` class which provides method access to its properties via [Hashie::Mash](http://github.com/intridea/hashie).

Aggregations and suggestions are wrapped in their own respective subclass of `Response::Response`

````ruby
results.response
=> #<Caoutsearch::Response::Response _shards=#<Caoutsearch::Response::Response failed=0 skipped=0 successful=5 total=5> hits=…

search.hits
=> #<Hashie::Array [#<Caoutsearch::Response::Response _id="2"…

search.aggregations
=> #<Caoutsearch::Response::Aggregations view_count=#<Caoutsearch::Response::Response…

search.suggestions
=> #<Caoutsearch::Response::Suggestions tags=#<Caoutsearch::Response::Response…
````