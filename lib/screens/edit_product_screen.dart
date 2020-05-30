import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-screen';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var _editiedProduct = Product(
    id: null,
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );

  var _isInit = true;
  var _isLoading = false;

  var initValues = {
    'title': '',
    'description': '',
    'price': 0,
    'imageUrl': '',
  };
  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        final _editiedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        initValues = {
          'title': _editiedProduct.title,
          'description': _editiedProduct.description,
          'price': _editiedProduct.price.toString(),
          // 'imageUrl': _editiedProduct.imageUrl
          'imageUrl': '',
        };
        _imageUrlController.text = _editiedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (_imageUrlController.text.isEmpty ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg')) ||
          (!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https'))) {
        return;
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final _validate = _formKey.currentState.validate();
    if (!_validate) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editiedProduct.id != null) {
      Provider.of<Products>(context, listen: false)
          .updateProduct(_editiedProduct.id, _editiedProduct);
      setState(() {
        _isLoading = false;
      });
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProducts(_editiedProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('Error occured !'),
                  content: Text('Something went wrong'),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Text('Okay'),
                    ),
                  ],
                ));
        // } finally {
        //   setState(() {
        //     _isLoading = false;
        //   });
        //   Navigator.of(context).pop();
        // }
      }
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Edit product'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveForm,
            )
          ],
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(15.0),
                child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            initialValue: initValues['title'],
                            decoration: InputDecoration(labelText: 'Title'),
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (value) {
                              FocusScope.of(context)
                                  .requestFocus(_priceFocusNode);
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please provide the title';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editiedProduct = Product(
                                id: _editiedProduct.id,
                                isFavourite: _editiedProduct.isFavourite,
                                title: value,
                                description: _editiedProduct.description,
                                price: _editiedProduct.price,
                                imageUrl: _editiedProduct.imageUrl,
                              );
                            },
                          ),
                          TextFormField(
                            initialValue: initValues['price'].toString(),
                            decoration: InputDecoration(labelText: 'Price'),
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number,
                            focusNode: _priceFocusNode,
                            onFieldSubmitted: (value) {
                              FocusScope.of(context)
                                  .requestFocus(_descFocusNode);
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please provide the price';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please provide the valid number';
                              }
                              if (double.parse(value) <= 0) {
                                return 'Price greater than zero is accepted';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editiedProduct = Product(
                                id: _editiedProduct.id,
                                isFavourite: _editiedProduct.isFavourite,
                                title: _editiedProduct.title,
                                description: _editiedProduct.description,
                                price: double.parse(value),
                                imageUrl: _editiedProduct.imageUrl,
                              );
                            },
                          ),
                          TextFormField(
                            initialValue: initValues['description'],
                            decoration:
                                InputDecoration(labelText: 'Description'),
                            maxLines: 3,
                            keyboardType: TextInputType.multiline,
                            focusNode: _descFocusNode,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please provide the description';
                              }
                              if (value.length <= 10) {
                                return 'Description should be atleast more than 10 characters.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editiedProduct = Product(
                                id: _editiedProduct.id,
                                isFavourite: _editiedProduct.isFavourite,
                                title: _editiedProduct.title,
                                description: value,
                                price: _editiedProduct.price,
                                imageUrl: _editiedProduct.imageUrl,
                              );
                            },
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                width: 100,
                                height: 100,
                                margin: EdgeInsets.only(
                                  top: 8,
                                  right: 10,
                                ),
                                padding: EdgeInsets.only(
                                  top: 30,
                                ),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                  width: 1,
                                  color: Colors.grey,
                                )),
                                child: _imageUrlController.text.isEmpty
                                    ? Text(
                                        'Enter image url',
                                        textAlign: TextAlign.center,
                                      )
                                    : FittedBox(
                                        child: Image.network(
                                          _imageUrlController.text,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  decoration:
                                      InputDecoration(labelText: 'Image URL'),
                                  keyboardType: TextInputType.url,
                                  textInputAction: TextInputAction.done,
                                  controller: _imageUrlController,
                                  focusNode: _imageUrlFocusNode,
                                  onFieldSubmitted: (_) {
                                    _saveForm();
                                  },
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please provide the image URL.';
                                    }
                                    if (!value.startsWith('http') &&
                                        !value.startsWith('https')) {
                                      return 'Please provide the valid image URL.';
                                    }
                                    if (!value.endsWith('.png') &&
                                        !value.endsWith('.jpg')) {
                                      return 'Please provide the valid image extension URL.';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _editiedProduct = Product(
                                      id: _editiedProduct.id,
                                      isFavourite: _editiedProduct.isFavourite,
                                      title: _editiedProduct.title,
                                      description: _editiedProduct.description,
                                      price: _editiedProduct.price,
                                      imageUrl: value,
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )),
              ));
    ;
  }
}
