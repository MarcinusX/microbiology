import 'dart:convert';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: App(), title: 'Microbiology 101'));

class App extends StatefulWidget {
  MState createState() => MState();
}

class MState extends State<App> {
  Map map;
  String currentId = 'plant_cell';
  Offset translate = Offset.zero;
  Offset startTranslate;
  Offset zoomStart;
  double baseZoom = 1;
  double zoom = 1;
  double botOffset = 400;

  Map get current => map[currentId];

  get width => MediaQuery.of(context).size.width;

  get tt => Theme.of(context).textTheme;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Microbiology 101')),
      drawer: map == null ? null : drawer(),
      backgroundColor: Color(0xFFB3E5FC),
      body: map == null
          ? Container()
          : Stack(
              children: [
                buildMainPreview(),
                backdrop(),
              ],
            ),
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

  Widget buildOrganella(Map childData) {
    var id = childData['id'];
    return Positioned(
      key: Key('$id${childData["top"]}${childData["left"]}'),
      top: width * (childData['top']),
      left: width * (childData['left']),
      width: width * (childData['size']),
      height: width * (childData['size']),
      child: GestureDetector(
        onTap: () => goTo(id),
        child: img(map[id]['img']),
      ),
    );
  }

  Widget relatedRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: (current["ref"] as List).map((id) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => goTo(id),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(children: <Widget>[
                img(map[id]['img'], 60.0),
                Text(map[id]['name']),
              ]),
            ),
          ),
        );
      }).toList(),
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
              relatedRow(),
              sb(16.0),
              FittedBox(child: Text('Source: ${current['source']}')),
            ],
          ),
        ),
      ),
    );
  }

  Widget drawer() {
    return Drawer(
      child: Container(
        color: Color(0xFFB3E5FC),
        child: ListView(
          children: [
            Text('Catalog:', style: tt.display1, textAlign: TextAlign.center),
            Divider(),
          ]..addAll(map.values.map(drawerItem)),
        ),
      ),
    );
  }

  Widget drawerItem(Map cell) {
    return ListTile(
      leading: img(cell['img'], 40.0),
      title: Text(cell['name']),
      onTap: () {
        goTo(cell['id']);
        Navigator.of(context).pop();
      },
    );
  }
}
