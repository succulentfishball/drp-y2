enum Method { 
  camera, gallery;

  @override
  String toString() {
    switch (this) {
      case camera:
        return "camera"; 
      case gallery:
        return "gallery";
    }
  }
}