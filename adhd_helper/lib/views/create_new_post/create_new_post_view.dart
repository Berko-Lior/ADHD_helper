import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hashpro/state/auth/providars/user_id_provider.dart';
import 'package:hashpro/state/image_upload/models/file_type.dart';
import 'package:hashpro/state/image_upload/models/thumbnail_request.dart';
import 'package:hashpro/state/image_upload/providers/image_upload_provider.dart';
import 'package:hashpro/state/post_settings/moders/post_setting.dart';
import 'package:hashpro/state/post_settings/providers/post_settings_provider.dart';
import 'package:hashpro/views/components/file_thumbnail_view.dart';
import 'package:hashpro/views/constants/strings.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CreateNewPostView extends StatefulHookConsumerWidget {
  final File fileToPost;
  final FileType fileType;
  const CreateNewPostView({
    required this.fileToPost,
    required this.fileType,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateNewPostViewState();
}

class _CreateNewPostViewState extends ConsumerState<CreateNewPostView> {
  @override
  Widget build(BuildContext context) {
    final thumbnailRequest = ThumbnailRequest(
      file: widget.fileToPost,
      fileType: widget.fileType,
    );
    final postSettings = ref.watch(postSettingProvider);
    final postController = useTextEditingController();
    final isPostButtonEnabled = useState(false);
    useEffect(() {
      void listener() {
        isPostButtonEnabled.value = postController.text.isNotEmpty;
      }

      postController.addListener(listener);

      return () => postController.removeListener(listener);
    }, [postController]);

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.createNewPost),
        actions: [
          IconButton(
            onPressed: isPostButtonEnabled.value
                ? () async {
                    final userId = ref.read(userIdProvider);
                    if (userId != null) {
                      final message = postController.text;
                      final isUploaded = await ref
                          .read(imageUploadNofifierProvider.notifier)
                          .upload(
                            file: widget.fileToPost,
                            fileType: widget.fileType,
                            message: message,
                            postSettings: postSettings,
                            userId: userId,
                          );
                      if (isUploaded && mounted) {
                        Navigator.of(context).pop();
                      }
                    }
                  }
                : null,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail
            FileThumbnailView(
              thumbnailRequest: thumbnailRequest,
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: Strings.pleaseWriteYourMessageHere,
                ),
                autofocus: true,
                maxLines: null,
                controller: postController,
              ),
            ),
            ...PostSetting.values.map(
              (currPostSetting) => ListTile(
                title: Text(currPostSetting.title),
                subtitle: Text(currPostSetting.description),
                trailing: Switch(
                  value: postSettings[currPostSetting] ?? false,
                  onChanged: (isOn) =>
                      ref.read(postSettingProvider.notifier).setSetting(
                            setting: currPostSetting,
                            value: isOn,
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
