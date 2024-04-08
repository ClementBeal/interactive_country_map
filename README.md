# Interactive country map

The purpose of this package is to draw an interactive map of a country or region where you can select a region.

It can be used to plot data.


## Demo

| Interaction | Chart  |
|--|--------------|
| ![](doc/france_department.webm) | ![](doc/a.gif) |

## How does it work?

The SVG maps are defined by several `<path>` tags. Because it's XML, we can define an `id` for each of them. The IDs are unique and defined by the [ISO_3166-2](https://en.wikipedia.org/wiki/ISO_3166-2).  
When a country is selected, its `id` is returned.

## Docs

### Interactive map

Use the `InteractiveMap` in your code to add an interactive map. Then, choose among the `MapEntity` enum the map you need.  
You can customize the theme of your map using `InteractiveMapTheme`.

The `onCountryChanged` will receive the code of the selected country/region. All the codes are defined by the [ISO_3166-2](https://en.wikipedia.org/wiki/ISO_3166-2).

The library is only returning country codes. It's your role to understand them and adapt your own widgets.

### Color mapping

You might want to use different colors for your regions. For instance, all the countries starting with `A` will be in blue and the ones starting with `B` will be in red.

Add in your interactive map theme the following code:

```dart
mappingCode: {
    ...MappingHelper.sameColor(
    Colors.green.shade300,
    [
        "FR-A",
        "FR-B",
        "FR-C",
        "FR-D",
        "FR-E",
    ],
    )
},
```

The `mappingCode` accepts a `Map<String, Color>` when the string is the region code.  
`MappingHelper.sameColor` is a helper to build your dictionary. It will map a list to the specified color.

### Markers

You have the choice between 2 types of markers:

- `Marker`: use the Cartesian coordinates to place the marker
- `GeoMarker` (TODO): use the lat/long to place the marker at the correct position on the map

Then, you use a `MarkerGroup` to gather the markers and give them properties:

```dart
MarkerGroup(
    borderColor: Colors.pink.shade600,
    backgroundColor: Colors.pink.shade300,
    markers: [
        Marker(x: 30, y: 40),
        GeoMarker(long: 2.294481, lat: 48.858370),
        Marker(x: 250, y: 340),
    ],
),
```

## Additional information

Download maps on this website: [Maps](https://mapsvg.com/maps)

Some maps are missing and I haven't found them yet. Feel free to open an issue if you have the SVG for a country or special subregion.