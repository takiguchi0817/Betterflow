module ApiHelper
  def get_track_list_from_itunes(artist_name)
    track_json_list = get_track_json_list_from_itunes(artist_name)
    save_track_to_db(track_json_list, artist_name)
  end

  def get_track_json_list_from_itunes(artist_name)
    host = 'itunes.apple.com'
    path = '/search?term=' + CGI::escape(artist_name)

    http = Net::HTTP.new(host, 80)
    req = Net::HTTP::Get.new(path)
    res = http.request(req)
    hash = JSON.parse(res.body)

    track_json_list = Array.new
    if hash['resultCount'] > 0
      hash['results'].each do |track_json|
        if valid_json?(track_json)
          track_json_list.push(track_json)
        end
      end
    end

    return track_json_list
  end

  def valid_json?(track_json)
    if !Hash.try_convert(track_json)
      return false
    end

    is_valid = (
      (track_json.key?('artistName')) and
      (track_json.key?('trackName')) and
      (track_json.key?('trackViewUrl')) and
      (track_json.key?('previewUrl')) and
      (track_json.key?('artworkUrl100')) and
      (track_json.key?('releaseDate'))
    )

    return is_valid
  end

  def save_track_to_db(track_json_list, artist_name)
    if track_json_list.size > 0
      track_json_list.each do |track_json|
        if track_json['artistName'].downcase == artist_name
          Track.create_from_json(track_json)
        end
      end
    end
  end

  def get_track_list_from_db
    track_json_list = Array.new
    track_list = Track.find(:all)
    if track_list.length > 0
      track_list.each do |track|
        track_json_list.push(track.to_hash)
      end
    end

    return track_json_list
  end
end
