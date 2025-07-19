// lib/widgets/briefing_card_bubble.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

// --- Main Widget ---
class BriefingCardBubble extends StatelessWidget {
  final Map<String, dynamic> data;

  const BriefingCardBubble({super.key, required this.data});

  // Helper function to safely access nested data from the JSON
  T? _get<T>(List<String> path) {
    dynamic current = data;
    for (var key in path) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }
    if (current is T) return current;
    return null;
  }

  // Function to format the card's data for clipboard, sharing, or export
  String _formatForExport() {
    final irac = _get<Map<String, dynamic>>(['structured_reasoning_irac']);
    final recommendations = _get<Map<String, dynamic>>(
        ['strategic_implications_and_recommendations']);
    final authorities = _get<List<dynamic>>(
            ['source_analysis_and_hierarchy', 'controlling_authorities']) ??
        [];

    final buffer = StringBuffer();
    buffer.writeln("ISSUE:\n${irac?['issue'] ?? 'N/A'}\n");
    buffer.writeln("CONCLUSION (BLUF):\n${irac?['conclusion'] ?? 'N/A'}\n");
    buffer.writeln("--- DETAILED ANALYSIS ---\n");
    buffer.writeln("RULE:\n${irac?['rule'] ?? 'N/A'}\n");
    buffer.writeln("APPLICATION:\n${irac?['application'] ?? 'N/A'}\n");

    if (recommendations != null) {
      buffer.writeln("--- GUIDANCE & RECOMMENDATIONS ---\n");
      final takeaways =
          recommendations['key_takeaways_for_leadership'] as List<dynamic>? ??
              [];
      final actions =
          recommendations['recommended_courses_of_action'] as List<dynamic>? ??
              [];
      final risks = recommendations['identified_risks_and_mitigations']
              as List<dynamic>? ??
          [];

      if (takeaways.isNotEmpty)
        buffer.writeln(
            "Key Takeaways:\n${takeaways.map((e) => "- $e").join('\n')}\n");
      if (actions.isNotEmpty)
        buffer.writeln(
            "Recommended Actions:\n${actions.map((e) => "- $e").join('\n')}\n");
      if (risks.isNotEmpty)
        buffer.writeln(
            "Risks & Mitigations:\n${risks.map((e) => "- $e").join('\n')}\n");
    }

    if (authorities.isNotEmpty) {
      buffer.writeln("--- CONTROLLING AUTHORITIES ---\n");
      buffer.writeln(authorities
          .map((auth) =>
              "- (${auth['precedence_level']}) ${auth['source_name']} ${auth['reference']}")
          .join('\n'));
      buffer.writeln();
    }

    final faqItems =
        recommendations?['anticipated_follow_ups'] as List<dynamic>? ?? [];
    if (faqItems.isNotEmpty) {
      buffer.writeln("--- FREQUENTLY ASKED QUESTIONS ---\n");
      buffer.writeln(faqItems
          .map((faq) => "Q: ${faq['question']}\nA: ${faq['answer']}")
          .join('\n\n'));
    }

    return buffer.toString();
  }

  // --- New helper method to build guidance items for the expansion tile ---
  List<Widget> _buildGuidanceItems(Map<String, dynamic> recommendations) {
    final takeaways =
        recommendations['key_takeaways_for_leadership'] as List<dynamic>? ?? [];
    final actions =
        recommendations['recommended_courses_of_action'] as List<dynamic>? ??
            [];
    final risks =
        recommendations['identified_risks_and_mitigations'] as List<dynamic>? ??
            [];

    List<Widget> items = [];
    items.addAll(
        takeaways.map((item) => _buildGuidanceItem('🧠', item.toString())));
    items.addAll(
        actions.map((item) => _buildGuidanceItem('✅', item.toString())));
    items
        .addAll(risks.map((item) => _buildGuidanceItem('⚠️', item.toString())));
    return items;
  }

  Widget _buildGuidanceItem(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
              child: SelectableText(text,
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFFE2E8F0)))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final irac = _get<Map<String, dynamic>>(['structured_reasoning_irac']);
    final recommendations = _get<Map<String, dynamic>>(
        ['strategic_implications_and_recommendations']);
    final authorities = _get<List<dynamic>>(
            ['source_analysis_and_hierarchy', 'controlling_authorities']) ??
        [];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3748),
        border: Border.all(color: const Color(0xFF4A5568)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            title: irac?['issue'] ?? 'Acquisition Analysis',
            onCopy: () {
              Clipboard.setData(ClipboardData(text: _formatForExport()));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard!')),
              );
            },
            onShare: () {
              Share.share(_formatForExport(),
                  subject: irac?['issue'] ?? 'Acquisition Analysis');
            },
          ),

          if (irac?['conclusion'] != null) ...[
            const SizedBox(height: 20),
            _Section(
              title: 'Determination (BLUF)',
              child: SelectableText(
                irac!['conclusion'],
                style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFFF7FAFC),
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],

          if (irac != null) ...[
            const SizedBox(height: 24),
            _IracAnalysisSection(irac: irac),
          ],

          // --- MODIFIED: Guidance Section is now a collapsible tile ---
          if (recommendations != null) ...[
            const SizedBox(height: 24),
            _CustomExpansionTile(
              title: '🔑 View Key Principles & Actions',
              children: _buildGuidanceItems(recommendations),
            ),
          ],

          const SizedBox(height: 20),
          _CardFooter(
            faqItems: recommendations?['anticipated_follow_ups'] ?? [],
            authorities: authorities,
          ),
        ],
      ),
    );
  }
}

// --- Sub-Widgets ---

class _CardHeader extends StatelessWidget {
  final String title;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _CardHeader(
      {required this.title, required this.onCopy, required this.onShare});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF4A5568))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⚖️', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: SelectableText(
                  title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF7FAFC)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _ActionButton(
                  icon: Icons.copy_all_outlined, label: 'Copy', onTap: onCopy),
              const SizedBox(width: 8),
              _ActionButton(
                  icon: Icons.share_outlined, label: 'Share', onTap: onShare),
              const SizedBox(width: 8),
              _ActionButton(
                  icon: Icons.download_outlined,
                  label: 'Export',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Export functionality coming soon!')),
                    );
                  }),
            ],
          )
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF4A5568),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFCBD5E0), size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: Color(0xFFEDF2F7), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFA0AEC0),
              letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _IracAnalysisSection extends StatelessWidget {
  final Map<String, dynamic> irac;
  const _IracAnalysisSection({required this.irac});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DETAILED ANALYSIS',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFA0AEC0),
              letterSpacing: 0.5),
        ),
        const SizedBox(height: 12),
        _buildIracItem('Rule', irac['rule']),
        _buildIracItem('Application', irac['application']),
      ],
    );
  }

  Widget _buildIracItem(String title, String? text) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEDF2F7))),
          const SizedBox(height: 4),
          SelectableText(text,
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFFE2E8F0), height: 1.5)),
        ],
      ),
    );
  }
}

class _CardFooter extends StatelessWidget {
  final List<dynamic> faqItems;
  final List<dynamic> authorities;
  const _CardFooter({required this.faqItems, required this.authorities});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF4A5568))),
      ),
      child: Column(
        children: [
          if (faqItems.isNotEmpty)
            _CustomExpansionTile(
              title: '❓ View Common Questions (FAQ)',
              isPrimary: true,
              children: faqItems
                  .map((faq) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: SelectableText.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                  text: '${faq['question']}\n',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFEDF2F7))),
                              TextSpan(text: faq['answer']),
                            ],
                          ),
                          style: const TextStyle(
                              color: Color(0xFFCBD5E0),
                              fontSize: 14,
                              height: 1.5),
                        ),
                      ))
                  .toList(),
            ),
          if (authorities.isNotEmpty) ...[
            const SizedBox(height: 12),
            _CustomExpansionTile(
              title: '📜 View Authorities & Sources',
              children: authorities
                  .map((auth) => _AuthorityItem(authority: auth))
                  .toList(),
            ),
          ]
        ],
      ),
    );
  }
}

class _AuthorityItem extends StatelessWidget {
  final Map<String, dynamic> authority;
  const _AuthorityItem({required this.authority});

  @override
  Widget build(BuildContext context) {
    final url = authority['url'] as String?;
    final canLaunch = url != null && url.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: canLaunch
                ? () async {
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  }
                : null,
            child: Text(
              '(${authority['precedence_level']}) ${authority['source_name']} ${authority['reference']}',
              style: TextStyle(
                  color: canLaunch
                      ? const Color(0xFF63B3ED)
                      : const Color(0xFFCBD5E0),
                  decoration: canLaunch
                      ? TextDecoration.underline
                      : TextDecoration.none,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            '"${authority['relevant_text']}"',
            style: const TextStyle(
                color: Color(0xFFA0AEC0), fontStyle: FontStyle.italic),
          )
        ],
      ),
    );
  }
}

class _CustomExpansionTile extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool isPrimary;

  const _CustomExpansionTile({
    required this.title,
    required this.children,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        iconColor: const Color(0xFFA0AEC0),
        collapsedIconColor: const Color(0xFFA0AEC0),
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color:
                isPrimary ? const Color(0xFF63B3ED) : const Color(0xFFE2E8F0),
          ),
        ),
        backgroundColor: const Color(0xFF1A202C),
        collapsedBackgroundColor:
            isPrimary ? const Color(0xFF2C5282) : const Color(0xFF4A5568),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
                color: isPrimary
                    ? const Color(0xFF2C5282)
                    : const Color(0xFF4A5568))),
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
                color: isPrimary
                    ? const Color(0xFF2C5282)
                    : const Color(0xFF4A5568))),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children),
          ),
        ],
      ),
    );
  }
}
