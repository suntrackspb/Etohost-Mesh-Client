/// Минимальный локальный стиль для схемы Protomaps v4.
/// Нет URL шрифтов, спрайтов или тайлов: оформление работает без сети.
Map<String, dynamic> offlineMapStyle(bool dark) {
  Map<String, dynamic> layer(
    String id,
    String type,
    String sourceLayer,
    Map<String, dynamic> paint, {
    Map<String, dynamic>? layout,
  }) => {
    'id': id,
    'type': type,
    'source': 'basemap',
    'source-layer': sourceLayer,
    'paint': paint,
    'layout': ?layout,
  };
  final text = dark ? '#c3cdd6' : '#343c40';
  final background = dark ? '#20262d' : '#f3f0e8';
  return {
    'version': 8,
    'name': dark ? 'etohost-offline-dark-v2' : 'etohost-offline-light-v1',
    'sources': {
      'basemap': {'type': 'vector'},
    },
    'layers': [
      {
        'id': 'background',
        'type': 'background',
        'paint': {'background-color': background},
      },
      layer('landuse', 'fill', 'landuse', {
        'fill-color': dark
            ? [
                'match',
                ['get', 'kind'],
                [
                  'park',
                  'forest',
                  'wood',
                  'garden',
                  'grass',
                  'meadow',
                  'nature_reserve',
                  'national_park',
                  'recreation_ground',
                ],
                '#263c35',
                ['industrial', 'commercial', 'railway'],
                '#252b33',
                '#222a31',
              ]
            : '#dde7ce',
      }),
      layer('water', 'fill', 'water', {
        'fill-color': dark ? '#12384d' : '#b4d8e8',
      }),
      layer('buildings', 'fill', 'buildings', {
        'fill-color': dark ? '#323c47' : '#d7cfc2',
      }),
      layer('boundaries', 'line', 'boundaries', {
        'line-color': dark ? '#46505e' : '#aaa1ad',
        'line-width': 1,
      }),
      layer(
        'roads',
        'line',
        'roads',
        {
          'line-color': dark
              ? [
                  'match',
                  ['get', 'kind'],
                  'highway',
                  '#8795a4',
                  'major_road',
                  '#6c7c8d',
                  'minor_road',
                  '#4c5c6d',
                  'rail',
                  '#424c59',
                  'path',
                  '#384b51',
                  '#41515e',
                ]
              : '#ffffff',
          'line-width': dark
              ? [
                  '*',
                  [
                    'interpolate',
                    ['linear'],
                    ['zoom'],
                    5,
                    0.4,
                    12,
                    1.2,
                    17,
                    4,
                  ],
                  [
                    'match',
                    ['get', 'kind'],
                    'highway',
                    1.4,
                    'major_road',
                    1.15,
                    'minor_road',
                    0.8,
                    'path',
                    0.3,
                    'rail',
                    0.35,
                    0.55,
                  ],
                ]
              : [
                  'interpolate',
                  ['linear'],
                  ['zoom'],
                  5,
                  0.5,
                  12,
                  1.5,
                  17,
                  5,
                ],
        },
        layout: {'line-cap': 'round', 'line-join': 'round'},
      ),
      layer(
        'road-labels',
        'symbol',
        'roads',
        {
          'text-color': text,
          'text-halo-color': background,
          'text-halo-width': 1,
        },
        layout: {
          'symbol-placement': 'line',
          'text-size': 11,
          'text-field': [
            'coalesce',
            ['get', 'name:ru'],
            ['get', 'name'],
            '',
          ],
        },
      ),
      layer(
        'places',
        'symbol',
        'places',
        {
          'text-color': text,
          'text-halo-color': background,
          'text-halo-width': 1.5,
        },
        layout: {
          'text-size': 13,
          'text-field': [
            'coalesce',
            ['get', 'name:ru'],
            ['get', 'name'],
            '',
          ],
        },
      ),
    ],
  };
}
