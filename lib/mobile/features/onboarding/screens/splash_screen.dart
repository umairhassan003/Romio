import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:romio/core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final VideoPlayerController _videoController;
  var _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('images/Romio.mp4')
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _videoController
          ..addListener(_onVideoProgress)
          ..play();
      }).catchError((Object _) {
        _goToOnboardingAfterFallback();
      });
  }

  void _onVideoProgress() {
    if (_videoController.value.position >= _videoController.value.duration) {
      _goToOnboarding();
    }
  }

  void _goToOnboardingAfterFallback() {
    Future<void>.delayed(const Duration(seconds: 5), () {
      _goToOnboarding();
    });
  }

  void _goToOnboarding() {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    _videoController.removeListener(_onVideoProgress);
    context.go('/onboarding');
  }

  @override
  void dispose() {
    _videoController
      ..removeListener(_onVideoProgress)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBurgundy,
      body: SizedBox.expand(
        child: _videoController.value.isInitialized
            ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              )
            : Center(
                child: SvgPicture.asset(
                  'images/RomioLogo.svg',
                  width: 200,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
      ),
    );
  }
}
