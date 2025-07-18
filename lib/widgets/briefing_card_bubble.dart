import 'package:flutter/material.dart';

// --- Main Widget ---
class BriefingCardBubble extends StatelessWidget {
  final Map<String, dynamic> data;

  const BriefingCardBubble({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Safely access nested data with a helper function
    T? get<T>(List<String> path) {
      dynamic current = data;
      for (var key in path) {
        if (current is Map<String, dynamic> && current.containsKey(key)) {
          current = current[key];
        } else {
          return null;
        }
      }
      return current as T?;
    }

    final blufText =
        get<String>(['structured_reasoning_irac', 'conclusion']) ?? 'N/A';
    final analysisText =
        get<String>(['structured_reasoning_irac', 'application']) ?? 'N/A';
    final guidanceItems = get<List<dynamic>>([
          'strategic_implications_and_recommendations',
          'key_takeaways_for_leadership'
        ]) ??
        [];
    final faqItems = get<List<dynamic>>([
          'strategic_implications_and_recommendations',
          'anticipated_follow_ups'
        ]) ??
        [];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFD),
        border: Border.all(color: const Color(0xFFD0D5DD)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            title:
                get<String>(['response_framing', 'perspective']) ?? 'Analysis',
            subtitle: get<String>(['response_framing', 'target_audience']) ??
                'Guidance',
          ),
          const SizedBox(height: 20),
          _Section(
              title: 'Determination',
              child: Text(blufText,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF101828),
                      fontWeight: FontWeight.w500))),
          const SizedBox(height: 24),
          _Section(
              title: 'Analysis',
              child: Text(analysisText,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF344054), height: 1.5))),
          const SizedBox(height: 24),
          _GuidanceSection(items: guidanceItems),
          const SizedBox(height: 20),
          _CardFooter(
              faqItems: faqItems,
              authorities: get<List<dynamic>>([
                    'source_analysis_and_hierarchy',
                    'controlling_authorities'
                  ]) ??
                  []),
        ],
      ),
    );
  }
}

// --- Sub-Widgets for Cleaner Code ---

class _CardHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _CardHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEAECF0))),
      ),
      child: Row(
        children: [
          const Text('⚖️', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF101828))),
              Text(subtitle,
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF475467))),
            ],
          ),
        ],
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
              color: Color(0xFF475467),
              letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _GuidanceSection extends StatelessWidget {
  final List<dynamic> items;

  const _GuidanceSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'KEY PRINCIPLES & ACTIONS',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475467),
                letterSpacing: 0.5),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🧠', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(item.toString(),
                            style: const TextStyle(
                                fontSize: 14, color: Color(0xFF344054)))),
                  ],
                ),
              )),
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
        border: Border(top: BorderSide(color: Color(0xFFEAECF0))),
      ),
      child: Column(
        children: [
          _CustomExpansionTile(
            title: '❓ View Common Questions (FAQ)',
            isPrimary: true,
            children: faqItems
                .map((faq) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: '${faq['question']}\n',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: faq['answer']),
                          ],
                        ),
                        style: const TextStyle(
                            color: Color(0xFF475467), fontSize: 14),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CustomExpansionTile(
                  title: '📜 Authorities',
                  children: authorities
                      .map((auth) => Text(
                          '${auth['source_name']}: ${auth['reference']}',
                          style: const TextStyle(
                              color: Color(0xFF475467), fontSize: 14)))
                      .toList(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CustomExpansionTile(
                  title: '⚙️ Process Log',
                  children: const [
                    Text('Details about query validation and retrieval...',
                        style:
                            TextStyle(color: Color(0xFF475467), fontSize: 14))
                  ],
                ),
              ),
            ],
          ),
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
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color:
                isPrimary ? const Color(0xFF0052CC) : const Color(0xFF344054),
          ),
        ),
        backgroundColor: const Color(0xFFF8F9FC),
        collapsedBackgroundColor:
            isPrimary ? const Color(0xFFF0F6FF) : const Color(0xFFF2F4F7),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
                color: isPrimary
                    ? const Color(0xFFD0E1FD)
                    : const Color(0xFFD0D5DD))),
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
                color: isPrimary
                    ? const Color(0xFFD0E1FD)
                    : const Color(0xFFD0D5DD))),
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
