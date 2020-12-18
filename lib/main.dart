import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PdfToImage(),
    );
  }
}

class PdfToImage extends HookWidget {
  const PdfToImage();
  @override
  Widget build(BuildContext context) {
    final files = useProvider(fileProvider.state);
    return Scaffold(
      body: Stack(
        children: [
          DropzoneView(
            onCreated: (c) => context.read(controllerProvider).state = c,
            onDrop: (d) => context.read(fileProvider).dropped(d),
          ),
          files == null
              ? Center(child: Text('Drop Files Here'))
              : Column(
                  children: [
                    for (final file in files)
                      Row(
                        children: [
                          Expanded(child: Text('Name: ${file.name}')),
                          Expanded(
                            child: Text('Size: ${file.size}'),
                          ),
                          Expanded(
                            child: Text('Mime: ${file.mime}'),
                          ),
                        ],
                      ),
                    SizedBox(height: 50),
                    RaisedButton(
                        onPressed: () => context.read(fileProvider).convert(),
                        child: Text('Convert'))
                  ],
                ),
        ],
      ),
    );
  }
}

final fileProvider =
    StateNotifierProvider<FileStateNotifier>((r) => FileStateNotifier(r.read));
final controllerProvider = StateProvider<DropzoneViewController>((_) => null);

class FileStateNotifier extends StateNotifier<List<FileData>> {
  FileStateNotifier(this.read) : super(null);
  final Reader read;
  DropzoneViewController get controller => read(controllerProvider).state;
  Future<void> dropped(dynamic d) async {
    final f = FileData(
      await controller.getFilename(d),
      await controller.getFileSize(d),
      await controller.getFileMIME(d),
      await controller.getFileData(d),
    );
    print(f);
    state = [...?state, f];
  }

  void convert() {}
}

class FileData {
  final String name;
  final int size;
  final String mime;
  final Uint8List data;

  FileData(this.name, this.size, this.mime, this.data);
}
