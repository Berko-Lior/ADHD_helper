extension RemoveAll on String {
  String removeAll(Iterable<String> valuesToRemove) => valuesToRemove.fold(
        this,
        (result, valueToRemove) => result.replaceAll(
          valueToRemove,
          '',
        ),
      );
}
