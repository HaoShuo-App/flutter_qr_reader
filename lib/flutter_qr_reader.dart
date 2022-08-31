import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class FlutterQrReader {
  static const MethodChannel _channel =
      const MethodChannel('me.hetian.flutter_qr_reader');

  static Future<String?> imgScan(File file) async {
    if (file.existsSync() == false) {
      return null;
    }
    try {
      final rest =
          await _channel.invokeMethod("imgQrCode", {"file": file.path});
      return rest;
    } catch (e) {
      print(e);
      return null;
    }
  }
}

class QrReaderView extends StatefulWidget {
  final int autoFocusIntervalInMs;
  final bool torchEnabled;
  final double? width;
  final double? height;

  QrReaderView({
    Key? key,
    this.width,
    this.height,
    this.autoFocusIntervalInMs = 500,
    this.torchEnabled = false,
  }) : super(key: key);

  @override
  _QrReaderViewState createState() => new _QrReaderViewState();
}

class _QrReaderViewState extends State<QrReaderView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: "me.hetian.flutter_qr_reader.reader_view",
        creationParams: {
          "width": (widget.width ?? 0 * window.devicePixelRatio).floor(),
          "height": (widget.height ?? 0 * window.devicePixelRatio).floor(),
          "extra_focus_interval": widget.autoFocusIntervalInMs,
          "extra_torch_enabled": widget.torchEnabled,
        },
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
          new Factory<OneSequenceGestureRecognizer>(
              () => new EagerGestureRecognizer()),
        ].toSet(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: "me.hetian.flutter_qr_reader.reader_view",
        creationParams: {
          "width": widget.width,
          "height": widget.height,
          "extra_focus_interval": widget.autoFocusIntervalInMs,
          "extra_torch_enabled": widget.torchEnabled,
        },
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
          new Factory<OneSequenceGestureRecognizer>(
              () => new EagerGestureRecognizer()),
        ].toSet(),
      );
    } else {
      return Text('平台暂不支持');
    }
  }

  void _onPlatformViewCreated(int id) {}

  @override
  void dispose() {
    super.dispose();
  }
}

typedef ReadChangeBack = void Function(String, List<Offset>);
