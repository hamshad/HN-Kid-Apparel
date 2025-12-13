import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../provider/admin_provider.dart';
import '../models/admin_models.dart';
import 'add_series_screen.dart';

class SeriesListScreen extends ConsumerWidget {
  const SeriesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Basic pagination mock - just loading page 1 for now
    final seriesAsync = ref.watch(seriesProvider(1));

    return Scaffold(
      body: seriesAsync.when(
        data: (seriesList) => RefreshIndicator(
          onRefresh: () => ref.refresh(seriesProvider(1).future),
          child: seriesList.isEmpty 
          ? const Center(child: Text('No Series Found'))
          : ListView.builder( // using ListView for text-heavy items often looks better than grid unless brief, but user asked for "sorta 3x3 grid" for others. Series might be just text. Let's use Grid for consistency if names are short. User said "Series" e.g. "Summer Collection".
            // Let's stick to Grid for consistency with Brands/Categories
            padding: const EdgeInsets.all(16),
            itemCount: seriesList.length,
            // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            //   crossAxisCount: 2, // 2 might be better for text, but let's try 3 or list. 
            //   // Actually text only cards look bad in small squares. 
            //   // Let's use a nice extensive List or a 2-column grid.
            //   // Let's use 2 columns for "Series" as names can be longer "Summer Collection 2024"
            //   childAspectRatio: 2.0, 
            //   crossAxisSpacing: 12,
            //   mainAxisSpacing: 12,
            // ),
            // Actually, let's use GridView as user seems to like grids.
            itemBuilder: (context, index) {
              final series = seriesList[index];
              return _SeriesItem(series: series, index: index);
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddSeriesScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SeriesItem extends StatelessWidget {
  final Series series;
  final int index;

  const _SeriesItem({required this.series, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blueAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.layers, color: Colors.blueAccent),
        ),
        title: Text(
          series.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    ).animate().fade(duration: 400.ms).slideX(delay: (50 * index).ms);
  }
}
