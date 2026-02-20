import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/circle_service.dart';
import '../../models/circle_member_model.dart';
import 'circle_member_tile.dart';

/// Circle Page
///
/// Shows the user's college community ("Circle"). Everyone who set the same
/// college_name automatically becomes part of the same Circle.
///
/// ┌────────────────────────────────────┐
/// │  🏫  Lovely Professional University │  ← circle name (college)
/// │  ══════════════════════════════    │
/// │  [Confessions] [Events] [Groups] [Matches]  ← filter chips
/// │  ─────────────────────────────────  │
/// │  👤  Members (24)                   │
/// │  ─────────────────────────────────  │
/// │  [Member tile] ...                  │
/// └────────────────────────────────────┘
class CirclePage extends StatefulWidget {
  const CirclePage({super.key});

  @override
  State<CirclePage> createState() => _CirclePageState();
}

class _CirclePageState extends State<CirclePage>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _circleService = CircleService();
  final _searchController = TextEditingController();

  static const _purple = Color(0xFF6B4CE6);
  static const _lightPurple = Color(0xFF9D7CE8);

  // ── Filter tabs ─────────────────────────────────────────────────────────────
  static const _filters = [
    _FilterTab(label: 'All', icon: Icons.groups_2_outlined),
    _FilterTab(label: 'Confessions', icon: Icons.favorite_border),
    _FilterTab(label: 'Events', icon: Icons.event_outlined),
    _FilterTab(label: 'Groups', icon: Icons.diversity_3_outlined),
    _FilterTab(label: 'Matches', icon: Icons.auto_awesome_outlined),
  ];

  int _selectedFilter = 0;

  // ── State ────────────────────────────────────────────────────────────────────
  String? _collegeName;
  String? _currentUserId;
  List<CircleMemberModel> _allMembers = [];
  List<CircleMemberModel> _filteredMembers = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentUserId = _authService.currentUser?.id;
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Data loading ─────────────────────────────────────────────────────────────

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = _authService.currentUser?.id;
      if (userId == null) throw 'Not logged in';

      final college = await _circleService.getCurrentUserCollege(userId);

      if (college == null || college.trim().isEmpty) {
        setState(() {
          _collegeName = null;
          _isLoading = false;
        });
        return;
      }

      final members = await _circleService.getCircleMembers(
        collegeName: college.trim(),
        excludeUserId: userId,
      );

      if (mounted) {
        setState(() {
          _collegeName = college.trim();
          _currentUserId = userId;
          _allMembers = members;
          _filteredMembers = members;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // ── Search ───────────────────────────────────────────────────────────────────

  Future<void> _onSearch(String query) async {
    if (_collegeName == null) return;
    if (query.trim().isEmpty) {
      setState(() {
        _filteredMembers = _allMembers;
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    try {
      final results = await _circleService.searchCircleMembers(
        collegeName: _collegeName!,
        query: query.trim(),
      );
      if (mounted) {
        setState(() {
          _filteredMembers = results;
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: _isLoading
          ? _buildLoading()
          : _errorMessage != null
          ? _buildError()
          : _collegeName == null
          ? _buildNoCollege()
          : _buildCircle(),
    );
  }

  // ── Loading ───────────────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(_purple),
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────────

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── No college set ───────────────────────────────────────────────────────────

  Widget _buildNoCollege() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_purple, _lightPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.school_outlined,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'No Circle Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add your college name in your profile to join your college Circle and connect with everyone from your college.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/profile'),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Update Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main Circle UI ───────────────────────────────────────────────────────────

  Widget _buildCircle() {
    return RefreshIndicator(
      onRefresh: _load,
      color: _purple,
      child: CustomScrollView(
        slivers: [
          // ── Hero banner ────────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildHeroBanner()),

          // ── Filter chips ───────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildFilterRow()),

          // ── Content based on filter ────────────────────────────────────
          if (_selectedFilter == 0)
            ..._buildMemberSection()
          else
            SliverToBoxAdapter(child: _buildComingSoon()),
        ],
      ),
    );
  }

  // ── Hero banner ──────────────────────────────────────────────────────────────

  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_purple, _lightPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.diversity_3_outlined,
              size: 34,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Circle',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _collegeName!,
                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 14,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_allMembers.length} member${_allMembers.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter chips ─────────────────────────────────────────────────────────────

  Widget _buildFilterRow() {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        itemCount: _filters.length,
        itemBuilder: (_, i) {
          final selected = _selectedFilter == i;
          final f = _filters[i];
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? _purple : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: selected
                        ? _purple.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: selected ? 10 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    f.icon,
                    size: 16,
                    color: selected ? Colors.white : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    f.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      color: selected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Members section ───────────────────────────────────────────────────────────

  List<Widget> _buildMemberSection() {
    return [
      // Search bar + header
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Member count header
              Row(
                children: [
                  const Icon(
                    Icons.people_alt_outlined,
                    size: 18,
                    color: _purple,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Members',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_filteredMembers.length}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _purple,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Search field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  decoration: InputDecoration(
                    hintText: 'Search members…',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.grey.shade400,
                              size: 18,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _onSearch('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Searching indicator
      if (_isSearching)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(_purple),
                ),
              ),
            ),
          ),
        )
      // Empty search result
      else if (_filteredMembers.isEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 56,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 12),
                Text(
                  'No members found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        )
      // Member list
      else
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index == _filteredMembers.length) {
              return const SizedBox(height: 32);
            }
            final member = _filteredMembers[index];
            return CircleMemberTile(
              member: member,
              isCurrentUser: member.id == _currentUserId,
            );
          }, childCount: _filteredMembers.length + 1),
        ),
    ];
  }

  // ── Coming soon placeholder ──────────────────────────────────────────────────

  Widget _buildComingSoon() {
    final f = _filters[_selectedFilter];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _purple.withValues(alpha: 0.15),
                  _lightPurple.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(f.icon, size: 44, color: _purple),
          ),
          const SizedBox(height: 24),
          Text(
            f.label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Circle ${f.label} are coming soon!\nStay connected with your college community.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Private data class ────────────────────────────────────────────────────────

class _FilterTab {
  final String label;
  final IconData icon;
  const _FilterTab({required this.label, required this.icon});
}
