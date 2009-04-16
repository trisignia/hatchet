%w(rubygems hpricot open-uri).each {|lib| require lib}

require 'htmlentities'
require 'iconv'
require 'erb'


class Page
  
  attr_accessor :url, :doc, :hdoc, :title, :divs, :div_scores
  
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
   
   #ic = Iconv.new('ASCII//TRANSLIT', 'utf-8') 
   coder = HTMLEntities.new
   
   begin
     main = ic.iconv(main) 
   rescue
     main = ic2.iconv(main) 
   end
   
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
   out = erb.result(binding())

   date = Time.now.strftime('%m-%d-%Y')
   
   # TODO write this file to a temp directory
   outfile = "#{@title}-#{date}.html"
   File.open(outfile, "w") do |f|
     f.write out
   end
  end

end