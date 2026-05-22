import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/api_service.dart';
import '../../widgets/admin_widgets.dart';

class AddArtistTab extends StatefulWidget {
  const AddArtistTab({super.key});

  @override
  State<AddArtistTab> createState() => _AddArtistTabState();
}

class _AddArtistTabState extends State<AddArtistTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  PlatformFile? _imageFile;
  bool _isUploading = false;
  bool _showImageError = false;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _imageFile = result.files.first;
        _showImageError = false;
      });
    }
  }

  Future<void> _submit() async {
    if (_imageFile == null) {
      setState(() => _showImageError = true);
    }

    if (!_formKey.currentState!.validate() || _imageFile == null) return;

    setState(() => _isUploading = true);
    
    final success = await ApiService.createArtist(
      name: _nameController.text,
      bio: _bioController.text,
      image: _imageFile!,
    );
    
    if (mounted) {
      setState(() => _isUploading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Artist Added Successfully!'))
        );
        _nameController.clear();
        _bioController.clear();
        setState(() => _imageFile = null);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add artist. Please try again.'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AdminFormContainer(
        title: 'Add New Artist',
        children: [
          const AdminInputLabel(label: 'Artist Name'),
          AdminTextField(
            controller: _nameController,
            hint: 'e.g. The Weeknd',
            validator: (value) => (value == null || value.isEmpty) ? 'Please enter artist name' : null,
          ),
          
          const AdminInputLabel(label: 'Biography'),
          AdminTextField(
            controller: _bioController,
            hint: 'Write artist biography...',
            maxLines: 4,
          ),
          
          const AdminInputLabel(label: 'Artist Image'),
          AdminFilePicker(
            label: 'Select Artist Image',
            icon: Icons.person,
            file: _imageFile,
            onTap: _pickImage,
            errorText: _showImageError ? 'Please select an image' : null,
          ),
          
          const SizedBox(height: 16),
          AdminSubmitButton(
            label: 'Add Artist',
            onPressed: _submit,
            isLoading: _isUploading,
          ),
        ],
      ),
    );
  }
}
