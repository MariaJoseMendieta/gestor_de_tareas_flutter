import 'package:flutter/material.dart';

/// Constantes de estilos de texto usados en toda la aplicación.
const TextStyle kDescriptionStyle = TextStyle(color: Colors.grey);
const TextStyle kTextStyleButton = TextStyle(color: Colors.white);
const TextStyle kTextStyleAppBar = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
);
const TextStyle kTextStyleDetailScreen = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 20.0,
);
const TextStyle kCardTitleStyle = TextStyle(
  fontSize: 17.0,
  fontWeight: FontWeight.bold,
  color: Colors.black,
);

/// Constantes de cadenas de texto usadas para etiquetas y mensajes.
const String kDeleteConfirmationTitle = '¿Eliminar tarea?';
const String kDeleteConfirmationMessage = 'Esta acción no se puede deshacer.';
const String kCancelLabel = 'Cancelar';
const String kDeleteLabel = 'Eliminar';
// Prioridades
const String kPriorityAlta = 'Alta';
const String kPriorityMedia = 'Media';
const String kPriorityBaja = 'Baja';
// Estados
const String kStatusPendiente = 'Pendiente';
const String kStatusEnProgreso = 'En Progreso';
const String kStatusCompletada = 'Completada';
// Firebase collection
const String kTasksCollection = 'tasks';
// Límites de caracteres
const int kMaxLengthDes = 1000;
const int kMaxLengthTitle = 150;

/// Constantes relacionadas con colores usados en la aplicación.
const Color kMainColor = Color(0xFF0569B4);
const Color kBackgroundColorApp = Color(0xFFF5FAFA);
const Color kCardsColor = Colors.white;
const Color kDropdownColor = Colors.white;

/// Tema para íconos.
const IconThemeData kIconThemeColor = IconThemeData(color: Colors.white);

/// Constantes relacionadas con el diseño, espaciados y elevaciones.
const EdgeInsets kPaddingDropStatus = EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0);
const EdgeInsets kPaddingDropPriority = EdgeInsets.symmetric(horizontal: 8.0);
const EdgeInsets kPaddingCard = EdgeInsets.all(8.0);
const EdgeInsets kPaddingTitleDesc = EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 2.0);
const double kElevationCard = 5.0;
