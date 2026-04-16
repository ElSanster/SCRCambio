import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:scrcambio_app/core/adaptative_colors.dart';

class ColorSelectorTile extends StatefulWidget {
  final Color currentColor;
  final List<Color> presetColors;
  final bool darkMode;
  final ValueChanged<Color> onColorChanged;
  final String text;

  const ColorSelectorTile({
    super.key,
    required this.currentColor,
    required this.presetColors,
    required this.darkMode,
    required this.onColorChanged,
    required this.text,
  });

  @override
  State<ColorSelectorTile> createState() => _ColorSelectorTileState();
}

class _ColorSelectorTileState extends State<ColorSelectorTile> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.currentColor;
  }

  /// Abre el diálogo de la paleta de colores predefinidos (estilo Block)
  void _showBlockPickerDialog() {
    Color tempColor = _selectedColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Selecciona un color"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Paleta de colores estilo Block (imagen 2)
              BlockPicker(
                pickerColor: tempColor,
                onColorChanged: (color) {
                  tempColor = color;
                },
                availableColors: widget.presetColors,
              ),
              const SizedBox(height: 8),
              // Botón para abrir el selector personalizado (imagen 1)
              TextButton.icon(
                icon: const Icon(Icons.colorize),
                label: const Text("Color personalizado"),
                onPressed: () {
                  Navigator.pop(context); // cierra el diálogo block
                  _showCustomColorDialog();
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Aceptar"),
            onPressed: () {
              setState(() => _selectedColor = tempColor);
              widget.onColorChanged(tempColor);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  /// Abre el sub-diálogo con el selector de rueda de color (imagen 1)
  void _showCustomColorDialog() {
    Color tempColor = _selectedColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Color personalizado"),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: tempColor,
            onColorChanged: (color) {
              tempColor = color;
            },
            enableAlpha: false,
            hexInputBar: true, // muestra el campo Hex como en la imagen 1
            pickerAreaHeightPercent: 0.7,
            displayThumbColor: true,
          ),
        ),
        actions: [
          // Volver al bloque de colores predefinidos
          TextButton(
            child: const Text("← Volver"),
            onPressed: () {
              Navigator.pop(context);
              _showBlockPickerDialog();
            },
          ),
          TextButton(
            child: const Text("Aceptar"),
            onPressed: () {
              setState(() => _selectedColor = tempColor);
              widget.onColorChanged(tempColor);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: AdaptativeColors.textBody(widget.text, widget.darkMode),
      subtitle: AdaptativeColors.smallText(
        '#${_selectedColor.value.toRadixString(16).toUpperCase().padLeft(8, '0').substring(2)}',
        widget.darkMode,
      ),
      trailing: GestureDetector(
        onTap: _showBlockPickerDialog,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _selectedColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.darkMode ? Colors.white38 : Colors.black26,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
