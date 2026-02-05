import 'package:flutter/material.dart';

class NoteFormWidget extends StatelessWidget {
  final bool? isImportant;
  final int? number;
  final String? title;
  final String? description;
  final ValueChanged<bool> onChangedImportant;
  final ValueChanged<int> onChangedNumber;
  final ValueChanged<String> onChangedTitle;
  final ValueChanged<String> onChangedDescription;

  const NoteFormWidget({
    Key? key,
    this.isImportant = false,
    this.number = 0,
    this.title = '',
    this.description = '',
    required this.onChangedImportant,
    required this.onChangedNumber,
    required this.onChangedTitle,
    required this.onChangedDescription,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: buildTitle(context)),
                IconButton(
                  icon: Icon(
                    size: 25.0,
                    isImportant ?? false
                        ? Icons.star
                        : Icons.star_border_outlined,
                    color: isImportant ?? false
                        ? colorScheme.primary
                        : Colors.grey,
                  ),
                  onPressed: () => onChangedImportant(!(isImportant ?? false)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            buildDescription(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget buildTitle(context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      maxLines: 1,
      initialValue: title,
      style: TextStyle(
        color: colorScheme.primary,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Título',
        hintStyle: TextStyle(color: colorScheme.primary.withOpacity(0.5)),
      ),
      validator: (title) => title != null && title.isEmpty
          ? 'O título não pode ser vazio.'
          : null,
      onChanged: onChangedTitle,
    );
  }

  Widget buildDescription(context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      maxLines: 5,
      initialValue: description,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Digite aqui sua nota.',
        hintStyle: TextStyle(color: colorScheme.primary.withOpacity(0.25)),
      ),
      validator: (title) => title != null && title.isEmpty
          ? 'Sua nota não pode ser vazia.'
          : null,
      onChanged: onChangedDescription,
    );
  }
}
