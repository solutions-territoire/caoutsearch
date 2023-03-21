---
title: Aggregations
order: -7
---

You can define simple to complex aggregations.

````ruby
class ArticleSearch < Caoutsearch::Search::Base
  has_aggregation :view_count, { sum: { field: :view_count } }
  has_aggregation :popular_tags, {
    filter: { term: { published: true } },
    aggs: {
      published: {
        terms: { field: :tags, size: 10 }
      }
    }
  }
end
````

Then you can request one or more aggregations at the same time or chain the `aggregate` method.  
The `aggregations` method will trigger a request and returns a [Response::Aggregations](/docs/searches/responses).

````ruby
ArticleSearch.aggregate(:view_count).aggregations
# ArticleSearch Search { "body": { "aggs": { "view_count": { "sum": { "field": "view_count" }}}}}
# ArticleSearch Search (10ms / took 5ms)
=> #<Caoutsearch::Response::Aggregations view_count=#<Caoutsearch::Response::Response value=119652>>

ArticleSearch.aggregate(:view_count, :popular_tags).aggregations
# ArticleSearch Search { "body": { "aggs": { "view_count": {…}, "popular_tags": {…}}}}
# ArticleSearch Search (10ms / took 5ms)
=> #<Caoutsearch::Response::Aggregations view_count=#<Caoutsearch::Response::Response value=119652> popular_tags=#<Caoutsearch::Response::Response buckets=…>>

ArticleSearch.aggregate(:view_count).aggregate(:popular_tags).aggregations
# ArticleSearch Search { "body": { "aggs": { "view_count": {…}, "popular_tags": {…}}}}
# ArticleSearch Search (10ms / took 5ms)
=> #<Caoutsearch::Response::Aggregations view_count=#<Caoutsearch::Response::Response value=119652> popular_tags=#<Caoutsearch::Response::Response buckets=…>>
````

You can create powerful aggregations using blocks and pass arguments to them.

````ruby
class ArticleSearch < Caoutsearch::Search::Base
  has_aggregation :popular_tags_since do |date|
    raise TypeError unless date.is_a?(Date)

    query.aggregations[:popular_tags_since] = {
      filter: { range: { publication_date: { gte: date.to_s } } },
      aggs: {
        published: {
          terms: { field: :tags, size: 20 }
        }
      }
    }
  end
end

ArticleSearch.aggregate(popular_tags_since: 1.day.ago).aggregations
# ArticleSearch Search { "body": { "aggs": { "popular_tags_since": {…}}}}
# ArticleSearch Search (10ms / took 5ms)
=> #<Caoutsearch::Response::Aggregations popular_tags_since=#<Caoutsearch::Response::Response …
````

Only one argument can be passed to an aggregation block.  
Use an Array or a Hash if you need to pass multiple options.

````ruby
class ArticleSearch < Caoutsearch::Search::Base
  has_aggregation :popular_tags_since do |options|
    # …
  end

  has_aggregation :popular_tags_between do |(first_date, end_date)|
    # …
  end
end

ArticleSearch.aggregate(popular_tags_since: { date: 1.day.ago, size: 20 })
ArticleSearch.aggregate(popular_tags_between: [date1, date2])
````

Finally, you can create a "catch-all" aggregation to handle cumbersome behaviors:

````ruby
class ArticleSearch < Caoutsearch::Search::Base
  has_aggregation do |name, options = {}|
    raise "unxpected_error" unless name.match?(/^view_count_(?<year>\d{4})$/)

    query.aggregations[name] = {
      filter: { term: { year: $LAST_LATCH_INFO[:year] } },
      aggs: {
        filtered: {
          sum: { field: :view_count }
        }
      }
    }
  end
end

ArticleSearch.aggregate(:view_count_2020, :view_count_2019).aggregations
# ArticleSearch Search { "body": { "aggs": { "view_count_2020": {…}, "view_count_2019": {…}}}}
# ArticleSearch Search (10ms / took 5ms)
=> #<Caoutsearch::Response::Aggregations view_count_2020=#<Caoutsearch::Response::Response …
````