import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import 'package:euphoria/models/models.dart';
import '../../widgets/admin_widgets.dart';

class AddSongTab extends StatefulWidget {
  const AddSongTab({super.key});

  @override
  State<AddSongTab> createState() => _AddSongTabState();
}

class _AddSongTabState extends State<AddSongTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _genreController = TextEditingController();
  final _durationController = TextEditingController();
  
  Artist? _selectedArtist;
  List<Artist> _artists = [];
  PlatformFile? _audioFile;
  PlatformFile? _thumbnailFile;
  bool _isLoading = true;
  bool _isUploading = false;
  bool _showAudioError = false;

  @override
  void initState() {
    super.initState();
    _loadArtists();
  }

  Future<void> _loadArtists() async {
    final artists = await ApiService.fetchArtists();
    if (mounted) setState(() { _artists = artists; _isLoading = false; });
  }

  Future<void> _upload() async {
    if (_audioFile == null) {
      setState(() => _showAudioError = true);
    }

    if (!_formKey.currentState!.validate() || _audioFile == null || _selectedArtist == null) {
      if (_selectedArtist == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an artist'))
        );
      }
      return;
    }

    setState(() => _isUploading = true);
    final success = await ApiService.uploadSong(
      title: _titleController.text,
      artistId: _selectedArtist!.id,
      genre: _genreController.text,
      durationSeconds: int.tryParse(_durationController.text) ?? 180,
      audioFile: _audioFile!,
      thumbnailFile: _thumbnailFile,
    );

    if (mounted) {
      setState(() => _isUploading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Song Uploaded Successfully!'))
        );
        _titleController.clear();
        _genreController.clear();
        _durationController.clear();
        setState(() {
          _audioFile = null;
          _thumbnailFile = null;
          _selectedArtist = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload failed. Please try again.'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.netflixRed));

    return Form(
      key: _formKey,
      child: AdminFormContainer(
        title: 'Add New Song',
        children: [
          const AdminInputLabel(label: 'Song Title'),
          AdminTextField(
            controller: _titleController,
            hint: 'e.g. Blinding Lights',
            validator: (value) => (value == null || value.isEmpty) ? 'Please enter song title' : null,
          ),
          
          const AdminInputLabel(label: 'Genre'),
          AdminTextField(
            controller: _genreController,
            hint: 'e.g. Pop',
            validator: (value) => (value == null || value.isEmpty) ? 'Please enter genre' : null,
          ),
          
          const AdminInputLabel(label: 'Select Artist'),
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceGrey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderGrey),
            ),
            child: DropdownButtonFormField<Artist>(
              dropdownColor: AppTheme.surfaceGrey,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                hintText: 'Select Artist',
                hintStyle: TextStyle(color: AppTheme.textDim),
              ),
              items: _artists.map((a) => DropdownMenuItem(
                value: a,
                child: Text(a.name),
              )).toList(),
              onChanged: (val) => setState(() => _selectedArtist = val),
              validator: (value) => value == null ? 'Please select an artist' : null,
            ),
          ),
          
          const AdminInputLabel(label: 'Audio File'),
          AdminFilePicker(
            label: 'Select Audio File',
            icon: Icons.audiotrack,
            file: _audioFile,
            onTap: () async {
              final res = await FilePicker.platform.pickFiles(type: FileType.audio);
              if (res != null) setState(() { _audioFile = res.files.first; _showAudioError = false; });
            },
            errorText: _showAudioError ? 'Please select an audio file' : null,
          ),
          
          const AdminInputLabel(label: 'Cover Thumbnail (Optional)'),
          AdminFilePicker(
            label: 'Select Thumbnail Image',
            icon: Icons.image,
            file: _thumbnailFile,
            onTap: () async {
              final res = await FilePicker.platform.pickFiles(type: FileType.image);
              if (res != null) setState(() => _thumbnailFile = res.files.first);
            },
          ),
          
          const SizedBox(height: 16),
          AdminSubmitButton(
            label: 'Upload Song',
            onPressed: _upload,
            isLoading: _isUploading,
          ),
        ],
      ),
    );
  }
}
