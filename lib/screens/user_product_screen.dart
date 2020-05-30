import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';
import '../screens/edit_product_screen.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = '/userprodscreen';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productData = Provider.of<Products>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your product'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              },
            ),
          ],
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
            future: _refreshProducts(context),
            builder: (ctx, snapshot) =>
                snapshot.connectionState == ConnectionState.waiting
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _refreshProducts(context),
                        child: Consumer<Products>(
                          builder: (ctx, productData, _) => Padding(
                            padding: EdgeInsets.all(9),
                            child: ListView.builder(
                              itemBuilder: (ctx, i) => Column(
                                children: <Widget>[
                                  UserProductItem(
                                      productData.items[i].id,
                                      productData.items[i].title,
                                      productData.items[i].imageUrl),
                                  Divider(),
                                ],
                              ),
                              itemCount: productData.items.length,
                            ),
                          ),
                        ),
                      )));
  }
}
