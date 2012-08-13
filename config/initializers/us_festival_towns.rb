# festivals names can map to an array of metros where they are located

FESTIVAL_TOWNS = {
  # enter any valuable keyword that is the primary alias for a festival
  first_friday: {name: 'Abbot Kinney Street Festival', description: 'Held on the first Friday of each month', locations: [{state_kw: :ca, city_kw: :venice}]},
  santa_anita:  {name: 'Santa Anita Park', description: '', locations: [{state_kw: :ca, city_kw: :santa_anita}]},
}

FESTIVAL_ALIASES = {
  # enter any valuable keyword that is a secondary(or more) aliase for one of the above FESTIVAL_TOWNS
    abbot_kinney:  :first_friday,
}
