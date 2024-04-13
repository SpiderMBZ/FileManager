import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Utils/AppC/core.dart';
import '../Utils/file_manager.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String searchQuery = '';
  var gotPermission = false;
  var isMoving = false;
  var fullScreen = false;
  var isSearching = false;
  late FileSystemEntity selectedFile;

  @override
  void initState() {
    refreshhome = () => setState(() {
          refresh = true;
        });

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return ControlBackButton(
        controller: controller,
        child: Scaffold(
          appBar: appBar(context),
          body: FileManager(
            controller: controller,
            builder: (context, snapshot) {
              final List<FileSystemEntity> entities = isSearching
                  ? snapshot
                      .where((element) => element.path.contains(searchQuery))
                      .toList()
                  : snapshot
                      .where((element) =>
                          element.path != '/storage/emulated/0/Android')
                      .toList();
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Visibility(
                        visible: !fullScreen,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SizedBox(
                                height: 7.5.h,
                                child: TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      isSearching = true;
                                      searchQuery = value;
                                      if (searchQuery.isEmpty ||
                                          searchQuery == "" ||
                                          searchQuery == " ") {
                                        isSearching = false;
                                      }
                                    });
                                  },
                                  decoration: InputDecoration(
                                    suffixIcon: const Icon(Icons.search),
                                    filled: true,
                                    fillColor: Colors.grey[200],
                                    hintText: 'Search Files',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(controller.getCurrentPath,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                        )),
                                  )
                                ],
                              ),
                            ),
                          ],
                        )),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2, vertical: 0),
                        itemCount: entities.length,
                        itemBuilder: (context, index) {
                          FileSystemEntity entity = entities[index];

                          if (currentfolderent != null && refresh) if (FileManager
                              .isDirectory(currentfolderent!)) {
                            try {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                refresh = false;

                                controller.openDirectory(currentfolderent!);
                              });
                            } catch (e) {
                              alert(context, "Enable to open this folder");
                            }
                          }

                          return Ink(
                            color: Colors.transparent,
                            child: ListTile(
                              trailing: PopupMenuButton(
                                  itemBuilder: (BuildContext context) {
                                    return <PopupMenuEntry>[
                                      PopupMenuItem(
                                        value: 'button1',
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(Icons.delete, color: bluea),
                                            const Text("Delete"),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'button2',
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(Icons.rotate_left_sharp,
                                                color: bluea),
                                            const Text("Rename"),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'button3',
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(Icons.move_down_rounded,
                                                color: Colors.black),
                                            const Text("Move"),
                                          ],
                                        ),
                                      ),
                                      if (!FileManager.isDirectory(entity)) ...[
                                        PopupMenuItem(
                                          value: 'button4',
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Icon(Icons.info_outline,
                                                  color: Colors.black),
                                              const Text("info"),
                                            ],
                                          ),
                                        ),
                                      ]
                                    ];
                                  },
                                  onSelected: (value) async {
                                    FocusScope.of(context).unfocus();
                                    switch (value) {
                                      case 'button1':
                                        delete(context, entity);

                                        break;
                                      case 'button2':
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            TextEditingController
                                                renameController =
                                                TextEditingController();
                                            return AlertDialog(
                                              title: Text(
                                                  "Rename ${FileManager.basename(entity)}"),
                                              content: Form(
                                                key: renamekey,
                                                child: TextFormField(
                                                  controller: renameController,
                                                  validator: (value) {
                                                    return value == null
                                                        ? "empty"
                                                        : (value == "" ||
                                                                value.isEmpty)
                                                            ? "empty"
                                                            : null;
                                                  },
                                                  onChanged: (v) => renamekey
                                                      .currentState!
                                                      .validate(),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("Cancel"),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    if (renamekey.currentState!
                                                        .validate()) {
                                                      await rename(
                                                          context,
                                                          renameController.text,
                                                          entity);
                                                    }
                                                  },
                                                  child: const Text("Rename"),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        break;
                                      case 'button3':
                                        selectedFile = entity;
                                        setState(() {
                                          isMoving = true;
                                        });
                                        break;
                                      case 'button4':
                                        entityde(context, entity);
                                        break;
                                    }
                                  },
                                  child: const Icon(Icons.more_vert)),
                              leading: FileManager.isFile(entity)
                                  ? Card(
                                      color: bluec,
                                      elevation: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.asset(
                                            "assets/icons8-copy-96.png"),
                                      ),
                                    )
                                  : Card(
                                      color: bluea,
                                      elevation: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.asset(
                                            "assets/icons8-folder-1000.png"),
                                      ),
                                    ),
                              title: Text(
                                FileManager.basename(
                                  entity,
                                  showFileExtension: true,
                                ),
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: subtitle(
                                entity,
                              ),
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                if (FileManager.isDirectory(entity)) {
                                  try {
                                    currentfolderent = entity;
                                    controller.openDirectory(entity);
                                  } catch (e) {
                                    alert(
                                        context, "Enable to open this folder");
                                  }
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FutureBuilder<bool>(
                future: storagePermission(false), // async work
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot0) {
                  switch (snapshot0.connectionState) {
                    case ConnectionState.waiting:
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FloatingActionButton.extended(
                            onPressed: () async {
                              storagePermission(true);
                            },
                            label: const Text("Request File Access Permission"),
                          ),
                          SizedBox(
                            height: 10,
                          )
                        ],
                      );

                    default:
                      if (snapshot0.hasData) {
                        gotPermission = snapshot0.data!;

                        if (snapshot0.hasError || !snapshot0.data!)
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              FloatingActionButton.extended(
                                onPressed: () async {
                                  await storagePermission(true);
                                },
                                label: const Text(
                                    "Request File Access Permission"),
                              ),
                              SizedBox(
                                height: 10,
                              )
                            ],
                          );
                        else {
                          return Container();
                        }
                      }
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FloatingActionButton.extended(
                            heroTag: "a1",
                            onPressed: () async {
                              await storagePermission(true);
                            },
                            label: const Text("Request File Access Permission"),
                          ),
                          SizedBox(
                            height: 10,
                          )
                        ],
                      );
                  }
                },
              ),
              FloatingActionButton.extended(
                onPressed: () async {
                  String? encodeQueryParameters(Map<String, String> params) {
                    return params.entries
                        .map((MapEntry<String, String> e) =>
                            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                        .join('&');
                  }

                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'mouhamad3456.mbz@gmail.com',
                    query: encodeQueryParameters(<String, String>{
                      'subject': 'Feedback (File Manager)',
                    }),
                  );

                  launchUrl(emailLaunchUri);
                },
                label: const Text("Leave Feedback"),
              )
            ],
          ),
        ),
      );
    });
  }

  final renamekey = GlobalKey<FormState>();
  Future<void> getPermission() async {
    await storagePermission(true);

    // if (await Permission.storage.request().isGranted) {
    //   setState(() {
    //     gotPermission = true;
    //   });
    // } else {
    //   await Permission.storage.request().then((value) {
    //     if (value.isGranted) {
    //       setState(() async {
    //         gotPermission = true;
    //
    //       });
    //     }
    //   });
    // }
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      actions: [
        Visibility(
            visible: isMoving,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  selectedFile.rename(
                      "${controller.getCurrentPath}/${FileManager.basename(selectedFile)}");
                  setState(() {
                    refresh = true;
                    isMoving = false;
                  });

                  if (currentfolderent !=
                      null) if (FileManager.isDirectory(currentfolderent!)) {
                    try {
                      controller.openDirectory(currentfolderent!);
                    } catch (e) {
                      alert(context, "Enable to open this folder");
                    }
                  }
                },
                child: Row(
                  children: const [
                    Text("Move here ",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    Icon(Icons.paste),
                  ],
                ),
              ),
            )),
        Visibility(
          visible: !isMoving,
          child: PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry>[
                  PopupMenuItem(
                    value: 'button1',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.file_present,
                          color: blueb,
                        ),
                        const Text("New File     "),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'button2',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.folder_open, color: bluea),
                        const Text("New Folder"),
                      ],
                    ),
                  ),
                ];
              },
              onSelected: (value) {
                FocusScope.of(context).unfocus();
                switch (value) {
                  case 'button1':
                    createFile(context, controller.getCurrentPath);

                    break;
                  case 'button2':
                    createFolder(context);

                    break;
                }
              },
              child: const Icon(Icons.create_new_folder_outlined)),
        ),
        Visibility(
          visible: !isMoving,
          child: IconButton(
            onPressed: () => sort(context),
            icon: const Icon(Icons.sort_rounded),
          ),
        ),
      ],
      title: const Text("File Manager",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () async {
          FocusScope.of(context).unfocus();

          await controller.goToParentDirectory().then((value) {
            currentfolderent = controller.getCurrentDirectory;
            if (controller.getCurrentPath == "/storage/emulated/0") {
              fullScreen = false;
              setState(() {});
            }
          });
        },
      ),
    );
  }

  Future<bool> storagePermission(bool re) async {
    final DeviceInfoPlugin info =
        DeviceInfoPlugin(); // import 'package:device_info_plus/device_info_plus.dart';
    final AndroidDeviceInfo androidInfo = await info.androidInfo;
    debugPrint('releaseVersion : ${androidInfo.version.release}');
    final double androidVersion = double.parse(androidInfo.version.release);
    bool havePermission = false;

    if (androidVersion >= 13) {
      final request = await [
        Permission.videos,
        Permission.photos,
        //..... as needed
      ].request(); //import 'package:permission_handler/permission_handler.dart';

      gotPermission = havePermission =
          request.values.every((status) => status == PermissionStatus.granted);
      if (re) setState(() {});
    } else {
      final status = await Permission.storage.status.isGranted;
      if (!status) {
        await Permission.storage.request().then((value) {
          print("aaaaaaaaaaaaaaaaaaaaa");
          Navigator.of(context).pushAndRemoveUntil(
              new MaterialPageRoute(
                  builder: (BuildContext cont) =>
                      MyHomePage(title: "File Manager")),
              (route) => false);
        });
      }

      final status1 = await Permission.storage.request();

      gotPermission = havePermission = status1.isGranted;

      if (re) setState(() {});
    }

    if (!havePermission) {
      // if no permission then open app-setting
      // await openAppSettings();
    }

    return havePermission;
  }
}

Future<void> rename(BuildContext? context, String renameController,
    FileSystemEntity entity) async {
  await entity
      .rename(
    "${controller.getCurrentPath}/${renameController.trim()}",
  )
      .then((value) {
    if (!testingmode) {
      Navigator.pop(context!);
      refreshhome();
      if (currentfolderent !=
          null) if (FileManager.isDirectory(currentfolderent!)) {
        try {
          controller.openDirectory(currentfolderent!);
        } catch (e) {
          alert(context, "Enable to open this folder");
        }
      }
    }
  });
}

Future<void> delete(BuildContext? context, FileSystemEntity entity) async {
  if (FileManager.isDirectory(entity)) {
    await entity.delete(recursive: true).then((value) {
      if (!testingmode) {
        refreshhome();
        if (currentfolderent !=
            null) if (FileManager.isDirectory(currentfolderent!)) {
          try {
            controller.openDirectory(currentfolderent!);
          } catch (e) {
            alert(context!, "Enable to open this folder");
          }
        }
      }
    });
  } else {
    await entity.delete().then((value) {
      if (!testingmode) {
        refreshhome();
        if (currentfolderent !=
            null) if (FileManager.isDirectory(currentfolderent!)) {
          try {
            controller.openDirectory(currentfolderent!);
          } catch (e) {
            alert(context!, "Enable to open this folder");
          }
        }
      }
    });
  }
}
