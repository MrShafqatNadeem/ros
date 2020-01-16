import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(restaurant());

class restaurant extends StatefulWidget {
  @override
  _restaurantState createState() => _restaurantState();
}

class _restaurantState extends State<restaurant> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'restaurant app home',
      home: tables(),
    );
  }
}

class tables extends StatefulWidget {
  @override
  _tablesState createState() => _tablesState();
}

class _tablesState extends State<tables> {
  Map tablesdata;
  List tableid;
  List tablename;

  Future gettables() async {
    http.Response tablesresponse =
    await http.get("http://api.samacell.com/api/Hotel/GetAllTables");
    setState(() {
      tablesdata = json.decode(tablesresponse.body);
      tablesdata = tablesdata["Data"];
      tableid = tablesdata["id"];
      tablename = tablesdata["name"];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gettables();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Restaurant Ordering System'),
        ),
        body: Center(
          child: loadtables(),
        ));
  }

  Widget loadtables() {
    if (tablesdata != null) {
      return Container(
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xff34a4eb), Color(0xff0d4569)],
            ),
          ),
          child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                childAspectRatio: 2,
              ),
              scrollDirection: Axis.vertical,
              itemCount: tablename.length,
              itemBuilder: (BuildContext context, int i) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFe6e9ed),
                      border: Border.all(width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child: FlatButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                                return foodcatagory(tableid[i]);
                              }));
                        },
                        child: Text(
                          tablename[i],
                          textAlign: TextAlign.center,
                        )),
                  ),
                );
              }));
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}

class foodcatagory extends StatefulWidget {
  String tableid;

  foodcatagory(this.tableid);

  @override
  _foodcatagoryState createState() => _foodcatagoryState();
}

class _foodcatagoryState extends State<foodcatagory> {
  List foodcatagoryid;
  List foodcatagoryname;
  Map foodcatagorydata;

  Future getfoodcatagoriesinit() async {
    http.Response foodcatresponse =
    await http.get("http://api.samacell.com/api/Hotel/GetCategory");

    setState(() {
      foodcatagorydata = json.decode(foodcatresponse.body);
      foodcatagorydata = foodcatagorydata["Data"];
      foodcatagoryid = foodcatagorydata["id"];
      foodcatagoryname = foodcatagorydata["name"];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getfoodcatagoriesinit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Table ' + widget.tableid)),
      ),
      body: Center(
        child: getfoodcatagories(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => orderclass(widget.tableid)));
        },
        child: Icon(
          Icons.playlist_add_check,
        ),
        heroTag: "demoTag",
      ),
    );
  }

  Widget getfoodcatagories() {
    if (foodcatagorydata != null) {
      return Container(
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff34a4eb), Color(0xff0d4569)],
          ),
        ),
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: foodcatagoryname.length,
            itemBuilder: (BuildContext, index) {
              return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFe6e9ed),
                        border: Border.all(width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(
                            5.0) //         <--- border radius here
                        ),
                      ),
                      child: FlatButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                                return fooditems(widget.tableid,
                                    foodcatagoryid[index], foodcatagoryname[index]);
                              }));
                        },
                        child: Text(foodcatagoryname[index]),
                      )));
            }),
      );
    } else {
      return Center(
        child: Column(
          children: <Widget>[
            Text("Loading delicious foods for table : " + widget.tableid),
            CircularProgressIndicator(),
          ],
        ),
      );
    }
  }
}

class fooditems extends StatefulWidget {
  String tableid;
  String foodcatagoryid;
  String foodcatagoryname;

  fooditems(this.tableid, this.foodcatagoryid, this.foodcatagoryname);

  @override
  _fooditemsState createState() => _fooditemsState();
}

class _fooditemsState extends State<fooditems> {
  Map fooditemsdata;
  List fooditemsname;
  List fooditemsid;
  List fooditemsprice;
  String urlforfooditems;

  Future getfooditemslist() async {
    urlforfooditems = "http://api.samacell.com/api/Hotel/GetItems?CategoryId=" +
        widget.foodcatagoryid;

    http.Response getfooditemsresponse = await http.get(urlforfooditems);
    setState(() {
      fooditemsdata = json.decode(getfooditemsresponse.body);
      fooditemsdata = fooditemsdata["Data"];
      fooditemsname = fooditemsdata["name"];
      fooditemsprice = fooditemsdata["price"];
      fooditemsid = fooditemsdata["id"];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getfooditemslist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.foodcatagoryname)),
      ),
      body: Center(
        child: loadfooditems(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => orderclass(widget.tableid)));
        },
        child: Icon(
          Icons.playlist_add_check,
        ),
        heroTag: "demoTag",
      ),
    );
  }

  Widget loadfooditems() {
    if (fooditemsdata != null) {
      if (fooditemsname.length != 0) {
        return Container(
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xff34a4eb), Color(0xff0d4569)],
            ),
          ),
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: fooditemsname.length,
              itemBuilder: (BuildContext, index) {
                return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFe6e9ed),
                          border: Border.all(width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(
                              5.0) //         <--- border radius here
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                                child: Text(fooditemsname[index]),
                              ),
                            ),
                            Expanded(
                              child: Center(child: Text(fooditemsprice[index])),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xFF2757db),
                                border: Border.all(width: 1.0),
                                borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                              ),
                              child: FlatButton(
                                onPressed: () async {
                                  final prefs =
                                  await SharedPreferences.getInstance();
                                  List<String> fooditemsnames = [];
                                  List<String> fooditemsprices = [];
                                  List<String> fooditemsids = [];
                                  fooditemsprices =
                                      prefs.getStringList('fooditemsprices') ??
                                          [];
                                  fooditemsnames =
                                      prefs.getStringList('fooditemsnames') ??
                                          [];
                                  fooditemsids =
                                      prefs.getStringList('fooditemsids') ?? [];
                                  fooditemsnames.add(fooditemsname[index]);
                                  fooditemsprices.add(fooditemsprice[index]);
                                  fooditemsids.add(fooditemsid[index]);
                                  prefs.setStringList(
                                      'fooditemsnames', fooditemsnames);
                                  prefs.setStringList(
                                      'fooditemsprices', fooditemsprices);
                                  prefs.setStringList(
                                      'fooditemsids', fooditemsids);
                                  //print(value[]);
                                },
                                child: Icon(
                                  Icons.add,
                                  size: 25,
                                  color: Color(0xFFffffff),
                                ),
                              ),
                            ),
                          ],
                        )));
              }),
        );
      } else {
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xff34a4eb), Color(0xff0d4569)],
            ),
          ),
          child: Center(
              child: Text("Sorry no food items available right now for " +
                  widget.foodcatagoryname)),
        );
      }
    } else {
      return Center(
        child: Column(
          children: <Widget>[
            Text("Loading delicious foods " +
                widget.foodcatagoryname +
                " for table : " +
                widget.tableid),
            CircularProgressIndicator(),
          ],
        ),
      );
    }
  }
}

class orderclass extends StatefulWidget {
  String tableid;

  orderclass(this.tableid);

  @override
  _orderclassState createState() => _orderclassState();
}

class _orderclassState extends State<orderclass> {
  int totalbill = 0;
  List fooditemsprices = [];
  List fooditemsnames = [];
  List fooditemsids = [];

  Future getorderdata() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
//    final key = 'my_int_key';
      fooditemsprices = prefs.getStringList('fooditemsprices') ?? [];
      fooditemsnames = prefs.getStringList('fooditemsnames') ?? [];
      fooditemsids = prefs.getStringList('fooditemsids') ?? [];
      //print('read: $value');
      totalbilcalculate();
    });
  }

  int totalbilcalculate() {
    totalbill = 0;
    setState(() {
      for (int i = 0; i < fooditemsprices.length; i++) {
        totalbill = totalbill + int.parse(fooditemsprices[i]);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getorderdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("orders here")),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("#"),
                    )),
                Expanded(child: Text("Item")),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Price"),
                ),
                Expanded(child: Center(child: Text("Quantity"))),
              ],
            ),
            Container(
              height: 450,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xfff6921e), Color(0xffee4036)],
                ),
              ),
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: fooditemsprices.length,
                  itemBuilder: (BuildContext, index) {
                    return Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(0xFFe6e9ed),
                        border: Border.all(width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(
                            5.0) //         <--- border radius here
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text((index + 1).toString()),
                          ),
                          Expanded(
                            child:
                            Center(child: Text(fooditemsnames[index])),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(fooditemsprices[index]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(fooditemsids[index]),
                          ),
                          Container(
                              width: 40,
                              child: Center(
                                  child: FlatButton(
                                    onPressed: () {
                                      setState(() {
                                        fooditemsnames
                                            .add(fooditemsnames[index]);
                                        fooditemsprices
                                            .add(fooditemsprices[index]);
                                        fooditemsids.add(fooditemsids[index]);
                                        totalbilcalculate();
                                      });
                                    },
                                    child: Icon(Icons.add, color: Colors.green),
                                  ))),
                          Container(
                              width: 40,
                              child: FlatButton(
                                onPressed: () {
                                  setState(() {
                                    fooditemsnames.removeAt(index);
                                    fooditemsprices.removeAt(index);
                                    fooditemsids.removeAt(index);
                                    totalbilcalculate();
                                  });
                                },
                                child: Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                ),
                              )),
                        ],
                      ),
                    );
                  }),
            ),
            Column(
              children: <Widget>[
                Text(
                    'total bill : PKR ' + totalbill.toString() + "/- only"),
                Container(
                  color: Colors.red,
                  child: FlatButton(
                    onPressed: () async {


                      if (fooditemsnames.length == 0) {

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            // return object of type Dialog
                            return AlertDialog(
                              title: new Text("Error"),
                              content: new Text(
                                  "Add at least 1 food item to place order !"),
                              actions: <Widget>[
                                // usually buttons at the bottom of the dialog
                                new FlatButton(
                                  child: new Text("Close"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                      else {
                        bool status = true;
                        String urlmasterorder =
                            "http://api.samacell.com/api/Hotel/SavOrderMaster?billamount=" +
                                totalbill.toString() +
                                "&orderTime=1112&OrderDate=121212&Tableid=" +
                                widget.tableid +
                                "&WaiterID=5";

                        http.Response orderidresponse =
                        await http.get(urlmasterorder);
                        String orderid = orderidresponse.body;

                        while (orderid == null);

                         orderid = orderid.substring(1, orderid.length - 1);
                         for (int i = 0; i < fooditemsnames.length; i++) {
                          String savorderdetailurl =
                              "http://api.samacell.com/api/Hotel/SavOrderDetail?orderId=" +
                                  orderid +
                                  "&itemid=" +
                                  fooditemsids[i] +
                                  "&Qty=1&saleprice=" +
                                  fooditemsprices[i] +
                                  "&Total=" +
                                  fooditemsprices[i] +
                                  "&ItemName=" +
                                  fooditemsnames[i];

                          http.Response orderdetailsresponse =
                          await http.get(savorderdetailurl);
                          String orderdetails = orderdetailsresponse.body;

                          while (orderdetails == null);
                          if (orderdetails == "false" && status == false ) {
                            status = false;
                          }
                         }

                        if (status == true) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              // return object of type Dialog
                              return AlertDialog(
                                title: new Text("Order : " + orderid),
                                content: new Text(
                                    "Order Placed at table : " +
                                        widget.tableid),
                                actions: <Widget>[
                                  Icon(Icons.tag_faces),
                                  // usually buttons at the bottom of the dialog
                                  new FlatButton(
                                    child: new Text("Close"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );

                          SharedPreferences preferences =
                          await SharedPreferences.getInstance();
                          preferences.clear();

                          setState(()   {

                            fooditemsprices = [];
                            fooditemsnames = [];
                            fooditemsids = [];
                          });
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              // return object of type Dialog
                              return AlertDialog(
                                title: new Icon(Icons.cancel),
                                content: new Text(
                                    "Order Could not be placed at table : " +
                                        widget.tableid),
                                actions: <Widget>[
                                  // usually buttons at the bottom of the dialog
                                  new FlatButton(
                                    child: new Text("Close"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                    },
                    child: Text("Submit order"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }


}
