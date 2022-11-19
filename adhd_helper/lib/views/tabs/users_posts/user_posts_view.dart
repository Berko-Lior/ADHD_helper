import 'package:flutter/material.dart';
import 'package:hashpro/state/posts/providers/user_posts_provider.dart';
import 'package:hashpro/views/components/animations/empty_contents_with_text_animation_view.dart';
import 'package:hashpro/views/components/animations/error_animation_view.dart';
import 'package:hashpro/views/components/animations/loading_animation_view.dart';
import 'package:hashpro/views/components/post/posts_grid_view.dart';
import 'package:hashpro/views/constants/strings.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UserPostsView extends ConsumerWidget {
  const UserPostsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(userPostsProvider);
    return RefreshIndicator(
      onRefresh: () {
        ref.refresh(userPostsProvider);

        // Even if sometime it will refresh instantly, we want to show the
        //refresh indicator for 1 second so the user will know that the refresh hepened.
        return Future.delayed(const Duration(seconds: 1));
      },
      child: posts.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const EmptyContentsWithTextAnimationView(
                text: Strings.youHaveNoTasks);
          } else {
            return PostsGridView(posts: posts);
          }
        },
        error: (error, stackTrace) => const ErrorAnimationView(),
        loading: () => const LoadingAnimationView(),
      ),
    );
  }
}
