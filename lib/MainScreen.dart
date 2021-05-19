import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:ui' as ui;
import 'package:permission_handler/permission_handler.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  GlobalKey _globalKey = new GlobalKey();
  List<String> hash = [];
  List<String> image = [];
  List<String> quotes = [];
  List<String> author = [];
  String url = "https://source.unsplash.com/random/720x1560";
  int item = 1;
  List<bool> liked = [];
  Response response, response2;
  var json, json2;

  @override
  void initState() {
    checkPermission();
    getImage();
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      getImage();
    });
  }

  checkPermission() async {
    var stat = await Permission.storage.request();
    if (stat.isDenied) {
      final snackBar = SnackBar(
        content: Text('Permission required to save quotes!'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      return;
    }
  }

  _capturePng() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData.buffer.asUint8List();
      var bs64 = base64Encode(pngBytes);
      print(pngBytes);
      print(bs64);
      setState(() {});
      final File myFile = File('/storage/emulated/0/Download/$item.png');
      myFile.writeAsBytes(pngBytes);
      final snackBar = SnackBar(
        content: Text('Quote Saved in Downloads Folder! ❤'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      print(e);
    }
  }

  getImage() async {
    response = await http.get(Uri.parse(
        "https://api.unsplash.com/photos/random/?client_id=BEPWuzVzKJ1I6nMmIskWGvT4O543qsWFTEDbCVYLb7U"));
    try {
      json = jsonDecode(response.body);
    } catch (FormatException) {
      json = {
        'blur_hash': 'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
        'urls': {
          'regular': url,
        },
      };
      setState(() {
        url = url.split('?r')[0] +
            '?r=' +
            DateTime.now().millisecondsSinceEpoch.toString();
      });
    }
    response2 = await http.get(
        Uri.parse(
            "https://api.forismatic.com/api/1.0/?method=getQuote&format=json&key=457653&lang=en"),
        headers: {
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8"
        });
    json2 = jsonDecode(response2.body);
    setState(() {
      if (image.contains(json['urls']['regular']) ||
          quotes.contains(json2['quoteText'])) {
        getImage();
        return;
      }
      hash.add(json["blur_hash"]);
      image.add(json['urls']['regular']);
      quotes.add(json2['quoteText']);
      author.add(json2['quoteAuthor']);
      liked.add(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: 0);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: FutureBuilder(
          future: Future.delayed(Duration(milliseconds: 2000), () => true),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(
                child: Text(
                  'Loading',
                  style: TextStyle(
                    fontSize: 22,
                    color: Color(0xFF000000),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            else
              return Stack(
                children: [
                  RepaintBoundary(
                    key: _globalKey,
                    child: PageView.builder(
                      scrollDirection: Axis.vertical,
                      controller: controller,
                      onPageChanged: (value) {
                        getImage();
                        item = value + 1;
                      },
                      itemBuilder: (BuildContext context, int index) {
                        if (hash != null)
                          return QuoteTile(
                            hash: hash[index],
                            url: image[index],
                            quote: quotes[index].replaceAll("\"", "'"),
                            author: author[index],
                          );
                        else
                          return QuoteTile(
                              hash: "LbK_LGxu?bIUazxt-pRj_Nt7oeRj",
                              url: image[index]);
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width / 1,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(
                            35,
                          ),
                          topRight: Radius.circular(
                            30,
                          ),
                        ),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: Icon(
                              liked[item - 1]
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: liked[item - 1]
                                  ? Colors.redAccent
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                liked[item - 1] = true;
                              });
                              _capturePng();
                            },
                          ),
                          SizedBox(),
                          IconButton(
                            icon: Icon(
                              Icons.info_outline,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              final snackBar = SnackBar(
                                content: Text('Made By Aditya Tajanpure!'),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 25,
                    left: MediaQuery.of(context).size.width / 2 - 35,
                    child: InkWell(
                      onTap: () {
                        controller.animateToPage(item,
                            duration: Duration(seconds: 1),
                            curve: Curves.easeInToLinear);
                      },
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(20)),
                        child: Icon(
                          Icons.format_quote_sharp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
          },
        ));
  }
}

class QuoteTile extends StatelessWidget {
  const QuoteTile({
    Key key,
    @required this.hash,
    @required this.url,
    this.quote,
    this.author,
  }) : super(key: key);

  final String hash;
  final String url;
  final String quote, author;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Container(
            child: Stack(
              children: [
                BlurHash(
                  hash: hash,
                  key: ValueKey(url),
                  image: url,
                  imageFit: BoxFit.cover,
                  fadeInCurve: Curves.easeIn,
                  fadeOutCurve: Curves.easeOut,
                  fadeInDuration: Duration(seconds: 2),
                  fadeOutDuration: Duration(seconds: 2),
                ),
                Container(
                  color: Colors.black.withOpacity(0.4),
                )
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$quote",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 22,
                      color: Color(0xFFfFFFFF),
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "-- $author --",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 21,
                      color: Color(0xFFf3f3f3),
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
