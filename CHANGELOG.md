
## 0.0.8

- svgData = null; in loadMap() to catch any errors
- Add function, onLoad, to a FutureBuilder called after SVG has loaded
- Add function, onError, if onLoad() errors. Option is to continue or not.
- Hide the State class as Library private

## 0.0.7

- Add more examples

## 0.0.6

- Add function to know which region contains a specific long/lat

## 0.0.5

- Add loaders to load SVG from files or assets
- Add `GeoMarker`. A marker that uses longitude and latitude coordinates
- More marker theming
- Can fill the background of the map with a color
- Draw a custom pin for the `GeoMarker`

## 0.0.4

- Fix: parse "Z" command form SVG path

## 0.0.3

- Fix: getEnumFromCountryCode() can return now

## 0.0.2

- Utility to get the MapEntity when a country code is provided

## 0.0.1

* First release
