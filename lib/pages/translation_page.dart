import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/audio_translation_service.dart';
import '../constants/languages.dart';

class TranslationPage extends StatefulWidget {
  const TranslationPage({super.key});

  @override
  _TranslationPageState createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  final AudioTranslationService _audioTranslationService =
      AudioTranslationService();

  String? _selectedAudioFile;
  String _selectedInputLanguage = 'es';
  String _selectedOutputLanguage = 'en';
  bool _playTranslatedAudio = false;
  String _transcription = '';
  String _translation = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Traducir Audio'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPickAudioButton(),
            if (_selectedAudioFile != null) _buildSelectedFileInfo(),
            const SizedBox(height: 20),
            _buildLanguageDropdown(
              label: 'Idioma de Entrada',
              value: _selectedInputLanguage,
              onChanged: (value) =>
                  setState(() => _selectedInputLanguage = value!),
            ),
            const SizedBox(height: 10),
            _buildLanguageDropdown(
              label: 'Idioma de Salida',
              value: _selectedOutputLanguage,
              onChanged: (value) =>
                  setState(() => _selectedOutputLanguage = value!),
            ),
            const SizedBox(height: 10),
            _buildPlayTranslatedAudioSwitch(),
            const SizedBox(height: 20),
            _buildProcessAudioButton(),
            const SizedBox(height: 20),
            if (_transcription.isNotEmpty)
              _buildResultSection('Transcripción', _transcription),
            if (_translation.isNotEmpty)
              _buildResultSection('Traducción', _translation),
          ],
        ),
      ),
    );
  }

  Widget _buildPickAudioButton() {
    return ElevatedButton.icon(
      onPressed: _pickAudioFile,
      icon: const Icon(Icons.audiotrack),
      label: const Text('Seleccionar Archivo de Audio'),
    );
  }

  Widget _buildSelectedFileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          'Archivo seleccionado: ${_selectedAudioFile!.split('/').last}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildLanguageDropdown({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: languages
          .map((lang) => DropdownMenuItem(
                value: lang['code'],
                child: Text(lang['language']!),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildPlayTranslatedAudioSwitch() {
    return SwitchListTile(
      title: const Text('Reproducir Audio Traducido'),
      value: _playTranslatedAudio,
      onChanged: (value) => setState(() => _playTranslatedAudio = value),
    );
  }

  Widget _buildProcessAudioButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _processAudio,
      child: _isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('Procesar Audio'),
    );
  }

  Widget _buildResultSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(content),
      ],
    );
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedAudioFile = result.files.single.path;
      });
    }
  }

  Future<void> _processAudio() async {
    if (_selectedAudioFile == null) {
      _showSnackBar('Por favor, selecciona un archivo de audio.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _audioTranslationService.processAudio(
        audioFilePath: _selectedAudioFile!,
        inputLanguage: _selectedInputLanguage,
        outputLanguage: _selectedOutputLanguage,
        playTranslatedAudio: _playTranslatedAudio,
      );

      setState(() {
        _transcription = result['texto'] ?? 'No disponible';
        _translation = result['texto_traducido'] ?? 'No disponible';
      });

      _showSnackBar('Procesamiento completado.');
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
