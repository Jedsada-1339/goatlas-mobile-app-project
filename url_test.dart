void main() {
  final url = Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'destination': '16.1,102.1',
    'waypoints': '16.2,102.2|16.3,102.3',
  });
  print(url.toString());
}
