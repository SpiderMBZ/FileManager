import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import '../file_manager.dart';
import 'package:flutter/services.dart';

Color blueb = const Color(0xff002ebfe);
Color bluea = const Color(0xff00099ff);
Color bluec = const Color(0xff000ffff);

final mainNavigatorKey = GlobalKey<NavigatorState>();
final FileManagerController controller = FileManagerController();
late VoidCallback refreshhome;
bool refresh=false;
FileSystemEntity? currentfolderent;
final folderformkey=GlobalKey<FormState>();
final fileformkey=GlobalKey<FormState>();
bool testingmode=false;



Future<void> selectStorage(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) => Dialog(
      child: FutureBuilder<List<Directory>>(
        future: FileManager.getStorageList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<FileSystemEntity> storageList = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: storageList
                      .map((e) => ListTile(
                            title: Text(
                              FileManager.basename(e),
                            ),
                            onTap: () {
                              controller.openDirectory(e);
                              Navigator.pop(context);
                            },
                          ))
                      .toList()),
            );
          }
          return const Dialog(
            child: CircularProgressIndicator(),
          );
        },
      ),
    ),
  );
}
sort(BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
                title: const Text("Name"),
                onTap: () {
                  controller.sortBy(SortBy.name);
                  Navigator.pop(context);
                }),
            ListTile(
                title: const Text("Size"),
                onTap: () {
                  controller.sortBy(SortBy.size);
                  Navigator.pop(context);
                }),
            ListTile(
                title: const Text("Date"),
                onTap: () {
                  controller.sortBy(SortBy.date);
                  Navigator.pop(context);
                }),
            ListTile(
                title: const Text("type"),
                onTap: () {
                  controller.sortBy(SortBy.type);
                  Navigator.pop(context);
                }),
          ],
        ),
      ),
    ),
  );
}





createFile(BuildContext context, String path) async {
  showDialog(
    context: context,
    builder: (context) {
      TextEditingController fileName = TextEditingController();
      TextEditingController fileSize = TextEditingController();
      TextEditingController fileExtension = TextEditingController();
      return Dialog(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Form(
            key: fileformkey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: TextFormField(
                      decoration: const InputDecoration(
                        hintText: "File Name",
                      ),
                      controller: fileName,
                      onChanged: (v)=>fileformkey.currentState!.validate(),

                      validator: (value) {
                        return value==null?"empty":(value==""||value.isEmpty)?"empty":null;
                      },
                    ),
                  ),
                  ListTile(
                    trailing: const Text("Bytes"),
                    title: TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: "File Size",
                      ),
                      controller: fileSize,
                      onChanged: (v)=>fileformkey.currentState!.validate(),
                      validator: (value) {
                        return value==null?"empty":(value==""||value.isEmpty)?"empty":null;
                      },
                    ),
                  ),
                  ListTile(
                    title: TextFormField(
                      decoration: const InputDecoration(
                        hintText: "File Extension",
                      ),
                      controller: fileExtension,
                      onChanged: (v)=>fileformkey.currentState!.validate(),
                      validator: (value) {
                        return value==null?"empty":(value==""||value.isEmpty)?"empty":null;
                      },
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      primary: blueb,
                    ),
                    onPressed: () async {
                      if(fileformkey.currentState!.validate()){

                        try {
                        await createfile(context, path, fileName.text, fileExtension.text, fileSize.text);
                        } catch (e) {
                          alert(context, "somthing went wrong");
                        }
                      }
                    },
                    child: const Text(
                      'Create File',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

}
Future<void> createfile(BuildContext? context, String path, String fileName,String fileExtension,String fileSize) async {
  Directory documentsDir =
      await getApplicationDocumentsDirectory();

  String folderPath = path;
  Directory folder = Directory(folderPath);
  if (!await folder.exists()) {
  await folder.create(recursive: true);
  }
  File file = File(
  '$folderPath/${fileName}.${fileExtension}');
  if (!await file.exists()) {
  await file.create();
  RandomAccessFile raf =
  await file.open(mode: FileMode.write);
  for (int i = 0; i < int.parse(fileSize); i++) {
  await raf.writeByte(0x00);
  }

  await raf.close().then((value) async {
    if(!testingmode) {
      Navigator.pop(context!);
      refreshhome();
      await controller.goToParentDirectory().then((value) {
        if (currentfolderent != null)
          if (FileManager.isDirectory(currentfolderent!)) {
            try {
              print("aaaaaaaaaaaaaaaaaaaaaa");
              controller.openDirectory(currentfolderent!);
            } catch (e) {
              alert(
                  context, "Enable to open this folder");
            }
          }
      });
    }
  });

  }
}


createFolder(BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) {
      TextEditingController folderName = TextEditingController();
      return Dialog(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(10),
          child: Form(
            key: folderformkey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: TextFormField(
                    decoration: const InputDecoration(
                      hintText: "Folder Name",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    onChanged: (v)=>folderformkey.currentState!.validate(),
                    validator: (value) {
                      return value==null?"empty":(value==""||value.isEmpty)?"empty":null;
                    },
                    controller: folderName,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    primary: blueb,
                  ),
                  onPressed: () async {
                    if (folderformkey.currentState!.validate()) {
                      try {
                       await createfolder(context, folderName.text);
                      } catch (e) {
                        alert(context, "Folder already exists");
                      }
                    }

                  },
                  child: const Text(
                    'Create Folder',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                )
              ],
            ),
          )
        ),
      );
    },
  );
}
Future<void> createfolder(BuildContext? context,String folderName) async {

  try{
  await FileManager.createFolder(
      controller.getCurrentPath, folderName)
      .then((value) async {


        if(!testingmode) {
          Navigator.pop(context!);
          refreshhome();
          if (currentfolderent != null)
            if (FileManager.isDirectory(currentfolderent!)) {
              try {
                controller.openDirectory(currentfolderent!);
              } catch (e) {
                alert(
                    context, "Enable to open this folder");
              }
            }
        }

      });}catch(E){print(E.toString()+"        errrrrrrrrrrrrrrrrrrr");}
}





Future<void> alert(BuildContext context, String message) async {
  return showDialog(
    context: context,
    builder: (context) => Dialog(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(message),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                primary: blueb,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Ok',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
      ),
    ),
  );
}
Widget subtitle(FileSystemEntity entity) {
  return FutureBuilder<FileStat>(
    future: entity.stat(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        if (entity is File) {
          int size = snapshot.data!.size;
          String ss="";
          try{
          ss=  FileManager.formatBytes(size);
          snapshot.data!.size;
          }catch(e){}
          return
            Text(

            ss,
          );
        }
        return Text(
          "${snapshot.data!.modified}".substring(0, 10),
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey,
            fontWeight: FontWeight.w400,
          ),
        );
      } else {}
      return const Text("");
    },
  );
}


Future<void> entityde(BuildContext context, FileSystemEntity entity) async {
  return showDialog(
    context: context,
    builder: (context) => Dialog(
      child: Container(
        padding: const EdgeInsets.all(10),
        child:
        FutureBuilder<FileStat>(
          future: entity.stat(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {

                int size = snapshot.data!.size;
                String ss="";
                try{
                  ss=  FileManager.formatBytes(size);
                  snapshot.data!.size;
                }catch(e){}
                return
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text("Path: ${ entity.path}"),
                      ),
                      ListTile(
                        title: Text("Date: ${ snapshot.data!.accessed}"),
                      ),
                      ListTile(
                        title: Text("Size: ${ ss}"),
                      ),
                      ListTile(
                        title: Text("Type: ${ snapshot.data!.type}"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          primary: blueb,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Ok',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      )
                    ],
                  );
                  Text(

                    ss,
                  );


            } else {}
            return const Text("");
          },
        )

      ),
    ),
  );
}
