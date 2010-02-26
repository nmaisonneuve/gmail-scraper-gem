require 'lib/gmail.rb'

    gmail=Gmail.new("n.maisonneuve", "EU357b??;;??")
    if (gmail.connect)
      gmail.search("appart"){|thread_summary,i|
        p thread_summary
        thread=gmail.fetch_conversation(thread_summary)
        p thread.emails[0].text
      }
    else
      p "not connected"
   end
