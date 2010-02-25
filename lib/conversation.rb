require 'lib/conv_summary.rb'
class Conversation<ConvSummary

  attr_accessor :created_at, :emails

  def initialize(conv_summary)  
     @subject=conv_summary.subject
     @nb_emails=conv_summary.nb_emails
     @tags=conv_summary.tags
     @emails=[]
     @uid=conv_summary.uid
     @url=conv_summary.url
  end
  
  
  def add_email(email)
    @emails<<email
    @created_at=email.created_at if (@created_at.nil? || @created_at>email.created_at)
    @updated_at=email.created_at if (@updated_at.nil? || @updated_at<email.created_at)
    email.subject=@subject unless @subject.nil?

  end

  def sort_emails
    @emails.sort
  end
end
