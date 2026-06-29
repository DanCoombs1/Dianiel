// lib/theme/owner_color.dart
import 'package:flutter/material.dart';
import '../models/enums.dart';
import 'app_colors.dart';

Color ownerColor(EventOwner o) => switch (o) {
      EventOwner.diana => AppColors.diana,
      EventOwner.dan => AppColors.dan,
      EventOwner.together => AppColors.together,
    };
