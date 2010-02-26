require 'rubygems'
require 'mechanize'
require 'gmail/email'
require 'gmail/conversation'
require 'gmail/conversation'


class ThreadNotFoundException<Exception
end

class Gmail

  CONV_PER_PAGE=50
  XPATH_CONV_IN_LIST="//tr[@bgcolor='#E8EEF7'] | //tr[@bgcolor='#ffffff']"
  XPATH_EMAIL_IN_CONV=".//table[@bgcolor='#efefef' and @border='0']"


  def initialize(email, pwd)
    @email=email
    @pwd=pwd
    @error=false
  end

  def connect
    base_url="http://www.gmail.com"
    @agent = WWW::Mechanize.new
    @agent.follow_meta_refresh = true
    base_page = @agent.get base_url
    login_form = base_page.forms.first
    login_form.Email = @email
    login_form.Passwd = @pwd
    @agent.submit(login_form)
    page= @agent.get "http://mail.google.com/mail/?ui=html&zy=a"

    # bad(but working) method to detect the connection
    connected=!(page.title[/Inbox/].nil?)

    return connected
  end

  # Scrap the list of summaries of conversations

  def search(tag, conv_start=0, conv_end=nil)
    summary_as_html("s=l&l=#{tag}", conv_start, conv_end){|html_conv, i|
      yield(html_conv, i)
    }
  end

  def list(conv_start=0, conv_end=nil)
    # display the list of emails
    summary_as_html("s=a", conv_start, conv_end){|html_conv, i|


    }
  end

  # Scrap the emails from the url of a given conversation
  def fetch_conversation(conv_summary)
    conv=Conversation.new(conv_summary)
    conversation_as_html(conv.url){|html|
      email=Email.create_from_html(html)
      conv.add_email(email)
    }
    return conv
  end

  private


  def summary_as_html(mode, conv_start, conv_end)

    page_index=conv_start/CONV_PER_PAGE

    while (!@error)

      # get the page of threads
      url="?#{mode}&st=#{page_index*CONV_PER_PAGE}"

      puts "fetching page: #{url}"
      page_list=@agent.get url

      # delegate each thread (html format)

      page_list.search(XPATH_CONV_IN_LIST).each_with_index{|conv, i|
        conv_index=page_index*CONV_PER_PAGE+i

        if (((!conv_end.nil?) && (conv_index>conv_end)) || @error)
          return
        end

        if (conv_index>=conv_start)
          begin
            c=ConvSummary.create_from_html(conv)
            yield(c)
          rescue DraftException
            puts "Skiping a draft"
          end
        end
      }

      # is there a next page?
      if (page_list.search("//a[@href='?s=a&st=#{((page_index+1)*CONV_PER_PAGE)}']").size>0)
        page_index+=1
      else
        @error=true
      end
    end
  end

# Scraping emails from the HTML UI of a thread/conversation
# input a thread object or an url
# output HTML tables
  def conversation_as_html(url=nil)

    url+="&d=e"

    # request the url of the thread
    list_emails=@agent.get(url).search(XPATH_EMAIL_IN_CONV)
    if list_emails.empty?
      raise ThreadNotFoundException.new
    else

      list_emails.each{|email_html|
        yield(email_html)
      }
    end
  end

end

