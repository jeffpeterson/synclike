require 'rdio'
class FeedEntry < ActiveRecord::Base
  default_scope order("created_at DESC")
  attr_accessor :rdio

  belongs_to :user
  after_create :add_to_rdio
  
  def self.update_feeds
    User.with_feed.each do |user|
      FeedEntry.update_feed_for(user)
    end
  end
  
  
  def self.update_feed_for user
    feed = Feedzirra::Feed.fetch_and_parse user.feed_url
    
    feed.entries.reverse.each do |fe|
      if !user.feed_entries.exists?(guid: fe.id) && fe.item_type == 'recentPositiveFeedback'
        user.feed_entries.create(
        guid:   fe.id,
        track:  fe.track.strip.split("\n").first.strip,
        album:  fe.album.strip,
        artist: fe.artist.strip,
        album_art_url: fe.album_art_url,
        item_type: fe.item_type
        )
      end
    end
  end
  
  def add_to_rdio
    results = rdio.call('search', query: "#{track} by #{artist}", types: 'Track')['result']['results']
    results.select! {|track| track['canStream'] }
    if results.first
      key = results.first['key']
      rdio.call('addToCollection', keys: key)
      rdio.call('setAvailableOffline', keys: key, offline: true)
    end
  end
  
  def rdio
    @rdio ||= Rdio.new([ENV['RDIO_APP_KEY'], ENV['RDIO_APP_SECRET']], [user.access_token, user.access_token_secret])
  end
  
end