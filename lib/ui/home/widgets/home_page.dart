import 'package:flutter/material.dart';


import 'package:web3_links/main.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  bool _selected = false;
  late AnimationController _controller;
  // late Animation<double> _animation;

  @override
  void initState() {
    appLogger.info('initState');
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // _animation = Tween<double>(begin: 50, end: 200).animate(
    //   CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    // );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   appLogger.info('beforeMounted');


    return Scaffold(
      appBar: AppBar(
        title: const Text('home'),
      ),
      body: const Center(
        child: Column(
          children: [
           Text('ss')
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _selected = !_selected;
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}