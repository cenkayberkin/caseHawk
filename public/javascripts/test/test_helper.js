Johnson.require(Ruby.File.dirname(__FILE__)+"/jspec");
Johnson.require(Ruby.File.dirname(__FILE__)+'/redgreen/redgreen')
Johnson.require(Ruby.File.dirname(__FILE__)+'/env')

for each (var file in Ruby.Dir.glob(Ruby.File.dirname(__FILE__) + '/../*.js')){
  Johnson.require(file)
}