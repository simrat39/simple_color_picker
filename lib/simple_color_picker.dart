library simple_color_picker;

import 'package:flutter/material.dart';

class SimpleColorPicker extends StatelessWidget {
  const SimpleColorPicker({
    Key? key,
    required this.height,
    required this.onColorSelect,
    this.onCancel,
    this.initialColor,
  }) : super(key: key);

  final double height;
  final Function(Color color) onColorSelect;
  final Function()? onCancel;
  final Color? initialColor;

  @override
  Widget build(BuildContext context) {
    return _MaterialColorPicker(
      height: this.height,
      onColorSelect: this.onColorSelect,
      initialColor: this.initialColor,
      onCancel: this.onCancel,
    );
  }
}

bool isValidated = true;

class _MaterialColorPicker extends StatefulWidget {
  _MaterialColorPicker({
    Key? key,
    required this.height,
    required this.onColorSelect,
    this.initialColor,
    this.onCancel,
  }) : super(key: key);

  final double height;
  final Function(Color color) onColorSelect;
  final Function()? onCancel;
  final Color? initialColor;

  @override
  _MaterialColorPickerState createState() => _MaterialColorPickerState();
}

class _MaterialColorPickerState extends State<_MaterialColorPicker> {
  SelectedColor selectedColor = SelectedColor();
  late TextEditingController _textEditingController;
  late Function() onCancel;

  @override
  void initState() {
    super.initState();
    selectedColor.addListener(() {
      setState(() {});
    });
    _textEditingController = TextEditingController();
    isValidated = true;
  }

  @override
  void didChangeDependencies() {
    if (widget.initialColor == null) {
      Color accent = Theme.of(context).accentColor;
      selectedColor.setColorFromRgb(
          accent.red, accent.green, accent.blue, true);
    } else {
      selectedColor.setColorFromRgb(
        widget.initialColor!.red,
        widget.initialColor!.green,
        widget.initialColor!.blue,
        true,
      );
    }
    _textEditingController.text =
        selectedColor.getColor().value.toRadixString(16);
    if (widget.onCancel == null) {
      onCancel = () => Navigator.of(context)?.pop();
    } else {
      onCancel = widget.onCancel!;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Color col = selectedColor.getColor();
    return Container(
      width: double.infinity,
      height: widget.height,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: double.infinity,
                height: widget.height * 0.6,
                color: col,
              ),
              Positioned(
                bottom: 10,
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 300),
                  opacity: isValidated ? 0.0 : 1.0,
                  child: Text(
                    "Invalid Color",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: col.computeLuminance() < 0.5
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: TextField(
                  controller: _textEditingController,
                  onEditingComplete: () {
                    String text = _textEditingController.text;
                    if (text.length != 8 || !selectedColor.isValidColor(text)) {
                      setState(() {
                        isValidated = false;
                      });
                    } else {
                      isValidated = true;
                      selectedColor
                          .setColorFromString(_textEditingController.text);
                    }
                  },
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    color: col.computeLuminance() < 0.5
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                top: 8.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ColorRow(
                      color: Colors.redAccent,
                      colorName: "red",
                      textEditingController: _textEditingController,
                      selectedColor: selectedColor,
                    ),
                  ),
                  Expanded(
                    child: ColorRow(
                      color: Colors.greenAccent,
                      colorName: "green",
                      textEditingController: _textEditingController,
                      selectedColor: selectedColor,
                    ),
                  ),
                  Expanded(
                    child: ColorRow(
                      color: Colors.blueAccent,
                      colorName: "blue",
                      textEditingController: _textEditingController,
                      selectedColor: selectedColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: 8.0,
              right: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    onCancel();
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: col,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Color col = Colors.white;
                    if (widget.initialColor == null) {
                      col = Theme.of(context).accentColor;
                    } else {
                      col = widget.initialColor!;
                    }
                    selectedColor.setColorFromRgb(col.red, col.green, col.blue);
                    _textEditingController.text =
                        selectedColor.getColor().value.toRadixString(16);
                    isValidated = true;
                  },
                  child: Text(
                    "Reset",
                    style: TextStyle(
                      color: col,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.onColorSelect(col);
                  },
                  child: Text(
                    "Ok",
                    style: TextStyle(
                      color: col,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ColorRow extends StatelessWidget {
  ColorRow({
    Key? key,
    required this.colorName,
    required this.color,
    required this.textEditingController,
    required this.selectedColor,
  }) : super(key: key);

  final String colorName;
  final Color color;
  final TextEditingController textEditingController;
  final SelectedColor selectedColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          colorName[0].toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).hintColor,
          ),
        ),
        Expanded(
          child: Slider(
            value: selectedColor.color[colorName]?.toDouble() ?? 0.0,
            onChanged: (value) {
              selectedColor.setIndividualColor(colorName, value.floor());
              textEditingController.text =
                  selectedColor.getColor().value.toRadixString(16);
              isValidated = true;
            },
            max: 255,
            activeColor: color,
            inactiveColor: color.withOpacity(0.2),
            divisions: 255,
            label: selectedColor.color[colorName].toString(),
          ),
        ),
      ],
    );
  }
}

class SelectedColor with ChangeNotifier {
  Map<String, int> color = {"red": 0, "green": 0, "blue": 0};

  void setIndividualColor(String color, int val, [bool notify = true]) {
    this.color[color] = val;
    if (notify) notifyListeners();
  }

  Color getColor() {
    return Color.fromRGBO(
      color["red"]!,
      color["green"]!,
      color["blue"]!,
      1,
    );
  }

  void setColorFromRgb(int red, int green, int blue, [bool notify = true]) {
    setIndividualColor("red", red, notify);
    setIndividualColor("green", green, notify);
    setIndividualColor("blue", blue, notify);
  }

  void setColorFromString(String radix) {
    Color col = Color(int.parse("0xff$radix"));
    setIndividualColor("red", col.red);
    setIndividualColor("green", col.green);
    setIndividualColor("blue", col.blue);
  }

  bool isValidColor(String color) {
    try {
      int.parse(color, radix: 16);
      return true;
    } catch (f) {
      return false;
    }
  }
}
