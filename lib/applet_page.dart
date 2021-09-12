import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'lazy_scroll_physics.dart';
import 'lazyhtmlcore/src/core_html_widget.dart';
import 'lazyhtmlcore/src/widgets/button.dart';
import 'main.dart';

class AppletPage extends StatefulWidget {
  final String url;

  AppletPage(this.url);

  @override
  _AppletPageState createState() => _AppletPageState();
}

class _AppletPageState extends State<AppletPage> {
  String? html = "";
  String localUrl = '';

  @override
  void initState() {
    eventBus.on<String>().listen((event) async {
      navigate(widget.url);
    });
    navigate(widget.url);
    super.initState();
  }

  navigate(String url) {
    localUrl = url;
    print(url);
    if (url.trim().startsWith('http')) {
      Dio().get(localUrl).then((value) {
        setState(() {
          html = value.data;
          print(html);
        });
      });
    } else {
      setState(() {
        html = url;
      });
    }
  }

  String getTitle(String html) {
    if (!html.contains('<title>') || !html.contains('</title>')) return '';
    return html.split('<title>')[1].split('</title>')[0].replaceAll('\n', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTitle(html!)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          physics: LazyScrollPhysics(),
          children: [
            AppletWidget(
              html!,
              onTapUrl: (url) {
                if (url.contains(';')) {
                  url.split(';').forEach((s) {
                    com(s);
                  });
                } else {
                  com(url);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  com(String url) {
    if (url.contains('#back')) {
      Navigator.of(context).maybePop();
      return;
    }
    if (url.contains('#home')) {
      //toHome(context);
      return;
    }
    if (url.startsWith('toast://')) {
      showToast(url.substring(8));
      return;
    }
    if (url.startsWith('copy://')) {
      Clipboard.setData(
        ClipboardData(text: url.substring(7)),
      );
      showToast('复制成功');
      return;
    }
    if (url.contains('lazy://')) {
      loadLazyTodoUrl(context, url.substring(7));
      return;
    }
    if (url.contains('#')) {
      //turnToPage(context, AppletPage(url));
      //} else {
      navigate(url);
    }
  }
}

loadLazyTodoUrl(BuildContext context, String url) async {
  String lowCaseUrl = url.toLowerCase();
  print(lowCaseUrl);
  if (lowCaseUrl.startsWith('#back')) {
    Navigator.of(context).maybePop();
    return;
  }
  if (lowCaseUrl.startsWith('#home')) {
    //toHome(context);
    return;
  }
  if (lowCaseUrl.startsWith('toast://')) {
    showToast(url.substring(8));
    return;
  }
  if (lowCaseUrl.contains('#starttask')) {
    // if (mTimer!.isRunning()) {
    //   showToast('你正在计时！');
    //   return;
    // }
    // if (lowCaseUrl.contains('#starttask:')) {
    //   mTimer!.name = url.substring(url.indexOf('#starttask:') + 11).trim();
    //   toHome(context);
    //   startFreeTiming(context);
    // } else {
    //   tapStudyButton(context);
    // }
    return;
  }
  if (lowCaseUrl.contains('#starttomato')) {
    // if (mTimer!.isRunning()) {
    //   showToast('你正在计时！');
    //   return;
    // }
    // if (lowCaseUrl.contains('#starttomato:')) {
    //   toHome(context);
    //   tapTomatoButton(context,
    //       oText: url.substring(url.indexOf('#starttomato:') + 13).trim());
    // } else {
    //   tapTomatoButton(context);
    // }
    return;
  }
  if (lowCaseUrl.startsWith('copy://')) {
    Clipboard.setData(
      ClipboardData(text: url.substring(7)),
    );
    showToast('复制成功');
    return;
  }
  if (lowCaseUrl.startsWith('lazy://')) {
    loadLazyTodoUrl(context, url.substring(7));
    return;
  }
  //http://oboard.ml/lazy/index.html?studyroom=11778
  if (lowCaseUrl.contains('studyroom=')) {
    //   var info = await StudyRoomNet().get(int.parse(url.split('studyroom=')[1]));
    //   turnToPageStable(StudyRoomDetailPage(info));
  } else if (lowCaseUrl.contains('app=')) {
    //   String info = url.split('app=')[1];
    //   turnToPageStable(AppletPage(info));
  } else if (lowCaseUrl.contains('user=')) {
    //   var info = int.parse(url.split('user=')[1]);
    //   turnToPageStable((mUserInfo == null)
    //       ? LoginPage()
    //       : UserPage(mUser: SimpleUserInfo()..userId = info));
  } else if (lowCaseUrl.contains('todo=')) {
    // String info =
    //     url.split('todo=')[1].replaceAll(' ', '').replaceAll('\n', '');
    // info = utf8.decode(base64Decode(info));
    // // print(info);

    // List<String> lines = info.split('|||');
    // late TodoListInfo l;
    // lines.forEach((s) {
    //   if (s.startsWith('TodoList:')) {
    //     l = TodoListInfo()..name = s.substring(9);
    //   } else if (s.startsWith('Todo:')) {
    //     if (l.list == null) l.list = [];
    //     l.list!.add(TodoItemInfo()..name = s.substring(5));
    //   }
    // });
    // showDialog<Null>(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       title: Text('添加待办列表"${l.name}"'),
    //       content: SizedBox(
    //         height: homeScreenSize.height / 2,
    //         width: homeScreenSize.width / 2,
    //         child: ListView.builder(
    //           physics: LazyScrollPhysics(),
    //           itemCount: lines.length - 2,
    //           itemBuilder: (BuildContext context, int index) {
    //             return Padding(
    //               padding: const EdgeInsets.all(8.0),
    //               child: Text(l.list![index].name!),
    //             );
    //           },
    //         ),
    //       ),
    //       actions: <Widget>[
    //         LazyButton(
    //             child: Text('取消'),
    //             onPressed: () {
    //               Navigator.of(context).maybePop();
    //             }),
    //         LazyButton(
    //           child: Text('确定'),
    //           onPressed: () async {
    //             Navigator.of(context).maybePop();
    //             showToast('成功添加待办列表');
    //           },
    //         ),
    //       ],
    //     );
    //   },
    // );
  } else {
//啥也不是
    launch(url, forceWebView: false, forceSafariVC: false);
  }
}
