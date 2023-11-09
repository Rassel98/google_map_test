// import 'dart:convert';
// import 'dart:io';
// import 'package:encrypt/encrypt.dart' as an;
// import 'package:flutter/material.dart';
// import 'package:path/path.dart' as path;
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:youtube_explode_dart/youtube_explode_dart.dart';
//
// void main() {
//   runApp(MyApp());
// }
//     <uses-permission android:name="android.permission.MEDIA_CONTENT_CONTROL"/>
//     <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" tools:ignore="ScopedStorage"/>
// // youtube_explode_dart: ^1.12.4
// // path_provider: ^2.0.15
// // permission_handler: ^9.2.0
// // path: ^1.8.1
// // encrypt: ^5.0.1
//
//
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter VideoDownload Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   MyHomePage({super.key, required this.title});
//
//   final String title;
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   final textController = TextEditingController();
//
//   // Future<Directory?> getDownloadPath() async {
//   //   Directory? directory;
//   //   try {
//   //     if (Platform.isIOS) {
//   //       directory = await getApplicationDocumentsDirectory();
//   //     } else {
//   //       directory = Directory('/storage/emulated/0/Download');
//   //       if (!await directory.exists()) {
//   //         directory = await getExternalStorageDirectory();
//   //       }
//   //     }
//   //   } catch (err) {
//   //     print("Cannot get download folder path");
//   //   }
//   //   return directory;
//   // }
//   Future<Directory?> getDownloadPath() async {
//     Directory? directory;
//     try {
//       if (Platform.isAndroid) {
//
//
//         if (await _requestPermission(Permission.storage) &&
//             await _requestPermission(Permission.accessMediaLocation) &&
//             await _requestPermission(Permission.manageExternalStorage)) {
//           directory = await getExternalStorageDirectory();
//           print(directory!.path);
//           String newPath = '';
//           List<String> folders = directory.path.split("/");
//           for (int i = 1; i < folders.length; i++) {
//             String folder = folders[i];
//             if (folder != "Android") {
//               newPath += "/$folder";
//             } else {
//               break;
//             }
//           }
//           newPath = "$newPath/SOSApp";
//           directory = Directory(newPath);
//         }
//       }
//       if (!await directory!.exists()) {
//         await directory.create(recursive: true);
//       }
//     } catch (err) {
//       print("Cannot get download folder path  $err");
//     }
//     return directory;
//   }
//
//   Future<bool> _requestPermission(Permission permission) async {
//
//
//     if (!await permission.isGranted ) {
//       var r = await permission.request();
//       if (r == PermissionStatus.granted) {
//         return true;
//       } else {
//         return false;
//       }
//     }
//     return true;
//   }
//
//   Future<void> encryptFile(String file) async {
//     File inFile = File(file);
//     File outFile = File("videoenc.aes");
//     bool outFileExists = await outFile.exists();
//     if (!outFileExists) {
//       await outFile.create();
//     }
//     final videoFileContents = await inFile.readAsStringSync(encoding: latin1);
//     final key = an.Key.fromUtf8('TVwyvD3vRllw0zaKcWErauXV5EG79Tnv');
//     final iv = an.IV.fromLength(16);
//     final encrypter = an.Encrypter(an.AES(key));
//     final encrypted = encrypter.encrypt(videoFileContents, iv: iv);
//     await outFile.writeAsBytes(encrypted.bytes);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     textController.text = 'https://www.youtube.com/watch?v=ElZfdU54Cp8';
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'Insert the video id or url',
//             ),
//             TextField(controller: textController),
//             ElevatedButton(
//                 child: const Text('Download'),
//                 onPressed: () async {
//                   // Here you should validate the given input or else an error
//                   // will be thrown.
//                   var yt = YoutubeExplode();
//                   var id = VideoId(textController.text.trim());
//                   var video = await yt.videos.get(id);
//
//                   // Display info about this video.
//                   await showDialog(
//                     context: context,
//                     builder: (context) {
//                       return AlertDialog(
//                         content: Text(
//                             'Title: ${video.title}, Duration: ${video.duration}'),
//                       );
//                     },
//                   );
//                   String result = video.title.replaceAll(RegExp('_'), ' ');
//                   print(result);
//
//                   // Request permission to write in an external directory.
//                   // (In this case downloads)
//                   // await Permission.storage.request();
//
//                   // Get the streams manifest and the audio track.
//                   var manifest = await yt.videos.streamsClient.getManifest(id);
//                   var audio = manifest.muxed.last;
//
//                   // Build the directory.
//                   var dir = await getDownloadPath();
//
//                   print(dir!.path.toString());
//
//                   var filePath = path.join(dir.uri.toFilePath(),
//                       '${video.id}.${audio.container.name}');
//                   //'${video.id}.sosm');
//
//                   // Open the file to write.
//                   var file = File(filePath);
//                   var fileStream = file.openWrite();
//
//                   // Pipe all the content of the stream into our file.
//                   await yt.videos.streamsClient.get(audio).pipe(fileStream);
//                   /*
//                   If you want to show a % of download, you should listen
//                   to the stream instead of using `pipe` and compare
//                   the current downloaded streams to the totalBytes,
//                   see an example ii example/video_download.dart
//                    */
//
//                   // Close the file.
//                   await fileStream.flush();
//                   await fileStream.close();
//
//                   // Show that the file was downloaded.
//                   await showDialog(
//                     context: context,
//                     builder: (context) {
//                       return AlertDialog(
//                         content:
//                         Text('Download completed and saved to: $filePath'),
//                       );
//                     },
//                   );
//                   //encryptFile(filePath);
//                   print('ok');
//
//                   // decryptFile() async {
//                   //   File inFile = new File("videoenc.aes");
//                   //   File outFile = new File("videodec.mp4");
//                   //
//                   //   bool outFileExists = await outFile.exists();
//                   //
//                   //   if(!outFileExists){
//                   //     await outFile.create();
//                   //   }
//                   //
//                   //   final videoFileContents = await inFile.readAsBytesSync();
//                   //
//                   //   final key = an.Key.fromUtf8('my 32 length key................');
//                   //   final iv = an.IV.fromLength(16);
//                   //
//                   //   final encrypter = an.Encrypter(an.AES(key));
//                   //
//                   //   final encryptedFile = an.Encrypted(videoFileContents);
//                   //   final decrypted = encrypter.decrypt(encryptedFile, iv: iv);
//                   //
//                   //   final decryptedBytes = an.latin1.encode(decrypted);
//                   //   await outFile.writeAsBytes(decryptedBytes);
//                   //
//                   // }
//                 }),
//           ],
//         ),
//       ),
//     );
//   }
// }
