import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopchecker/ViewModel/shopList_ViewModel.dart';

class ShoplistScreen extends ConsumerStatefulWidget {
  const ShoplistScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ShoplistScreenState();
}

class _ShoplistScreenState extends ConsumerState<ShoplistScreen> {
  @override
  Widget build(BuildContext context) {
    final listViewModel = ref.read(listViewModelProvider.notifier);
    final shopList = listViewModel.list;
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              // leading: IconButton(
              //     onPressed: () => Navigator.pop,
              //     icon: Icon(Icons.arrow_back))),
              title: Text('Список Покупок',
                  style: TextStyle(
                    fontSize: 20,
                  )),
            ),
            body: Column(
              children: [
                Expanded(
                  child: Card(
                    color: Theme.of(context).colorScheme.surface,
                    child: ListView.builder(
                      itemCount: shopList.length,
                      itemBuilder: (context, index) {
                        return Card(
                            color: Theme.of(context).colorScheme.surface,
                            child: ExpansionTile(
                              leading: Text(
                                "${(index + 1).toString()}. ",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              ),
                              title: Text(
                                "${shopList[index]["name"]} ",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              ),
                              children: [
                                Text(
                                  "Цена: ${shopList[index]['price']}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                ),
                                shopList[index].containsKey('count')
                                    ? Text(
                                        "Количество: ${shopList[index]['count']}",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                      )
                                    : Text(
                                        "Количество: 1",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                      ),
                                Text(
                                  shopList[index]['store_name'],
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                ),
                              ],
                            ));
                        // return Text('',
                        //     style: TextStyle(
                        //         color: Theme.of(context).colorScheme.secondary));
                      },
                    ),
                  ),
                ),
                // IconButton(
                //     onPressed: () {
                //       print(listViewModel.write());
                //     },
                //     icon: Icon(Icons.arrow_back_ios))
              ],
            )));
  }
}
