class FeedEntry < ActiveRecord::Base
  belongs_to :user
  
  
  def self.update_feeds
    User.with_feed.each do |user|
      FeedEntry.update_feed_for(user)
    end
  end
  
  
  def self.update_feed_for user
    feed = Feedzirra::Feed.fetch_and_parse user.feed_url
    
    feed.entries.each do |fe|
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
  
end