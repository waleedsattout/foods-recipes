import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:foods/constants.dart';
import 'package:foods/models/images.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class ImageSaver {
  final ImagePicker _picker = ImagePicker();
  final box = Hive.box<Images>('images');
  ImageSaver() {
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (await Permission.storage.request().isGranted) {
    } else {
      await Permission.storage.request();
    }
  }

  Future<Uint8List?> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return await pickedFile.readAsBytes();
    }
    return null;
  }

  Future<void> saveImage(Uint8List imageData, String imageName) async {
    await box.add(Images(imageData: imageData));
    saveImageAsFile(imageData, imageName);
  }

  Future<String?> saveImageAsFile(Uint8List imageData, String imageName) async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      return null;
    }

    final filePath = path.join(directory.path, '$imageName.jpg');
    final file = File(filePath);
    await file.writeAsBytes(imageData);
    return filePath;
  }

  Future<Image> displayImageFromFile(String imageName,
      {BuildContext? context}) async {
    double? width;
    if (context != null && context.mounted) {
      width = MediaQuery.of(context).size.width;
    }
    if (isAndroid) {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        return placeHolder(width: width);
      }

      final filePath = path.join(directory.path, "$imageName.jpg");
      final file = File(filePath);

      if (await file.exists()) {
        final imageData = await file.readAsBytes();
        return Image.memory(
          height: width,
          imageData,
          width: width,
          fit: BoxFit.cover,
        );
      } else {
        return placeHolder(width: width);
      }
    } else {
      return placeHolder(width: width);
    }
  }

  Future<Uint8List?> getImageData(String imageName) async {
    final directory = await getExternalStorageDirectory();
    final filePath = "${path.join(directory!.path, imageName)}.jpg";
    final file = File(filePath);
    if (await file.exists()) {
      return file.readAsBytes();
    } else {
      return null;
    }
  }

  Image placeHolder({double? width}) {
    return Image.asset(
      "assets/images/food-placeholder-image.jpg",
      fit: BoxFit.contain,
      width: width,
    );
  }
}
