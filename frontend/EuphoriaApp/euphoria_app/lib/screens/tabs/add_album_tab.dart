import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/app_theme.dart';
import 'package:euphoria/models/models.dart';
import '../../services/api_service.dart';
import '../../widgets/admin_widgets.dart';

class AddAlbumTab extends StatefulWidget {
  const AddAlbumTab({super.key});

  @override
  State<AddAlbumTab> createState() => _AddAlbumTabState();
}

class _AddAlbumTabState extends State<AddAlbumTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  Artist? _selectedArtist;
  PlatformFile? _coverFile;
  List<Artist> _artists = [];
  bool _isLoading = true;
  bool _isUploading = false;
  bool _showCoverError = false;

  @override
  void initState() {
    super.initState();
    _loadArtists();
  }

  Future<void> _loadArtists() async {
    final artists = await ApiService.fetchArtists();
    if (mounted) setState(() { _artists = artists; _isLoading = false; });
  }

  Future<void> _pickCover() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _coverFile = result.files.first;
        _showCoverError = false;
      });
    }
  }

  Future<void> _submit() async {
    if (_coverFile == null) {
      setState(() => _showCoverError = true);
    }

    if (!_formKey.currentState!.validate() || _coverFile == null || _selectedArtist == null) {
      if (_selectedArtist == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an artist'))
        );
      }
      return;
    }

    setState(() => _isUploading = true);
    
    final success = await ApiService.createAlbum(
      title: _titleController.text,
      artistId: _selectedArtist!.id,
      coverImage: _coverFile!,
    );
    
    if (mounted) {
      setState(() => _isUploading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Album Added Successfully!'))
        );
        _titleController.clear();
        setState(() {
          _coverFile = null;
          _selectedArtist = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add album. Please try again.'))
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
        title: 'Add New Album',
        children: [
          const AdminInputLabel(label: 'Album Title'),
          AdminTextField(
            controller: _titleController,
            hint: 'e.g. Starboy',
            validator: (value) => (value == null || value.isEmpty) ? 'Please enter album title' : null,
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
          
          const AdminInputLabel(label: 'Album Cover'),
          AdminFilePicker(
            label: 'Select Album Cover',
            icon: Icons.album,
            file: _coverFile,
            onTap: _pickCover,
            errorText: _showCoverError ? 'Please select a cover image' : null,
          ),
          
          const SizedBox(height: 16),
          AdminSubmitButton(
            label: 'Add Album',
            onPressed: _submit,
            isLoading: _isUploading,
          ),
        ],
      ),
    );
  }
}
