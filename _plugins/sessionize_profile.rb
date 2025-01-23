require 'httparty'
require 'nokogiri'
require 'countries'

module Jekyll
  class SessionizeProfile < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      parts = text.split(' ', 2)
      @url = parts.first.strip
      @id = @url.split('/').last
      @blurb = parts.last.strip
    end

    def render(_)
      # Fetch the profile page
      response = HTTParty.get(@url)
      if response.code == 200
        parse_profile(response.body)
      else
        '<p>Unable to fetch Sessionize profile</p>'
      end
    end

    def iso_alpha2(country_name)
      iso = ISO3166::Country.find_country_by_any_name(country_name)
      if iso&.alpha2
        return "<img class='flag' src='/images/flags/flat/32/#{iso.alpha2}.png' alt='Flag of #{country_name}' />"
      end

      country_name
    end

    def parse_profile(html)
      doc = Nokogiri::HTML(html)
      profile_name = doc.css('.c-s-speaker-info--full .c-s-speaker-info__name').text.strip
      profile_tag = doc.css('.c-s-speaker-info--full .c-s-speaker-info__tagline').text.strip
      profile_image = doc.css('.c-s-speaker-info--full .c-s-speaker-info__avatar img').attr('src')
      profile_location = doc.css('.c-s-speaker-info--full .c-s-speaker-info__location').text.strip
      profile_flag = iso_alpha2(profile_location.split(',').last&.strip)
      profile_bio = doc.css('.c-s-speaker-info__bio').first&.inner_html

      topics = doc.css('ul.c-s-tags')&.last&.css('li.c-s-tags__item')&.sort_by(&:text)&.map do |topic|
        topic.text.strip
      end

      events = doc.css('.c-s-event__name').map do |event|
        event.text.strip
      end

      talks = doc.css('.c-s-session').first(10).map do |session|
        title = session.css('.c-s-session__title a').text.strip
        url = session.css('.c-s-session__title a').attr('href')
        "<li><a href='https://sessionize.com#{url}'>#{title}</a></li>"
      end

      html = <<-HTML
      <section class="person" id="#{@id}">
        <img class="photo" src="#{profile_image}" alt="#{profile_name}" />
        <h3>#{profile_name}</h3>
        <p><em>#{profile_tag}</em></p>
      HTML
      if profile_location
        html << <<-HTML
            <p>#{profile_flag} #{profile_location}</p>
        HTML
      end
      html << profile_bio
      if topics&.any?
        html << <<-HTML
        	<p><strong>Topics:</strong> #{topics.join(', ')}</p>
        HTML
      end
      if talks&.any?
        html << <<-HTML
			<h3>Talks:</h3>
			<ul>
			#{talks.join("\n")}
			</ul>
        HTML
      end
      if events&.any?
        html << <<-HTML
			<p><strong>Events:</strong> #{events.join(', ')}</p>
        HTML
      end
      html << <<-HTML
        <p>Full Speaker Profile: <a href="#{@url}">#{@url}</a></p>
      </section>
      HTML
    end
  end
end

Liquid::Template.register_tag('sessionize_profile', Jekyll::SessionizeProfile)
