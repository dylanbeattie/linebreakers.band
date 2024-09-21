require 'httparty'
require 'nokogiri'

module Jekyll
  class SessionizeProfile < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @url = text.strip
    end

    def render(context)
      # Fetch the profile page
      response = HTTParty.get(@url)
      if response.code == 200
        parse_profile(response.body)
      else
        "<p>Unable to fetch Sessionize profile</p>"
      end
    end

    def parse_profile(html)
      # Parse the HTML with Nokogiri
      doc = Nokogiri::HTML(html)
      # Extract profile information
      profile_name = doc.css('.c-s-speaker-info--full .c-s-speaker-info__name').text.strip
      profile_tag = doc.css('.c-s-speaker-info--full .c-s-speaker-info__tagline').text.strip
      profile_image = doc.css('.c-s-speaker-info--full .c-s-speaker-info__avatar img').attr('src')
      topics = doc.css("ul.c-s-tags").map do |topic|
        topic.text.strip
      end

      # Extract sessions (this might vary depending on the Sessionize page structure)
      sessions = doc.css('.session-card').map do |session|
        title = session.css('.session-title').text.strip
        description = session.css('.session-description').text.strip
        "<li><strong>#{title}</strong><p>#{description}</p></li>"
      end

      # Format the information as HTML
      <<-HTML
      <section class="person">
        <img src="#{profile_image}" alt="#{profile_name}" />
        <h2>#{profile_name}</h2>
        <p>#{profile_tag}</p>
        #{topics.join(", ")}
        <h3>Sessions:</h3>
        <ul>
          #{sessions.join("\n")}
        </ul>
      </div>
      HTML
    end
  end
end

Liquid::Template.register_tag('sessionize_profile', Jekyll::SessionizeProfile)
