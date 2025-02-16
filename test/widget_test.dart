// Este archivo se ubica en test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Asegúrate de que la ruta de importación sea correcta según la ubicación de tu main.dart
import 'package:practica_4/main.dart';

void main() {
  testWidgets('Test de navegación y CRUD de notas', (WidgetTester tester) async {
    // Construye la app y espera a que termine la carga (incluyendo operaciones asíncronas)
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // Verifica que la pantalla inicial sea la lista de notas
    expect(find.text("Lista de Notas"), findsOneWidget);
    expect(find.text("No hay notas. Agrega una nueva nota."), findsOneWidget);

    // Pulsa el botón flotante para agregar una nueva nota
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verifica que se muestre la página de crear nota
    expect(find.text("Crear Nota"), findsOneWidget);

    // Pulsa el botón para guardar la nota
    await tester.tap(find.widgetWithText(ElevatedButton, 'Guardar Nota'));
    await tester.pumpAndSettle();

    // Verifica que se regrese a la lista de notas y que aparezca la nota creada
    expect(find.text("Lista de Notas"), findsOneWidget);
    expect(find.text("Test Note"), findsOneWidget);
    expect(find.text("This is a test note."), findsOneWidget);

    // Navega al menú de Perfiles usando el BottomNavigationBar:
    // Se localiza el item de texto "Perfiles" (el tercer elemento)
    await tester.tap(find.text("Perfiles"));
    await tester.pumpAndSettle();

    // Verifica que se muestre la pantalla de perfiles
    expect(find.text("Perfiles de Usuario"), findsOneWidget);
    expect(find.text("Keury Ramirez"), findsOneWidget);

    // Regresa a la pantalla de Notas a través del menú (toca "Notas")
    await tester.tap(find.text("Notas"));
    await tester.pumpAndSettle();
    expect(find.text("Lista de Notas"), findsOneWidget);
  });
}
