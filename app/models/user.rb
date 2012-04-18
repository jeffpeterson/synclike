require 'open-uri'
require 'json'

class User < ActiveRecord::Base
  attr_accessor :pandora_email
  attr_accessible :pandora_username, :pandora_email
  
  has_many :feed_entries
  has_one :rdio_account
  
  scope :with_feed, where( User.arel_table[:feed_url].not_eq(nil) )

  before_save :pandora_username_from_email, :feed_url_from_pandora_username
    
  def self.find_or_create_by_auth_hash auth_hash
    find_by_uid( auth_hash["uid"] ) || create_with_auth_hash(auth_hash)
  end

  private
  
  def self.create_with_auth_hash auth_hash
    create! do |user|
      user.uid                 = auth_hash["uid"]
      user.name                = auth_hash["info"]["name"]
      user.access_token        = auth_hash["credentials"]["token"]
      user.access_token_secret = auth_hash["credentials"]["secret"]
    end
  end
  
  def feed_url_from_pandora_username
    self.feed_url = "http://feeds.pandora.com/feeds/people/#{pandora_username}/recentactivity.xml" if pandora_username
  end

  def pandora_username_from_email
    return true if pandora_email.blank?

    result = JSON.parse(open(
      "http://www.pandora.com/services/ajax/" +
      "?method=authenticate.emailToWebname&email=" +
      pandora_email
    ).read)
    Rails.logger.info result
    self.pandora_username = result['result']['webname'] if result['stat'] == 'ok'
  end
end
