require 'rubygems'
require "spec"
require '../lib/gmail.rb'

describe Gmail do

  before(:all) do
    @login="loging"
    @pass="password"
    @gmail=Gmail.new(@login, @pass)
    @gmail.connect
  end


  it "should not be connected with wrong login/password" do
    gmail=Gmail.new("bar", "foo")
    gmail.connect.should==false
  end


  it "should be connected with right login/password" do
    @gmail.connect.should==true
  end


  it "should be able to extract a summary of the first 50 conversations" do
    email_start=0
    email_end=1
    @gmail.connect
    i=0
    @gmail.list(email_start, email_end) { |thread_summary|
      thread_summary.subject.should_not==nil
      thread_summary.nb_emails.should>=1
      thread_summary.uid.should_not==nil
      thread_summary.tags.size.should>=0
      
      i+=1
    }
    i.should==(email_end-email_start+1)
  end

  it "should be able only to extract the correct interval of conversations" do
    i=0
    @gmail.list(1,2){ |conv_summary|
      conv=@gmail.fetch_conversation(conv_summary)
       i+=1
    }
    i.should==2
  end

  it "should be able to fetch the correct number of emails in a conversations" do
    @gmail.list(500,551){ |conv_summary|        
        conversation=@gmail.fetch_conversation(conv_summary)
        conversation.emails.size.should==conversation.nb_emails
    }
  end

end