class Email
  attr_accessor :uid, :sender, :receivers, :created_at, :text, :subject

  def initialize
    @receivers=[]
  end

  def self.create_from_html(html)

    email=Email.new

    tr=html.search(".//tr/td")

    # sender
    sender=tr[0].content.chomp.strip.gsub("/n", "")
    sender=emails_to_array(sender)
    email.sender=sender[0].downcase

    # uid
    #email.uid=conv.uid
    tr[0].search(".//a").each{|link|
      link=link.attributes['href'].to_s
      email.uid=link[/#.*/].gsub("#", "")
    }

    # date
    date=tr[1].content.chomp.strip.gsub("/n", "")
    email.created_at=DateTime.strptime(date, '%a, %b %d, %Y at %I:%M %p')


    # extract TO
    receivers_to=tr[2].content.chomp.strip.gsub("/n", "")
    email.receivers<<emails_to_array(receivers_to)

    # extract CC
    receivers_cc=tr[3].content.chomp.strip.gsub("/n", "")
    email.receivers<<emails_to_array(receivers_cc)
    # #puts  "receiver_cc:#{receivers_cc}"

    # extract Body
    content=""
    content = tr[4].content unless tr[4].nil?
    content = tr[5].content if content.chomp.strip.gsub("/n", "").index("Reply |")==0
    email.text=content.chomp.strip.gsub("/n", "")

    return email
  end

  private
  def self.emails_to_array(txt)
    reg = /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i
    txt.scan(reg).uniq
  end

end

