## Yelp

This is a Yelp search app using the [Yelp API](http://developer.rottentomatoes.com/docs/read/JSON).

Time spent: `<Number of hours spent>`

### Setup
You must create a config.plist file with the keys `yelpConsumerKey`, `yelpConsumerSecret`, `yelpToken`, and `yelpTokenSecret` and the proper values to access the Yelp API.

### Features

#### Required

- [x] Search results page
   - [x] Table rows have dynamic height according to the content height
   - [x] Custom cells have the proper Auto Layout constraints
   - [x] Search bar in the navigation bar
- [x] Filter page
   - [x] Filters: category, sort (best match, distance, highest rated), radius (meters), deals (on/off)
   - [x] The filters table is organized into sections as in the mock
   - [x] Use the default UISwitch for on/off states
   - [x] Clicking on the "Search" button dismisses the filters page and triggers the search with the new filter settings.
   - [x] Displays some of the available Yelp categories

#### Optional

- [ ] Search results page
   - [ ] Infinite scroll for restaurant results
   - [x] Implement map view of restaurant results
- [x] Filter page
   - [ ] Use a custom switch
   - [x] Sort by and distance filters expand and collapse as in the real Yelp app
   - [x] Categories shows a subset of the full list with a "Show All" row to expand
- [ ] Implement the restaurant detail page.

### Walkthrough

![Video Walkthrough](...)
