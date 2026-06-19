abstract interface class GalleryRepository {
  Future<List<String>> getGalleryImagePaths(String characterId);
}
