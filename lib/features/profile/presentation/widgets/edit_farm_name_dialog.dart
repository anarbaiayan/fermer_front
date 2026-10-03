import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';

/// Диалог смены названия фермы.
///
/// Контроллер принадлежит самому диалогу: его нельзя создавать снаружи и
/// уничтожать сразу после `await showDialog`. Пока идёт анимация закрытия,
/// поддерево диалога ещё живо, и закрытие клавиатуры меняет `viewInsets` —
/// `TextField` перестраивается и переподписывается на
/// `Listenable.merge([controller, focusNode])`. На уничтоженном контроллере
/// это падало с `ChangeNotifier was used after being disposed`, а следом —
/// с `_dependents.isEmpty` при размонтировании.
class EditFarmNameDialog extends StatefulWidget {
  final String initialName;

  const EditFarmNameDialog({super.key, required this.initialName});

  @override
  State<EditFarmNameDialog> createState() => _EditFarmNameDialogState();
}

class _EditFarmNameDialogState extends State<EditFarmNameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialName,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.profileEditFarmTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 255,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: l10n.profileFarmNameHint,
          filled: true,
          fillColor: const Color(0xFFF1F1ED),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dialogCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.profileSaveButton)),
      ],
    );
  }
}
