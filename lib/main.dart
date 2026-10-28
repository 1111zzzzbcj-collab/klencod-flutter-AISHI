import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const AishiApp());
}

// ألوان تطبيق AISHI
const Color bg = Color(0xFF0D1220);
const Color surface = Color(0xFF171F32);
const Color surface2 = Color(0xFF202B42);
const Color accent = Color(0xFF69E0C0);
const Color muted = Color(0xFF9BA8C2);

class AishiApp extends StatelessWidget {
  const AishiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AISHI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
        ),
      ),
      home: const AishiHome(),
    );
  }
}

class AishiStatus {
  final String name;
  final String text;
  final String? path;
  final String type;
  final Color color;
  final DateTime time;

  AishiStatus({
    required this.name,
    required this.text,
    this.path,
    required this.type,
    required this.color,
    required this.time,
  });
}

class AishiHome extends StatefulWidget {
  const AishiHome({super.key});

  @override
  State<AishiHome> createState() => _AishiHomeState();
}

class _AishiHomeState extends State<AishiHome> {
  int page = 0;

  final String userId =
      'AI-${Random().nextInt(900000) + 100000}';

  final ImagePicker picker = ImagePicker();

  final TextEditingController searchController =
      TextEditingController();

  String searchText = '';

  final List<AishiStatus> statuses = [];

  final List<Map<String, dynamic>> contacts = [
    {
      'name': 'أحمد محمد',
      'id': 'AI-184205',
      'message': 'مرحبًا، كيف حالك؟',
      'color': const Color(0xFF82A8FF),
      'unread': 2,
    },
    {
      'name': 'سارة علي',
      'id': 'AI-639174',
      'message': 'أرسلت صورة',
      'color': const Color(0xFFFF9FC8),
      'unread': 0,
    },
    {
      'name': 'محمد خالد',
      'id': 'AI-820451',
      'message': 'نتحدث لاحقًا إن شاء الله',
      'color': const Color(0xFFFFC66D),
      'unread': 0,
    },
    {
      'name': 'ملاحظاتي',
      'id': 'AI-105832',
      'message': 'مساحة خاصة لك',
      'color': accent,
      'unread': 0,
    },
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: bg,
          title: const Row(
            children: [
              Icon(
                Icons.forum_rounded,
                color: accent,
                size: 32,
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AISHI',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'تواصل بلا حدود',
                    style: TextStyle(
                      fontSize: 11,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() => page = 0);
              },
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: _newChat,
              icon: const Icon(Icons.add_comment_outlined),
            ),
          ],
        ),
        body: SafeArea(
          child: IndexedStack(
            index: page,
            children: [
              _chatsPage(),
              _statusesPage(),
              _peoplePage(),
              _settingsPage(),
              _profilePage(),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: const Color(0xFF12192A),
          indicatorColor: accent.withOpacity(0.18),
          selectedIndex: page,
          onDestinationSelected: (index) {
            setState(() => page = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble),
              label: 'الدردشات',
            ),
            NavigationDestination(
              icon: Icon(Icons.donut_large_outlined),
              selectedIcon: Icon(Icons.donut_large),
              label: 'الحالات',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: 'الأشخاص',
            ),
            NavigationDestination(
              icon: Icon(Icons.palette_outlined),
              selectedIcon: Icon(Icons.palette),
              label: 'المظهر',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_circle_outlined),
              selectedIcon: Icon(Icons.account_circle),
              label: 'حسابي',
            ),
          ],
        ),
      ),
    );
  }

  // صفحة المحادثات
  Widget _chatsPage() {
    final filtered = contacts.where((contact) {
      final name = contact['name'].toString();
      final message = contact['message'].toString();

      return name.contains(searchText) ||
          message.contains(searchText);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _accountCard(),
        const SizedBox(height: 22),
        const Text(
          'محادثاتك',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: (value) {
            setState(() => searchText = value);
          },
          decoration: InputDecoration(
            hintText: 'ابحث عن محادثة...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...filtered.map((contact) {
          return _chatTile(contact);
        }),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Text(
            'هذه نسخة تجريبية. الرسائل لا تصل إلى '
            'مستخدمين آخرين حتى نربط التطبيق بخادم.',
            style: TextStyle(
              color: muted,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _accountCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF253858),
            Color(0xFF17413D),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accent.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.fingerprint, color: accent),
              SizedBox(width: 8),
              Text('معرّف حسابك'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            userId,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'احتفظ بمعرّفك للرجوع إليه لاحقًا.',
            style: TextStyle(color: muted),
          ),
        ],
      ),
    );
  }

  Widget _chatTile(Map<String, dynamic> contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(17),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 5,
        ),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor:
              (contact['color'] as Color).withOpacity(0.18),
          child: Icon(
            Icons.person,
            color: contact['color'] as Color,
          ),
        ),
        title: Text(
          contact['name'].toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          contact['message'].toString(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: muted),
        ),
        trailing: const Icon(
          Icons.chevron_left,
          color: muted,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPage(
                contact: contact,
              ),
            ),
          );
        },
      ),
    );
  }

  // صفحة الحالات
  Widget _statusesPage() {
    final now = DateTime.now();

    final visibleStatuses = statuses.where((status) {
      return now.difference(status.time).inHours < 24;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'الحالات',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'شارك لحظاتك مع أصدقائك',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: accent,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'حالتي',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'أضف نصًا أو صورة أو فيديو',
                      style: TextStyle(
                        color: muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _showAddStatus,
                icon: const Icon(
                  Icons.add_circle,
                  color: accent,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'الحالات الحديثة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (visibleStatuses.isEmpty)
          const Padding(
            padding: EdgeInsets.all(25),
            child: Center(
              child: Text(
                'لم تنشر حالة بعد. ابدأ بإضافة حالتك!',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted),
              ),
            ),
          ),
        ...visibleStatuses.reversed.map((status) {
          return _statusTile(status);
        }),
      ],
    );
  }

  Widget _statusTile(AishiStatus status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: Container(
          width: 54,
          height: 54,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: accent,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            backgroundColor: status.color,
            child: Icon(
              status.type == 'video'
                  ? Icons.play_arrow
                  : status.type == 'image'
                      ? Icons.image
                      : Icons.text_fields,
              color: Colors.white,
            ),
          ),
        ),
        title: Text(
          status.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          status.text.isEmpty
              ? status.type == 'video'
                  ? 'حالة فيديو'
                  : 'حالة صورة'
              : status.text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: muted),
        ),
        onTap: () => _openStatus(status),
      ),
    );
  }

  // إضافة حالة نص أو صورة أو فيديو
  void _showAddStatus() {
    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'إضافة حالة جديدة',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                ListTile(
                  leading: const Icon(
                    Icons.text_fields,
                    color: accent,
                  ),
                  title: const Text('حالة نصية'),
                  subtitle: const Text('اكتب ما تريد مشاركته'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _addTextStatus();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.image,
                    color: accent,
                  ),
                  title: const Text('اختيار صورة'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickMedia(false);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.video_library,
                    color: accent,
                  ),
                  title: const Text('اختيار فيديو'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickMedia(true);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addTextStatus() {
    final controller = TextEditingController();
    Color selectedColor = const Color(0xFF285B55);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: surface,
              title: const Text('حالة نصية'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    maxLines: 4,
                    maxLength: 300,
                    decoration: const InputDecoration(
                      hintText: 'اكتب حالتك هنا...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    children: [
                      Colors.teal,
                      Colors.blue,
                      Colors.purple,
                      Colors.deepOrange,
                      Colors.green,
                    ].map((color) {
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedColor = color;
                          });
                        },
                        child: CircleAvatar(
                          backgroundColor: color,
                          radius: 17,
                          child: selectedColor == color
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: bg,
                  ),
                  onPressed: () {
                    final text = controller.text.trim();

                    if (text.isEmpty) return;

                    setState(() {
                      statuses.add(
                        AishiStatus(
                          name: 'حالتي',
                          text: text,
                          type: 'text',
                          color: selectedColor,
                          time: DateTime.now(),
                        ),
                      );
                    });

                    Navigator.pop(dialogContext);
                  },
                  child: const Text('نشر'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _pickMedia(bool video) async {
    try {
      final XFile? file = video
          ? await picker.pickVideo(
              source: ImageSource.gallery,
              maxDuration: const Duration(seconds: 60),
            )
          : await picker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 90,
            );

      if (file == null || !mounted) return;

      setState(() {
        statuses.add(
          AishiStatus(
            name: 'حالتي',
            text: '',
            path: file.path,
            type: video ? 'video' : 'image',
            color: accent,
            time: DateTime.now(),
          ),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أُضيفت الحالة بنجاح'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر اختيار الملف: $e'),
        ),
      );
    }
  }

  void _openStatus(AishiStatus status) {
    if (status.type == 'text') {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: status.color,
            content: SizedBox(
              width: double.maxFinite,
              child: Text(
                status.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      );
    } else if (status.type == 'image' && status.path != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MediaStatusViewer(
            path: status.path!,
            video: false,
          ),
        ),
      );
    } else if (status.type == 'video' && status.path != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MediaStatusViewer(
            path: status.path!,
            video: true,
          ),
        ),
      );
    }
  }

  // صفحة الأشخاص
  Widget _peoplePage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'الأشخاص',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'ابحث عن أصدقائك باستخدام معرّف AISHI.',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: bg,
            padding: const EdgeInsets.all(15),
          ),
          onPressed: _newChat,
          icon: const Icon(Icons.person_add),
          label: const Text('إضافة شخص بالمعرّف'),
        ),
        const SizedBox(height: 20),
        ...contacts.map((contact) {
          return _chatTile(contact);
        }),
      ],
    );
  }

  void _newChat() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: surface,
          title: const Text('إضافة شخص'),
          content: TextField(
            controller: controller,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(
              hintText: 'AI-123456',
              labelText: 'معرّف المستخدم',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: bg,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'البحث الحقيقي يحتاج إلى ربط خادم.',
                    ),
                  ),
                );
              },
              child: const Text('بحث'),
            ),
          ],
        );
      },
    );
  }

  // صفحة المظهر
  Widget _settingsPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'المظهر والتخصيص',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _settingTile(
          Icons.color_lens,
          'ألوان AISHI',
          'كحلي داكن وأخضر نعناعي',
        ),
        _settingTile(
          Icons.text_fields,
          'حجم الخط',
          'إعدادات الخط ستُطوّر لاحقًا',
        ),
        _settingTile(
          Icons.notifications,
          'الإشعارات',
          'تحتاج إلى تفعيل خدمة الإشعارات',
        ),
        _settingTile(
          Icons.lock,
          'الخصوصية',
          'ستُضاف مع نظام الحسابات',
        ),
      ],
    );
  }

  // عنصر إعدادات قابل لإضافة أمر عند الضغط
  Widget _settingTile(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(17),
      ),
      child: ListTile(
        leading: Icon(icon, color: accent),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: muted),
        ),
        onTap: onTap,
      ),
    );
  }

  // صفحة حسابي
  Widget _profilePage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 20),
        const CircleAvatar(
          radius: 48,
          backgroundColor: surface2,
          child: Icon(
            Icons.person,
            size: 55,
            color: accent,
          ),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'مستخدم AISHI',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            userId,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              color: accent,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 25),
        _settingTile(
          Icons.account_circle,
          'الملف الشخصي',
          'تعديل الاسم والصورة قريبًا',
        ),
        _settingTile(
          Icons.shield,
          'الأمان',
          'نظام الأمان يحتاج إلى خادم',
        ),
        _settingTile(
          Icons.info_outline,
          'حول التطبيق',
          'AISHI - تواصل بلا حدود',
          onTap: _showAbout,
        ),
      ],
    );
  }

  // نافذة معلومات التطبيق وصاحب المشروع
  void _showAbout() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: surface2,
                  child: Icon(
                    Icons.forum_rounded,
                    color: accent,
                    size: 42,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'AISHI',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: accent,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'تواصل بلا حدود',
                  style: TextStyle(
                    fontSize: 13,
                    color: muted,
                  ),
                ),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(color: surface2),
                SizedBox(height: 10),
                Text(
                  'تطبيق AISHI',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'مساحة للتواصل والمحادثات ومشاركة '
                  'الحالات والصور والفيديو.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: muted,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 20),
                Icon(
                  Icons.person_pin_circle_outlined,
                  color: accent,
                  size: 30,
                ),
                SizedBox(height: 6),
                Text(
                  'صاحب المشروع',
                  style: TextStyle(
                    color: muted,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'خالد الشامي',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 18),
                Text(
                  'الإصدار 1.0.0',
                  style: TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '© 2026 AISHI',
                  style: TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: bg,
                  minimumSize: const Size(140, 45),
                ),
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('إغلاق'),
              ),
            ],
          ),
        );
      },
    );
  }
}

// شاشة المحادثة التجريبية
class ChatPage extends StatefulWidget {
  final Map<String, dynamic> contact;

  const ChatPage({
    super.key,
    required this.contact,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController controller =
      TextEditingController();

  final List<String> messages = [
    'مرحبًا بك في AISHI 👋',
    'هذه محادثة تجريبية.',
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.contact['color'] as Color;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: bg,
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: Icon(
                  Icons.person,
                  color: color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.contact['name'].toString(),
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      widget.contact['id'].toString(),
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _notice('المكالمات غير مفعلة بعد'),
                icon: const Icon(Icons.call),
              ),
              IconButton(
                onPressed: () => _notice(
                  'مكالمات الفيديو غير مفعلة بعد',
                ),
                icon: const Icon(Icons.videocam),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final mine = index.isEven;

                  return Align(
                    alignment: mine
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 290,
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: mine
                            ? const Color(0xFF20483F)
                            : surface,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Text(messages[index]),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              color: surface,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _notice(
                      'إرسال الملفات يحتاج إلى تطوير إضافي',
                    ),
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: accent,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالة...',
                        filled: true,
                        fillColor: bg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(
                    onPressed: _send,
                    icon: const Icon(
                      Icons.send,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _send() {
    final text = controller.text.trim();

    if (text.isEmpty) return;

    setState(() {
      messages.add(text);
    });

    controller.clear();
  }

  void _notice(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }
}

// شاشة عرض الصور والفيديو
class MediaStatusViewer extends StatefulWidget {
  final String path;
  final bool video;

  const MediaStatusViewer({
    super.key,
    required this.path,
    required this.video,
  });

  @override
  State<MediaStatusViewer> createState() =>
      _MediaStatusViewerState();
}

class _MediaStatusViewerState
    extends State<MediaStatusViewer> {
  VideoPlayerController? controller;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();

    if (widget.video) {
      controller = VideoPlayerController.file(
        File(widget.path),
      );

      controller!.initialize().then((_) {
        if (!mounted) return;

        setState(() => loading = false);
        controller!.play();
      }).catchError((e) {
        if (!mounted) return;

        setState(() {
          loading = false;
          error = 'تعذر تشغيل الفيديو';
        });
      });
    } else {
      loading = false;
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('حالة AISHI'),
      ),
      body: Center(
        child: loading
            ? const CircularProgressIndicator(
                color: accent,
              )
            : error != null
                ? Text(error!)
                : widget.video
                    ? _videoView()
                    : InteractiveViewer(
                        child: Image.file(
                          File(widget.path),
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) {
                            return const Text(
                              'تعذر عرض الصورة',
                            );
                          },
                        ),
                      ),
      ),
    );
  }

  Widget _videoView() {
    final videoController = controller!;

    if (!videoController.value.isInitialized) {
      return const CircularProgressIndicator(
        color: accent,
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio:
                  videoController.value.aspectRatio,
              child: VideoPlayer(videoController),
            ),
          ),
        ),
        IconButton(
          iconSize: 55,
          color: accent,
          onPressed: () {
            setState(() {
              if (videoController.value.isPlaying) {
                videoController.pause();
              } else {
                videoController.play();
              }
            });
          },
          icon: Icon(
            videoController.value.isPlaying
                ? Icons.pause_circle
                : Icons.play_circle,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}