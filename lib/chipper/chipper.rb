%w(rubygems hpricot open-uri).each {|lib| require lib}

require 'htmlentities'
require 'iconv'
require 'erb'


class Chipper
  
  attr_accessor :url, :doc, :hdoc, :title, :divs, :div_scores, :khtml
  
  ERB_TEMPLATE = File.dirname(__FILE__) + "/template.erb.html"
  
  def initialize(url)
    @url            = url    
    @downvote_regex = /(comment|meta|footer|footnote|side)/
    @upvote_regex   = /((^|\\s)(post|hentry|entry[-]?(content|text|body)?|article[-]?(content|text|body)?)(\\s|$))/

    parse_doc
    score_divs
    kindlize_main_div
  end
  
  def parse_doc
    @doc = Hpricot(open(@url))
    # add a wrapper div in case the main content isn't wrapped in a div
    (@doc/:body).inner_html = "<div>" + (@doc/:body).inner_html + "</div>"    
    fetch_divs
  end
  
  def title
   (@doc/:title).inner_html 
  end

  # find divs containing paragraphs (uncontained by other *divs*)
  def fetch_divs
    @divs = (@doc/:div)
    @div_scores = Array.new(@divs.size, 0)
  end
  
  def score_divs
    self.divs.each_with_index do |div, index|
      # Look for a special classname
      div_scores[index] -= 50 if (div.attributes['class'] =~ @downvote_regex || div.attributes['id'] =~ @downvote_regex)
        
      # Look for a special id
      div_scores[index] += 25 if (div.attributes['class'] =~ @upvote_regex || div.attributes['id'] =~ @upvote_regex)
      
      # Add a point for the paragraph found -- don't include paragraphs found within inner divs
      # div_scores[index] += (div/:p).size
      (div/:p).each do |p|

        if p.parent == div
          div_scores[index] += 1   

          # Add points for any commas found within the paragraph
          div_scores[index] += p.inner_html.count(',')
        end
        
      end
      
    end
  end
  
  def div_score(div_index)
    div_scores[div_index]
  end
  
  def main_div
    hash = Hash.new
    self.div_scores.each_with_index {|item, index| hash[item] = index}
    self.divs[hash[self.div_scores.max]]
  end
  
  def kindlize_main_div
    main = self.main_div.inner_html 

    # clean up entries:
    ic = Iconv.new('ISO-8859-1//TRANSLIT', 'utf-8') 
    ic2 = Iconv.new('ISO-8859-1//IGNORE', 'utf-8') 

    coder = HTMLEntities.new

    main = coder.decode(main)

    # replace troublesome nbsps
    main.gsub!("\xa0", ' ')
    main.gsub!("\xA9", ' ')

    # this bastard's not working for some reason
    # begin
    #  main = ic.iconv(main) 
    # rescue
    #  main = ic2.iconv(main) 
    # end
    
    begin
      # convert main to native charset (note: in this case we're
      # converting from utf-8 to the native charset, but the only thing
      # about the code that's utf-8 specific is the assumption about
      # character width and the unicode lookup table below)
      main = ic.iconv(main) << ic.iconv(nil)
    rescue Iconv::IllegalSequence => e
      # save the portion of the string that was successful, the
      # invalid character, and the remaining (pending) string
      success_str = e.success
      ch, pending_str = e.failed.split(//, 2)
      ch_int = ch.to_i

      main = success_str + pending_str
      retry
    end

    ret = main

    doc = Hpricot(main)
    doc.search('h1, h2, h3') do |h|
     h.swap("<h4>#{h.inner_text}</h4>")
    end
    doc.search('//font') do |font|
     font.swap(font.inner_text)
    end
    doc.search('//img').remove
    doc.search('svg, object, embed').remove
    doc.search('script').remove
    @content =  doc.to_s
    @title   = self.title
  
    erb = ERB.new(File.read(ERB_TEMPLATE))
    @khtml = erb.result(binding())
  end

end