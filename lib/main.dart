import 'dart:async';
import 'dart:convert';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: App(), title: 'Microbiology 101'));

class App extends StatefulWidget {
  MState createState() => MState();
}

class MState extends State<App> with TickerProviderStateMixin {
  Map map;
  String currentId = 'plant_cell';
  Offset translate = Offset.zero;
  Offset startTranslate;
  Offset zoomStart;
  double baseZoom = 1;
  double zoom = 1;
  double botOffset = 400;
  AnimationController transCtrl;
  ScrollController scrlCtrl = ScrollController();
  Timer timer;
  int scrollDirection = 1;

  Map get current => map[currentId];

  get width => MediaQuery.of(context).size.width;

  get th => Theme.of(context);

  get tt => th.textTheme;

  sb(size, [child]) => SizedBox(width: size, height: size, child: child);

  img(name, [size]) => sb(size, FlareActor(name, animation: 'idle'));

  toggleBackdrop() => setState(() => botOffset = botOffset == 400 ? 16 : 400);

  loadData() {
    DefaultAssetBundle.of(context)
        .loadString("assets/organellas.json")
        .then((s) => setState(() => map = json.decode(s)));
  }

  goTo(id) {
    setState(() {
      currentId = id;
      baseZoom = 1;
      zoom = 1;
      translate = Offset.zero;
      botOffset = 400;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
    transCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    transCtrl.addListener(() {});
    timer = Timer.periodic(Duration(seconds: 5), (t) {
      if (scrlCtrl.hasClients) {
        double offset = scrlCtrl.offset + 250 * scrollDirection;
        if (offset > scrlCtrl.position.maxScrollExtent || offset < 0)
          scrollDirection *= -1;

        scrlCtrl.animateTo(
          offset,
          duration: Duration(seconds: 5),
          curve: Curves.linear,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Image.asset(
            'assets/background.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
          backgroundColor: Color(0),
          body: map == null
              ? Container()
              : Stack(
                  children: [
                    buildMainPreview(),
                    backdrop(),
                    hints(),
                  ],
                ),
        ),
      ],
    );
  }

  Widget hints() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(16),
          child: SafeArea(
            bottom: false,
            child: Text(
              'Microbiology 101',
              style: th.primaryTextTheme.title,
            ),
          ),
        ),
        SizedBox(
          height: 80,
          child: ListView(
            controller: scrlCtrl,
            scrollDirection: Axis.horizontal,
            children: map.keys.map(smallCard).toList(),
          ),
        ),
      ],
    );
  }

  Widget buildMainPreview() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onScaleStart: (det) {
        startTranslate = translate;
        zoomStart = det.focalPoint;
      },
      onScaleUpdate: (det) {
        setState(() {
          zoom = det.scale * baseZoom;
          translate = startTranslate + det.focalPoint - zoomStart;
        });
      },
      onScaleEnd: (det) => baseZoom = zoom,
      child: Center(
        child: Transform.translate(
          offset: translate,
          child: Transform.scale(
            scale: zoom,
            child: SizedBox(
              height: width,
              child: Stack(
                children: [buildOrganella(current)]
                  ..addAll((current['children'] as List).map(buildOrganella)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildOrganella(childData) {
    var id = childData['id'];
    var left = childData['left'];
    var top = childData['top'];
    var size = childData['size'];
    return Positioned(
      key: Key('$id$top$left'),
      top: width * top,
      left: width * left,
      width: width * size,
      height: width * size,
      child: GestureDetector(
        child: img(map[id]['img']),
        onTap: () {
          var x = -(left - 0.5 + size / 2) * width / size;
          var y = -(top - 0.5 + size / 2) * width / size;
          Animation animation =
              Tween(begin: translate, end: Offset(x, y)).animate(transCtrl);
          Animation zoomAnimation =
              Tween(begin: zoom, end: 1 / size).animate(transCtrl);
          var listener = () {
            setState(() {
              baseZoom = zoomAnimation.value;
              zoom = zoomAnimation.value;
              translate = animation.value;
              botOffset = 400;
            });
          };
          transCtrl.addListener(listener);
          transCtrl.forward(from: 0).then((_) {
            transCtrl.removeListener(listener);
            goTo(id);
          });
        },
      ),
    );
  }

  Widget smallCard(id) {
    return Opacity(
      opacity: 0.8,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => goTo(id),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(children: <Widget>[
              img(map[id]['img'], 40.0),
              Text(map[id]['name']),
            ]),
          ),
        ),
      ),
    );
  }

  Widget backdrop() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      bottom: -botOffset,
      left: 0,
      right: 0,
      child: GestureDetector(
        onVerticalDragUpdate: (d) {
          if ((d.primaryDelta > 10 && botOffset == 16) ||
              (d.primaryDelta < -10 && botOffset == 400)) {
            toggleBackdrop();
          }
        },
        onTap: toggleBackdrop,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          height: 450,
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(current['name'], style: tt.title),
              sb(16.0),
              Text(current['desc'], maxLines: 12, overflow: TextOverflow.fade),
              sb(16.0),
              Text('Related:', style: tt.subtitle),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: (current["ref"] as List).map(smallCard).toList(),
              ),
              sb(16.0),
              FittedBox(child: Text('Source: ${current['source']}')),
            ],
          ),
        ),
      ),
    );
  }
}
