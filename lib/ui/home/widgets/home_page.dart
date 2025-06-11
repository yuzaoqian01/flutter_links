import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3_links/main.dart';
import 'package:web3_links/ui/home/view_models/wallet_view_model.dart';

import 'package:web3_links/ui/components/field_cell/field_cell.dart';
import 'package:web3_links/ui/components/line/divider_line.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final userControler = TextEditingController();
  late FocusNode myFocusNode;
  final _formkey = GlobalKey<FormState>();

  final snackBar = SnackBar(
    content: const Text('data'),
    action: SnackBarAction(label: '是否确定', onPressed: (){
      appLogger.info('message');
    }),
  );

  @override
  void initState() {
    super.initState();

    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    userControler.dispose();
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web3 钱包'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<WalletViewModel>().refreshBalance();
            },
          ),
        ],
      ),
      body: Consumer<WalletViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('错误: ${viewModel.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.connectWallet(),
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          // final walletInfo = viewModel.walletInfo;
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: '请输入内容',
                    ),
                    validator :(value){
                      if(value == null || value.isEmpty){
                        return '请输入文字';
                      }
                      return null;
                    }
                  ),
                  TextField(focusNode: myFocusNode),
                  ElevatedButton(
                    child: const Text('snackbar'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                  ),
                  ElevatedButton(
                    onPressed: (){
                      myFocusNode.requestFocus();
                    }, 
                    child: const Text('聚焦')
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Validate returns true if the form is valid, or false otherwise.
                      if (_formkey.currentState!.validate()) {
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Processing Data')),
                        );
                      }
                    },
                    child: const Text('Submit'),
                  ),
                  FieldCell(
                    labelWidth: 0,
                    spacing: 16,
                    direction: FieldDirection.row,
                    suffixIcon: ElevatedButton(
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                        ),
                        backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
                      ),
                      onPressed: null,
                      child: const Text('验证码', style: TextStyle(fontSize: 12 ,color: Colors.blue),),
                    ),
                    required: true,
                    controller: userControler,
                    hintText: '请输入用户名',
                    onChanged: (value) {
                      appLogger.info('用户名输入: $value');
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入用户名';
                      }
                      return null;
                    },
                  ),
                  const Center(
                    child: DividerLine(
                      widthMinus: 64,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}



class MyButton extends StatelessWidget {
  const MyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { 
        appLogger.info('MyButton: Button clicked');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Colors.red, Colors.blue]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '点击我',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}