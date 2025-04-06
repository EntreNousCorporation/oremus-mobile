import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkStatusOverlay extends StatefulWidget {
  final Widget child;
  final NetworkOverlayConfig config;
  final GlobalKey<NavigatorState> navigatorKey;

  const NetworkStatusOverlay({Key? key,
    required this.child,
    this.config = const NetworkOverlayConfig(),
    required this.navigatorKey,
  }) : super(key: key);

  @override
  State<NetworkStatusOverlay> createState() => _NetworkStatusOverlayState();
}

class _NetworkStatusOverlayState extends State<NetworkStatusOverlay> with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _connectivityTimer;
  bool _isVisible = false;
  bool _hasInternetAccess = true;
  int _consecutiveSuccesses = 0;
  static const int _requiredSuccesses = 2;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeNetworkMonitoring();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<double>(
      begin: -100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));
  }

  void _initializeNetworkMonitoring() {
    _checkInternetConnectivity();

    _subscription = Connectivity().onConnectivityChanged.listen(
          (List<ConnectivityResult> results) {
        if (!mounted) return;

        if (results.contains(ConnectivityResult.none)) {
          _updateConnectionStatus(false);
        } else {
          _checkInternetConnectivity();
        }
      },
      onError: (error) {
        debugPrint('Error monitoring network status: $error');
        _updateConnectionStatus(false);
      },
    );

    _connectivityTimer = Timer.periodic(
      const Duration(seconds: 10),
          (_) => _checkInternetConnectivity(),
    );
  }

  Future<void> _checkInternetConnectivity() async {
    if (!mounted) return;

    bool hasInternet = false;
    try {
      final results = await Future.wait([
        _checkHost('google.com'),
        _checkHost('cloudflare.com'),
        _checkHost('1.1.1.1'),
      ], eagerError: false);

      hasInternet = results.any((result) => result);
    } catch (e) {
      debugPrint('Error checking internet connectivity: $e');
      hasInternet = false;
    }

    if (mounted) {
      if (hasInternet) {
        _consecutiveSuccesses++;
        if (_consecutiveSuccesses >= _requiredSuccesses) {
          _updateConnectionStatus(true);
        }
      } else {
        _consecutiveSuccesses = 0;
        _updateConnectionStatus(false);
      }
    }
  }

  Future<bool> _checkHost(String host) async {
    try {
      final result = await InternetAddress.lookup(host)
          .timeout(const Duration(seconds: 3));
      final socket = await Socket.connect(host, 80,
          timeout: const Duration(seconds: 3))
          .then((socket) {
        socket.destroy();
        return true;
      });
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty && socket;
    } catch (e) {
      return false;
    }
  }

  void _updateConnectionStatus(bool hasInternet) {
    if (_hasInternetAccess != hasInternet) {
      setState(() {
        _hasInternetAccess = hasInternet;
      });

      if (!hasInternet) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    }
  }

  void _showOverlay() {
    if (_isVisible || !mounted) return;

    final overlay = widget.navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).padding.top + 50,
            left: 20,
            right: 20,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: child,
                ),
              ),
              child: _buildOverlayContent(),
            ),
          ),
        ],
      ),
    );

    try {
      overlay.insert(_overlayEntry!);
      _isVisible = true;
      _animationController.forward();
      widget.config.onShow?.call();
    } catch (e) {
      debugPrint('Error showing network overlay: $e');
    }
  }

  Widget _buildOverlayContent() {
    return Material(
      elevation: widget.config.elevation,
      borderRadius: BorderRadius.circular(8),
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: widget.config.backgroundColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, color: widget.config.textColor),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                widget.config.noConnectionMessage,
                style: TextStyle(color: widget.config.textColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _hideOverlay() async {
    if (_overlayEntry != null && _isVisible) {
      try {
        await _animationController.reverse();
        _overlayEntry?.remove();
        widget.config.onHide?.call();
      } catch (e) {
        debugPrint('Error removing network overlay: $e');
      } finally {
        _overlayEntry = null;
        _isVisible = false;
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _connectivityTimer?.cancel();
    _animationController.dispose();
    _hideOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class NetworkOverlayConfig {
  final Color backgroundColor;
  final Color textColor;
  final double elevation;
  final String noConnectionMessage;
  final VoidCallback? onShow;
  final VoidCallback? onHide;

  const NetworkOverlayConfig({
    this.backgroundColor = Colors.red,
    this.textColor = Colors.white,
    this.elevation = 4.0,
    this.noConnectionMessage = 'Pas d\'accès Internet',
    this.onShow,
    this.onHide,
  });
}
