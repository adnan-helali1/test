import 'package:e_smart/core/copy/app_copy.dart';

class StaticPage {
  const StaticPage({
    required this.id,
    required this.slug,
    required this.title,
    required this.status,
    required this.locale,
    required this.body,
  });

  final String id;
  final String slug;
  final String title;
  final String status;
  final String locale;
  final String body;
}

/// Local published pages — not `GET /content` (that path is empty / 404).
const staticPages = <StaticPage>[
  StaticPage(
    id: 'pg1',
    slug: 'about',
    title: AppCopy.pageAbout,
    status: 'منشور',
    locale: 'ar',
    body:
        'دار نصري متجر عطور يهتم بتقديم تجربة تسوّق واضحة وموثوقة لمنتجات العطر.',
  ),
  StaticPage(
    id: 'pg2',
    slug: 'shipping-policy',
    title: AppCopy.pageShipping,
    status: 'منشور',
    locale: 'ar',
    body:
        'يتم تجهيز الطلبات وفق الفرع المتاح، ويُحتسب الشحن عند تأكيد الطلب حسب العنوان.',
  ),
  StaticPage(
    id: 'pg3',
    slug: 'privacy',
    title: AppCopy.pagePrivacy,
    status: 'منشور',
    locale: 'ar',
    body:
        'نحفظ بيانات الحساب والطلبات لغرض تنفيذ الخدمة فقط، ولا نشاركها خارج أغراض التشغيل.',
  ),
  StaticPage(
    id: 'pg4',
    slug: 'terms',
    title: AppCopy.pageTerms,
    status: 'منشور',
    locale: 'ar',
    body:
        'باستخدامك للمتجر فإنك توافق على شروط الشراء والدفع والاسترجاع المعتمدة في المنصة.',
  ),
  StaticPage(
    id: 'pg5',
    slug: 'faq',
    title: AppCopy.pageFaq,
    status: 'منشور',
    locale: 'ar',
    body:
        'للأسئلة حول الطلبات والشحن والدفع استخدم صفحة تواصل معنا أو محادثات الدعم من حسابك.',
  ),
  StaticPage(
    id: 'pg6',
    slug: 'payment-methods',
    title: AppCopy.pagePayment,
    status: 'منشور',
    locale: 'ar',
    body:
        'تتوفر طرق الدفع المفعّلة عند إتمام الطلب، ومنها الدفع عند الاستلام وبطاقة الائتمان عند التفعيل.',
  ),
  StaticPage(
    id: 'pg7',
    slug: 'contact',
    title: AppCopy.pageContact,
    status: 'منشور',
    locale: 'ar',
    body: 'للتواصل بشأن طلبك استخدم محادثات الدعم من لوحة الحساب بعد تسجيل الدخول.',
  ),
  StaticPage(
    id: 'pg8',
    slug: 'track-order',
    title: AppCopy.pageTrack,
    status: 'منشور',
    locale: 'ar',
    body:
        'يمكنك متابعة حالة طلبك من قسم طلباتي في الحساب بعد تسجيل الدخول.',
  ),
];

StaticPage? staticPageBySlug(String slug) {
  for (final page in staticPages) {
    if (page.slug == slug) return page;
  }
  return null;
}
