class UploadAvatarRequest {
  const UploadAvatarRequest({required this.fileBytes, required this.fileName});

  static const maxFileSizeBytes = 5 * 1024 * 1024;
  static const allowedExtensions = <String>['jpg', 'jpeg', 'png', 'webp'];

  final List<int> fileBytes;
  final String fileName;

  String get normalizedFileName {
    validate();
    return fileName.trim();
  }

  String get contentType {
    validate();
    return switch (_extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => throw StateError('Unsupported avatar file type.'),
    };
  }

  void validate() {
    final name = fileName.trim();
    if (name.isEmpty || fileBytes.isEmpty) {
      throw ArgumentError('An avatar image is required.');
    }
    if (!allowedExtensions.contains(_extension)) {
      throw ArgumentError('Avatar must be a JPEG, PNG or WebP image.');
    }
    if (fileBytes.length > maxFileSizeBytes) {
      throw ArgumentError('Avatar cannot exceed 5 MB.');
    }
  }

  String get _extension {
    final name = fileName.trim();
    final separator = name.lastIndexOf('.');
    if (separator < 0 || separator == name.length - 1) return '';
    return name.substring(separator + 1).toLowerCase();
  }
}
