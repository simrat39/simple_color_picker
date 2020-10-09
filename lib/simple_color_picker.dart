library simple_color_picker;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';

class SimpleColorPicker extends StatelessWidget {
  const SimpleColorPicker(
      {Key key,
      @required this.height,
      @required this.onColorSelect,
      @required this.onCancel,
      this.initialColor})
      : super(key: key);

  final double height;
  final Function(Color color) onColorSelect;
  final Function() onCancel;
  final Color initialColor;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: _MaterialColorPicker(
        height: this.height,
        onColorSelect: this.onColorSelect,
        initialColor: this.initialColor,
        onCancel: this.onCancel,
      ),
    );
  }
}

class _MaterialColorPicker extends StatefulWidget {
  _MaterialColorPicker(
      {Key key,
      @required this.height,
      @required this.onColorSelect,
      this.initialColor,
      @required this.onCancel})
      : super(key: key);

  final double height;
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
      selectedColor.setColorInitial("red", Theme.of(context).accentColor.red);
      selectedColor.setColorInitial(
          "green", Theme.of(context).accentColor.green);
      selectedColor.setColorInitial("blue", Theme.of(context).accentColor.blue);
    } else {
      selectedColor.setColorInitial("red", widget.initialColor.red);
      selectedColor.setColorInitial("green", widget.initialColor.green);
      selectedColor.setColorInitial("blue", widget.initialColor.blue);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        var selectedColor = watch(colorProvider);
        Color col = Color.fromRGBO(selectedColor.color["red"],
            selectedColor.color["green"], selectedColor.color["blue"], 1.0);
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
                  Center(
                    child: Text(
                      "#" + col.value.toRadixString(16).toUpperCase(),
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
                        ),
                      ),
                      Expanded(
                        child: ColorRow(
                          color: Colors.greenAccent,
                          colorName: "green",
                        ),
                      ),
                      Expanded(
                        child: ColorRow(
                          color: Colors.blueAccent,
                          colorName: "blue",
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
                        selectedColor.setColor("red", widget.initialColor.red);
                        selectedColor.setColor(
                            "green", widget.initialColor.green);
                        selectedColor.setColor(
                            "blue", widget.initialColor.blue);
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
  ColorRow({Key key, this.colorName, this.color}) : super(key: key);

  final String colorName;
  final Color color;

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
                  color.setColor(widget.colorName, value.floor());
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

  void setColor(String color, int val) {
    this.color[color] = val;
    notifyListeners();
  }

  void setColorInitial(String color, int val) {
    this.color[color] = val;
  }
}
