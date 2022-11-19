import 'package:flutter/foundation.dart' show immutable;
import 'package:hashpro/views/components/constants/strings.dart';
import 'package:hashpro/views/components/dialogs/alert_dialog_model.dart';

@immutable
class DeleteDialog extends AlertDialogModel<bool> {
  const DeleteDialog({
    required String titleObjectToDElete,
  }) : super(
          title: '${Strings.delete} $titleObjectToDElete?',
          message:
              '${Strings.areYouSureYouWantToDeleteThis} $titleObjectToDElete?',
          buttons: const {
            Strings.cancel: false,
            Strings.delete: true,
          },
        );
}
