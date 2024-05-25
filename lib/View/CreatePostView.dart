import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media/View%20Model/CreatePostViewModel.dart';
import 'package:social_media/View/full_screen.dart';

class CreatePostScreen extends StatelessWidget {
  final String userName;
  final String userProfileUrl;

  CreatePostScreen({required this.userName, required this.userProfileUrl});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreatePostViewModel(
          userName: userName, userProfileUrl: userProfileUrl),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 65, 152, 223),
          title: Text('Gönderi Oluştur'),
        ),
        body: Consumer<CreatePostViewModel>(
          builder: (context, viewModel, child) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Form(
                    key: viewModel.formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: viewModel.headerController,
                          decoration: InputDecoration(
                            labelText: 'Başlık',
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 65, 152, 223),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen bir başlık girin';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: viewModel.bodyController,
                          decoration: InputDecoration(
                            labelText: 'Metin',
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 65, 152, 223),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen metin girin';
                            }
                            return null;
                          },
                          maxLines: 4,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => viewModel.pickImages(context),
                          icon: Icon(Icons.photo_library),
                          label: Text('Fotoğrafları Seç'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 65, 152, 223),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        _buildSelectedImages(viewModel, context),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => viewModel.createPost(context),
                          child: Text('Gönder'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 65, 152, 223),
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (viewModel.isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectedImages(
      CreatePostViewModel viewModel, BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: viewModel.imageFiles.map((file) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenImageGallery(
                    imageFiles: viewModel.imageFiles,
                    initialIndex: viewModel.imageFiles.indexOf(file)),
              ),
            );
          },
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Image.file(
                file,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              IconButton(
                icon: Icon(Icons.cancel, color: Colors.red),
                onPressed: () {
                  viewModel.imageFiles.remove(file);
                  viewModel.notifyListeners();
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
