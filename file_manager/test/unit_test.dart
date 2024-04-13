import 'dart:io';

import 'package:file_manager/Utils/AppC/core.dart';
import 'package:file_manager/Utils/controller/file_manager_controller.dart';
import 'package:file_manager/Utils/file_manager.dart';
import 'package:file_manager/Screens/Home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

/*
*                                 Note
*
*      Android Only                                     Android Only
*
*                 for android >=31 enable all files access
*
*
* Please test on android device (flutter run test/unit_test.dart)
*
*
*                 for android >=31 enable all files access
*
*
*      Android Only                                      Android Only
*                                 Note
* */



/*
*
*                   file manager support android only
*
*                         DO NO TRY ON DESKTOP
*
*
*         <3 <3   If you need desk/ios..... version ask me   <3 <3
*
*
*                             Thank you
* */


void main() {
  String foldername = "abc";
  String filename = "def";
  String path = '/storage/emulated/0';

  setUp(() async {
    testingmode = true;
    Directory folder = Directory(path + "/" + foldername);
    if (await folder.exists()) {
      await folder.delete(recursive: true);
    }
    Directory folder2 = Directory(path + "/abc2");
    if (await folder2.exists()) {
      await folder2.delete(recursive: true);
    }
    Directory folder3 = Directory(path + "/abc3");
    if (await folder3.exists()) {
      await folder3.delete(recursive: true);
    }
  });
  group('file manager', () {
    testWidgets("ff", (widgetTester) async {
      await widgetTester.pumpWidget(FileManager(
        controller: controller,
        builder: (context, snapshot) {
          return Container();
        },
      ));

      await widgetTester.pump();

      await createfolder(null, foldername);
      expect(await Directory(path + "/" + foldername).exists(), true);

      await createfile(null, "$path/$foldername/", filename, "txt", "22");
      expect(await File("$path/$foldername/$filename.txt").exists(), true);

      await rename(null, "abc2", await Directory(path + "/" + foldername));
      expect(await Directory(path + "/" + "abc2").exists(), true);

      await rename(
          null, "abc2/def2.txt", await File("$path/abc2/$filename.txt"));
      expect(await File("$path/abc2/def2.txt").exists(), true);

      await createfolder(null, "abc3");
      expect(await Directory(path + "/abc3").exists(), true);
      await rename(null, "abc3/abc2", await Directory(path + "/abc2"));
      expect(await Directory(path + "/" + "abc3/abc2").exists(), true);

      await rename(
          null, "abc3/def2.txt", await File("$path/abc3/abc2/def2.txt"));
      expect(await File("$path/abc3/def2.txt").exists(), true);

      await delete(null, await File("$path/abc3/def2.txt"));
      expect(await File("$path/abc3/def2.txt").exists(), false);
      await delete(null, await Directory("$path/abc3/abc2"));
      expect(await Directory("$path/abc3/abc2").exists(), false);
    });
  });
}
