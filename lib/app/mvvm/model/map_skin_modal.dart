class MapSkin {
  final String name;
  final String urlTemplate;
  final List<String> subdomains;
  final String attribution;

  const MapSkin({
    required this.name,
    required this.urlTemplate,
    this.subdomains = const ['a', 'b', 'c', 'd'],
    required this.attribution,
  });
}
