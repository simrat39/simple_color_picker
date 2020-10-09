library simple_color_picker;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';

class SimpleColorPicker extends StatelessWidget {
  const SimpleColorPicker(
      {Key key,
      @required this.height,
      @required this.onColorSelect,
      @required this.onCancel,
      @required this.width,
      this.initialColor})
      : super(key: key);

  final double height;
  final double width;
  final Function(Color color) onColorSelect;
  final Function() onCancel;
  final Color initialColor;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: _MaterialColorPicker(
        height: this.height,
        width: this.width,
        onColorSelect: this.onColorSelect,
        initialColor: this.initialColor,
        onCancel: this.onCancel,
      ),
    );
  }
}

bool isValidated = true;

class _MaterialColorPicker extends StatefulWidget {
  _MaterialColorPicker({
    Key key,
    @required this.height,
    @required this.width,
    @required this.onColorSelect,
    this.initialColor,
    @required this.onCancel,
  }) : super(key: key);

  final double height;
  final double width;
  final Function(Color color) onColorSelect;
  final Function() onCancel;
  final Color initialColor;

  @override
  _MaterialColorPickerState createState() => _MaterialColorPickerState();
}

final colorProvider = ChangeNotifierProvider<SelectedColor>((ref) {
  return SelectedColor();
});

class _MaterialColorPickerState extends State<_MaterialColorPicker> {
  @override
  void didChangeDependencies() {
    var selectedColor = context.read(colorProvider);
    if (widget.initialColor == null) {
      Color accent = Theme.of(context).accentColor;
      selectedColor.setColorFromRgbInitial(
          accent.red, accent.green, accent.blue);
    } else {
      selectedColor.setColorFromRgbInitial(
        widget.initialColor.red,
        widget.initialColor.green,
        widget.initialColor.blue,
      );
    }
    _textEditingController.text =
        selectedColor.getColor().value.toRadixString(16);
    super.didChangeDependencies();
  }

  TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
  }

  double getFieldWidth() {
    if (widget.width == double.infinity) {
      return MediaQuery.of(context).size.width;
    } else {
      return widget.width;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        var selectedColor = watch(colorProvider);
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
                        if (text.length != 8 ||
                            !selectedColor.isValidColor(text)) {
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
                        ),
                      ),
                      Expanded(
                        child: ColorRow(
                          color: Colors.greenAccent,
                          colorName: "green",
                          textEditingController: _textEditingController,
                        ),
                      ),
                      Expanded(
                        child: ColorRow(
                          color: Colors.blueAccent,
                          colorName: "blue",
                          textEditingController: _textEditingController,
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
                        widget.onCancel();
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
                        selectedColor.setColorFromRgb(
                            widget.initialColor.red,
                            widget.initialColor.green,
                            widget.initialColor.blue);
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
      },
    );
  }
}

class ColorRow extends StatefulWidget {
  ColorRow({Key key, this.colorName, this.color, this.textEditingController})
      : super(key: key);

  final String colorName;
  final Color color;
  final TextEditingController textEditingController;

  @override
  _ColorRowState createState() => _ColorRowState();
}

class _ColorRowState extends State<ColorRow> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        var color = watch(colorProvider);
        return Row(
          children: [
            Text(
              widget.colorName[0].toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).hintColor,
              ),
            ),
            Expanded(
              child: Slider(
                value: color.color[widget.colorName].toDouble(),
                onChanged: (value) {
                  color.setIndividualColor(widget.colorName, value.floor());
                  widget.textEditingController.text =
                      color.getColor().value.toRadixString(16);
                  isValidated = true;
                },
                max: 255,
                activeColor: widget.color,
                inactiveColor: widget.color.withOpacity(0.2),
                divisions: 255,
                label: color.color[widget.colorName].toString(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SelectedColor with ChangeNotifier {
  Map<String, int> color = {};

  void setIndividualColor(String color, int val) {
    this.color[color] = val;
    notifyListeners();
  }

  void setIndividualColorInitial(String color, int val) {
    this.color[color] = val;
  }

  Color getColor() {
    return Color.fromRGBO(
      color["red"],
      color["green"],
      color["blue"],
      1,
    );
  }

  void setColorFromRgb(int red, int green, int blue) {
    setIndividualColor("red", red);
    setIndividualColor("green", green);
    setIndividualColor("blue", blue);
  }

  void setColorFromRgbInitial(int red, int green, int blue) {
    setIndividualColorInitial("red", red);
    setIndividualColorInitial("green", green);
    setIndividualColorInitial("blue", blue);
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
