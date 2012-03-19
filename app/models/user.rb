class User < ActiveRecord::Base
  attr_accessor :pandora_username
  attr_accessible :pandora_username
  has_many :feed_entries
  has_one :rdio_account
  
  scope :with_feed, where(User.arel_table[:feed_url].not_eq(nil))

  before_save :feed_url_from_pandora_username
    
  def self.find_or_create_by_auth_hash auth_hash
    find_by_provider_and_uid( auth_hash["provider"], auth_hash["uid"] ) || create_with_auth_hash(auth_hash)
  end

  
  private
  
  def self.create_with_auth_hash auth_hash
    create! do |user|
      user.provider = auth_hash["provider"]
      user.uid      = auth_hash["uid"]
      user.name     = auth_hash["info"]["name"]
    end
  end
  
  def feed_url_from_pandora_username
    self.feed_url = "http://feeds.pandora.com/feeds/people/#{pandora_username}/recentactivity.xml" if pandora_username
  end
end