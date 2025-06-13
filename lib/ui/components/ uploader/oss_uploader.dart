import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class AliyunOssUploadPage extends StatefulWidget {
  const AliyunOssUploadPage({super.key});

  @override
  _AliyunOssUploadPageState createState() => _AliyunOssUploadPageState();
}

class _AliyunOssUploadPageState extends State<AliyunOssUploadPage> {
  File? _file;
  String? _fileName;
  double _progress = 0.0;
  final Dio _dio = Dio();

  // 这些参数需要你后端生成并传给客户端
  final String uploadUrl = "https://your-bucket.oss-cn-region.aliyuncs.com/your-object-key";
  final Map<String, String> headers = {
    // 例如包括Authorization, x-oss-security-token等
    "Authorization": "OSS your-signature",
    // 如果用STS Token则有
    //"x-oss-security-token": "your-token",
  };

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() {
        _file = File(result.files.single.path!);
        _fileName = result.files.single.name;
        _progress = 0.0;
      });
    }
  }

  Future<void> uploadFile() async {
    if (_file == null) return;

    try {
      // 阿里云OSS支持PUT上传单个文件
      await _dio.put(
        uploadUrl,
        data: _file!.openRead(),
        options: Options(
          headers: headers,
          contentType: "application/octet-stream",
        ),
        onSendProgress: (sent, total) {
          setState(() {
            _progress = sent / total;
          });
        },
      );
      
      if(!mounted)return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('上传成功')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('上传失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('阿里云 OSS 上传示例')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickFile,
              child: const Text('选择文件'),
            ),
            if (_fileName != null) Text('文件名: $_fileName'),
            const SizedBox(height: 20),
            LinearProgressIndicator(value: _progress),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: uploadFile,
              child: const Text('上传文件'),
            ),
          ],
        ),
      ),
    );
  }
}
