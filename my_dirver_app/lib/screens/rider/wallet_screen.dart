import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFF),
      appBar: AppBar(
        title: Text("المحفظة",
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xff1C2541),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceCard(),
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
                icon: Icons.credit_card_rounded,
                title: "**** 4242",
                sub: "بطاقة فيزا منتهية في 12/26",
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
                  TextButton(
                    onPressed: () {},
                    child: Text("عرض الكل",
                        style:
                            GoogleFonts.cairo(color: const Color(0xff007AFF))),
                  ),
                ],
              ),
              _buildTransactionItem(
                  "رحلة إلى مول العرب", "- 120 جـ", "اليوم، 12:30 م", true),
              _buildTransactionItem(
                  "شحن المحفظة", "+ 500 جـ", "أمس، 09:00 ص", false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff007AFF), Color(0xff0057FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff007AFF).withValues(alpha: 0.3),
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
          Text("1,250.00 جـ",
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
              foregroundColor: const Color(0xff007AFF),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(130, 45),
            ),
          )
        ],
      ),
    );
  }

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
              color: isSelected ? const Color(0xff007AFF) : Colors.white,
              width: 2),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4))
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
                Text(title,
                    style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text(sub,
                    style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xff007AFF), size: 25)
            else
              const Icon(Icons.radio_button_off, color: Colors.grey, size: 25),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
      String title, String amount, String date, bool isNegative) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: isNegative
                    ? const Color(0xffFFF0F0)
                    : const Color(0xffF0FFF4),
                child: Icon(
                  isNegative ? Icons.north_east : Icons.south_west,
                  size: 18,
                  color: isNegative ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(date,
                      style:
                          GoogleFonts.cairo(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
          Text(amount,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isNegative ? Colors.redAccent : Colors.green)),
        ],
      ),
    );
  }
}
