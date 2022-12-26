import 'package:flutter/material.dart';
import 'package:hashpro/state/post_settings/moders/post.dart';
import 'package:hashpro/views/components/post/post_thumbnail_view.dart';

class PostsGridView extends StatelessWidget {
  final Iterable<Post> posts;
  const PostsGridView({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final currPost = posts.elementAt(index);
        return PostThumbnailView(
          post: currPost,
          onTapped: () {
          },
        );
      },
    );
  }
}
