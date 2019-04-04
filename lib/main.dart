import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

main() => runApp(MaterialApp(home: App(), title: 'Biology dive'));

class App extends StatefulWidget {
  MState createState() => MState();
}

class MState extends State<App> with SingleTickerProviderStateMixin {
  Map data;
  List<String> history = [];
  String currentId = 'menu';
  Offset translate = Offset.zero;
  Offset startTranslate;
  Offset zoomStart;
  double baseZoom = 1;
  double zoom = 1;
  double botOffset = 380;
  double opacity = 1;
  AnimationController transCtrl;
  Timer timer;
  int scrollDirection = 1;
  var scrlCtrl = ScrollController();
  Map get current => data[currentId];
  get width => MediaQuery.of(context).size.width;
  get th => Theme.of(context);
  get tt => th.textTheme;
  sb(size, [child]) => SizedBox(width: size, height: size, child: child);
  img(name, [size]) => sb(size, FlareActor(name, animation: 'idle'));
  pad8(child) => Padding(padding: EdgeInsets.all(8), child: child);
  toggleBackdrop() {
    setState(() => botOffset = botOffset == 380 ? 16 : 380);
  }

  loadData() {
    DefaultAssetBundle.of(context)
        .loadString('data.json')
        .then((s) => setState(() => data = json.decode(s)));
  }

  goBack() {
    goTo(history.last, true);
  }

  goTo(id, [isReturn = false]) {
    setState(() {
      if (isReturn) {
        history.removeLast();
      } else if (id != currentId) {
        history.add(currentId);
      }
      currentId = id;
      baseZoom = 1;
      zoom = 1;
      opacity = 1;
      translate = Offset.zero;
      botOffset = 380;
    });
  }

  void initState() {
    super.initState();
    loadData();
    transCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    timer = Timer.periodic(Duration(seconds: 5), (t) {
      if (scrlCtrl.hasClients) {
        double offset = scrlCtrl.offset + 500 * scrollDirection;
        if (offset > scrlCtrl.position.maxScrollExtent || offset < 0) {
          scrollDirection *= -1;
          offset = max(0, min(scrlCtrl.position.maxScrollExtent, offset));
        }
        scrlCtrl.animateTo(
          offset,
          duration: Duration(seconds: 10),
          curve: Curves.linear,
        );
      }
    });
  }

  @override
  Widget build(c) {
    return WillPopScope(
      onWillPop: () async {
        if (history.isEmpty) {
          return true;
        }
        goBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: Color(0),
        body: data == null
            ? Container()
            : Stack(children: [
                Positioned.fill(
                  child: Image.asset('bcg.jpg', fit: BoxFit.cover),
                ),
                preview,
                hints,
                header,
                backdrop,
                backButton,
              ]),
      ),
    );
  }

  Widget get backButton => history.isEmpty
      ? Container()
      : SafeArea(
          child: pad8(
            GestureDetector(
              onTap: goBack,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  img(data[history.last]['img'], 40.0),
                  Icon(Icons.arrow_back, color: Colors.white),
                ],
              ),
            ),
          ),
        );
  Widget get hints => Positioned(
        left: 0,
        right: 0,
        bottom: 56,
        child: SizedBox(
          height: 100,
          child: ListView(
            controller: scrlCtrl,
            scrollDirection: Axis.horizontal,
            children: data.keys.map(smallCard).toList().sublist(4),
          ),
        ),
      );
  Widget get header => Positioned(
        top: 16,
        left: 0,
        right: 0,
        child: SafeArea(
          child: Text(
            'Biology dive',
            style: th.primaryTextTheme.title,
            textAlign: TextAlign.center,
          ),
        ),
      );
  Widget get preview => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onScaleStart: (d) {
          baseZoom = zoom;
          startTranslate = translate;
          zoomStart = d.focalPoint;
        },
        onScaleUpdate: (d) {
          setState(() {
            zoom = d.scale * baseZoom;
            translate = startTranslate + d.focalPoint - zoomStart;
          });
        },
        child: Center(
          child: Transform.translate(
            offset: translate,
            child: Transform.scale(
              scale: zoom,
              child: sb(
                width,
                Stack(children: [cell(current, width, 2)]),
              ),
            ),
          ),
        ),
      );
  Widget get backdrop => AnimatedPositioned(
        duration: Duration(milliseconds: 300),
        bottom: -botOffset,
        left: 0,
        right: 0,
        child: GestureDetector(
          onVerticalDragUpdate: (d) {
            if ((d.primaryDelta > 10 && botOffset == 16) ||
                (d.primaryDelta < -10 && botOffset == 380)) {
              toggleBackdrop();
            }
          },
          onTap: toggleBackdrop,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            height: 430,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(current['name'], style: tt.title),
                sb(8.0),
                Text(current['desc'], maxLines: 14),
                sb(8.0),
                Text('See also:', style: tt.subtitle),
                SizedBox(
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: (current["ref"] as List).map(smallCard).toList(),
                  ),
                ),
                sb(8.0),
                FittedBox(child: Text('More: ${current['source']}')),
              ],
            ),
          ),
        ),
      );
  Widget cell(childData, width, lvl) {
    var id = childData['id'];
    var left = childData['left'];
    var top = childData['top'];
    var size = childData['size'];
    var children = (data[id]['children'] as List)
        .map((childData) => cell(childData, size * width, lvl - 1));
    var child = Opacity(
      opacity: opacity,
      child: Stack(
        children: [img(data[id]['img'])]..addAll(children),
      ),
    );
    onTap() {
      if (id != currentId) {
        if (currentId == 'menu') {
          return goTo(id);
        }
        var x = -(left - 0.5 + size / 2) * width / size;
        var y = -(top - 0.5 + size / 2) * width / size;
        baseZoom = zoom;
        startTranslate = translate;
        var listener = () {
          setState(() {
            var t = transCtrl.value;
            zoom = baseZoom + (1 / size - baseZoom) * t;
            translate = startTranslate + (Offset(x, y) - startTranslate) * t;
            opacity = 1 - pow(t, 2);
            botOffset = 380;
          });
        };
        transCtrl.addListener(listener);
        transCtrl.forward(from: 0).then((_) {
          transCtrl.removeListener(listener);
          goTo(id);
        });
      }
    }

    return Positioned(
      key: Key('$id$top$left'),
      top: width * top,
      left: width * left,
      width: width * size,
      height: width * size,
      child: lvl > 0
          ? GestureDetector(
              child: child,
              onTap: onTap,
            )
          : child,
    );
  }

  Widget smallCard(id) => Opacity(
        opacity: 0.8,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () => goTo(id),
            child: pad8(
              Column(children: [
                img(data[id]['img'], 56.0),
                Flexible(child: Text(data[id]['name'])),
              ]),
            ),
          ),
        ),
      );
}
