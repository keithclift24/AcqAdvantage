// lib/widgets/briefing_card_bubble.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';

// --- Main Widget ---
class BriefingCardBubble extends StatelessWidget {
  final Map<String, dynamic> data;
  final Function(String) onActionTapped;

  const BriefingCardBubble({
    super.key,
    required this.data,
    required this.onActionTapped,
  });

  // Helper function to safely access nested data
  T? _get<T>(List<String> path) {
    dynamic current = data;
    for (var key in path) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return null;
      }
    }
    if (current is T) {
      return current;
    }
    return null;
  }

  // Formats the card's data for clipboard/sharing
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

      if (takeaways.isNotEmpty) {
        buffer.writeln(
            "Key Takeaways:\n${takeaways.map((e) => "- $e").join('\n')}\n");
      }
      if (actions.isNotEmpty) {
        buffer.writeln(
            "Recommended Actions:\n${actions.map((e) => "- $e").join('\n')}\n");
      }
      if (risks.isNotEmpty) {
        buffer.writeln(
            "Risks & Mitigations:\n${risks.map((e) => "- $e").join('\n')}\n");
      }
    }

    if (authorities.isNotEmpty) {
      buffer.writeln("--- CONTROLLING AUTHORITIES ---\n");
      buffer.writeln(authorities
          .map((auth) =>
              "- (${auth['precedence_level']}) ${auth['precedence_name']}: ${auth['source_name']} ${auth['reference']}")
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

    int? highestPrecedenceLevel;
    if (authorities.isNotEmpty) {
      highestPrecedenceLevel = authorities
          .map((auth) => auth['precedence_level'] as int)
          .reduce(min);
    }

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
          if (recommendations != null) ...[
            const SizedBox(height: 24),
            _CustomExpansionTile(
              title: '🔑 View Key Principles & Actions',
              children: _buildGuidanceItems(recommendations),
            ),
          ],
          const SizedBox(height: 20),
          _CardFooter(
            recommendations: recommendations,
            authorities: authorities,
            highestPrecedenceLevel: highestPrecedenceLevel,
            onActionTapped: onActionTapped,
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
  final IconData? icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF4A5568),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: const Color(0xFFCBD5E0), size: 16),
              const SizedBox(width: 6),
            ],
            Text(label,
                style: const TextStyle(
                    color: Color(0xFFEDF2F7),
                    fontWeight: FontWeight.w500,
                    fontSize: 12)),
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
    if (text == null || text.isEmpty) {
      return const SizedBox.shrink();
    }
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

class _CommandPalette extends StatelessWidget {
  final Map<String, dynamic>? recommendations;
  final Function(String) onActionTapped;

  const _CommandPalette({this.recommendations, required this.onActionTapped});

  static const Map<String, IconData> _commandIcons = {
    '/more': Icons.zoom_in_outlined,
    '/deeper': Icons.explore_outlined,
    '/scenario': Icons.theater_comedy_outlined,
    '/cite': Icons.format_quote_outlined,
    '/contrast': Icons.compare_arrows_outlined,
    '/wider': Icons.public_outlined,
    '/alt': Icons.people_alt_outlined,
    '/mythbuster': Icons.lightbulb_outline,
  };

  @override
  Widget build(BuildContext context) {
    final faqItems =
        recommendations?['anticipated_follow_ups'] as List<dynamic>? ?? [];
    final suggestedCommandsRaw =
        recommendations?['suggested_commands'] as List<dynamic>? ?? [];

    // Create the final list of commands to display
    final List<Map<String, dynamic>> suggestedCommands = [
      {'command': '/more', 'description': 'Drill deeper'},
      {'command': '/deeper', 'description': 'Explore related topics'},
      ...suggestedCommandsRaw,
    ];
    // Remove duplicates, keeping the first occurrence
    final uniqueCommands = <String>{};
    final uniqueCommandList = suggestedCommands.where((cmd) {
      return uniqueCommands.add(cmd['command'] as String);
    }).toList();

    if (faqItems.isEmpty && suggestedCommands.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SUGGESTED ACTIONS',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFA0AEC0),
              letterSpacing: 0.5),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: const Color(0xFF1A202C),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Suggested Questions
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Explore Further',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFCBD5E0)),
                    ),
                    const SizedBox(height: 8),
                    ...faqItems.map((faq) {
                      final question = faq['question'] as String?;
                      if (question == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _QuestionButton(
                          text: question,
                          onTap: () => onActionTapped(question),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(width: 12),
              const IntrinsicHeight(
                  child: VerticalDivider(
                      color: Color(0xFF2D3748), width: 1, thickness: 1)),
              const SizedBox(width: 12),

              // Right Column: Power Commands
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Commands',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFCBD5E0)),
                    ),
                    const SizedBox(height: 8),
                    ...uniqueCommandList.map((cmd) {
                      final command = cmd['command'] as String?;
                      if (command == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _CommandButton(
                          command: command,
                          icon: _commandIcons[command],
                          onTap: () => onActionTapped(command),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuestionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _QuestionButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2D3748),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Text(text,
              style: const TextStyle(
                  color: Color(0xFFEDF2F7),
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}

class _CommandButton extends StatelessWidget {
  final String command;
  final IconData? icon;
  final VoidCallback onTap;
  const _CommandButton({required this.command, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPrimary = command == '/more' || command == '/deeper';
    final label = command.replaceFirst('/', ''); // Remove the slash for display

    return Material(
      color: isPrimary ? const Color(0xFF2C5282) : const Color(0xFF2D3748),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: const Color(0xFFCBD5E0), size: 14),
                const SizedBox(width: 6),
              ],
              Text(label,
                  style: const TextStyle(
                      color: Color(0xFFEDF2F7),
                      fontWeight: FontWeight.w500,
                      fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardFooter extends StatelessWidget {
  final Map<String, dynamic>? recommendations;
  final List<dynamic> authorities;
  final int? highestPrecedenceLevel;
  final Function(String) onActionTapped;

  const _CardFooter({
    this.recommendations,
    required this.authorities,
    this.highestPrecedenceLevel,
    required this.onActionTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CommandPalette(
          recommendations: recommendations,
          onActionTapped: onActionTapped,
        ),
        const SizedBox(height: 24),
        if (authorities.isNotEmpty)
          _CustomExpansionTile(
            title: '📜 View Authorities & Sources',
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: authorities
                          .map((auth) => _AuthorityItem(
                              authority: auth,
                              isHighlighted: auth['precedence_level'] ==
                                  highestPrecedenceLevel))
                          .toList(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _PrecedencePyramid(
                        highlightLevel: highestPrecedenceLevel),
                  ),
                ],
              )
            ],
          ),
      ],
    );
  }
}

class _AuthorityItem extends StatelessWidget {
  final Map<String, dynamic> authority;
  final bool isHighlighted;
  const _AuthorityItem({required this.authority, this.isHighlighted = false});

  @override
  Widget build(BuildContext context) {
    final url = authority['url'] as String?;
    final canLaunch = url != null && url.isNotEmpty;
    final isSupplemental = authority['is_supplemental'] as bool? ?? false;
    final precedenceName = authority['precedence_name'] as String?;

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
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                    text:
                        '(${authority['precedence_level']}) ${precedenceName ?? ""}: ',
                    style: TextStyle(
                        color: isHighlighted
                            ? const Color(0xFF63B3ED)
                            : const Color(0xFFA0AEC0))),
                TextSpan(
                    text:
                        '${authority['source_name']} ${authority['reference']}',
                    style: TextStyle(
                      color: canLaunch
                          ? const Color(0xFF63B3ED)
                          : const Color(0xFFCBD5E0),
                      decoration: canLaunch
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    )),
                if (isSupplemental)
                  const TextSpan(
                      text: ' [Supplemental]',
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Color(0xFFA0AEC0)))
              ]),
              style: const TextStyle(fontWeight: FontWeight.bold),
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

class _PrecedencePyramid extends StatelessWidget {
  final int? highlightLevel;

  final List<Map<String, dynamic>> precedenceLevels = const [
    {'level': 1, 'name': 'Constitution'},
    {'level': 2, 'name': 'Statutes'},
    {'level': 3, 'name': 'Exec Orders'},
    {'level': 4, 'name': 'Gov Policy'},
    {'level': 5, 'name': 'FAR'},
    {'level': 6, 'name': 'Supplements'},
    {'level': 7, 'name': 'Procedures'},
    {'level': 8, 'name': 'DoD FMR'},
    {'level': 9, 'name': 'Memos'},
    {'level': 10, 'name': 'Case Law'},
    {'level': 11, 'name': 'T&Cs'},
    {'level': 12, 'name': 'Local'},
    {'level': 13, 'name': 'Forums'}
  ];

  const _PrecedencePyramid({this.highlightLevel});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1 / 1.1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            alignment: Alignment.center,
            children: precedenceLevels.map((item) {
              final index = precedenceLevels.indexOf(item);
              final isHighlighted = item['level'] == highlightLevel;

              final width = constraints.maxWidth *
                  (0.55 + (index / (precedenceLevels.length - 1)) * 0.45);
              final top = constraints.maxHeight *
                  (index / (precedenceLevels.length - 1)) *
                  0.9;

              return Positioned(
                top: top,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: width,
                  height: constraints.maxHeight * 0.1,
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? const Color(0xB32C5282)
                        : const Color(0x334A5568),
                    border: Border.all(
                        color: isHighlighted
                            ? const Color(0xFF63B3ED)
                            : const Color(0x4D4A5568)),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: isHighlighted
                        ? [
                            BoxShadow(
                              color: const Color(0x8063B3ED),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      '${item['level']}. ${item['name']}',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: isHighlighted
                            ? Colors.white
                            : const Color(0xFFA0AEC0),
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _CustomExpansionTile extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _CustomExpansionTile({
    required this.title,
    required this.children,
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
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFFE2E8F0),
          ),
        ),
        backgroundColor: const Color(0xFF1A202C),
        collapsedBackgroundColor: const Color(0xFF4A5568),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFF4A5568))),
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFF4A5568))),
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
