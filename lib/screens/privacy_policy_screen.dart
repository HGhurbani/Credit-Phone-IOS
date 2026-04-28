// lib/screens/privacy_policy_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LocaleProvider>(context).locale.languageCode;
    final isAr = lang == 'ar';
    final textDirection = isAr ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isAr ? 'سياسة الخصوصية' : 'Privacy Policy',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          backgroundColor: const Color(0xFF1A2543),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0, // Remove shadow for a cleaner look
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Container(
          // Optional: Add a subtle background color or gradient
          color: const Color(0xFFF9F9F9),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  context,
                  isAr ? 'مقدمة' : 'Introduction',
                  Icons.info_outline,
                ),
                _buildParagraph(
                  isAr
                      ? 'نحن نحترم خصوصيتك ونلتزم التزاماً كاملاً بحماية بياناتك الشخصية. توضح هذه السياسة كيف نقوم بجمع معلوماتك واستخدامها وحمايتها.'
                      : 'We highly respect your privacy and are fully committed to protecting your personal data. This policy explains how we collect, use, and safeguard your information.',
                  textDirection,
                ),
                const SizedBox(height: 20),

                _buildSectionHeader(
                  context,
                  isAr ? 'جمع واستخدام البيانات' : 'Data Collection and Usage',
                  Icons.data_usage,
                ),
                _buildBulletPoint(
                  isAr
                      ? 'لا نقوم بجمع بيانات بطاقات الدفع أو معالجة مدفوعات إلكترونية داخل التطبيق. قد يتم استكمال بعض خطوات التواصل أو التأكيد خارج التطبيق، مثل واتساب أو التواصل المباشر مع فريقنا.'
                      : 'We do not collect card-payment data or process electronic payments inside the app. Some communication or order-confirmation steps may be completed outside the app, such as via WhatsApp or direct contact with our team.',
                  textDirection,
                ),
                _buildBulletPoint(
                  isAr
                      ? 'البيانات التي نجمعها (مثل الاسم، رقم الهاتف، وأي ملاحظات تقدمها) تستخدم فقط لتسهيل التواصل معك ومعالجة طلباتك بفعالية.'
                      : 'The data we collect (such as your name, phone number, and any notes you provide) is solely used to facilitate communication with you and to process your orders efficiently.',
                  textDirection,
                ),
                _buildBulletPoint(
                  isAr
                      ? 'قد نستخدم رقم هاتفك للتواصل معك بخصوص حالة طلبك أو لتقديم الدعم اللازم.'
                      : 'Your phone number may be used to contact you regarding your order status or to provide necessary support.',
                  textDirection,
                ),
                _buildBulletPoint(
                  isAr
                      ? 'لا يطلب التطبيق بيانات مالية حساسة مثل الراتب أو بيانات البنك أو مستندات الهوية لإرسال طلب شراء. نستخدم معلومات التواصل والمنتجات المختارة والملاحظات فقط لمعالجة الاستفسار.'
                      : 'The app does not request sensitive financial data such as salary, bank details, or identity documents to submit a purchase inquiry. We use contact details, selected products, and notes only to process the inquiry.',
                  textDirection,
                ),
                _buildBulletPoint(
                  isAr
                      ? 'إذا فعّلت الإشعارات، فقد نقوم بمعالجة رمز الإشعارات الخاص بجهازك وإرسال إشعارات تتعلق بحالة الطلب أو التحديثات الخدمية المهمة.'
                      : 'If you enable notifications, we may process your device notification token and send notifications related to order status or other important service updates.',
                  textDirection,
                ),
                const SizedBox(height: 20),

                _buildSectionHeader(
                  context,
                  isAr ? 'مشاركة البيانات' : 'Data Sharing',
                  Icons.security,
                ),
                _buildParagraph(
                  isAr
                      ? 'نحن لا نبيع بياناتك الشخصية. وقد تتم مشاركة الحد الأدنى من البيانات فقط مع مزودي الخدمات والتقنيات اللازمة لتشغيل التطبيق، أو مع الجهات المعنية بمعالجة الطلب أو الالتزام بالمتطلبات القانونية والتنظيمية عند الحاجة.'
                      : 'We do not sell your personal data. We may share the minimum necessary data only with service and technology providers required to operate the app, or with parties involved in processing your request or meeting legal and regulatory obligations when needed.',
                  textDirection,
                ),
                const SizedBox(height: 20),

                _buildSectionHeader(
                  context,
                  isAr ? 'الاحتفاظ بالبيانات وحذف الحساب' : 'Data Retention and Account Deletion',
                  Icons.delete_forever_outlined,
                ),
                _buildParagraph(
                  isAr
                      ? 'نحتفظ ببيانات الحساب طوال مدة استخدامك للتطبيق ما لم تتطلب القوانين أو متطلبات معالجة الطلب الاحتفاظ ببعض السجلات لمدة أطول.'
                      : 'We retain account data for as long as you use the app unless laws or request-processing requirements require certain records to be kept longer.',
                  textDirection,
                ),
                _buildBulletPoint(
                  isAr
                      ? 'لحذف حسابك: من التطبيق انتقل إلى "حسابي" ثم اختر "حذف الحساب". سيُطلب منك التأكيد، وبعد التأكيد يتم حذف الحساب والبيانات المرتبطة به ولا يمكن التراجع عن ذلك.'
                      : 'To delete your account: In the app, go to "My Account" then choose "Delete Account". You will be asked to confirm; after confirmation your account and associated data will be permanently deleted and cannot be recovered.',
                  textDirection,
                ),
                _buildBulletPoint(
                  isAr
                      ? 'بعد حذف الحساب تُزال بياناتك من أنظمتنا وفق إجراءاتنا الأمنية، ولا نطلب منك التواصل مع الدعم أو استخدام طريقة خارج التطبيق لحذف حسابك.'
                      : 'After account deletion your data is removed from our systems in line with our security procedures. You do not need to contact support or use any method outside the app to delete your account.',
                  textDirection,
                ),
                const SizedBox(height: 20),

                _buildSectionHeader(
                  context,
                  isAr ? 'نطاق التطبيق' : 'Application Scope',
                  Icons.phone_android,
                ),
                _buildParagraph(
                  isAr
                      ? 'هذا التطبيق لا يقدم قروضاً أو تمويلاً أو موافقات تقسيط. يتيح فقط تصفح المنتجات وإرسال طلبات شراء، ويتم استكمال الطلب عبر فريقنا خارج التطبيق.'
                      : 'This app does not provide loans, credit, financing, or installment approval. It only allows customers to browse products and submit purchase inquiries. Order completion is handled by our team outside the app.',
                  textDirection,
                ),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    isAr ? 'شكراً لثقتك بنا.' : 'Thank you for trusting us.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                    textDirection: textDirection,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6FE0DA), size: 28),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2543),
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Divider(color: Color(0xFF6FE0DA), thickness: 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParagraph(String text, TextDirection textDirection) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          height: 1.6,
          color: Colors.grey[800],
        ),
        textAlign: TextAlign.justify, // Justify text for a more formal look
        textDirection: textDirection,
      ),
    );
  }

  Widget _buildBulletPoint(String text, TextDirection textDirection) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 10, right: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 8, color: const Color(0xFF6FE0DA)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.grey[800],
              ),
              textDirection: textDirection,
            ),
          ),
        ],
      ),
    );
  }
}