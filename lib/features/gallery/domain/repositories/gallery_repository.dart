abstract interface class GalleryRepository {
  Future<List<String>> getGalleryImagePaths(String characterId);

  Future<void> addGalleryImages({
    required String characterId,
    required List<String> imagePaths,
    void Function(int completed, int total)? onProgress,
  });
}
