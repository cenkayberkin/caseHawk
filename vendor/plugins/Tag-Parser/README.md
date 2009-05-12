Tag Parser
===

Ever needed to parse tags for your latest web 2.0 client project and wanted to handle all the quotes and commas and everything else - but couldn't really be arsed? Well worry no longer, we've got the parser for you.

We've used flickr tags as the model for our tagging.

It's as easy as:
<pre>
  results = TagParser.parse('one "two three" four')
  p results.tags        # => ['one', 'two three', 'four']
</pre>

If for any reason your parsing failed

<pre>  
  results = TagParser.parse('one "two three four')
  p results.tags        # => []
  p results.errors      # => ['Missing end quote']
</pre>

You can also unparse your tags:

<pre>
  TagParser.un_parse(['one', 'two three', 'four'])   # => 'one "two three" four'
</pre>

Check the specs to see all the scenarios we cover.

Brought to you by the wonder that is Envato [http://envato.com](http://envato.com)

Written by John Barton [http://whoisjohnbarton.com](http://whoisjohnbarton.com), specs provided by Clinton 'King of France' Forbes [http://github.com/clinton](http://github.com/clinton)