import 'dart:async';

import 'package:coldate2_0/home_model.dart';
import 'package:coldate2_0/main.dart';
import 'package:coldate2_0/models.dart';
import 'package:coldate2_0/summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'Groval.dart';
import 'card.dart';
import 'colcounter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'DatabaseHelper.dart';

class Oldmenulist extends StatefulWidget {
  //databasehelper
  @override
  _OldmenulistState createState() => _OldmenulistState();
}

class _OldmenulistState extends State<Oldmenulist> {
  final dbHelper = DatabaseHelper.instance;
  final PageController pageController = PageController();

  //snackbar表示のscaffoldkey設定
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  //DBに保管するためのカウンタ
  var todaycount = colcounter();

  var yesterdaycount = colcounter();

  //過去日付選択
  DateTime _date = DateTime.now();
  //選択フラグ
  bool flag = false;

  List<Map<String, dynamic>> pastlistitem = [];

  List<Map<String, dynamic>> tmpList = [];

  //Edittextメニュー名の初期値設定のコントローラー
  TextEditingController menuController = TextEditingController();

  //Edittextカロリーの初期値設定のコントローラー
  TextEditingController calController = TextEditingController();

  void pastincrement(){
      setState(() {
        //配列の初期化
        pastlistitem = [];

        //過去データ配列に検索値を選択
        tmpList.forEach((element) { 
          var splitmenu = element["menuname"].split("【");
          if(element["date"] == DateFormat('yyyy-MM-dd').format(_date)){
            print("合致");
            pastlistitem.add({
              "id" : element["_id"],
              "date": element["date"],
              "datetime": element["datetime"],
              "menuname": splitmenu[0],
              "menucal": element["menucal"]
            });
          }else{
            print("非合致");
          }
        });
        print(pastlistitem.toString());
      });
    }


  @override
  Widget build(BuildContext context) {
    //mediaquery
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;

    //今日の日時
    var now = DateTime.now();

    //昨日の日時
    var yesterday = now.add(Duration(days: 1) * -1);

    return Consumer<HomeModel>(builder: (context, model, child) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.cyan[10],
          body: Container(
            child: Center(
              child: FutureBuilder(
                future: _query(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    //queryList
                    List<Map<String, dynamic>> listitem = snapshot.data;

                    //今日食べたもののリストの初期化
                    List<Map<String, dynamic>> todaylistitem = [];

                    //昨日食べたもののリストの初期化
                    List<Map<String, dynamic>> yesterdaylistitem = [];


                    tmpList = listitem;
                    

                    //今日食べたカロリーの合計
                    int todayTotalcal = 0;

                    //昨日食べたカロリーの合計
                    int yesterdayTotalcal = 0;

                    //今日食べたものを抽出
                    listitem.forEach((element) {
                      if (element["date"] ==
                          DateFormat('yyyy-MM-dd').format(now)) {
                        var splitmenu = element["menuname"].split("【");
                        todaylistitem.add({
                          "id" : element["_id"],
                          "date": element["date"],
                          "datetime": element["datetime"],
                          "menuname": splitmenu[0],
                          "menucal": element["menucal"]
                        });
                        todayTotalcal += element["menucal"];
                        todaycount.setCol(todayTotalcal);
                      }
                      //昨日食べたものを抽出
                      if (element["date"] ==
                          DateFormat('yyyy-MM-dd').format(yesterday)) {
                        var splitmenu = element["menuname"].split("【");
                        yesterdaylistitem.add({
                          "id" : element["_id"],
                          "date": element["date"],
                          "datetime": element["datetime"],
                          "menuname": splitmenu[0],
                          "menucal": element["menucal"]
                        });
                        yesterdayTotalcal += element["menucal"];
                        yesterdaycount.setCol(yesterdayTotalcal);
                      }
                    });

                    return PageView(
                      children: [
                        //リスト１　今日食べたもの
                        Center(
                          child: Container(
                            width: screenwidth - 50,
                            height: screenheight - 180,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0xff332A7C).withOpacity(0.5),
                                    blurRadius: 40.0)
                              ],
                              color: Color(0xff332A7C),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                        margin: EdgeInsets.only(top: 40),
                                        child: Text(
                                          "今日食べたもの",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        )),
                                    Container(
                                      margin: EdgeInsets.only(top: 40),
                                      child: Text(
                                        "合計：$todayTotalcal" + "kCal",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: ListView.builder(
                                      itemCount: todaylistitem.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          title: Text(
                                            todaylistitem[index]["menuname"],
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          subtitle: Text(
                                            todaylistitem[index]["datetime"],
                                            style:
                                                TextStyle(color: Colors.white60),
                                          ),
                                          trailing: Text(
                                            todaylistitem[index]["menucal"]
                                                    .toString() +
                                                "kCal",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          onTap: () async{
                                            //食品名の初期値設定
                                            menuController.text = todaylistitem[index]["menuname"];

                                            //カロリーの初期値設定
                                            calController.text = todaylistitem[index]["menucal"].toString();


                                            //ダイアログの表示
                                            var dialog = await showGeneralDialog(
                                              barrierColor: Colors.black.withOpacity(0.5),
                                              transitionDuration: Duration(milliseconds: 200),
                                              context: context,
                                              barrierDismissible: true,
                                              barrierLabel: "",
                                              transitionBuilder: (context, a1, a2, widget) {
                                                return Transform.scale(
                                                  scale: a1.value,
                                                  child: Dialog(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(4.0)
                                                    ),
                                                    child: Stack(
                                                      overflow: Overflow.visible,
                                                      alignment: Alignment.topCenter,
                                                      children: [
                                                        FutureBuilder(
                                                          future: Todo().select().toList(),
                                                          builder: (context, snapshot) {
                                                            if(snapshot.hasData){
                                                              var i = snapshot.data;
                                                              return Container(
                                                                height: screenheight - 200,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.fromLTRB(10, 70, 10, 10),
                                                                  child: Column(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                    children: [
                                                                      TextFormField(
                                                                        controller: menuController,
                                                                        maxLength: 50,
                                                                        decoration: const InputDecoration(
                                                                          border: OutlineInputBorder(),
                                                                          labelText: "メニュー名"
                                                                        ),
                                                                      ),
                                                                      TextFormField(
                                                                        controller: calController,
                                                                        keyboardType: TextInputType.number,
                                                                        maxLength: 4,
                                                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                                                        decoration: const InputDecoration(
                                                                          border: OutlineInputBorder(),
                                                                          labelText: "カロリー"
                                                                        ),
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          TextButton(
                                                                            child: Text("キャンセル"),
                                                                            onPressed: () => Navigator.of(context).pop(),
                                                                          ),
                                                                          ElevatedButton(
                                                                            onPressed: () async{
                                                                            //入力後のデータ
                                                                            int id = todaylistitem[index]["id"];
                                                                            String aftermenuname = menuController.text;
                                                                            int aftermenucal = 0;
                                                                            try{
                                                                              aftermenucal = int.parse(calController.text);
                                                                            }catch(e){
                                                                              AlertDialog(
                                                                                shape: const RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.all(Radius.circular(
                                                                                    10)
                                                                                  )
                                                                                ),
                                                                                backgroundColor: Color(0xffa18cd1).withOpacity(0.85),
                                                                                title:Text(
                                                                                  '項目にエラーがあります',
                                                                                  style: TextStyle(
                                                                                  color: Colors.white,
                                                                                  fontWeight: FontWeight.bold),
                                                                                ),
                                                                                content:
                                                                                  Column(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                      children: <Widget>[
                                                                                        SizedBox(
                                                                                          height: 10,
                                                                                        ),
                                                                                        
                                                                                        Text(
                                                                                          '・変更するカロリーには数字以外は入力できません',
                                                                                          style: TextStyle(color: Colors.white, fontSize: 16),
                                                                                        )
                                                                                      ],
                                                                                  )
                                                                              );
                                                                            }
                                                                            
                                                                            
                                                                            //リストの更新
                                                                            todaylistitem[index]["menuname"] = menuController.text;
                                                                            todaylistitem[index]["menucal"] = int.parse(calController.text);

                                                                            //入力後のトータルカロリーの再計算
                                                                            int tmp = 0;
                                                                            todaylistitem.forEach((element) {
                                                                              tmp += element["menucal"];
                                                                            });

                                                                            todaycount.setCol(tmp);

                                                                            //Summaryに表示されるDBの更新                                                      
                                                                            await Todo(id: i.length, cal: todaycount.getCol(), date: now.month.toString() + '/' + now.day.toString(), year: now.year.toString()).save();
                                                                            
                                                                            
                                                                            //食べたもののDB更新
                                                                            await _update(id, aftermenuname, aftermenucal);
                                                                            
                                                                      
                                                                            //snackBarの表示
                                                                            _scaffoldKey.currentState.showSnackBar(
                                                                              SnackBar(
                                                                                content: Text("変更しました。"),
                                                                                duration: const Duration(seconds: 5),
                                                                                action: SnackBarAction(
                                                                                  label: "OK",
                                                                                  onPressed: () {
                                                                                    //snackbarのOKボタンを押したときの動作
                                                                                    //特になし
                                                                                  },
                                                                                ),
                                                                              )
                                                                            );
                                                                            
                                                                            //ダイアログを閉じる
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                            child: Text('変更する', style: TextStyle(color: Colors.white),),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            }else{
                                                              return CircularProgressIndicator();
                                                            }
                                                          },
                                                          
                                                        ),
                                                        Positioned(
                                                          top: -60,
                                                          child: CircleAvatar(
                                                            backgroundColor: Color(0xff332A7C),
                                                            radius: 60,
                                                            child: Icon(Icons.refresh, color: Colors.white, size: 50,),
                                                          )
                                                        ),
                                                      ],
                                                    )
                                                  ),
                                                );
                                              }, pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {  },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        //リスト２ 昨日食べたもの
                        Center(
                          child: Container(
                            width: screenwidth - 50,
                            height: screenheight - 180,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0xffF25767).withOpacity(0.5),
                                    blurRadius: 40.0)
                              ],
                              color: Color(0xffF25767),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                        margin: EdgeInsets.only(top: 40),
                                        child: Text(
                                          "昨日食べたもの",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold),
                                        )),
                                    Container(
                                      margin: EdgeInsets.only(top: 40),
                                      child: Text(
                                        "合計：$yesterdayTotalcal" + "kCal",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: ListView.builder(
                                      itemCount: yesterdaylistitem.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          title: Text(
                                            yesterdaylistitem[index]["menuname"],
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          subtitle: Text(
                                            yesterdaylistitem[index]["datetime"],
                                            style:
                                                TextStyle(color: Colors.white60),
                                          ),
                                          trailing: Text(
                                            yesterdaylistitem[index]["menucal"]
                                                    .toString() +
                                                "kCal",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          onTap: ()  async{
                                            //食品名の初期値設定
                                            menuController.text = yesterdaylistitem[index]["menuname"];

                                            //カロリーの初期値設定
                                            calController.text = yesterdaylistitem[index]["menucal"].toString();


                                            //ダイアログの表示
                                            var dialog = await showGeneralDialog(
                                              barrierColor: Colors.black.withOpacity(0.5),
                                              transitionDuration: Duration(milliseconds: 200),
                                              context: context,
                                              barrierDismissible: true,
                                              barrierLabel: "",
                                              transitionBuilder: (context, a1, a2, widget) {
                                                return Transform.scale(
                                                  scale: a1.value,
                                                  child: Dialog(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(4.0)
                                                    ),
                                                    child: Stack(
                                                      overflow: Overflow.visible,
                                                      alignment: Alignment.topCenter,
                                                      children: [
                                                        FutureBuilder(
                                                          future: Todo().select().toList(),
                                                          builder: (context, snapshot) {
                                                            if(snapshot.hasData){
                                                              var i = snapshot.data;
                                                              return Container(
                                                                height: screenheight - 200,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.fromLTRB(10, 70, 10, 10),
                                                                  child: Column(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                    children: [
                                                                      TextFormField(
                                                                        controller: menuController,
                                                                        maxLength: 50,
                                                                        decoration: const InputDecoration(
                                                                          border: OutlineInputBorder(),
                                                                          labelText: "メニュー名"
                                                                        ),
                                                                      ),
                                                                      TextFormField(
                                                                        controller: calController,
                                                                        keyboardType: TextInputType.number,
                                                                        maxLength: 4,
                                                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                                                        decoration: const InputDecoration(
                                                                          border: OutlineInputBorder(),
                                                                          labelText: "カロリー"
                                                                        ),
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          TextButton(
                                                                            child: Text("キャンセル"),
                                                                            onPressed: () => Navigator.of(context).pop(),
                                                                          ),
                                                                          ElevatedButton(
                                                                            onPressed: () async{
                                                                            //入力後のデータ
                                                                            int id = yesterdaylistitem[index]["id"];
                                                                            String aftermenuname = menuController.text;
                                                                            int aftermenucal = int.parse(calController.text);
                                                                            
                                                                            //リストの更新
                                                                            yesterdaylistitem[index]["menuname"] = menuController.text;
                                                                            yesterdaylistitem[index]["menucal"] = int.parse(calController.text);

                                                                            //入力後のトータルカロリーの再計算
                                                                            int tmp = 0;
                                                                            yesterdaylistitem.forEach((element) {
                                                                              tmp += element["menucal"];
                                                                            });

                                                                            todaycount.setCol(tmp);

                                                                            //今日のカロリーを未入力の場合のバリデーションチェック
                                                                            if(todaylistitem.length == 0){
                                                                              //Summaryに表示されるDBの更新                                                      
                                                                              await Todo(id: i.length, cal: todaycount.getCol(), date: yesterday.month.toString() + '/' + yesterday.day.toString(), year: yesterday.year.toString()).save();
                                                                            }else{
                                                                              //Summaryに表示されるDBの更新                                                      
                                                                              await Todo(id: i.length - 1, cal: todaycount.getCol(), date: yesterday.month.toString() + '/' + yesterday.day.toString(), year: yesterday.year.toString()).save();
                                                                            }
                                                                            
                                                                            //食べたもののDB更新
                                                                            await _update(id, aftermenuname, aftermenucal);
                                                                            
                                                                      
                                                                            //snackBarの表示
                                                                            _scaffoldKey.currentState.showSnackBar(
                                                                              SnackBar(
                                                                                content: Text("変更しました。"),
                                                                                duration: const Duration(seconds: 5),
                                                                                action: SnackBarAction(
                                                                                  label: "OK",
                                                                                  onPressed: () {
                                                                                    //snackbarのOKボタンを押したときの動作
                                                                                    //特になし
                                                                                  },
                                                                                ),
                                                                              )
                                                                            );
                                                                            
                                                                            //ダイアログを閉じる
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                            child: Text('変更する', style: TextStyle(color: Colors.white),),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            }else{
                                                              return CircularProgressIndicator();
                                                            }
                                                          },
                                                          
                                                        ),
                                                        Positioned(
                                                          top: -60,
                                                          child: CircleAvatar(
                                                            backgroundColor: Color(0xffF25767),
                                                            radius: 60,
                                                            child: Icon(Icons.refresh, color: Colors.white, size: 50,),
                                                          )
                                                        ),
                                                      ],
                                                    )
                                                  ),
                                                );
                                              }, pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {  },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        //リスト３ 過去食べたものを検索
                        Center(
                          child: Container(
                            width: screenwidth - 50,
                            height: screenheight - 180,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0xffFFA000).withOpacity(0.5),
                                    blurRadius: 40.0)
                              ],
                              color: Color(0xffFFA000),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(top: 40, left: 15),
                                      child: TextButton(
                                        child: flag == false
                                            ? Text(
                                              "過去のデータを選択する",
                                              style: TextStyle(
                                                fontSize: 22
                                              ),
                                              )
                                            : Text(_date.year.toString() + "年" + _date.month.toString() + "月" + _date.day.toString() + "日", style: TextStyle(fontSize: 22),),
                                        onPressed: () async {
                                          //日付選択
                                          _selectDate(context);

                                        },
                                      )
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 45),
                                      child: IconButton(
                                        icon: Icon(Icons.search_rounded),
                                        //リスト更新
                                        onPressed: () => pastincrement(),
                                      ),
                                    )
                                  ],
                                ),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: ListView.builder(
                                      itemCount: pastlistitem.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          title: Text(
                                            pastlistitem[index]["menuname"],
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          subtitle: Text(
                                            pastlistitem[index]["datetime"],
                                            style:
                                                TextStyle(color: Colors.white60),
                                          ),
                                          trailing: Text(
                                            pastlistitem[index]["menucal"]
                                                    .toString() +
                                                "kCal",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          onTap: () async {
                                            //食品名の初期値設定
                                            menuController.text = pastlistitem[index]["menuname"];

                                            //カロリーの初期値設定
                                            calController.text = pastlistitem[index]["menucal"].toString();


                                            //ダイアログの表示
                                            var dialog = await showGeneralDialog(
                                              barrierColor: Colors.black.withOpacity(0.5),
                                              transitionDuration: Duration(milliseconds: 200),
                                              context: context,
                                              barrierDismissible: true,
                                              barrierLabel: "",
                                              transitionBuilder: (context, a1, a2, widget) {
                                                return Transform.scale(
                                                  scale: a1.value,
                                                  child: Dialog(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(4.0)
                                                    ),
                                                    child: Stack(
                                                      overflow: Overflow.visible,
                                                      alignment: Alignment.topCenter,
                                                      children: [
                                                        FutureBuilder(
                                                          future: Todo().select().toList(),
                                                          builder: (context, snapshot) {
                                                            if(snapshot.hasData){
                                                              var i = snapshot.data;
                                                              return Container(
                                                                height: screenheight - 200,
                                                                child: Padding(
                                                                  padding: const EdgeInsets.fromLTRB(10, 70, 10, 10),
                                                                  child: Column(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                    children: [
                                                                      TextFormField(
                                                                        controller: menuController,
                                                                        maxLength: 50,
                                                                        decoration: const InputDecoration(
                                                                          border: OutlineInputBorder(),
                                                                          labelText: "メニュー名"
                                                                        ),
                                                                      ),
                                                                      TextFormField(
                                                                        controller: calController,
                                                                        keyboardType: TextInputType.number,
                                                                        maxLength: 4,
                                                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                                                        decoration: const InputDecoration(
                                                                          border: OutlineInputBorder(),
                                                                          labelText: "カロリー"
                                                                        ),
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          TextButton(
                                                                            child: Text("キャンセル"),
                                                                            onPressed: () => Navigator.of(context).pop(),
                                                                          ),
                                                                          ElevatedButton(
                                                                            onPressed: () async{
                                                                            //入力後のデータ
                                                                            int id = pastlistitem[index]["id"];
                                                                            String aftermenuname = menuController.text;
                                                                            int aftermenucal = int.parse(calController.text);
                                                                            
                                                                            //リストの更新
                                                                            pastlistitem[index]["menuname"] = menuController.text;
                                                                            pastlistitem[index]["menucal"] = int.parse(calController.text);

                                                                            //入力後のトータルカロリーの再計算
                                                                            int tmp = 0;
                                                                            pastlistitem.forEach((element) {
                                                                              tmp += element["menucal"];
                                                                            });

                                                                            todaycount.setCol(tmp);

                                                                            //id取得
                                                                            var p1 = await Todo().select().date.contains(_date.month.toString() +'/' + _date.day.toString()).toList();
                                                                            var x1 = p1[p1.length - 1].toMap();
                                                                            var getid = x1['id'];

                                                                            //Summaryに表示されるDBの更新                                                      
                                                                            await Todo(id: getid, cal: todaycount.getCol(), date: _date.month.toString() + '/' + _date.day.toString(), year: _date.year.toString()).save();
                                                                            
                                                                            
                                                                            //食べたもののDB更新
                                                                            await _update(id, aftermenuname, aftermenucal);
                                                                            
                                                                      
                                                                            //snackBarの表示
                                                                            _scaffoldKey.currentState.showSnackBar(
                                                                              SnackBar(
                                                                                content: Text("変更しました。"),
                                                                                duration: const Duration(seconds: 5),
                                                                                action: SnackBarAction(
                                                                                  label: "OK",
                                                                                  onPressed: () {
                                                                                    //snackbarのOKボタンを押したときの動作
                                                                                    //特になし
                                                                                  },
                                                                                ),
                                                                              )
                                                                            );
                                                                            
                                                                            //ダイアログを閉じる
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                            child: Text('変更する', style: TextStyle(color: Colors.white),),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            }else{
                                                              return CircularProgressIndicator();
                                                            }
                                                          },
                                                          
                                                        ),
                                                        Positioned(
                                                          top: -60,
                                                          child: CircleAvatar(
                                                            backgroundColor: Color(0xffFFA000),
                                                            radius: 60,
                                                            child: Icon(Icons.refresh, color: Colors.white, size: 50,),
                                                          )
                                                        ),
                                                      ],
                                                    )
                                                  ),
                                                );
                                              }, pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {  },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                      controller: pageController,
                      onPageChanged: (index) {
                        model.updateIndex(index);
                      },
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
          ),
          bottomNavigationBar: Container(
            height: 100,
            decoration: BoxDecoration(
                color: Colors.black12,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 40.0)],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0))),
            child: Transform(
              transform:
                  Matrix4.translationValues(model.center(screenwidth), 0, 0),
              child: Stack(
                  children: List.generate(3, (index) {
                final card = CustomCard.fromMap(Global.cardData[index]);
                return Align(
                  alignment:
                      index == 0 ? Alignment.centerLeft : Alignment.centerRight,
                  child: Transform(
                    transform: Matrix4.translationValues(
                        model.spacing(screenwidth, index), 0, 0),
                    child: AnimatedContainer(
                      transform: Matrix4.translationValues(
                          index == 1 ? model.moveMiddle : 0, 0, 0),
                      duration: Duration(milliseconds: 500),
                      width: model.animation(index),
                      height: model.dotSize,
                      curve: Curves.elasticOut,
                      child: GestureDetector(
                        onTap: () {
                          model.updateIndex(index);

                          pageController.animateToPage(index,
                              duration: Duration(milliseconds: 1000),
                              curve: Curves.easeInOutQuart);
                          print("test" + index.toString());
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 1000),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(model.dotSize / 2),
                              color: card.backGroundColor),
                        ),
                      ),
                    ),
                  ),
                );
              })),
            ),
          ),
        ),
      );
    });
  }

  @override
  void dispose(){
    menuController.dispose();
    calController.dispose();
    super.dispose();
  }


  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: new DateTime(2016),
        lastDate: new DateTime.now().add(new Duration(days: 360)));
    flag = true;
    if (picked != null) setState(() => _date = picked);
  }

  Future<List<Map<String, dynamic>>> _query() async {
    return await dbHelper.queryAllRows();
  }

  Future<void> _update(int id, String menu, int cal) async{
    await dbHelper.updateMenu(id, menu, cal);
  }

  Future<void> _delete(int id) async{
    await dbHelper.delete(id);
  }
}
