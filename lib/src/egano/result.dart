import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:egano/src/background/particle.dart';
import 'package:egano/src/background/particles_animation.dart';

class EganoResult extends StatefulWidget {
  final File image;
  final String method;
  final String privateMessage;
  final int privateKey;

  const EganoResult({super.key, required this.image, required this.method, required this.privateKey, required this.privateMessage});

  @override
  _EganoResultState createState() => _EganoResultState();
}

class _EganoResultState extends State<EganoResult> {
  late List<Particle> particles;
  final directory = Directory('/storage/emulated/0/Pictures/Egano');
  bool _isLoading = true;
  String plainText = 'Halox!';

  @override
  void initState() {
    particles = [];
    _startLoading();
    for (int i = 0; i < 20; i++) {
      particles.add(Particle(width: 600, height: 701));
    }
    update();
    super.initState();
  }

  update() {
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (mounted) {
        setState(() {});
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _saveImage() async {
    try {
      final timestamp = DateFormat('HH-mm-dd-MM-yyyy').format(DateTime.now());
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final extension = widget.image.path.split('.').last;
      final path = '${directory.path}/encrypted-$timestamp.$extension';
      final file = File(path);
      await file.writeAsBytes(await widget.image.readAsBytes());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image saved to $path', style: const TextStyle(color: Colors.black87)),
          backgroundColor: const Color.fromARGB(255, 230, 250, 252),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save image: $e', style: const TextStyle(color: Colors.black87)),
          backgroundColor: const Color.fromARGB(255, 230, 250, 252),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _startLoading() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D2437),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF1D2437),
        title: Text.rich(
          TextSpan(
            style: const TextStyle(color: Colors.white),
            children: [
              const TextSpan(
                text: 'EGANO',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: widget.method == 'Encrypt' ? ' | Encryptor' : ' | Decryptor',
              ),
            ],
          ),
        ),
      ),
      body: CustomPaint(
        painter: ParticlesPainter(particles: particles, opacity: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Center(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Column(
                          children: [
                            Container(
                              width: _isLoading ? 50 : double.infinity,
                              decoration: BoxDecoration(
                                border: _isLoading ? null : Border.all(
                                  color: Colors.white30,
                                  style: BorderStyle.solid,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _isLoading
                              ? const AspectRatio(
                                aspectRatio: 1,
                                child: CircularProgressIndicator(),
                              )
                              : SizedBox(
                                height: 240,
                                child: Image.file(widget.image),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(width: 5),
                                Expanded(child: 
                                  _isLoading 
                                  ? const Text('', style: TextStyle(color: Colors.white70))
                                  : Text.rich(
                                    TextSpan(
                                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                                      children: [
                                        TextSpan(
                                          text: widget.method == 'Encrypt' ? 'ENCRYPTED: ' : 'DECRYPTED: ',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: plainText,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  MaterialButton(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    color: _isLoading ? const Color.fromARGB(118, 15, 98, 81) : const Color(0xFF0f6252),
                    onPressed: () async {
                      if (!_isLoading) {
                        if (widget.method == "Encrypt") {
                          await _saveImage();
                        } else {
                          Clipboard.setData(const ClipboardData(text: "Decrypted text"));
                        }
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.method == "Encrypt" ? Icons.download : Icons.copy_all_rounded,
                          color: _isLoading ? Colors.white38 : Colors.white70),
                        const SizedBox(width: 8),
                        Text(
                          widget.method == "Encrypt" ? "Download Encrypted Image" : "Copy Decrypted Text",
                          style: TextStyle(color: _isLoading ? Colors.white38 : Colors.white70, fontWeight: FontWeight.bold)
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              )
            )
          ],
        ),
      )
    );
  }
}