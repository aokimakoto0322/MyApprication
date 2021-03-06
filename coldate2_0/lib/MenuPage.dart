import 'dart:convert';
import 'package:coldate2_0/DatabaseHelper.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:intl/intl.dart';
import 'Mesi.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

import 'models.dart';

const MethodChannel _channel = const MethodChannel('package/coldate');

//DBHelperの設定
final dbHelper = DatabaseHelper.instance;

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Mesi> _notes = List<Mesi>();
  List<Mesi> _noteForDisplay = List<Mesi>();
  var now = DateTime.now();
  //一時カロリー保管場所
  var mesicalsub = 0;
  //pickuplist
  List<Map<String, dynamic>> mesiarray = [];

  var _controller = TextEditingController();

  Future<List<Mesi>> fetchNotes() async {
    var url =
        'https://raw.githubusercontent.com/aokimakoto0322/caldate/master/Mesilist.json';
    var response = await http.get(url);

    var notes = List<Mesi>();

    if (response.statusCode == 200) {
      var noteJson = json.decode(response.body);
      for (var noteJson in noteJson) {
        notes.add(Mesi.fromJson(noteJson));
      }
    }
    return notes;
  }

  @override
  void initState() {
    fetchNotes().then((value) {
      setState(() {
        _notes.addAll(value);
        _noteForDisplay = _notes;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              floating: true,
              pinned: false,
              snap: true,
              expandedHeight: 50,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.only(left: 50),
                title: Align(
                  alignment: Alignment.bottomCenter,
                  child: TextField(
                    controller: _controller,
                    onChanged: (value) {
                      value = value.toLowerCase();
                      setState(() {
                        _noteForDisplay = _notes.where((element) {
                          var mesiTitle = element.mesiname.toLowerCase();
                          return mesiTitle.contains(value);
                        }).toList();
                      });
                    },
                    decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.black38,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.black38,
                          ),
                          onPressed: () {
                            _controller.clear();
                          },
                        ),
                        hintText: 'Search',
                        border: InputBorder.none),
                    style: TextStyle(fontSize: 25),
                  ),
                ),
              ),
            ),
            SliverFixedExtentList(
              itemExtent: 125,
              delegate:
                  SliverChildBuilderDelegate((BuildContext context, int index) {
                return _listItem(index);
              }, childCount: _noteForDisplay.length),
            )
          ],
        ),
      ),
      floatingActionButton: Container(
        child: FloatingActionButton.extended(
          label: Text(
            mesicalsub.toString(),
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          icon: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () async {
            final pl = await Todo().select().toList();
            if (pl.length == 0) {
              Todo(
                      cal: mesicalsub,
                      date: now.month.toString() + '/' + now.day.toString(),
                      year: now.year.toString())
                  .save();
              
            } else {
              var x1 = pl[pl.length - 1].toMap();
              var x2 = x1['cal'];
              x2 += mesicalsub;
              //methodchannel
              _channel.invokeMethod('test', x2.toString());

              if (x1['date'] ==
                  now.month.toString() + '/' + now.day.toString()) {
                Todo(
                        id: x1['id'],
                        cal: x2,
                        date: now.month.toString() + '/' + now.day.toString(),
                        year: now.year.toString())
                    .save();
              } else {
                Todo(
                        cal: mesicalsub,
                        date: now.month.toString() + '/' + now.day.toString(),
                        year: now.year.toString())
                    .save();
              }
            }

            //配列にたまったデータをDBにINSERT
            mesiarray.forEach((element) {
              _insert(element["mesiname"], element["mesical"]);
            });

            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  _listItem(index) {
    return ListTile(
      title: Text(_noteForDisplay[index].mesiname),
      trailing: Text(_noteForDisplay[index].mesical.toString() + 'kCal'),
      onTap: () {
        //食べたものとカロリーを一時リストに保管
        mesiarray.add({
          "mesiname": _noteForDisplay[index].mesiname,
          "mesical": _noteForDisplay[index].mesical
        });
        setState(() {
          mesicalsub += _noteForDisplay[index].mesical;
        });
      },
    );
  }

  void _insert(String mesiname, int mesical) async {
    Map<String, dynamic> row = {
      DatabaseHelper.date: DateFormat('yyyy-MM-dd').format(now),
      DatabaseHelper.datetime: DateFormat('HH:mm').format(now),
      DatabaseHelper.menuname: mesiname,
      DatabaseHelper.menucal: mesical,
    };
    await dbHelper.insert(row);
    print("insert成功");
  }
}
