import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/locale_provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;

  bool notificationsEnabled = true;
  bool _isLoading = false;

  final NotificationService _notificationService = NotificationService.instance;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.username ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadNotificationSettings() async {
    final enabled = await _notificationService.getNotificationsEnabled();
    if (!mounted) return;
    setState(() => notificationsEnabled = enabled);
  }

  Future<void> _saveAccountInfo(UserProvider userProvider, bool isAr) async {
    if (!_isValidEmail(_emailController.text.trim())) {
      _showSnackBar(
        isAr ? 'الرجاء إدخال بريد إلكتروني صحيح.' : 'Please enter a valid email address.',
        Colors.red,
      );
      return;
    }

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final success = await _apiService.updateUserInfo(
        name: name,
        email: email,
        phone: phone,
        password: password.isNotEmpty ? password : null,
      );

      if (!mounted) return;
      if (success) {
        await userProvider.updateUser(username: name, email: email, phone: phone);
        _showSnackBar(
          isAr ? 'تم حفظ بيانات الحساب بنجاح!' : 'Account info saved successfully!',
          const Color(0xFF6FE0DA),
        );
      } else {
        _showSnackBar(
          isAr ? 'فشل في حفظ البيانات. الرجاء المحاولة مرة أخرى.' : 'Failed to save. Please try again.',
          Colors.red,
        );
      }
    } catch (e) {
      if (!mounted) return;
      if (e.toString().contains('expired_token')) {
        _showSnackBar(
          isAr ? 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى.' : 'Session expired, please log in again.',
          Colors.red,
        );
        await userProvider.logout();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      } else if (e.toString().contains('user_id_missing')) {
        _showSnackBar(
          isAr
              ? 'لم يتم العثور على معرف المستخدم. يرجى تسجيل الخروج ثم تسجيل الدخول مرة أخرى.'
              : 'User ID is missing. Please log out and log in again.',
          Colors.orange,
        );
      } else {
        _showSnackBar(isAr ? 'فشل في حفظ البيانات.' : 'Failed to save.', Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String? _getSectionArgument(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    return args is String ? args : null;
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final languageCode = localeProvider.locale.languageCode;
    final isAr = languageCode == 'ar';
    final isLoggedIn = userProvider.isLoggedIn;
    final section = _getSectionArgument(context);

    final showGeneral = section == null || section == 'app';
    final showAccount = section == null || (section == 'account' && isLoggedIn);

    String appBarTitle;
    if (section == 'account') {
      appBarTitle = isAr ? 'بياناتي' : 'My data';
    } else if (section == 'app') {
      appBarTitle = isAr ? 'إعدادات التطبيق' : 'App settings';
    } else {
      appBarTitle = isAr ? 'الإعدادات / Settings' : 'الإعدادات / Settings';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: const Color(0xFF1A2543),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        children: [
          if (showGeneral) ...[
            _buildSectionHeader(isAr ? 'عام' : 'General'),
            const SizedBox(height: 12),
            _sectionCard(
              icon: Icons.language_rounded,
              title: isAr ? 'اللغة / Language' : 'اللغة / Language',
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: languageCode,
                  icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF1A2543)),
                  onChanged: (value) {
                    if (value != null) {
                      localeProvider.setLocale(Locale(value));
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (!mounted) return;
                        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
                      });
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'ar', child: Text('عربي / Arabic')),
                    DropdownMenuItem(value: 'en', child: Text('إنجليزي / English')),
                  ],
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _sectionCard(
              icon: Icons.notifications_active_outlined,
              title: isAr ? 'الإشعارات' : 'Notifications',
              trailing: Switch.adaptive(
                value: notificationsEnabled,
                onChanged: (val) async {
                  await _notificationService.setNotificationsEnabled(val);
                  if (!mounted) return;
                  setState(() => notificationsEnabled = val);
                },
                activeColor: const Color(0xFF6FE0DA),
                inactiveTrackColor: Colors.grey.shade300,
                inactiveThumbColor: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
          ],
          if (showAccount) ...[
            _buildSectionHeader(isAr ? "معلومات الحساب" : "Account Info"),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _nameController,
              hint: isAr ? 'الاسم الكامل' : 'Full Name',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 15),
            _buildInputField(
              controller: _emailController,
              hint: isAr ? 'البريد الإلكتروني' : 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),
            _buildInputField(
              controller: _phoneController,
              hint: isAr ? 'رقم الجوال' : 'Phone Number',
              icon: Icons.phone_android_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),
            _buildInputField(
              controller: _passwordController,
              hint: isAr
                  ? 'كلمة المرور الجديدة (اترك فارغاً لعدم التغيير)'
                  : 'New Password (leave blank to keep current)',
              icon: Icons.lock_outline_rounded,
              obscure: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Icon(Icons.save_alt_rounded, color: Colors.white, size: 24),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A2543),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              label: Text(
                isAr ? 'حفظ بيانات الحساب' : 'Save account info',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: _isLoading ? null : () => _saveAccountInfo(userProvider, isAr),
            ),
            const SizedBox(height: 40),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.red.shade100, width: 1.5),
              ),
              tileColor: Colors.red.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: const Icon(Icons.logout_rounded, color: Colors.red, size: 26),
              title: Text(
                isAr ? 'تسجيل الخروج' : 'Logout',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.red, size: 20),
              onTap: () => _confirmLogout(userProvider, isAr),
            ),
            const SizedBox(height: 40),
          ],
          const SizedBox(height: 24),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          _buildSectionHeader(isAr ? 'الدعم والمساعدة' : 'Support & Help'),
          const SizedBox(height: 15),
          _sectionCard(
            icon: Icons.support_agent_rounded,
            title: isAr ? 'الاستفسارات والشكاوى' : 'Inquiries & Complaints',
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF1A2543)),
            onTap: () => _showContactDialog(isAr),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Color(0xFF1A2543),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      shadowColor: Colors.grey.withOpacity(0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF1A2543), size: 28),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1A2543),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFF1A2543)),
      cursorColor: const Color(0xFF6FE0DA),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF6FE0DA), size: 24),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF6FE0DA), width: 3),
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _confirmLogout(UserProvider userProvider, bool isAr) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAr ? 'تسجيل الخروج' : 'Logout'),
        content: Text(isAr ? 'هل تريد تسجيل الخروج؟' : 'Do you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await userProvider.logout();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isAr ? 'تسجيل الخروج' : 'Logout'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(bool isAr) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isAr ? 'تواصل معنا' : 'Contact Us'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildContactOption(
              "+97477704313",
              "77704313",
              isAr ? "الاستفسار والطلب والمبيعات" : "Inquiries, orders & sales",
            ),
            const SizedBox(height: 12),
            _buildContactOption(
              "+97471727771",
              "71727771",
              isAr ? "الاستفسار والطلب والمبيعات" : "Inquiries, orders & sales",
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.email_rounded, color: Color(0xFF1A2543)),
              title: Text(isAr ? "البريد الإلكتروني للدعم" : "Support Email"),
              onTap: () => _launchEmail("support@creditphoneqatar.com", isAr),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isAr ? 'إغلاق' : 'Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption(String phoneNumber, String displayNumber, String label) {
    return ListTile(
      leading: const Icon(Icons.phone, color: Colors.green),
      title: Text(label),
      subtitle: Text(displayNumber),
      onTap: () {
        Navigator.pop(context);
        _openWhatsApp(phoneNumber);
      },
    );
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final uri = Uri.parse("https://wa.me/$phoneNumber");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail(String email, bool isAr) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': isAr ? 'استفسار من التطبيق' : 'App Inquiry',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
