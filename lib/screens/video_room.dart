import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoRoom extends StatefulWidget {
  const VideoRoom({super.key});

  @override
  _VideoRoomState createState() => _VideoRoomState();
}

class _VideoRoomState extends State<VideoRoom> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _simulateVideoJoin();
  }

  _simulateVideoJoin() async {
    // محاكاة انتظار الانضمام للفيديو
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }

  _openJitsiWeb() async {
    // فتح Jitsi في المتصفح مباشرة
    final roomName = "teachzone-class-${DateTime.now().millisecondsSinceEpoch}";
    final jitsiUrl = "https://meet.jit.si/$roomName";

    final Uri url = Uri.parse(jitsiUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print('Cannot launch $jitsiUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('غرفة الفيديو'),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 20),
                  Text('جاري تحضير الغرفة...', style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_call, size: 80, color: Colors.green),
                  SizedBox(height: 20),
                  Text('نظام الفيديو جاهز!',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('Jitsi Meet متكامل مع التطبيق',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                  SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _openJitsiWeb,
                    icon: Icon(Icons.open_in_new),
                    label: Text('فتح غرفة الفيديو'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'ملاحظة: نظام الفيديو الحقيقي جاهز للتكامل\nعند تشغيل التطبيق على Android/iOS',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.orange),
                  ),
                ],
              ),
            ),
    );
  }
}
