import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/core/widgets/empty_state.dart';
import 'package:moments/core/widgets/moment_card.dart';
import 'package:moments/features/moments/domain/models/moment.dart';
import 'package:moments/features/player/presentation/providers/mini_player_provider.dart';

/// Screen displaying the user's saved song snippets / Moments.
class YourMomentsScreen extends ConsumerStatefulWidget {
  /// Creates a [YourMomentsScreen].
  const YourMomentsScreen({super.key});

  @override
  ConsumerState<YourMomentsScreen> createState() => _YourMomentsScreenState();
}

class _YourMomentsScreenState extends ConsumerState<YourMomentsScreen> {
  bool _showEmptyState = false;

  static const List<Moment> _mockMoments = [
    Moment(
      id: 'm-1',
      title: 'After Dark (Drop)',
      artist: 'Mr.Kitty',
      thumbnailUrl: '',
      startSeconds: 62.0,
      endSeconds: 88.0,
      songId: 'mock-1',
      tags: ['LateNight', 'Synth'],
    ),
    Moment(
      id: 'm-2',
      title: 'Midnight City (Sax Solo)',
      artist: 'M83',
      thumbnailUrl: '',
      startSeconds: 182.0,
      endSeconds: 215.0,
      songId: 'mock-2',
      tags: ['Energy'],
    ),
    Moment(
      id: 'm-3',
      title: 'Resonance (Intro Wave)',
      artist: 'HOME',
      thumbnailUrl: '',
      startSeconds: 0.0,
      endSeconds: 32.0,
      songId: 'mock-3',
      tags: ['Nostalgia'],
    ),
    Moment(
      id: 'm-4',
      title: 'Nightcall (Chorus)',
      artist: 'Kavinsky',
      thumbnailUrl: '',
      startSeconds: 58.0,
      endSeconds: 89.0,
      songId: 'mock-4',
      tags: ['Drive'],
    ),
    Moment(
      id: 'm-5',
      title: 'Space Song (Outro Drift)',
      artist: 'Beach House',
      thumbnailUrl: '',
      startSeconds: 220.0,
      endSeconds: 260.0,
      songId: 'mock-6',
      tags: ['Melancholy'],
    ),
    Moment(
      id: 'm-6',
      title: 'Memory Reboot (Synth Lead)',
      artist: 'VOJ & Narvent',
      thumbnailUrl: '',
      startSeconds: 42.0,
      endSeconds: 74.0,
      songId: 'mock-7',
      tags: ['Cyberpunk'],
    ),
    Moment(
      id: 'm-7',
      title: 'Starboy (Bassline Hook)',
      artist: 'The Weeknd',
      thumbnailUrl: '',
      startSeconds: 35.0,
      endSeconds: 68.0,
      songId: 'mock-5',
      tags: ['Pop'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Moments'),
        actions: [
          IconButton(
            icon: Icon(
              _showEmptyState ? Icons.view_list_rounded : Icons.inbox_outlined,
            ),
            tooltip: _showEmptyState ? 'Show Mock List' : 'Preview Empty State',
            onPressed: () {
              setState(() {
                _showEmptyState = !_showEmptyState;
              });
            },
          ),
        ],
      ),
      body: _showEmptyState
          ? EmptyState(
              icon: Icons.bookmark_border_rounded,
              title: 'No Moments Saved Yet',
              subtitle:
                  'Search for songs on YouTube, trim your favorite timestamped snippet, and loop it anytime.',
              actionLabel: 'Discover Songs',
              onAction: () {
                setState(() {
                  _showEmptyState = false;
                });
              },
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: _mockMoments.length,
              itemBuilder: (context, index) {
                final moment = _mockMoments[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: MomentCard(
                    moment: moment,
                    onTap: () {
                      ref.read(miniPlayerProvider.notifier).loadTrack(
                            title: moment.title,
                            artist: moment.artist,
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Playing snippet "${moment.title}"'),
                          duration: const Duration(milliseconds: 900),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
