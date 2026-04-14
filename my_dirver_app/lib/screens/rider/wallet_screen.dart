import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  final _supabase = Supabase.instance.client;

  // دالة لجلب الرصيد الحقيقي من جدول البروفايل (أو المحفظة)
  Future<Map<String, dynamic>> _getWalletData() async {
    final userId = _supabase.auth.currentUser!.id;

    // نفترض وجود جدول باسم 'profiles' يحتوي على عمود 'wallet_balance'
    final data = await _supabase
        .from('profiles')
        .select('wallet_balance')
        .eq('id', userId)
        .single();

    // جلب آخر 5 معاملات من جدول 'transactions' (اختياري لو متاح)
    final transactions = await _supabase
        .from('transactions')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(5);

    return {
      'balance': data['wallet_balance'] ?? 0.0,
      'transactions': transactions,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFF),
      appBar: AppBar(
        title: Text("المحفظة",
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xff1C2541),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getWalletData(),
        builder: (context, snapshot) {
          // في حالة التحميل أو الخطأ نعرض قيم افتراضية
          double balance = snapshot.data?['balance']?.toDouble() ?? 0.0;
          List transactions = snapshot.data?['transactions'] ?? [];

          return Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBalanceCard(balance),
                  const SizedBox(height: 30),
                  Text("طرق الدفع",
                      style: GoogleFonts.cairo(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildPaymentMethod(
                    icon: Icons.payments_rounded,
                    title: "نقداً (كاش)",
                    sub: "الدفع يدوياً للسائق",
                    isSelected: true,
                    onTap: () {},
                  ),
                  _buildPaymentMethod(
                    icon: Icons.account_balance_wallet_rounded,
                    title: "رصيد المحفظة",
                    sub: "الدفع المباشر من التطبيق",
                    isSelected: false,
                    onTap: () {},
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("آخر المعاملات",
                          style: GoogleFonts.cairo(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      if (transactions.isNotEmpty)
                        TextButton(
                          onPressed: () {},
                          child: Text("عرض الكل",
                              style: GoogleFonts.cairo(color: const Color(0xff007AFF))),
                        ),
                    ],
                  ),

                  if (transactions.isEmpty)
                    Center(child: Text("لا توجد معاملات حالياً", style: GoogleFonts.cairo(color: Colors.grey)))
                  else
                    ...transactions.map((tx) => _buildTransactionItem(
                          tx['title'] ?? "رحلة",
                          tx['amount'].toString(),
                          "اليوم", // تحويل tx['created_at'] لاحقاً
                          tx['amount'] < 0,
                        )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff1C2541), Color(0xff3A506B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1C2541).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("إجمالي الرصيد الحالي",
              style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 5),
          Text("${balance.toStringAsFixed(2)} جـ",
              style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: Text("شحن الرصيد",
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xff1C2541),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(130, 45),
            ),
          )
        ],
      ),
    );
  }

  // الودجت الفرعية تظل كما هي مع تحسينات طفيفة في الألوان
  Widget _buildPaymentMethod({
    required IconData icon,
    required String title,
    required String sub,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: isSelected ? const Color(0xff007AFF) : Colors.transparent,
              width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: const Color(0xffF0F7FF),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: const Color(0xff007AFF)),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(sub, style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const Spacer(),
            Icon(isSelected ? Icons.check_circle : Icons.radio_button_off,
                 color: isSelected ? const Color(0xff007AFF) : Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(String title, String amount, String date, bool isNegative) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: isNegative ? const Color(0xffFFF0F0) : const Color(0xffF0FFF4),
                child: Icon(isNegative ? Icons.north_east : Icons.south_west,
                            size: 18, color: isNegative ? Colors.red : Colors.green),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(date, style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
          Text("${isNegative ? '' : '+'}$amount جـ",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isNegative ? Colors.redAccent : Colors.green)),
        ],
      ),
    );
  }
}