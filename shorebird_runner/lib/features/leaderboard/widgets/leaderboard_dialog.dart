import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shorebird_runner/core/constants/constants.dart';
import 'package:shorebird_runner/features/leaderboard/bloc/leaderboard_bloc.dart';
import 'package:shorebird_runner/features/leaderboard/models/leaderboard_entry_model.dart';

/// Arcade-themed dialog displaying the global & event leaderboard.
class LeaderboardDialog extends StatefulWidget {
  final String? initialEvent;

  const LeaderboardDialog({super.key, this.initialEvent});

  static Future<void> show(
    BuildContext context, {
    String? initialEvent,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Leaderboard',
      barrierColor: Colors.black.withValues(alpha: 0.8),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, anim1, anim2) => LeaderboardDialog(
        initialEvent: initialEvent,
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        final curved =
            CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
          child: FadeTransition(
            opacity: curved,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<LeaderboardDialog> createState() => _LeaderboardDialogState();
}

class _LeaderboardDialogState extends State<LeaderboardDialog> {
  final TextEditingController _searchController = TextEditingController();
  bool _todayOnly = false;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<LeaderboardBloc>();
    bloc.add(FetchLeaderboard(initialEvent: widget.initialEvent));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D131F),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.shorebirdGold.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shorebirdGold.withValues(alpha: 0.12),
                blurRadius: 40,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              const BoxShadow(
                color: Colors.black87,
                blurRadius: 48,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              children: [
                // Top Gold Accent Bar
                Container(
                  height: 4,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.goldAmber,
                        AppColors.shorebirdGold,
                        AppColors.goldPale,
                        AppColors.shorebirdGold,
                      ],
                    ),
                  ),
                ),

                // Dialog Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              AppColors.shorebirdGold.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                AppColors.shorebirdGold.withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          color: AppColors.shorebirdGold,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LEADERBOARD',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.shorebirdGold,
                                letterSpacing: 2.5,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Top OTA Deployers & Patch Champions',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.slateMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.slateMuted,
                          size: 20,
                        ),
                        splashRadius: 20,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                const Divider(color: Color(0xFF1E293B), height: 1),

                // Filter & Search Controls
                BlocBuilder<LeaderboardBloc, LeaderboardState>(
                  builder: (context, state) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Column(
                        children: [
                          // Time Scope Selector (All-Time vs Today)
                          Row(
                            children: [
                              _TimePill(
                                label: 'ALL TIME',
                                icon: Icons.all_inclusive_rounded,
                                isSelected: !_todayOnly,
                                onTap: () => setState(() => _todayOnly = false),
                              ),
                              const SizedBox(width: 8),
                              _TimePill(
                                label: 'TODAY',
                                icon: Icons.today_rounded,
                                isSelected: _todayOnly,
                                onTap: () => setState(() => _todayOnly = true),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Search Box
                          TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              context
                                  .read<LeaderboardBloc>()
                                  .add(SearchLeaderboard(val));
                            },
                            style: const TextStyle(
                              color: Color(0xFFF1F5F9),
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF131C2E),
                              hintText:
                                  'Search by player, organization, or event...',
                              hintStyle: const TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 13,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppColors.slateMuted,
                                size: 18,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear_rounded,
                                        color: AppColors.slateMuted,
                                        size: 16,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        context
                                            .read<LeaderboardBloc>()
                                            .add(const SearchLeaderboard(''));
                                      },
                                    )
                                  : null,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1E293B),
                                  width: 1.2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.shorebirdGold,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Event Filter Selector
                          Row(
                            children: [
                              const Icon(
                                Icons.filter_alt_outlined,
                                size: 16,
                                color: AppColors.slateMuted,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'EVENT:',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.slateMuted,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF131C2E),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: state.availableEvents
                                              .contains(state.selectedEvent)
                                          ? state.selectedEvent
                                          : 'All Events',
                                      isDense: true,
                                      isExpanded: true,
                                      dropdownColor: const Color(0xFF131C2E),
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: AppColors.shorebirdGold,
                                        size: 18,
                                      ),
                                      style: const TextStyle(
                                        color: Color(0xFFF1F5F9),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      items: state.availableEvents
                                          .map(
                                            (e) => DropdownMenuItem(
                                              value: e,
                                              child: Text(
                                                e.toUpperCase(),
                                                style: TextStyle(
                                                  color: e ==
                                                          state.selectedEvent
                                                      ? AppColors.shorebirdGold
                                                      : const Color(0xFFCBD5E1),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          context.read<LeaderboardBloc>().add(
                                                FilterLeaderboardByEvent(val),
                                              );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const Divider(color: Color(0xFF1E293B), height: 1),

                // Table Header
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        child: Text(
                          'RANK',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.slateMuted,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'PLAYER / ORGANIZATION',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.slateMuted,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 90,
                        child: Text(
                          'SCORE',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.slateMuted,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(color: Color(0xFF1A2234), height: 1),

                // Leaderboard List
                Expanded(
                  child: BlocBuilder<LeaderboardBloc, LeaderboardState>(
                    builder: (context, state) {
                      if (state.status == LeaderboardStatus.loading &&
                          state.allEntries.isEmpty) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.shorebirdGold,
                            strokeWidth: 2.5,
                          ),
                        );
                      }

                      var entries = state.filteredEntries;
                      if (_todayOnly) {
                        final now = DateTime.now();
                        final startOfToday =
                            DateTime(now.year, now.month, now.day);
                        entries = entries
                            .where((e) => e.createdAt.isAfter(startOfToday))
                            .toList();
                      }

                      if (entries.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.search_off_rounded,
                                size: 40,
                                color: AppColors.slateMuted,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _todayOnly
                                    ? 'No runners today yet'
                                    : 'No runners found',
                                style: const TextStyle(
                                  color: Color(0xFFCBD5E1),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _todayOnly
                                    ? 'Be the first runner on the board today!'
                                    : state.searchQuery.isNotEmpty
                                        ? 'No results matching "${state.searchQuery}"'
                                        : 'Be the first to set a high score in this event!',
                                style: const TextStyle(
                                  color: AppColors.slateMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: entries.length,
                        separatorBuilder: (context, i) =>
                            const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          final rank = index + 1;
                          return _LeaderboardRow(rank: rank, entry: entry);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final LeaderboardEntryModel entry;

  const _LeaderboardRow({
    required this.rank,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    Color rankColor;
    Color? rankBg;
    Widget? rankIcon;

    if (rank == 1) {
      rankColor = const Color(0xFFFFD700);
      rankBg = const Color(0xFFFFD700).withValues(alpha: 0.15);
      rankIcon = const Icon(
        Icons.workspace_premium_rounded,
        color: Color(0xFFFFD700),
        size: 16,
      );
    } else if (rank == 2) {
      rankColor = const Color(0xFFE2E8F0);
      rankBg = const Color(0xFFE2E8F0).withValues(alpha: 0.12);
      rankIcon = const Icon(
        Icons.military_tech_rounded,
        color: Color(0xFFCBD5E1),
        size: 16,
      );
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32);
      rankBg = const Color(0xFFCD7F32).withValues(alpha: 0.15);
      rankIcon = const Icon(
        Icons.military_tech_outlined,
        color: Color(0xFFCD7F32),
        size: 16,
      );
    } else {
      rankColor = AppColors.slateMuted;
      rankBg = Colors.transparent;
    }

    final isTopThree = rank <= 3;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isTopThree
            ? rankColor.withValues(alpha: 0.06)
            : const Color(0xFF101726),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTopThree
              ? rankColor.withValues(alpha: 0.3)
              : const Color(0xFF1A2333),
          width: isTopThree ? 1.2 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 36,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: rankBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (rankIcon != null) ...[
                  rankIcon,
                  const SizedBox(width: 2),
                ],
                Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: rankColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Player Name & Organization / Event Tag
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.playerName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF8FAFC),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (entry.organization.isNotEmpty) ...[
                      Text(
                        entry.organization,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.slateMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: AppColors.slateMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (entry.event.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          entry.event.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Score & Patches Count
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${entry.score}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.shorebirdGold,
                  letterSpacing: 0.5,
                ),
              ),
              if (entry.patches > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '🐤',
                      style: TextStyle(fontSize: 10),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${entry.patches}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slateMuted,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimePill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimePill({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.shorebirdGold.withValues(alpha: 0.15)
                : const Color(0xFF131C2E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AppColors.shorebirdGold.withValues(alpha: 0.6)
                  : const Color(0xFF1E293B),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13,
                color:
                    isSelected ? AppColors.shorebirdGold : AppColors.slateMuted,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.shorebirdGold
                      : AppColors.slateMuted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
