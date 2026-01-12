import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

void showProfileImage(BuildContext context, String imageUrl) {
  if (imageUrl.isEmpty) return; // ✅ SAFETY

  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.9),
    builder: (_) {
      return GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Center(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              placeholder: (_, __) =>
                  const CircularProgressIndicator(color: Colors.white),
              errorWidget: (_, __, ___) => const Icon(
                Icons.person,
                color: Colors.white,
                size: 120,
              ),
            ),
          ),
        ),
      );
    },
  );
}
