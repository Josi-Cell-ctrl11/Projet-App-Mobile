import "package:flutter/material.dart";

/// Tuile service sur le dashboard (7 services).
class ServiceTileModel {
  const ServiceTileModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.routePath,
    this.enabled = true,
  });

  final String id;
  final String title;
  final IconData icon;
  final String routePath;
  final bool enabled;
}
