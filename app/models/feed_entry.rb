require 'rdio'
class FeedEntry < ActiveRecord::Base
  default_scope order("created_at DESC")
  attr_accessor :rdio, :rdio_track
  attr_accessible :track, :album, :artist, :item_type, :album_art_url

  belongs_to :user
  
  def self.update_feeds
    User.with_feed.each do |user|
      FeedEntry.update_feed_for(user)
    end
  end
  
  
  def self.update_feed_for user
    feed = Feedzirra::Feed.fetch_and_parse user.feed_url

    return unless feed.respond_to? :entries
    feed_entries = []
    
    feed.entries.reverse.each do |fe|
      if fe.item_type == 'recentPositiveFeedback'
        track = fe.track.strip.split("\n").first.strip
        album =  fe.album.strip
        next if user.feed_entries.where(
          track: track,
          album: fe.album.strip
        ).any?

        feed_entry = user.feed_entries.create(
          track:  track,
          album:  album,
          artist: fe.artist.strip,
          album_art_url: fe.album_art_url,
          item_type: fe.item_type
        )

        feed_entries << feed_entry
      end
    end

    add_to_rdio feed_entries
  end
  
  def self.add_to_rdio feed_entries
    keys = []
    
    feed_entries.each do |feed_entry|
      keys << feed_entry.rdio_track['key'] if feed_entry.rdio_track && feed_entry.rdio_track['key']
    end

    Rails.logger.info "Adding keys: " + keys.inspect

    return if keys.blank?

    keys = keys.join(',')

    rdio = feed_entries.first.rdio

    rdio.call('addToCollection', keys: keys)
    rdio.call('setAvailableOffline', keys: keys, offline: true)

    if result = rdio.call('getPlaylists')
      playlist = result['result']['owned'].select {|pl| pl['name'] == 'From Pandora'}.first

      if playlist
        rdio.call 'addToPlaylist', playlist: playlist['key'], tracks: keys
      else
        playlist = rdio.call 'createPlaylist', name: 'From Pandora', description: "Thumbed up tracks from Pandora.", tracks: keys
        rdio.call 'setAvailableOffline', keys: playlist['key'], offline: true
      end
    end
  end

  def rdio_track
    @rdio_track ||= begin
      results = rdio.call('search', query: "#{track} by #{artist}", types: 'Track')['result']['results']
      results.select! {|track| track['canStream'] && track["artist"].strip.downcase == artist.strip.downcase }
      results.first
    end
    
  end
  
  def rdio
    @rdio ||= Rdio.new([ENV['RDIO_APP_KEY'], ENV['RDIO_APP_SECRET']], [user.access_token, user.access_token_secret])
  end
  
end
