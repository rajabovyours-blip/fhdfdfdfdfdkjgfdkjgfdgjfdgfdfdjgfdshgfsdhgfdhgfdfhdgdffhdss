import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Banner uchun ovozsiz, avtomatik takrorlanadigan video pleer.
///
/// Reklama bannerlarida video ko'rsatish uchun ishlatiladi — boshqaruv
/// tugmalari (play/pause/progress) YO'Q, chunki bu shunchaki "jonli rasm"
/// vazifasini bajaradi, YouTube kabi pleer emas.
class VideoBannerPlayer extends StatefulWidget {
  final String videoUrl;
  final Widget Function(BuildContext context)? placeholderBuilder;

  const VideoBannerPlayer({
    super.key,
    required this.videoUrl,
    this.placeholderBuilder,
  });

  @override
  State<VideoBannerPlayer> createState() => _VideoBannerPlayerState();
}

class _VideoBannerPlayerState extends State<VideoBannerPlayer> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(covariant VideoBannerPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller?.dispose();
      _controller = null;
      _ready = false;
      _failed = false;
      _init();
    }
  }

  Future<void> _init() async {
    try {
      final controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      _controller = controller;
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      // Reklama banneri — doim ovozsiz, doim aylanadi. Foydalanuvchidan
      // hech qanday amal talab qilinmaydi.
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();
      setState(() => _ready = true);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return widget.placeholderBuilder?.call(context) ??
          const ColoredBox(color: Colors.black12);
    }
    if (!_ready || _controller == null) {
      return widget.placeholderBuilder?.call(context) ??
          const ColoredBox(color: Colors.black12);
    }
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: _controller!.value.size.width,
        height: _controller!.value.size.height,
        child: VideoPlayer(_controller!),
      ),
    );
  }
}
