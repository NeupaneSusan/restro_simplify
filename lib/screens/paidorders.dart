// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaidOrders extends StatefulWidget {
  const PaidOrders({Key? key, this.data}) : super(key: key);

  final data;

  @override
  _PaidOrdersState createState() => _PaidOrdersState();
}

class _PaidOrdersState extends State<PaidOrders> {
  List? orders = [];
  int count = 0;

  final url = "http://192.168.1.1/restroms/api";

  Future<String> getOrderData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.get("userid");

    final response =
        await http.get(Uri.parse(url + "/tableOrders/getPaidOrders/$id"));

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      if (mounted) {
        setState(() {
          orders = jsonData['data'];
          count = orders!.length;
        });
      }

      return "success";
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    getOrderData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Set landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white10,
        leading: IconButton(icon: const Icon(Icons.arrow_back,color: Colors.blueGrey,),onPressed: (){
          Navigator.pop(context);
        },),
      ),
      body: count == 0
          ? const Center(
              child: Center(
                child: Text("No Orders Yet!"),
              ),
            )
          : ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Paid Orders : " + count.toString(),
                    style: const TextStyle(
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
                GridView.count(
                  childAspectRatio: 0.8,
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
                  crossAxisCount: 7,
                  children: orders!.map((data) {
                    return Card(
                      color: Colors.green,
                      child: InkWell(
                        onTap: () {
                          Fluttertoast.showToast(
                              msg: "Bill already paid",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              textColor: Colors.white,
                              backgroundColor: Colors.green);
                        },
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 5.0),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: SizedBox(
                                    width: 40.0,
                                    child: Image.asset(
                                      "assets/table.png",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  data['table_name'],
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Text(
                                    data['settled_time'],
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 13),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Card(
                                      color: Colors.lightGreen,
                                      elevation: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Rs. " + data['net_amount'],
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Text(
                                      "${data['payment_method']}",
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}