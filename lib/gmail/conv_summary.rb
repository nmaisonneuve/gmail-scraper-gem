class DraftException<Exception
end

class ConvSummary

  attr_accessor :uid, :subject, :nb_emails, :updated_at, :tags, :url

  def self.create_from_html(html)

    conv=self.new
    data=html.content.split("\n\n")
    # extract link
    link=html.search(".//a").first.attributes['href'].to_s
      
    # raise an exception if there is only a draft
    raise DraftException.new if (link[/draft=.*/])

    conv.url=link
    conv.uid=link[/th=.*/].gsub("th=", "")

    #if (data.size>1)

    # extract nb_emails     
    num=data[1][/\((\d)+\)/]
    conv.nb_emails=(num.nil?)? 1 : num.gsub(/\(|\)/,"").to_i
    
    # remove drafts from the number of emails  
    unless data[1][/, Draft( \((\d)\))*/].nil?
           nb_drafts=/, Draft( \((\d)\))*/.match(data[1])[1]
           conv.nb_emails-=(nb_drafts.nil?)? 1: nb_drafts.gsub(/\(|\)/,"").to_i      
    end

    conv.nb_emails-=1 unless data[1][/, Draft/].nil?

   # extract nb_draft
    num=data[1][/\((\d)+\)/]
    conv.nb_emails=(num.nil?)? 1 : num.gsub(/\(|\)/,"").to_i
    # extract labels
    conv.tags=data[3].split(",").collect {|s| s.strip.downcase }

    # extract subject
    conv.subject=data[4]
    #else

    # extract subject
    # conv.subject=data[2]
    #end
    conv
  end
end