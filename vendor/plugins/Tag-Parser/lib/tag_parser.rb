class TagParser
  class Result
    def initialize(tags, errors)
      @tags, @errors = tags, errors
    end
    
    attr_accessor :tags, :errors
  end
  
  def self.parse(input)
    parser = new(input)
    parser.results
  end
  
  def self.un_parse(tags)
    tags.map {|tag| tag.include?(?\s) ? "\"#{tag}\"" : tag }.join(' ')
  end
  
  def initialize(input)
    @input = input
    @tags, @errors = [], []
    reset_current_tag
  end  

  def results
    input_io = StringIO.new(@input)
    
    open_quote = nil
    using_commas = @input.include? ?,
 
    while (char = input_io.getc)
      case char
      when ?", ?'
        if open_quote
          if char == open_quote
            open_quote = nil
          else
            set_error 'Missing end quote'
            break
          end
        else
          open_quote = char
        end
      when ?,
        if open_quote
          set_error "The character ',' is not allowed in tag names. (No commas inside quotes.)"
          break
        else
          flush
        end
      when ?\s
        if using_commas || open_quote
          @current_tag << char
        else
          flush
        end
      when ?@
        set_error "The character '@' is not allowed in tag names"
        break
      else
        @current_tag << char
      end
    end
    flush
 
    if open_quote && @errors.empty?
      set_error 'Missing end quote'
    end
    
    flush
    Result.new(@tags, @errors)
  end

private
  def reset_current_tag
    @current_tag = ''
  end
  
  def set_error(error_msg)
    @tags = []
    reset_current_tag
    @errors << error_msg
  end
  
  def flush
    current_tag = @current_tag.downcase
    unless @current_tag.empty? || @tags.any? {|e| e.downcase == current_tag }
      @tags << @current_tag.strip
    end
    reset_current_tag
  end
end