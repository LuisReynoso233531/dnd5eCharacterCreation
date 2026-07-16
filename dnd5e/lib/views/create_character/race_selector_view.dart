import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/app_theme.dart';
import '../../view_models/character/character_view_model.dart';
import 'background_selecter_view.dart';

class RaceSelectionView extends StatefulWidget {
  const RaceSelectionView({super.key});

  @override
  State<RaceSelectionView> createState() => _RaceSelectionViewState();
}

class _RaceSelectionViewState extends State<RaceSelectionView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<CreateCharacterViewModel>().fetchRaces(),
    );
  }

  void _showRaceDetails(BuildContext context, Map<String, dynamic> race) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              width: 42,
              height: 4,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: context.dndColors.borderStrong,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            Text(
              race['name'],
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: context.colors.primary,
              ),
            ),
            const SizedBox(height: 10),
            _detailSection(context, 'Description', race['desc']),
            _detailSection(context, 'Ability Score Increase', race['asi_desc']),
            _detailSection(context, 'Age', race['age']),
            _detailSection(context, 'Size', race['size']),
            _detailSection(context, 'Speed', race['speed_desc']),
            _detailSection(context, 'Languages', race['languages']),
            if (race['vision'] != null)
              _detailSection(context, 'Vision', race['vision']),
            _detailSection(context, 'Traits', race['traits']),
          ],
        ),
      ),
    );
  }

  Widget _detailSection(BuildContext context, String title, dynamic content) {
    if (content == null || content.toString().isEmpty) {
      return const SizedBox.shrink();
    }
    final cleanContent = content.toString().replaceAll(RegExp(r'[\*#_]'), '');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: context.dndColors.info,
            ),
          ),
          const SizedBox(height: 4),
          Text(cleanContent, style: const TextStyle(fontSize: 14, height: 1.4)),
          const Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateCharacterViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Select Race')),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: vm.races.length,
              itemBuilder: (context, index) {
                final race = vm.races[index];
                final asiList = List<dynamic>.from(race['asi'] ?? []);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      title: Text(
                        race['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: context.colors.primary,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            "Speed: ${race['speed']['walk']} ft.",
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Hold for info',
                            style: TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: context.dndColors.mutedText,
                            ),
                          ),
                        ],
                      ),
                      trailing: Wrap(
                        direction: Axis.vertical,
                        crossAxisAlignment: WrapCrossAlignment.end,
                        spacing: 4,
                        children: asiList.map((asi) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: context.dndColors.infoContainer,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: context.dndColors.info.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                            ),
                            child: Text(
                              "${asi['attributes'][0]} +${asi['value']}",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: context.dndColors.onInfoContainer,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      onTap: () {
                        vm.setRace(race);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BackgroundSelectionView(),
                          ),
                        );
                      },
                      onLongPress: () => _showRaceDetails(context, race),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
