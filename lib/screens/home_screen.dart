import 'dart:math';

import 'package:flutter/material.dart';

import '../misc/default_input_decoration.dart';
import '../misc/is_numeric.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TextEditingController> controllers = [];
  List<FocusNode> focusNodes = [];
  String total = '';
  late Duration totalDuration;

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 3; i++) {
      controllers.add(TextEditingController());
      focusNodes.add(FocusNode());
    }

    totalDuration = const Duration(seconds: 0);

    Future.delayed(
      const Duration(milliseconds: 50),
      () => focusNodes.first.requestFocus(),
    );
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    for (final focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _updateTotalDuration() {
    totalDuration = const Duration(seconds: 0);

    for (int i = 0; i < controllers.length; i++) {
      final text = controllers[i].text;
      final split = text.split(':');

      final hours = split[0].isNotEmpty ? int.parse(split[0]) : 0;
      final int minutes =
          split.length > 1 && split[1].isNotEmpty ? int.parse(split[1]) : 0;
      final int seconds =
          split.length > 2 && split[2].isNotEmpty ? int.parse(split[2]) : 0;

      totalDuration += Duration(
        hours: hours,
        minutes: minutes,
        seconds: seconds,
      );
    }

    setState(() {
      total = totalDuration.inSeconds > 0 ? _getDurationString() : '00:00';
    });
  }

  String _getDurationString() {
    String s = '';
    if (totalDuration.inHours > 0) {
      s = '${totalDuration.inHours < 10 ? '0' : ''}${totalDuration.inHours}:';
    }
    final minutes = totalDuration.inMinutes % 60;
    s += '${minutes < 10 ? '0' : ''}$minutes';
    final seconds = totalDuration.inSeconds % 60;
    if (seconds > 0) {
      s += ':${seconds < 10 ? '0' : ''}$seconds';
    }

    return s;
  }

  Widget _buildTextFields() {
    List<Widget> children = [];

    for (int i = 0; i < controllers.length; i++) {
      children.add(
        _TextField(
          controller: controllers[i],
          focusNode: focusNodes[i],
          index: i,
          onChanged: (s) {
            final controller = controllers[i];
            if (!isNumericOrSpecialChars(controller.text, chars: ':')) {
              controller.text =
                  controller.text.substring(0, controller.text.length - 1);
              controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length));
              return;
            }
          },
          onSubmit: (_) {
            if (i == controllers.length - 1 || i == controllers.length - 2) {
              controllers.add(TextEditingController());
              focusNodes.add(FocusNode());
            }
            _updateTotalDuration();

            if (i < controllers.length - 1) {
              focusNodes[i + 1].requestFocus();
            }
          },
        ),
      );
    }

    return Column(
      children: children,
    );
  }

  void _resetState() {
    //? dispose and remove controllers / focus nodes after 3rd index
    while (controllers.length > 3) {
      controllers[controllers.length - 1].dispose();
      focusNodes[controllers.length - 1].dispose();
      controllers.removeLast();
      focusNodes.removeLast();
    }
    //? Clear the text of remaining controllers
    for (final controller in controllers) {
      controller.text = '';
    }
    setState(() {
      total = '';
      totalDuration = const Duration(seconds: 0);
    });
    //? Focus first focus node
    focusNodes.first.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * .05,
                width: double.infinity,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, right: 10),
                    child: IconButton(
                      onPressed: _resetState,
                      iconSize: 36,
                      color: Colors.grey.shade300,
                      icon: const Icon(Icons.refresh),
                    ),
                  ),
                ),
              ),
              SelectableText(
                total.isEmpty ? '00:00' : total,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .05,
              ),
              SizedBox(
                width: min(
                  500,
                  MediaQuery.of(context).size.width * .9,
                ),
                child: _buildTextFields(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSubmit;
  final Function(String) onChanged;
  final int index;

  const _TextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    required this.onChanged,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: Theme.of(context)
            .textTheme
            .headlineSmall!
            .copyWith(color: Colors.grey.shade800),
        decoration: defaultInputDecoration.copyWith(
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        onChanged: onChanged,
        onSubmitted: onSubmit,
      ),
    );
  }
}
