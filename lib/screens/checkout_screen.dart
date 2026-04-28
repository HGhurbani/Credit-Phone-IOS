import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../providers/cart_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils.dart';

extension ContextExtensions on BuildContext {
  bool get isAr =>
      Provider.of<LocaleProvider>(this, listen: false).locale.languageCode ==
      'ar';
}

class CheckoutScreen extends StatefulWidget {
  final double totalPrice;

  const CheckoutScreen({
    Key? key,
    required this.totalPrice,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _authService = AuthService();
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;

  final _noteController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final primaryColor = const Color(0xFF1A2543);
  final secondaryColor = const Color(0xFFDEE3ED);
  final accentColor = const Color(0xFF00BFA5);

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.isLoggedIn) {
      _emailController.text = userProvider.user?.email ?? '';
      _phoneController.text = userProvider.user?.phone ?? '';
      _fullNameController.text = userProvider.user?.username ?? '';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.isAr;
    final isLoggedIn = Provider.of<UserProvider>(context).isLoggedIn;
    final cartItems = Provider.of<CartProvider>(context).items;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? "طلب المنتج" : "Product Request"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionHeader(
                  isAr ? "معلومات التواصل" : "Contact Information",
                ),
                _buildUserForm(isAr, isLoggedIn),
                const SizedBox(height: 20),
                _buildSectionHeader(
                    isAr ? "المنتجات المحددة" : "Selected Products"),
                _buildOrderSummary(isAr, cartItems),
                const SizedBox(height: 20),
                _buildSectionHeader(isAr ? "ملخص الطلب" : "Request Summary"),
                _buildPriceSummary(isAr),
                const SizedBox(height: 30),
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        child: Text(
                          isAr ? "إرسال الطلب" : "Submit Request",
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _buildUserForm(bool isAr, bool isLoggedIn) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(
              _fullNameController,
              isAr ? "الاسم الكامل" : "Full Name",
              validator: (value) => value!.trim().isEmpty
                  ? (isAr ? "الاسم مطلوب" : "Name is required")
                  : null,
            ),
            _buildTextField(
              _phoneController,
              isAr ? "رقم الهاتف" : "Phone",
              inputType: TextInputType.phone,
              validator: (value) => value!.trim().isEmpty
                  ? (isAr ? "رقم الهاتف مطلوب" : "Phone is required")
                  : null,
            ),
            _buildTextField(
              _emailController,
              isAr ? "البريد الإلكتروني" : "Email",
              inputType: TextInputType.emailAddress,
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) {
                  return isAr ? "البريد الإلكتروني مطلوب" : "Email is required";
                }
                if (!isValidEmail(email)) {
                  return isAr
                      ? "صيغة بريد إلكتروني غير صحيحة"
                      : "Invalid email format";
                }
                return null;
              },
            ),
            if (!isLoggedIn) ...[
              _buildTextField(
                _passwordController,
                isAr ? "كلمة المرور" : "Password",
                obscure: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return isAr ? "كلمة المرور مطلوبة" : "Password is required";
                  }
                  if (value.length < 6) {
                    return isAr
                        ? "كلمة المرور قصيرة جداً (6 أحرف على الأقل)"
                        : "Password too short (min 6 chars)";
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 15),
            _buildTextField(
              _noteController,
              isAr ? "ملاحظات (اختياري)" : "Notes (optional)",
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType inputType = TextInputType.text,
    bool obscure = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        obscureText: obscure,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: primaryColor.withOpacity(0.8)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: secondaryColor.withOpacity(0.3),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primaryColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primaryColor.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(bool isAr, List cartItems) {
    if (cartItems.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              isAr ? "سلة التسوق فارغة." : "Your cart is empty.",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...cartItems.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${isAr ? 'الكمية' : 'Qty'}: ${item.quantity}",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const Divider(height: 24),
            Text(
              isAr
                  ? 'سيتواصل معك فريقنا لتأكيد توفر المنتج وتفاصيل الطلب'
                  : 'Our team will contact you to confirm availability and order details',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary(bool isAr) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: secondaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryRow(isAr ? "إجمالي سعر المنتجات" : "Total Product Price",
              widget.totalPrice),
          const SizedBox(height: 8),
          Text(
            isAr
                ? "تواصل معنا لإتمام الطلب"
                : "Contact us to complete your order",
            style: TextStyle(
              color: primaryColor.withOpacity(0.9),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: primaryColor,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            "${formatNumber(value)} ${context.isAr ? 'ر.ق' : 'QAR'}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _ensureUserIsRegisteredAndLoggedIn({
    required String username,
    required String email,
    required String phone,
    required String password,
    required bool isAr,
    required UserProvider userProvider,
  }) async {
    try {
      await _authService.register(username, email, password, phone);
    } catch (error) {
      final message = _extractErrorMessage(error);
      if (!_isDuplicateAccountError(message)) {
        throw CheckoutAuthException(
          isAr
              ? 'تعذّر إنشاء الحساب: $message'
              : 'Failed to create the account: $message',
        );
      }
    }

    try {
      final user = await _loginWithEmailOrUsername(
        email: email,
        username: username,
        password: password,
      );
      userProvider.setUser(user);
    } catch (error) {
      final message = _extractErrorMessage(error);
      throw CheckoutAuthException(
        isAr
            ? 'تعذّر تسجيل الدخول. يرجى التأكد من صحة البريد الإلكتروني/اسم المستخدم وكلمة المرور أو تسجيل الدخول يدوياً. التفاصيل: $message'
            : 'We could not sign you in. Please verify your email/username and password or sign in manually. Details: $message',
      );
    }
  }

  Future<User> _loginWithEmailOrUsername({
    required String email,
    required String username,
    required String password,
  }) async {
    dynamic lastError;

    if (email.isNotEmpty) {
      try {
        return await _authService.login(email, password);
      } catch (error) {
        lastError = error;
      }
    }

    if (username.isNotEmpty) {
      try {
        return await _authService.login(username, password);
      } catch (error) {
        lastError = error;
      }
    }

    if (lastError is Exception) {
      throw lastError;
    }

    throw Exception(lastError?.toString() ?? 'Unknown login error');
  }

  String _extractErrorMessage(dynamic error) {
    final rawMessage = error.toString();
    const prefix = 'Exception: ';
    if (rawMessage.startsWith(prefix)) {
      return rawMessage.substring(prefix.length);
    }
    return rawMessage;
  }

  bool _isDuplicateAccountError(String message) {
    final lower = message.toLowerCase();
    return lower.contains('already registered') ||
        lower.contains('already exists') ||
        lower.contains('email exists') ||
        lower.contains('email address is already') ||
        lower.contains('مسجل') ||
        lower.contains('موجود') ||
        lower.contains('duplicate');
  }

  Future<void> _placeOrder() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isAr = context.isAr;

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? "يرجى ملء جميع الحقول المطلوبة بشكل صحيح."
                : "Please fill all required fields correctly.",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final wasLoggedIn = userProvider.isLoggedIn;
    final customerName = _fullNameController.text.trim();
    final customerEmail = _emailController.text.trim();
    final customerPhone = _phoneController.text.trim();
    final cartItems = cartProvider.items;

    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAr
              ? "لا يوجد منتجات في سلة التسوق."
              : "No products in the cart."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final lineItems = cartItems
        .map(
          (item) => {
            'product_id': item.product.id,
            'quantity': item.quantity,
          },
        )
        .toList();

    setState(() => _loading = true);

    try {
      if (!wasLoggedIn) {
        await _ensureUserIsRegisteredAndLoggedIn(
          username: customerName,
          email: customerEmail,
          phone: customerPhone,
          password: _passwordController.text.trim(),
          isAr: isAr,
          userProvider: userProvider,
        );
      } else {
        final currentUser = userProvider.user;
        final profileChanged = currentUser != null &&
            (currentUser.username != customerName ||
                currentUser.email != customerEmail ||
                currentUser.phone != customerPhone);

        if (profileChanged) {
          final updated = await _apiService.updateUserInfo(
            name: customerName,
            email: customerEmail,
            phone: customerPhone,
          );
          if (updated) {
            await userProvider.updateUser(
              username: customerName,
              email: customerEmail,
              phone: customerPhone,
            );
          }
        }
      }

      final customerId = userProvider.user?.id;

      await _apiService.createOrder(
        customerName: customerName,
        customerEmail: customerEmail,
        customerPhone: customerPhone,
        lineItems: lineItems,
        isNewCustomer: !wasLoggedIn,
        customerNote: _noteController.text,
        customerId: customerId,
      );

      if (!mounted) {
        cartProvider.clearCart();
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? "تم إرسال الطلب بنجاح! سيتواصل معك فريقنا لتأكيد توفر المنتج وتفاصيل الطلب."
                : "Request submitted successfully! Our team will contact you to confirm availability and order details.",
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );

      cartProvider.clearCart();
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/orders', (route) => false);
    } on CheckoutAuthException catch (authError) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authError.message), backgroundColor: Colors.red),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? "فشل في إرسال الطلب. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى."
                : "Failed to submit request. Please check your internet connection and try again.",
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}

class CheckoutAuthException implements Exception {
  final String message;

  CheckoutAuthException(this.message);

  @override
  String toString() => message;
}
