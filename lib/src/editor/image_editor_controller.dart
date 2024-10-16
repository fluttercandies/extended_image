part of 'editor.dart';

/// [ImageEditorController] is used to control the state of the image editor
/// by providing functions like rotating, flipping, undoing, and redoing actions.
/// It communicates with the editor state and allows for real-time updates using
/// Flutter's `ChangeNotifier`.

class ImageEditorController extends ChangeNotifier
    with ImageEditorControllerMixin {
  ExtendedImageEditorState? _state;
  ExtendedImageEditorState? get state => _state;

  /// Retrieves the current rotation angle of the image.
  /// Defaults to 0 if no rotation has been applied.
  double get rotateAngle => _state?._editActionDetails?.rotateAngle ?? 0;

  /// Retrieves the current crop aspect ratio.
  /// Returns null if not set, or a value greater than 0 if a ratio is applied.
  double? get cropAspectRatio => _state?._editActionDetails?.cropAspectRatio;

  /// Retrieves the original aspect ratio of the crop rectangle before any changes.
  /// Returns null, or a value equal to or greater than 0.
  double? get originalCropAspectRatio =>
      _state?._editActionDetails?.originalCropAspectRatio;

  /// Retrieves the details of the current edit action, which may include
  /// transformations like cropping, rotating, and scaling.
  EditActionDetails? get editActionDetails => _state?._editActionDetails;

  /// Flips the image horizontally. You can enable animation and adjust the
  /// animation duration.
  @override
  void flip({
    bool animation = false,
    Duration duration = const Duration(milliseconds: 200),
  }) {
    _state?.flip(animation: animation, duration: duration);
  }

  /// Redoes the most recent undone action in the editor.
  @override
  void redo() {
    _state?.redo();
  }

  /// Resets the image editor to its initial state, undoing all transformations.
  @override
  void reset() {
    _state?.reset();
  }

  /// Rotates the image by a specified angle. Optionally, you can animate the rotation
  /// and adjust the rotation of the crop rectangle if the angle is a multiple of 90.
  @override
  void rotate({
    double angle = 90,
    bool animation = false,
    Duration duration = const Duration(milliseconds: 200),
    bool rotateCropRect = true,
  }) {
    _state?.rotate(
      angle: angle,
      animation: animation,
      duration: duration,
      rotateCropRect: rotateCropRect,
    );
  }

  /// Undoes the most recent action in the editor.
  @override
  void undo() {
    _state?.undo();
  }

  /// Returns `true` if the user can redo a previous undone action, otherwise `false`.
  @override
  bool get canRedo => _state?.canRedo ?? false;

  /// Returns `true` if the user can undo the most recent action, otherwise `false`.
  @override
  bool get canUndo => _state?.canUndo ?? false;

  /// Notifies listeners of state changes.
  /// call on the history of editor is changed
  void _notifyListeners() {
    notifyListeners();
  }

  /// Updates the crop aspect ratio of the image. A value of `null` allows freeform cropping.
  @override
  void updateCropAspectRatio(double? aspectRatio) {
    _state?.updateCropAspectRatio(aspectRatio);
  }

  @override
  ui.Rect? getCropRect() {
    return _state?.getCropRect();
  }
}

/// `ImageEditorControllerMixin` provides a mixin with common image editing functions.
/// It defines methods for actions like rotating, flipping, undoing, and redoing,
/// which can be used in conjunction with an image editor controller.
mixin ImageEditorControllerMixin {
  /// Rotates the image by a specified angle, with an option to animate the rotation.
  /// Rotation of the crop rect occurs only if the angle is a multiple of 90.
  void rotate({
    double angle = 90,
    bool animation = false,
    Duration duration = const Duration(milliseconds: 200),
    bool rotateCropRect = true,
  });

  /// Flips the image horizontally. Optionally, you can animate the flip action.
  void flip({
    bool animation = false,
    Duration duration = const Duration(milliseconds: 200),
  });

  /// Resets the image editor, undoing all changes.
  void reset();

  /// Undoes the most recent action.
  void undo();

  /// Redoes the most recent undone action.
  void redo();

  /// Returns `true` if the user can undo an action, otherwise `false`.
  bool get canUndo;

  /// Returns `true` if the user can redo a previously undone action, otherwise `false`.
  bool get canRedo;

  /// Updates the crop aspect ratio of the image.
  void updateCropAspectRatio(double? aspectRatio);

  /// Get the rect to crop.
  Rect? getCropRect();
}
