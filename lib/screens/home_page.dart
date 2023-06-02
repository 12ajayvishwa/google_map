import 'package:flutter/material.dart';
import 'my_location.dart';
import 'order_tracking_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void getCurrentPosition() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Location"),
      ),
      body: Center(
        child: ElevatedButton(
            // style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => OrderTrackingPage()));
            },
            child: const Text("Get Current Location")),
      ),
    );
  }
}
