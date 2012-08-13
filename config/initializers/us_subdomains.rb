# be sure these domains are
# 1. recorded in the zone
# 2. added to the heroku app  ( heroku domains:add domain.com )

# Any _ should be converted to _ in a subdomain name

SUBDOMAINS = {
  # +++ specialty features
  menu:           {  },  # future functionality 
  schedule:       {  },  # future functionality 
  map:            {  },  # future functionality 

  # synonyms for index
  gourmet:        {  },
  location:       {  },
  list:           {  },
  twitter:        {  },
  street:         {  },
  finder:         {  },
  locator:        {  },

  # college 
  # usc:            { college: true, metro: :los_angeles  },  #! not yet added as subdomain
  # ut:             { college: true, city: :austin  },        #! not yet added as subdomain

  # highly rated
  great:          { highly_rated: true },
  best:           { highly_rated: true },
  top:            { highly_rated: true },

  # festivals
  # festival:       { fest:true },
  # fiesta:         { fest:true },
  # fest:           { fest:true },
  # fair:           { fest:true },
  # santa_anita:    { fest:true, metro: :los_angeles },
  # first_friday:   { fest:true, city: :venice },

  # cuisine
  # hot_dog:        { cuisine: true },
  # taco:           { cuisine: true },
  # pizza:          { cuisine: true },
  # bacon:          { cuisine: true },
  # coffee:         { cuisine: true },
  # mexican:        { cuisine: true },
  # bbq:            { cuisine: true },
  # vegan:          { cuisine: true },
  # grilled_cheese: { cuisine: true },
  # indian:         { cuisine: true },
  # thai:           { cuisine: true },
  # filipino:       { cuisine: true },
  # korean:         { cuisine: true },
  # ice_cream:      { cuisine: true },
  # crepe:          { cuisine: true },
  # chinese:        { cuisine: true },
  # sushi:          { cuisine: true },
  # vietnamese:     { cuisine: true },
  # cuban:          { cuisine: true },
  # italian:        { cuisine: true },
  # bakery:         { cuisine: true },
  # taiwanese:      { cuisine: true },

  # meal
  # lunch:          { meal: true },
  # breakfast:      { meal: true },
  # dinner:         { meal: true },

  
  # location: metro
  la:             { metro: true },
  dc:             { metro: true },
  ny:             { metro: true },
  nyc:            { metro: true },
  miami:          { metro: true },
  boston:         { metro: true },
  portland:       { metro: true },
  sf:             { metro: true },
  san_francisco:  { metro: true },
  san_diego:      { metro: true },
  dallas:         { metro: true },
  orange_county:  { metro: true },
  oc:             { metro: true },
  houston:        { metro: true },
  seattle:        { metro: true },
  austin:         { metro: true },
  orlando:        { metro: true },
  st_louis:       { metro: true },
  nashville:      { metro: true },
  minneapolis:    { metro: true },
  phoenix:        { metro: true },
  denver:         { metro: true },
  tampa:          { metro: true },
  las_vegas:      { metro: true },
  sacramento:     { metro: true },
  baltimore:      { metro: true },
  clover:         { metro: true },
  cleveland:      { metro: true },
  san_antonio:    { metro: true },
  columbus:       { metro: true },
  kansas_city:    { metro: true },
  long_beach:     { metro: true },
  baton_rouge:    { metro: true },
  cincinnati:     { metro: true },
  hawaii:         { metro: true },
  milwaukee:      { metro: true },
  detroit:        { metro: true },
  charlotte:      { metro: true },
  pittsburgh:     { metro: true },

  santa_monica:   { city: true },
  burbank:        { city: true },
  pasadena:       { city: true },
  venice:         { city: true }, #! not yet added as subdomain
  # abbot_kinney:   { street: true, city: :venice }
}