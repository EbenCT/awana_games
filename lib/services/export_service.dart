// lib/services/export_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import '../models/team.dart';
import '../models/game.dart';

class ExportService {
  // Existing methods for PDF and CSV export
  
  // Export results to PDF
  static Future<void> exportToPdf({
    required List<Team> teams,
    required List<Game> games,
    required BuildContext context,
  }) async {
    // Crear un documento PDF
    final pdf = pw.Document();
    
    // Ordenar equipos por puntuación
    final sortedTeams = List<Team>.from(teams)
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));
    
    // Calcular posiciones
    final positions = _calculatePositions(sortedTeams);
    
    // Añadir página de título
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Resultados Awana Games',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Fecha: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: const pw.TextStyle(
                    fontSize: 16,
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  'Clasificación Final',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                // Tabla de equipos ordenados por posición
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    // Encabezado
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey300,
                      ),
                      children: [
                        _buildTableCell('Pos.', isHeader: true),
                        _buildTableCell('Equipo', isHeader: true),
                        _buildTableCell('Puntuación', isHeader: true),
                      ],
                    ),
                    // Filas de equipos
                    ...sortedTeams.map((team) => pw.TableRow(
                          children: [
                            _buildTableCell('${positions[team.id]}°'),
                            _buildTableCell(team.name),
                            _buildTableCell('${team.totalScore}'),
                          ],
                        )),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
    
    // Añadir página con detalles por juego
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Resultados por Juego',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              // Tabla con resultados por juego
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // Encabezado
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      _buildTableCell('Equipo', isHeader: true),
                      ...List.generate(games.length, (index) =>
                          _buildTableCell(games[index].name, isHeader: true)
                      ),
                      _buildTableCell('Total', isHeader: true),
                    ],
                  ),
                  // Filas de equipos
                  ...teams.map((team) => pw.TableRow(
                        children: [
                          _buildTableCell(team.name),
                          ...List.generate(games.length, (index) =>
                              _buildTableCell(
                                team.gameScores.length > index
                                    ? (team.gameScores[index]?.toString() ?? '-')
                                    : '-'
                              )
                          ),
                          _buildTableCell('${team.totalScore}'),
                        ],
                      )),
                ],
              ),
            ],
          );
        },
      ),
    );
    
    try {
      // Guardar el PDF en almacenamiento temporal
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/resultados_awana_games.pdf');
      await file.writeAsBytes(await pdf.save());
      
      // Compartir el archivo
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Resultados Awana Games',
        text: 'Compartiendo resultados de Awana Games',
      );
    } catch (e) {
      // Mostrar error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Exportar a CSV
  static Future<void> exportToCsv({
    required List<Team> teams,
    required List<Game> games,
    required BuildContext context,
  }) async {
    try {
      // Ordenar equipos por puntuación
      final sortedTeams = List<Team>.from(teams)
        ..sort((a, b) => b.totalScore.compareTo(a.totalScore));
      
      // Crear contenido CSV
      String csvContent = 'Equipo,';
      
      // Encabezados
      for (int i = 0; i < games.length; i++) {
        csvContent += '${games[i].name},';
      }
      csvContent += 'Total\n';
      
      // Datos de equipos
      for (var team in sortedTeams) {
        csvContent += '${team.name},';
        for (int i = 0; i < games.length; i++) {
          if (team.gameScores.length > i && team.gameScores[i] != null) {
            csvContent += '${team.gameScores[i]},';
          } else {
            csvContent += '0,';
          }
        }
        csvContent += '${team.totalScore}\n';
      }
      
      // Guardar el CSV en almacenamiento temporal
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/resultados_awana_games.csv');
      await file.writeAsString(csvContent);
      
      // Compartir el archivo
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Resultados Awana Games (CSV)',
        text: 'Compartiendo resultados de Awana Games en formato CSV',
      );
    } catch (e) {
      // Mostrar error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // New method for exporting as an image
  static Future<void> exportToImage({
    required GlobalKey tableKey,
    required BuildContext context,
  }) async {
    try {
      final screenshotController = ScreenshotController();
      
      // Capture the table widget as an image
      final Uint8List? capturedImage = await screenshotController.captureFromWidget(
        // Find the widget by key and capture it
        Builder(
          builder: (BuildContext context) {
            final RenderRepaintBoundary boundary = tableKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
            return boundary.child as Widget;
          },
        ),
        delay: const Duration(milliseconds: 10),
        pixelRatio: 2.0, // Higher quality
      );
      
      if (capturedImage != null) {
        // Save image to temporary storage
        final output = await getTemporaryDirectory();
        final file = File('${output.path}/resultados_awana_games.png');
        await file.writeAsBytes(capturedImage);
        
        // Share the image
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Resultados Awana Games (Imagen)',
          text: 'Compartiendo tabla de resultados de Awana Games',
        );
      } else {
        throw Exception('No se pudo capturar la imagen');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Alternative method using RepaintBoundary approach
  static Future<void> exportToImageUsingBoundary({
    required GlobalKey tableKey,
    required BuildContext context,
  }) async {
    try {
      // Get the render object of the widget with the key
      final RenderRepaintBoundary boundary = tableKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      // Convert to image
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        // Convert to Uint8List
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        
        // Save image to temporary storage
        final output = await getTemporaryDirectory();
        final file = File('${output.path}/resultados_awana_games.png');
        await file.writeAsBytes(pngBytes);
        
        // Share the image
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Resultados Awana Games (Imagen)',
          text: 'Compartiendo tabla de resultados de Awana Games',
        );
      } else {
        throw Exception('No se pudo convertir a bytes');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Método para calcular posiciones
  static Map<int, int> _calculatePositions(List<Team> sortedTeams) {
    Map<int, int> positions = {};
    int currentPosition = 1;
    int teamsWithSameScore = 1;
    
    for (int i = 0; i < sortedTeams.length; i++) {
      if (i > 0 && sortedTeams[i].totalScore == sortedTeams[i - 1].totalScore) {
        positions[sortedTeams[i].id] = positions[sortedTeams[i - 1].id]!;
        teamsWithSameScore++;
      } else {
        positions[sortedTeams[i].id] = currentPosition;
        currentPosition = i + teamsWithSameScore + 1;
        teamsWithSameScore = 1;
      }
    }
    return positions;
  }
  
  // Método para construir celdas de tabla
  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : null,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}