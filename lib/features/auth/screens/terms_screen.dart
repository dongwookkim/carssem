import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';

class TermsScreen extends ConsumerWidget {
  const TermsScreen({super.key});

  static const _accentColor = Color(0xFFEC5B13);

  Future<void> _acceptTerms(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('terms_accepted', true);
    if (context.mounted) {
      context.go('/permission');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '이용약관',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.divider,
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mascot
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 168,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 23),

            // Intro text
            const Text(
              '이 약관은 귀하가 CARSSEM 서비스를 이용할 때 적용되는\n규칙과 저희의 약속을 담고 있습니다.',
              style: TextStyle(
                fontSize: 14,
                height: 1.625,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 23),

            // Summary Section
            _buildSummarySection(),
            const SizedBox(height: 23),

            // Section 1
            _buildSection1(),
            const SizedBox(height: 23),

            // Section 2
            _buildSection2(),
            const SizedBox(height: 23),

            // Section 3
            _buildSection3(),
            const SizedBox(height: 23),

            // Section 4
            _buildSection4(),
            const SizedBox(height: 23),

            // Footer
            const Center(
              child: Text(
                '최종 수정일: 2024년 5월',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textHint,
                ),
              ),
            ),
          ],
        ),
      ),

      // Fixed Bottom Button
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          border: const Border(
            top: BorderSide(color: AppColors.divider),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 17, 16, 16),
        child: SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFBFDBFE).withValues(alpha: 0.6),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                  spreadRadius: -3,
                ),
                BoxShadow(
                  color: const Color(0xFFBFDBFE).withValues(alpha: 0.6),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _acceptTerms(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('동의하고 시작하기'),
            ),
          ),
        ),
      ),
    );
  }

  // ── Summary Section (주황 테두리) ──
  Widget _buildSummarySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 34, 25, 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accentColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(Icons.auto_awesome, '핵심 요약 (개요)'),
          const SizedBox(height: 16),
          _buildSummaryRow(
              '저희의 목표', 'AI를 통해 귀하의 복잡한 정비 내역을 깔끔한 디지털 목록으로 변환해 드리는 것입니다.'),
          const SizedBox(height: 16),
          _buildSummaryRow('귀하의 권리', '귀하는 언제든 서비스를 중단하고 데이터를 삭제할 수 있습니다.'),
          const SizedBox(height: 16),
          _buildSummaryRow('면책 사항',
              'AI의 분석 결과는 완벽하지 않을 수 있습니다. 최종적인 정비 판단은 전문가와 상담하시기 바랍니다.'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _accentColor,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              height: 1.714,
              color: Color(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }

  // ── Section 1: 서비스 이용 규칙 ──
  Widget _buildSection1() {
    return _buildSectionCard(
      icon: Icons.description_outlined,
      title: '1. CARSSEM 서비스 이용 규칙',
      children: [
        const Text(
          '귀하가 내역서를 스캔하고 서비스를 이용함으로써, 본 약관에 동의하게 됩니다.',
          style: TextStyle(
            fontSize: 14,
            height: 1.625,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoBox(
          title: '비회원제',
          content: '현재 서비스는 가입 없이 이용 가능합니다. 데이터는 귀하의 기기와 연결된 식별값(UUID)을 기반으로 관리됩니다.',
        ),
        const SizedBox(height: 16),
        _buildInfoBox(
          title: '사용자 의무',
          content: '타인의 정비 내역서나 개인정보가 포함된 문서를 무단으로 업로드해서는 안 됩니다.',
        ),
      ],
    );
  }

  // ── Section 2: 데이터 및 AI 기술 활용 ──
  Widget _buildSection2() {
    return _buildSectionCard(
      icon: Icons.memory,
      title: '2. 데이터 및 AI 기술 활용',
      children: [
        const Text(
          '저희는 더 나은 서비스를 만들기 위해 기술을 활용합니다.',
          style: TextStyle(
            fontSize: 14,
            height: 1.43,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 20),
        _buildLabeledItem(
          badge: 'AI',
          title: 'AI 인식',
          content:
              'AI가 내역서를 읽는 과정에서 오타나 금액 오류가 발생할 수 있습니다. 추출된 정보는 귀하가 직접 확인해야 합니다.',
        ),
        const SizedBox(height: 20),
        _buildLabeledItem(
          badge: 'DATA',
          title: '데이터 개선',
          content: '업로드된 내역서 정보(차량번호 제외)는 서비스 개선을 위한 데이터로 활용될 수 있습니다.',
        ),
      ],
    );
  }

  // ── Section 3: 책임 및 보증 ──
  Widget _buildSection3() {
    return _buildSectionCard(
      icon: Icons.shield_outlined,
      title: '3. 책임 및 보증',
      children: [
        _buildBulletItem('서비스 중단:', ' 기술적 문제나 점검을 위해 서비스가 일시적으로 중단될 수 있습니다.'),
        const SizedBox(height: 12),
        _buildBulletItem(
            '데이터 소멸:', ' 앱을 삭제하거나 휴대폰을 교체할 경우 데이터가 유실될 수 있습니다.'),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFEDD5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '책임의 제한:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _accentColor,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'CARSSEM은 정보 제공 도구일 뿐입니다. 서비스에서 얻은 정보를 바탕으로 내린 정비/매매 결정에 따른 결과에 대해 저희는 책임을 지지 않습니다.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.625,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Section 4: 서비스의 변화 및 법령 등 ──
  Widget _buildSection4() {
    return _buildSectionCard(
      icon: Icons.sync,
      title: '4. 서비스의 변화 및 법령 등',
      children: [
        const Text(
          '저희는 계속해서 성장하고 있습니다. 향후 백업 기능 제공 등을 위해 회원제로 전환될 수 있습니다. 이 경우 적용 14일 전에 앱 내 공지사항을 통해 상세히 안내해 드립니다.',
          style: TextStyle(
            fontSize: 14,
            height: 1.625,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '본 약관은 대한민국 법령을 따릅니다. 문의사항이 있으시면 언제든 아래로 연락해 주세요.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.625,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Icon(Icons.email_outlined, size: 12, color: _accentColor),
                  SizedBox(width: 8),
                  Text(
                    'help@carssem.com',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _accentColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Shared Widgets ──

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColors.textPrimary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 22, 25, 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(icon, title),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoBox({required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12,
              height: 1.625,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledItem({
    required String badge,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            badge,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.625,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBulletItem(String boldText, String normalText) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            '\u2022',
            style: TextStyle(fontSize: 14, color: _accentColor),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: boldText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
                TextSpan(
                  text: normalText,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.43,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
