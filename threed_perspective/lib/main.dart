import 'package:flutter/material.dart';
import 'package:threed_perspective/PageViewHolder.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const TDPers());
}

class TDPers extends StatelessWidget {
  const TDPers({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(26, 13, 19, 94)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter 3DPERSPECTIVE '),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late PageViewHolder holder;
  late PageController _controller;
  double fraction =
      0.5; //fractionu kullanarak bir resim ekranın ortasindayken once ki ve sonra ki resimlerin 0.5 ise yarısı gösterilsin demek.1 olursa onceki ve sornaki fotonun hıcbırı gorunmez.page view ile iletişim kurar
  @override
  void initState() {
    // TODO: implement initStat
    super.initState();
    holder = PageViewHolder(value: 2.0);

    _controller = PageController(initialPage: 2, viewportFraction: fraction);
    _controller.addListener(() {
      holder?.setValue(_controller.page);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Container(
        color: Colors.white,
        child: Center(
          child: AspectRatio(
            aspectRatio: 1,
            child: ChangeNotifierProvider<PageViewHolder>.value(
              value: holder,
              child: PageView.builder(
                controller: _controller,
                itemCount: 12,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return MyPage(
                    number: index.toDouble(),
                    fraction: fraction,
                  );
                },
              ),
            ),
          ),
        ),
      )),
    ));
  }
}

class MyPage extends StatelessWidget {
  final double number;
  final double fraction;
  const MyPage({required this.number, required this.fraction});

  @override
  Widget build(BuildContext context) {
    double? value = Provider.of<PageViewHolder>(context).value;

    double diff = 0.0;
    if (value != null) {
      diff = number - value;
    }
    final Matrix4 pvMatrix = Matrix4.identity()
      ..setEntry(3, 3,
          1) //burada ki 1 sayısı resimlerin yakınlaşma seviyesini gösterir
      ..setEntry(1, 1, fraction)
      ..setEntry(3, 0, 0.004 * -diff);
    final Matrix4 shadowMatrix = Matrix4.identity()
      ..setEntry(3, 3,
          1 / 6) //burada ki 1 sayısı resimlerin yakınlaşma seviyesini gösterir
      ..setEntry(1, 1, -0.004)
      ..setEntry(3, 0, 0.002 * -diff);
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        if (diff <= 1.0 && diff >= -1.0) ...[
          AnimatedOpacity(
            duration: Duration(milliseconds: 100),
            opacity: 1 - diff.abs(), //resimler saga sola kayaken ki opacityleri
            child: Transform(
              transform: shadowMatrix,
              alignment: FractionalOffset.bottomCenter,
              child: Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 10.0,
                    spreadRadius: 1.0,
                  ),
                ]),
              ),
            ),
          ),
        ],
        Transform(
          transform: pvMatrix,
          alignment: FractionalOffset.center,
          child: Container(
            child: Image.asset(
              "Assets/imag_${number.toInt() + 1}.jpg",
              fit: BoxFit.fill,
            ),
          ),
        )
      ],
    );
  }
}
