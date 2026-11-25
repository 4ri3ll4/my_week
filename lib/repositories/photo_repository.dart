import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const _cloudName = 'fgiidgwh';
const _uploadPreset = 'hnpttlyp';

class PhotoRepository {
  Future<String> upload(File photo) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', photo.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Upload failed: $body');
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    return json['secure_url'] as String;
  }
}