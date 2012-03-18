class Feedzirra::Parser::RSSEntry
  element 'pandora:itemType', as: :item_type
  element 'pandora:albumArtUrl', as: :album_art_url
  element 'mm:Artist', as: :artist
  element 'mm:Album', as: :album
  element 'mm:Track', as: :track
end