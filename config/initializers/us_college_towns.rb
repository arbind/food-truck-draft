# college names can point to metro they are in, or just be true if they are not in any metro

COLLEGE_TOWNS = {
  # enter any valuable keyword that is the primary alias for a university
  usc:  {name: 'University of Southern California', locations: [{state_kw: :ca, city_kw: :venice}]},
  ut:   {name: 'University of Texas',               locations: [{state_kw: :tx, city_kw: :austin}]},
}

COLLEGE_ALIASES = {
  # enter any valuable keyword that is a secondary(or more) aliase for one of the above COLLEGE_TOWNS
}