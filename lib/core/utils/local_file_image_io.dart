import "dart:io";

import "package:flutter/material.dart";

ImageProvider? localFileImage(String? path) {
  if (path == null || path.isEmpty) return null;
  return FileImage(File(path));
}
