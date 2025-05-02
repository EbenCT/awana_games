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
import '../models/team.dart';
import '../models/game.dart';

class ExportService {
  // Método principal para exportar a PDF con diseño mejorado
  static Future<void> exportToPdf({
    required List<Team> teams,
    required List<Game> games,
    required BuildContext context,
  }) async {
    // Crear un documento PDF
    final pdf = pw.Document();
    
    // Definir colores para los equipos
    final teamColors = {
      'Rojo': PdfColors.red,
      'Amarillo': PdfColors.amber,
      'Verde': PdfColors.green,
      'Azul': PdfColors.blue,
    };
    
    // Ordenar equipos por puntuación
    final sortedTeams = List<Team>.from(teams)
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));
    
    // Calcular posiciones
    final positions = _calculatePositions(sortedTeams);
    
    // Fecha actual para el pie de página
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    
    // Añadir página de título con diseño mejorado
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Fondo con cuadrados de colores en las esquinas
              pw.Positioned(
                top: 0,
                left: 0,
                child: pw.Container(
                  width: 200,
                  height: 200,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue100,
                    borderRadius: pw.BorderRadius.only(
                      bottomRight: pw.Radius.circular(100),
                    ),
                  ),
                ),
              ),
              pw.Positioned(
                top: 0,
                right: 0,
                child: pw.Container(
                  width: 200,
                  height: 200,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green100,
                    borderRadius: pw.BorderRadius.only(
                      bottomLeft: pw.Radius.circular(100),
                    ),
                  ),
                ),
              ),
              pw.Positioned(
                bottom: 0,
                left: 0,
                child: pw.Container(
                  width: 200,
                  height: 200,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.red100,
                    borderRadius: pw.BorderRadius.only(
                      topRight: pw.Radius.circular(100),
                    ),
                  ),
                ),
              ),
              pw.Positioned(
                bottom: 0,
                right: 0,
                child: pw.Container(
                  width: 200,
                  height: 200,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.yellow100,
                    borderRadius: pw.BorderRadius.only(
                      topLeft: pw.Radius.circular(100),
                    ),
                  ),
                ),
              ),
              
              // Contenido principal
              pw.Center(
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    // Título principal con estilo mejorado
                    pw.Container(
                      padding: pw.EdgeInsets.all(15),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.purple700,
                        borderRadius: pw.BorderRadius.circular(10),
                      ),
                      child: pw.Text(
                        'AWANA GAMES',
                        style: pw.TextStyle(
                          fontSize: 40,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 30),
                    pw.Text(
                      'RESULTADOS FINALES',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.purple700,
                      ),
                    ),
                    pw.SizedBox(height: 15),
                    pw.Text(
                      'Fecha: $dateStr',
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 50),
                    
                    // Podio de equipos ganadores
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        // 2do lugar
                        if (sortedTeams.length > 1)
                          _buildPodiumPosition(
                            sortedTeams[1],
                            2,
                            height: 120,
                            teamColor: _getPdfColor(sortedTeams[1].name, teamColors)
                          ),
                        pw.SizedBox(width: 10),
                        
                        // 1er lugar
                        _buildPodiumPosition(
                          sortedTeams[0],
                          1,
                          height: 150,
                          teamColor: _getPdfColor(sortedTeams[0].name, teamColors)
                        ),
                        pw.SizedBox(width: 10),
                        
                        // 3er lugar
                        if (sortedTeams.length > 2)
                          _buildPodiumPosition(
                            sortedTeams[2],
                            3,
                            height: 90,
                            teamColor: _getPdfColor(sortedTeams[2].name, teamColors)
                          ),
                      ],
                    ),
                    pw.SizedBox(height: 50),
                    
                    // Tabla de puntuaciones finales de equipos
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(10),
                        color: PdfColors.white,
                      ),
                      padding: pw.EdgeInsets.all(15),
                      child: pw.Table(
                        border: pw.TableBorder.all(
                          color: PdfColors.grey300,
                          width: 0.5,
                        ),
                        children: [
                          // Encabezado
                          pw.TableRow(
                            decoration: pw.BoxDecoration(
                              color: PdfColors.purple100,
                            ),
                            children: [
                              _buildTableHeader('Pos.'),
                              _buildTableHeader('Equipo'),
                              _buildTableHeader('Puntuación Total'),
                            ],
                          ),
                          // Filas de equipos
                          ...sortedTeams.map((team) {
                            // Determinar color de fondo según posición
                            PdfColor? bgColor;
                            if (positions[team.id] == 1) {
                              bgColor = PdfColors.amber100;
                            } else if (positions[team.id] == 2) {
                              bgColor = PdfColors.grey200;
                            } else if (positions[team.id] == 3) {
                              bgColor = PdfColors.orange100;
                            } else {
                              bgColor = PdfColors.white;
                            }
                            
                            return pw.TableRow(
                              decoration: pw.BoxDecoration(
                                color: bgColor,
                              ),
                              children: [
                                _buildTableCell('${positions[team.id]}°', 
                                  fontWeight: positions[team.id]! <= 3 ? pw.FontWeight.bold : null),
                                _buildTableCell(team.name, 
                                  textColor: _getPdfColor(team.name, teamColors)),
                                _buildTableCell('${team.totalScore}', 
                                  textAlign: pw.TextAlign.center,
                                  fontWeight: positions[team.id]! <= 3 ? pw.FontWeight.bold : null),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Pie de página
              pw.Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Awana Games - Resultados Oficiales',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
    
    // Añadir página con resultados detallados por juego
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Fondo sutil con líneas diagonales
              pw.Container(
                width: double.infinity,
                height: double.infinity,
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                ),
              ),
              pw.Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: pw.Container(
                  height: 15,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.purple700,
                  ),
                ),
              ),
              
              // Contenido principal
              pw.Padding(
                padding: pw.EdgeInsets.only(top: 30),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Título de la página
                    pw.Container(
                      padding: pw.EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.purple200,
                        borderRadius: pw.BorderRadius.only(
                          topRight: pw.Radius.circular(20),
                          bottomRight: pw.Radius.circular(20),
                        ),
                      ),
                      child: pw.Text(
                        'Resultados por Juego',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.purple900,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 30),
                    
                    // Tabla con resultados por juego
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(horizontal: 15),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Table(
                            border: pw.TableBorder.all(
                              color: PdfColors.grey300,
                              width: 0.5,
                            ),
                            children: [
                              // Encabezado
                              pw.TableRow(
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.purple100,
                                ),
                                children: [
                                  _buildTableHeader('Equipo'),
                                  ...List.generate(games.length, (index) =>
                                    _buildTableHeader(games[index].name)
                                  ),
                                  _buildTableHeader('Total'),
                                ],
                              ),
                              // Filas de equipos
                              ...teams.map((team) {
                                // Color de fondo según posición
                                PdfColor? rowColor;
                                if (positions[team.id] == 1) {
                                  rowColor = PdfColors.amber100;
                                } else {
                                  rowColor = PdfColors.white;
                                }
                                
                                return pw.TableRow(
                                  decoration: pw.BoxDecoration(
                                    color: rowColor,
                                  ),
                                  children: [
                                    _buildTableCell(team.name, 
                                      textColor: _getPdfColor(team.name, teamColors),
                                      fontWeight: pw.FontWeight.bold),
                                    ...List.generate(games.length, (index) {
                                      final gameScore = team.gameScores.length > index
                                          ? team.gameScores[index]
                                          : null;
                                      
                                      // Verificar si el juego es de tipo "rounds"
                                      final isRoundGame = games[index].type == GameType.rounds;
                                      String scoreText = gameScore != null ? '$gameScore' : '-';
                                      
                                      // Para juegos de tipo "rounds", mostrar los puntos de ronda
                                      if (isRoundGame && index < team.gameScores.length) {
                                        final roundPoints = team.roundPoints;
                                        if (roundPoints > 0) {
                                          scoreText = '$gameScore\n($roundPoints pts)';
                                        }
                                      }
                                      
                                      // Determinar color de fondo según puntaje
                                      PdfColor? cellBgColor;
                                      if (gameScore != null && gameScore >= 75) {
                                        cellBgColor = PdfColors.green50;
                                      } else if (gameScore != null && gameScore >= 50) {
                                        cellBgColor = PdfColors.blue50;
                                      } else if (gameScore != null && gameScore >= 25) {
                                        cellBgColor = PdfColors.orange50;
                                      } else {
                                        cellBgColor = null;
                                      }
                                      
                                      return _buildTableCell(
                                        scoreText,
                                        textAlign: pw.TextAlign.center,
                                        backgroundColor: cellBgColor,
                                      );
                                    }),
                                    _buildTableCell(
                                      '${team.totalScore}',
                                      textAlign: pw.TextAlign.center,
                                      fontWeight: pw.FontWeight.bold,
                                      backgroundColor: PdfColors.grey100,
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                          
                          pw.SizedBox(height: 30),
                          
                          // Leyenda de puntuaciones
                          pw.Container(
                            padding: pw.EdgeInsets.all(10),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.grey100,
                              borderRadius: pw.BorderRadius.circular(8),
                              border: pw.Border.all(
                                color: PdfColors.grey300,
                                width: 0.5,
                              ),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Leyenda de Puntuaciones:',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                                pw.SizedBox(height: 5),
                                pw.Row(
                                  children: [
                                    _buildLegendItem('1er Lugar: 100 pts', PdfColors.green50),
                                    pw.SizedBox(width: 15),
                                    _buildLegendItem('2do Lugar: 75 pts', PdfColors.blue50),
                                    pw.SizedBox(width: 15),
                                    _buildLegendItem('3er Lugar: 50 pts', PdfColors.orange50),
                                    pw.SizedBox(width: 15),
                                    _buildLegendItem('4to Lugar: 25 pts', PdfColors.white),
                                  ],
                                ),
                                if (_anyRoundGames(games)) ...[
                                  pw.SizedBox(height: 8),
                                  pw.Text(
                                    'Nota: Para juegos por rondas, se muestra el puntaje final y los puntos acumulados en las rondas entre paréntesis.',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      fontStyle: pw.FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Pie de página
              pw.Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Página 2 - Resultados detallados por juego - $dateStr',
                      style: pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
    
    // Si hay juegos de tipo ronda, agregar una página específica para estos juegos
    if (_anyRoundGames(games)) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                // Fondo sutilmente decorado
                pw.Positioned(
                  bottom: 0,
                  right: 0,
                  child: pw.Container(
                    width: 150,
                    height: 150,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.purple50,
                      borderRadius: pw.BorderRadius.only(
                        topLeft: pw.Radius.circular(75),
                      ),
                    ),
                  ),
                ),
                
                // Contenido principal
                pw.Padding(
                  padding: pw.EdgeInsets.only(top: 30, left: 15, right: 15),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Título de la página
                      pw.Container(
                        padding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.purple200,
                          borderRadius: pw.BorderRadius.circular(10),
                        ),
                        child: pw.Text(
                          'Detalle de Juegos por Rondas',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.purple900,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 20),
                      
                      pw.Text(
                        'Los siguientes juegos se realizaron utilizando el sistema de puntos por rondas:',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.SizedBox(height: 20),
                      
                      // Información de los juegos por rondas
                      ...games.asMap().entries
                        .where((entry) => entry.value.type == GameType.rounds)
                        .map((entry) {
                          final gameIndex = entry.key;
                          final game = entry.value;
                          
                          return pw.Container(
                            margin: pw.EdgeInsets.only(bottom: 20),
                            padding: pw.EdgeInsets.all(15),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.white,
                              borderRadius: pw.BorderRadius.circular(8),
                              border: pw.Border.all(
                                color: PdfColors.grey300,
                                width: 0.5,
                              ),
                            ),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                // Título del juego
                                pw.Text(
                                  game.name,
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.purple700,
                                  ),
                                ),
                                pw.Divider(color: PdfColors.grey300),
                                pw.SizedBox(height: 10),
                                
                                // Tabla de resultados por equipo
                                pw.Table(
                                  border: pw.TableBorder.all(
                                    color: PdfColors.grey300,
                                    width: 0.5,
                                  ),
                                  children: [
                                    // Encabezado
                                    pw.TableRow(
                                      decoration: pw.BoxDecoration(
                                        color: PdfColors.purple100,
                                      ),
                                      children: [
                                        _buildTableHeader('Equipo'),
                                        _buildTableHeader('Puntos de Ronda'),
                                        _buildTableHeader('Posición'),
                                        _buildTableHeader('Puntuación Final'),
                                      ],
                                    ),
                                    // Información de los equipos para este juego
                                    ...teams.map((team) {
                                      final gameScore = team.gameScores.length > gameIndex
                                          ? team.gameScores[gameIndex]
                                          : null;
                                      
                                      // Determinar posición en este juego
                                      final List<Team> sortedForGame = List.from(teams)
                                        ..sort((a, b) {
                                          final aScore = a.gameScores.length > gameIndex ? a.gameScores[gameIndex] ?? 0 : 0;
                                          final bScore = b.gameScores.length > gameIndex ? b.gameScores[gameIndex] ?? 0 : 0;
                                          return bScore.compareTo(aScore);
                                        });
                                      
                                      final gamePosition = sortedForGame.indexOf(team) + 1;
                                      
                                      // Determinar color de fondo según posición
                                      PdfColor? posBgColor;
                                      if (gamePosition == 1) {
                                        posBgColor = PdfColors.amber100;
                                      } else if (gamePosition == 2) {
                                        posBgColor = PdfColors.grey200;
                                      } else if (gamePosition == 3) {
                                        posBgColor = PdfColors.orange100;
                                      } else {
                                        posBgColor = PdfColors.white;
                                      }
                                      
                                      return pw.TableRow(
                                        children: [
                                          _buildTableCell(
                                            team.name,
                                            textColor: _getPdfColor(team.name, teamColors),
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                          _buildTableCell(
                                            '${team.roundPoints}',
                                            textAlign: pw.TextAlign.center,
                                          ),
                                          _buildTableCell(
                                            '$gamePosition°',
                                            textAlign: pw.TextAlign.center,
                                            backgroundColor: posBgColor,
                                          ),
                                          _buildTableCell(
                                            '${gameScore ?? "-"}',
                                            textAlign: pw.TextAlign.center,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                                
                                pw.SizedBox(height: 10),
                                
                                // Explicación del sistema de puntos por rondas
                                pw.Container(
                                  padding: pw.EdgeInsets.all(8),
                                  decoration: pw.BoxDecoration(
                                    color: PdfColors.grey100,
                                    borderRadius: pw.BorderRadius.circular(5),
                                  ),
                                  child: pw.Text(
                                    'En este tipo de juego, los equipos acumulan puntos en cada ronda. Al final, la puntuación se convierte a la escala 100/75/50/25 según la posición final.',
                                    style: pw.TextStyle(
                                      fontSize: 8,
                                      fontStyle: pw.FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
                
                // Pie de página
                pw.Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Página 3 - Detalles de juegos por rondas - $dateStr',
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
    }
    
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
  
  // Método para exportar a CSV (conservado del código original)
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
  
  // Método para exportar como imagen usando RepaintBoundary 
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
  
  // Método para verificar si hay juegos de tipo rondas
  static bool _anyRoundGames(List<Game> games) {
    return games.any((game) => game.type == GameType.rounds);
  }
  
  // Método para obtener el color PDF correspondiente al equipo
  static PdfColor _getPdfColor(String teamName, Map<String, PdfColor> teamColors) {
    return teamColors[teamName] ?? PdfColors.black;
  }
  
  // Método para construir una posición en el podio para la portada
  static pw.Widget _buildPodiumPosition(Team team, int position, {required double height, required PdfColor teamColor}) {
    // Determinamos el color del podio según la posición
    final podiumColor = position == 1 
      ? PdfColors.amber 
      : position == 2 
        ? PdfColors.grey400 
        : PdfColors.orange;
    
    // Texto de medalla según posición 
    final medalText = position == 1 ? "1°" : position == 2 ? "2°" : "3°";
        
    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        // Texto de posición
        pw.Container(
          padding: pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: pw.BoxDecoration(
            color: podiumColor,
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Text(
            medalText,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
        ),
        pw.SizedBox(height: 5),
        // Nombre del equipo
        pw.Text(
          team.name,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: teamColor,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          '${team.totalScore} pts',
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 5),
        // Podio
        pw.Container(
          width: 80,
          height: height,
          decoration: pw.BoxDecoration(
            color: podiumColor,
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          padding: pw.EdgeInsets.all(8),
          child: pw.Center(
            child: pw.Text(
              '$position',
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Método para construir una celda de tabla de encabezado
  static pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.purple900,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
  
  // Método para construir una celda de tabla normal
  static pw.Widget _buildTableCell(
    String text, {
    pw.TextAlign textAlign = pw.TextAlign.left,
    PdfColor? textColor,
    PdfColor? backgroundColor,
    pw.FontWeight? fontWeight,
  }) {
    return pw.Container(
      color: backgroundColor,
      padding: pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: textColor ?? PdfColors.black,
          fontWeight: fontWeight,
        ),
        textAlign: textAlign,
      ),
    );
  }
  
  // Método para construir un ítem de la leyenda
  static pw.Widget _buildLegendItem(String text, PdfColor color) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Container(
          width: 12,
          height: 12,
          decoration: pw.BoxDecoration(
            color: color,
            border: pw.Border.all(
              color: PdfColors.grey400,
              width: 0.5,
            ),
          ),
        ),
        pw.SizedBox(width: 5),
        pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 8,
          ),
        ),
      ],
    );
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
}