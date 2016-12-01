Rails.application.routes.draw do
  get 'welcome/index' 
  root 'welcome#index'
  
  get  "/searchConcert"        => "welcome#clearData"
  get  "/searchKrithi"         => "welcome#clearData"
  get  "/searchArtist"         => "welcome#clearData"
  get  "/searchRagam"          => "welcome#clearData" 
  get  "/searchComposer"       => "welcome#clearData"
  get  "/clearData"            => "welcome#clearData"
  
  post "searchConcert"         => "welcome#searchConcert"
  post "searchKrithi"          => "welcome#searchKrithi"
  post "searchRagam"           => "welcome#searchRagam" 
  get  "searchComposer"        => "welcome#searchComposer"
  post "searchArtist"          => "welcome#searchArtist"
  post "clearData"             => "welcome#clearData"               
end
