import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MaterialApp(
    home: FileUploadScreen(),
  ));
}

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  _FileUploadScreenState createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  String? selectedFileType;
  File? uploadedFile;
  List<List<dynamic>>? csvData;
  String? selectedColumn;
  List<String> columnNames = [];
  List<FlSpot> graphData = [];
  double? minY, maxY;
  VideoPlayerController? _videoController;

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'File Upload',
          style: TextStyle(
              color: Color.fromARGB(158, 43, 14, 0),
              fontSize: 20,
              fontWeight: FontWeight.bold,),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Customized Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select File Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: Colors.deepPurple.withOpacity(0.1),
              ),
              value: selectedFileType,
              items: const [
                DropdownMenuItem(
                  value: 'Image',
                  child: Row(
                    children: [
                      Icon(Icons.image, color: Colors.purple),
                      SizedBox(width: 10),
                      Text('Image'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Video',
                  child: Row(
                    children: [
                      Icon(Icons.video_file, color: Colors.blue),
                      SizedBox(width: 10),
                      Text('Video'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'CSV',
                  child: Row(
                    children: [
                      Icon(Icons.insert_drive_file, color: Colors.green),
                      SizedBox(width: 10),
                      Text('CSV'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedFileType = value;
                  uploadedFile = null;
                  _videoController?.dispose();
                  csvData = null;
                  columnNames = [];
                  selectedColumn = null;
                  graphData = [];
                });
              },
            ),
            const SizedBox(height: 20),
            if (selectedFileType != null)
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload File'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color.fromARGB(255, 232, 173, 127), // Button color
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (selectedFileType == 'Image' && uploadedFile != null)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.file(uploadedFile!),
                ),
              ),
            if (selectedFileType == 'Video' && _videoController != null)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                ),
              ),
            if (selectedFileType == 'CSV' && columnNames.isNotEmpty)
              DropdownButton<String>(
                hint: const Text('Select Column for Y-axis'),
                value: selectedColumn,
                items: columnNames.map((String column) {
                  return DropdownMenuItem<String>(
                    value: column,
                    child: Text(column),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedColumn = value;
                    _generateGraphData();
                  });
                },
              ),
            const SizedBox(height: 20),
            if (selectedFileType == 'CSV' && graphData.isNotEmpty)
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: graphData,
                        isCurved: true,
                        barWidth: 4,
                        color: Colors.blue,
                        belowBarData: BarAreaData(show: false),
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toString(),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toString(),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                    ),
                    minY: minY,
                    maxY: maxY,
                    clipData: FlClipData.all(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    if (selectedFileType == null) return;

    FilePickerResult? result;

    if (selectedFileType == 'CSV') {
      result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
    } else if (selectedFileType == 'Image') {
      result = await FilePicker.platform.pickFiles(type: FileType.image);
    } else if (selectedFileType == 'Video') {
      result = await FilePicker.platform.pickFiles(type: FileType.video);
    }

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);

      if (selectedFileType == 'Image' || selectedFileType == 'Video') {
        setState(() {
          uploadedFile = file;
        });

        if (selectedFileType == 'Video') {
          _videoController = VideoPlayerController.file(file)
            ..initialize().then((_) {
              setState(() {});
              _videoController!.play();
            });
        }
      } else if (selectedFileType == 'CSV') {
        final content = await file.readAsString();
        final data = const CsvToListConverter().convert(content);
        setState(() {
          csvData = data;
          columnNames = data.first.map((e) => e.toString()).toList();
          selectedColumn = columnNames[1]; // Default to the second column
          _generateGraphData();
        });
      }
    }
  }

  void _generateGraphData() {
    if (csvData == null || selectedColumn == null) return;

    final colIndex = columnNames.indexOf(selectedColumn!);
    final List<FlSpot> spots = [];
    for (int i = 1; i < csvData!.length; i++) {
      final yValue = double.tryParse(csvData![i][colIndex].toString());
      if (yValue != null) {
        spots.add(FlSpot(i.toDouble(), yValue));
      }
    }

    if (spots.isNotEmpty) {
      minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
      maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    }

    setState(() {
      graphData = spots;
    });
  }
}
