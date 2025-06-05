import 'package:flutter/material.dart';

const kDescriptionStyle = TextStyle(color: Colors.grey);
const kTextStyleButton = TextStyle(color: Colors.white);
const kTextStyleAppBar = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
);
const kTextStyleDetailScreen = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 20.0,
);
const kCardTitleStyle = TextStyle(
  fontSize: 17.0,
  fontWeight: FontWeight.bold,
  color: Colors.black,
);
const String kDeleteConfirmationTitle = '¿Eliminar tarea?';
const String kDeleteConfirmationMessage = 'Esta acción no se puede deshacer.';
const String kCancelLabel = 'Cancelar';
const String kDeleteLabel = 'Eliminar';
const String kPriorityAlta = 'Alta';
const String kPriorityMedia = 'Media';
const String kPriorityBaja = 'Baja';
const String kStatusPendiente = 'Pendiente';
const String kStatusEnProgreso = 'En Progreso';
const String kStatusCompletada = 'Completada';

const kMainColor = Color(0xFF0569B4);
const kBackgroundColorApp = Color(0xFFF5FAFA);
const kCardsColor = Colors.white;
const kDropdownColor = Colors.white;
const kIconThemeColor = IconThemeData(color: Colors.white);

const kPaddingDropTitleDesc = EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 2.0);
const kPaddingDropStatus = EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0);
const kPaddingDropPriority = EdgeInsets.symmetric(horizontal: 8.0);
const kPaddingCard = EdgeInsets.all(8.0);

const kElevationCard = 5.0;

const String kTasksCollection = 'tasks';

const kMaxLengthDes = 1000;
const kMaxLengthTitle = 150;
