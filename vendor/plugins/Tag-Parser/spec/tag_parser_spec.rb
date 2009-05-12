Dir.glob(File.dirname(__FILE__) + '/../lib/*.rb').each {|rb| require rb}

describe TagParser, "parsing tags from a string" do
  it "should allow nothing as valid input" do
    result = TagParser.parse("")
    result.tags.should == []
    result.errors.should == []
  end
 
  it "should seperate tags on spaces" do
    result = TagParser.parse("one two three four")
    result.tags.should == ["one", "two", "three", "four"]
    result.errors.should == []
  end
 
  it "should allow double quotes to allow spaces in tags" do
    result = TagParser.parse('one "two parts" three four')
    result.tags.should == ["one", "two parts", "three", "four"]
    result.errors.should == []
  end
 
  it "should crack the sads if quotes are not closed properly" do
    result = TagParser.parse('one "two" parts "three four')
    result.tags.should == []
    result.errors.should == ["Missing end quote"]
  end
 
  it "should allow numbers and full-stops" do
    result = TagParser.parse('one "web 2.0" three 4000')
    result.tags.should == ["one", "web 2.0", "three", "4000"]
    result.errors.should == []
  end
 
  it "should allow dashes" do
    result = TagParser.parse("one two-point-two three four")
    result.tags.should == ["one", "two-point-two", "three", "four"]
    result.errors.should == []
  end
 
  it "should not allow other crazy characters" do
    result = TagParser.parse('clinton@gmail.com "web 2.0" three four')
    result.tags.should == []
    result.errors.should == ["The character '@' is not allowed in tag names"]
  end
 
  it "should allow single quotes to allow spaces in tags" do
    result = TagParser.parse("one 'two parts' three four")
    result.tags.should == ["one", "two parts", "three", "four"]
    result.errors.should == []
  end
 
  it "should force quotes to be closed with the matching quote" do
    result = TagParser.parse("one 'two parts\" three four")
    result.tags.should == []
    result.errors.should == ["Missing end quote"]
 
    result = TagParser.parse("one \"two parts' three four")
    result.tags.should == []
    result.errors.should == ["Missing end quote"]
  end
 
  it "should preserve case" do
    result = TagParser.parse("One 'two parts' tHree four")
    result.tags.should == ["One", "two parts", "tHree", "four"]
    result.errors.should == []
  end
 
  it "should ignore duplicates, irrespective of case, using the case of the first instance found" do
    result = TagParser.parse("One three 'two parts' tHree four one")
    result.tags.should == ["One", "three", "two parts", "four"]
    result.errors.should == []
  end
 
  it "should seperate tags on commas also" do
    result = TagParser.parse("one, two three, four")
    result.tags.should == ["one", "two three", "four"]
    result.errors.should == []
  end
  
  it "should seperate tags on commas and only commas if commas are in use" do
    result = TagParser.parse("one two, two three, four")
    result.tags.should == ["one two", "two three", "four"]
    result.errors.should == []
  end
  
  it "should not seperate a quoted tag on a comma, but report an error" do
    result = TagParser.parse('one "two parts, three" four')
    result.tags.should == []
    result.errors.should == ["The character ',' is not allowed in tag names. (No commas inside quotes.)"]
  end
 
  it "should seperate all tags by commas, if used once" do
    result = TagParser.parse('one, two three four ')
    result.tags.should == ['one', 'two three four']
    result.errors.should == []
  end
 
  it "should not get confused if both commas and double-quotes are combined" do
    result = TagParser.parse('one, "two three", four')
    result.tags.should == ['one', 'two three', 'four']
    result.errors.should == []
  end 
end

describe TagParser, "converting an array of tags back to a string" do
  it "should return an empty array as an empty string" do
    tags = []
    TagParser.un_parse(tags).should == ''
  end
  
  it "should return tags separated by spaces where no quotes are involved" do
    tags = %w(one two three four)
    TagParser.un_parse(tags).should == 'one two three four'
  end
  
  it "should handle numbers fine" do
    tags = %w(1 2 3 4)
    TagParser.un_parse(tags).should == '1 2 3 4'
  end
  
  it "should wrap separated words in double quotes" do
    tags = ["one", "two three", "four", "five"]
    TagParser.un_parse(tags).should == 'one "two three" four five'
  end
end