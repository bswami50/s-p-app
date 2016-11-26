#global variables
$modified_base_link = '' #Mirror location
$concert_id = ''
$artist = ''
$venue = ''
$file_name_array = Array.new(0)
$file_path_array = Array.new(0)
$fuzzy_krithi_array = Array.new(0)
$fuzzy_artist_array = Array.new(0)
$krithi = ''
$full_array = Hash.new{|hsh,key| hsh[key] = [] }
NUM_FIELDS = 7
@user_agent = "SangeethaPriya/1.1.5 CFNetwork/808.0.2 Darwin/16.0.0"
@user_agent_play = "AppleCoreMedia/1.0.0.14A456 (iPhone; U; CPU OS 10_0_2 like Mac OS X; en_us)"

class WelcomeController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def initData
    $modified_base_link = 'null'
    $concert_id = ''
    $artist = ''
    $venue = ''
        
    $file_name_array = Array.new(0)
    $file_path_array = Array.new(0)
    $fuzzy_krithi_array = Array.new(0)
    $fuzzy_artist_array = Array.new(0)    
    $full_array = Hash.new{|hsh,key| hsh[key] = [] }
    $krithi = ''
  end
  
  def searchConcert
    #init for each search
    base_link = '' #Landing page for concert    
    file_name = '' #Filename (without .mp3)
    final_file_path = '' #download link
    file_count = 0
     
    initData()
    
    if(!params[:queryConcert].nil?)
     $concert_id = params[:queryConcert].strip
    elsif(!params[:commit].nil?)
     $concert_id = params[:commit].strip
    else
      puts "Invalid Concert ID"
    end
     
    cid = $concert_id.split('-') #ul - cid
    
    if(!$concert_id.blank?)    
          
      url = "https://www.sangeethamshare.org/mccbala/scripts/api/view/album/#{cid[0]}/#{cid[1]}/?format=json"
      response = HTTParty.get(url, :headers => {"User-Agent" => "#{@user_agent}"}, follow_redirects: false)
      data = JSON.parse(response.body)
      #puts JSON.pretty_generate(data)
    
      $artist = data["album"]["mainartist"]
      $venue  =  data["album"]["venue"]
       
      base_link = data["album"]["url"] 
      print "Base link: ", base_link, "\n \n"
      $modified_base_link = base_link
       
      if(!data["tracks"][0]["composer"].blank?) #sanity check for tracks
       data["tracks"].each_with_index do |record, i|
        file_name = record["kriti"]
        file_name = file_name.split('_').join(' ').downcase.gsub(' ', '_')
        ragam = record["ragam"]
        ragam = ragam.downcase
        file_name = file_name + "-" + ragam
        final_file_path = record["url1"]
        $file_path_array.push(final_file_path)
        $file_name_array.push(file_name)
      end
      elsif
        puts "No tracks found for #{$concert_id}!"
      end
    elsif
      puts "Concert #{$concert_id} not found!"
    end  

    render "index"
  end

#==============================================================================  
  
        def searchKrithi

          initData()
          kid = 0
         
          $krithi = params[:queryKrithi].strip
          $artist = params[:queryArtist].strip

        if(!$krithi.blank?) 
          url = "https://www.sangeethamshare.org/mccbala/scripts/api/list/kriti/?format=json&kriti=#{$krithi}"

          response = HTTParty.get(url, :headers => {"User-Agent" => "#{@user_agent}"}, follow_redirects: false)
          data = JSON.parse(response.body)
 
          data.each do |record|
           kid = record["kid"] unless (record["trackcount"].to_i == 0) 
          end

         if(kid!=0)
          url = "https://www.sangeethamshare.org/mccbala/scripts/api/list/track/?offset=0&count=200&kid=#{kid}&format=json"

           response = HTTParty.get(url, :headers => {"User-Agent" => "#{@user_agent}"}, follow_redirects: false)
           data = JSON.parse(response.body)
           #puts JSON.pretty_generate(data)

           data.each_with_index do |record,i|
            cid = record["uid"]+"-"+record["cid"].upcase
            krithi = record["kriti"].split('_').join(' ').downcase.gsub(' ', '_')
            ragam = record["ragam"].downcase
            composer = record["composer"].split('_').join(' ').downcase.gsub(' ', '_')
            artist = record["mainartist"]
            genre = record["genre"].downcase
            concert_url = record["url"]
            track_url = record["audiourl"] 
            if(!$artist.empty?)
             $full_array[i].push [cid, krithi, ragam, artist, genre, composer, concert_url, track_url] unless ($artist != artist)
            elsif
             $full_array[i].push [cid, krithi, ragam, genre, artist, composer, concert_url, track_url]
            end
           end
          end
           
         end

    render "index"
  end 
  
#==============================================================================  
  def searchRagam

        initData()
    
        $ragam = params[:queryRagam].strip

        if(!$ragam.blank?) 
          url = "https://www.sangeethamshare.org/mccbala/scripts/api/list/kriti/?offset=0&count=200&format=json&ragam=#{$ragam}"

          response = HTTParty.get(url, :headers => {"User-Agent" => "#{@user_agent}"}, follow_redirects: false)
          data = JSON.parse(response.body)
 
          data.each_with_index do |record, i|
            krithi = record["kriti"].split('_').join(' ').downcase.gsub(' ', '_')
            ragam = record["ragam"].downcase
            composer = record["composer"].split('_').join(' ').downcase.gsub(' ', '_')
            count = record["trackcount"]
            kid = record["kid"]
            no = record["no"]
            $full_array[i].push [kid, krithi, ragam, composer, count]         
          end
        end
    
    $full_array_new = $full_array.sort_by { |k| k[4]}
    puts $full_array_new
    
    render "index"
  end
  
#==============================================================================
  
        def searchArtist

          @tmp_array = Array.new(0)
          @row_count = 1
          initData()

          system("rm sp_link > /dev/null 2>&1")
          system("rm sp_save > /dev/null 2>&1")

          $artist = params[:queryArtist1].strip

          if(!$artist.blank?)
           uri = URI('https://www.sangeethapriya.org/fetch_tracks.php?main_artist1')
           req = Net::HTTP::Post.new(uri)
           req.set_form_data('FIELD_TYPE' => $artist) 

           res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
            http.request(req)
           end

           case res
           when Net::HTTPSuccess
             File.open('sp_save', 'wb'){|f| f << res.body}
           when Net::HTTPRedirection
             puts "Redirected"
           else
            res.value
           end

          col_count = 0
          doc = Nokogiri::HTML(open("sp_save"))
            doc.search("//td").each do |cell| 

               if (col_count % NUM_FIELDS == 0) #0-concert
                 @tmp_array[1] = cell.text.upcase
               elsif (col_count % NUM_FIELDS == 2) #2-song
                 @tmp_array[2] = cell.text.split('_').join(' ').downcase.gsub(' ', '_')
               elsif (col_count % NUM_FIELDS == 3) #3-ragam 
                 @tmp_array[3] = cell.text.downcase
               elsif (col_count % NUM_FIELDS == 4) #4-composer
                 @tmp_array[4] = cell.text.split('_').join(' ').downcase.gsub(' ', '_')
               elsif (col_count % NUM_FIELDS == 5) #5-artist
                 @tmp_array[5] = cell.text
               end         

             col_count = col_count + 1 

             if (col_count % NUM_FIELDS == 0) 
              col_count = 0
               $full_array[@row_count].push [@tmp_array[1], @tmp_array[2], @tmp_array[3], @tmp_array[4], @tmp_array[5]] 
               @row_count += 1 
              end   
             end
          end

    render "index"
  end   


#==============================================================================   

  def searchKrithiFuzzy
      
    krithi = params[:queryKrithiFuzzy].strip
    artist = params[:queryArtistFuzzy].strip
    initData()
    
    if(!krithi.blank?)
     File.open('public/sp_db_krithi.txt', "r") do |f|
     f.each_line do |line|
       $fuzzy_krithi_array.push line.split('_').join(' ').downcase.gsub(' ', '_') unless !line.downcase.include? krithi.downcase    
      end   
     end
    end

    if(!artist.blank?)
     File.open('public/sp_db_artist.txt', "r") do |f|
     f.each_line do |line|
      $fuzzy_artist_array.push line unless !line.downcase.include? artist.downcase    
      end   
     end
    end
    
    render "index"
    
  end  
  
  #===================================================
  
  def clearData
    
    initData()
    
    render "index"
  end 
end



