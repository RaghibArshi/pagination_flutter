import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;  // Install the http package from pubdev.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final controller = ScrollController();
  int page = 1;
  bool moreData = true;
  bool isLoading = false;
  // List<String> listItems = List.generate(20, (index) {
  //   return 'List Items ${index + 1}';
  // });

  List<String> listItems = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadDataFromApi();
    controller.addListener(() {
      if(controller.position.maxScrollExtent == controller.offset){
        // loadMoreData();
        loadDataFromApi();
      }
    });
  }

  loadMoreData() async {
    setState(() {
      listItems.addAll(['New Item 1', 'New Item 2', 'New Item 3', 'New Item 4']);
    });
  }

  loadDataFromApi() async {
    if(isLoading){
      return;
    }
    isLoading = true;
    int limit = 20;
    final url = Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=$limit&_page=$page');
    final response = await http.get(url);
    if(response.statusCode == 200){
      final List listFromApi = json.decode(response.body);
      setState(() {
        page++;
        isLoading = false;
        if(listFromApi.length < limit){
          moreData = false;
        }
        listItems.addAll(listFromApi.map<String>((e){
          final number = e['id'];
          return 'Items $number';
        }).toList());
      });
    }
  }

  Future refreshFunction() async {
    setState(() {
      isLoading = false;
      moreData = true;
      page = 0;
      listItems.clear();
    });
    loadDataFromApi();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Infinite List Scrolling'),
      ),
      body: RefreshIndicator(
        onRefresh: refreshFunction,
        child: ListView.builder(
            controller: controller,
            padding: const EdgeInsets.all(10.0),
            itemCount: listItems.length + 1,
            itemBuilder: (context, index) {
              if (listItems.length > index) {
                final item = listItems[index];
                return ListTile(
                  title: Text(item),
                );
              } else {
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: moreData ? const CircularProgressIndicator() : const Text('No More Data'),
                  ),
                );
              }
            }),
      ),
    );
  }
}
