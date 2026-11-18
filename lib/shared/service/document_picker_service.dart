import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:delivery_app/core/utils/app_logger.dart';

class PickedDocumentImage {
  final String path;
  final String fileName;
  final bool isDemoSample;

  const PickedDocumentImage({
    required this.path,
    required this.fileName,
    this.isDemoSample = false,
  });
}

abstract class DocumentPickerService {
  String? get lastErrorMessage;
  Future<PickedDocumentImage?> pickFromCamera();
  Future<PickedDocumentImage?> pickFromGallery();
  PickedDocumentImage createSampleDocument(String label);
}

class DocumentPickerServiceImpl implements DocumentPickerService {
  final ImagePicker _picker;
  String? _lastErrorMessage;

  DocumentPickerServiceImpl({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  @override
  String? get lastErrorMessage => _lastErrorMessage;

  @override
  Future<PickedDocumentImage?> pickFromCamera() async {
    _lastErrorMessage = null;
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1600,
      );
      if (file == null) return null;
      return PickedDocumentImage(
        path: file.path,
        fileName: file.name,
      );
    } on PlatformException catch (e) {
      if (e.code == 'channel-error') {
        _lastErrorMessage =
            'Camera plugin needs a full app restart (stop & rebuild) to link native Android/iOS code.';
      } else {
        _lastErrorMessage = e.message ?? 'Camera unavailable on this device.';
      }
      AppLogger.warning(
        'Camera capture unavailable (${e.code}): $_lastErrorMessage',
        tag: 'DocumentPickerService',
      );
      return null;
    } catch (e, st) {
      _lastErrorMessage = 'Camera capture failed: $e';
      AppLogger.error(
        'Camera capture failed',
        error: e,
        stackTrace: st,
        tag: 'DocumentPickerService',
      );
      return null;
    }
  }

  @override
  Future<PickedDocumentImage?> pickFromGallery() async {
    _lastErrorMessage = null;
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1600,
      );
      if (file == null) return null;
      return PickedDocumentImage(
        path: file.path,
        fileName: file.name,
      );
    } on PlatformException catch (e) {
      if (e.code == 'channel-error') {
        _lastErrorMessage =
            'Gallery plugin needs a full app restart (stop & rebuild) to link native Android/iOS code.';
      } else {
        _lastErrorMessage = e.message ?? 'Gallery unavailable on this device.';
      }
      AppLogger.warning(
        'Gallery selection unavailable (${e.code}): $_lastErrorMessage',
        tag: 'DocumentPickerService',
      );
      return null;
    } catch (e, st) {
      _lastErrorMessage = 'Gallery selection failed: $e';
      AppLogger.error(
        'Gallery selection failed',
        error: e,
        stackTrace: st,
        tag: 'DocumentPickerService',
      );
      return null;
    }
  }

  @override
  PickedDocumentImage createSampleDocument(String label) {
    _lastErrorMessage = null;
    final slug = label.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    return PickedDocumentImage(
      path: 'demo://documents/$slug.jpg',
      fileName: '${slug}_verified.jpg',
      isDemoSample: true,
    );
  }
}
