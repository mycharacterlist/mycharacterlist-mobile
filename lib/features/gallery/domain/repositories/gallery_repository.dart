abstract interface class GalleryRepository {
  Future<List<String>> getGalleryImagePaths(String characterId);

  Future<void> addGalleryImages({
    required String characterId,
    required List<String> imagePaths,
    void Function(int completed, int total)? onProgress,
  });

  Future<void> removeGalleryImage({
    required String characterId,
    required int imageIndex,
  });

  Future<void> reorderGalleryImages({
    required String characterId,
    required int fromIndex,
    required int toIndex,
  });

  Future<void> updateGalleryImagePaths({
    required String characterId,
    required List<String> imagePaths,
  });
}
