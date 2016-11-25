Rails.application.routes.draw do
  get 'welcome/index' 
  root 'welcome#index'
  
  get  "/searchConcert"        => "welcome#index"
  get  "/searchKrithi"         => "welcome#index"
  get  "/searchArtist"         => "welcome#index"
  get  "/searchRagam"          => "welcome#index" 
  get  "/searchKrithiFuzzy"    => "welcome#index"
  get  "/clearData"            => "welcome#clearData"
  
  post "searchConcert"         => "welcome#searchConcert"
  post "searchKrithi"          => "welcome#searchKrithi"
  post "searchRagam"           => "welcome#searchRagam" 
  post "searchArtist"          => "welcome#searchArtist"
  post "searchKrithiFuzzy"     => "welcome#searchKrithiFuzzy" 
  post "clearData"             => "welcome#clearData"               
end
