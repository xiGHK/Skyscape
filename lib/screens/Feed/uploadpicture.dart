import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:skyscape/services/database.dart';
import 'package:skyscape/services/auth.dart';
import 'package:skyscape/flutter_flow_theme.dart';
//import 'package:skyscape/upload_model.dart';
//export 'package:skyscape/upload_model.dart';
class UploadPicture extends StatefulWidget {
  const UploadPicture({super.key});

  @override
  State<UploadPicture> createState() => _UploadPictureState();
}

class _UploadPictureState extends State<UploadPicture> {
  File? _selectedImage;
  bool _isUploading = false;

  final AuthService _auth = AuthService();


  Future<void> _selectImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }
Future<void> _uploadImage() async {
  if (_selectedImage == null) return;

  setState(() {
    _isUploading = true;
  });

  try {
    // Generate a unique file path for the uploaded photo
    final fileExtension = _selectedImage!.path.split('.').last;
    final fileName = '${_auth.currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
    final storageRef = FirebaseStorage.instance.ref().child('photos/$fileName');

    // Upload image to Firebase Storage
    final uploadTask = storageRef.putFile(_selectedImage!);
    final snapshot = await uploadTask.whenComplete(() {});

    // Get the download URL of the uploaded photo
    final downloadUrl = await snapshot.ref.getDownloadURL();

    // Save the photo URL to the user's document in Firestore
    await DatabaseService(uid: _auth.currentUser!.uid).savePhotoUrl(downloadUrl);

    setState(() {
      _selectedImage = null;
      _isUploading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image uploaded successfully')),
    );
  } catch (e) {
    setState(() {
      _isUploading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error uploading image: $e')),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[300],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            //begin: Alignment.topCenter,
            //end: Alignment.bottomCenter,
            colors: [Colors.orange[300]!, Color.fromARGB(255, 226, 75, 16)!],
            stops: [0, 1],
            begin: AlignmentDirectional(0, -1),
            end: AlignmentDirectional(0, 1),
          ),
        ),
        
        child: Stack(
          
          children: [
            Align(
                      alignment: AlignmentDirectional(0, -0.9),
                      child: Text(
                        'Upload Picture',
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              color: FlutterFlowTheme.of(context)
                                  .primaryBackground,
                              fontSize: 40,
                            ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional(0, -0.6),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () async {},
                        child: Container(
                          width: 323,
                          height: 203,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            image: _selectedImage != null // Check if an image is selected
                            ? DecorationImage(
                            fit: BoxFit.cover,
                            image: _selectedImage!.path.startsWith('http') // Handle network image or local file
                              ? NetworkImage(_selectedImage!.path)
                              : FileImage(_selectedImage!) as ImageProvider,
                           )
                            : null, // Display no image placeholder if not selected
                            
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(50),
                              bottomRight: Radius.circular(50),
                              topLeft: Radius.circular(50),
                              topRight: Radius.circular(50),
                            ),
                            shape: BoxShape.rectangle,
                          ),
                          /*alignment: AlignmentDirectional(0, 0),
                          child: Visibility(
                            visible:
                                _model.isDataUploading1 != null ? true : false,
                            child: Align(
                              alignment: AlignmentDirectional(0, 0),
                              child: Text(
                                'No Picture Uploaded Yet',
                                style: FlutterFlowTheme.of(context)
                                    .headlineLarge
                                    .override(
                                      fontFamily: 'Outfit',
                                      fontSize: 24,
                                    ),
                              ),
                            ),
                          ),*/
                          child:GestureDetector(
                            onTap: () => _selectImage(ImageSource.gallery),
                            child: Container(
                              alignment: AlignmentDirectional(0, 0),
                              child: _selectedImage == null
                              ? Text( 'No Picture Uploaded Yet',
                              style: FlutterFlowTheme.of(context).headlineLarge.override(
                              fontFamily: 'Outfit',
                              fontSize: 24,
                                 ),
                               )
                               : null
                            ),
                         ),
                        ),
                      ),
                    ),
           
            
            
            Align(
              
              alignment: AlignmentDirectional(0, 1),
              child: Container(
                width: 392,
                height: 377,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                  ),
                ),
                child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
                  alignment: AlignmentDirectional(0, -0.9),
                  child: Text(
                    'Select Source of Photo',
                    style: FlutterFlowTheme.of(context).headlineLarge.override(
                          fontFamily: 'Outfit',
                          fontSize: 29,
                        ),
                  ),
                  
                ),
                SizedBox(height: 30),
           
            SizedBox(width:250, 
            height:50,
            child: ElevatedButton(
              onPressed: () => _selectImage(ImageSource.camera),
              child: const Text('Take Picture'),
            )
            ),
            SizedBox(height: 10),
            
            SizedBox(width:250, 
            height:50,
            child: ElevatedButton(
              onPressed: () => _selectImage(ImageSource.gallery),
              child: const Text('Choose From Gallery'),
            ),
            ),
            SizedBox(height: 20),
            
            SizedBox(width:100, 
            height:100,
            child:
            
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadImage,
              child: const Text('Upload'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[300]!,
              foregroundColor:Color.fromARGB(255, 206, 49, 37)!),
            ),
            )
                ],
                 
              ),
            ),
            )
          ],
        ),
      ),
    );
  }
}