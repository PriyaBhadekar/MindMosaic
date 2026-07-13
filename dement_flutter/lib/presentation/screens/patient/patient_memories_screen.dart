// CREATE lib/presentation/screens/patient/patient_memories_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/memory_model.dart';
import '../../../providers/memory_provider.dart';
import '../../../providers/voice_provider.dart';
import '../../../data/storage/local_storage.dart';

class PatientMemoriesScreen extends StatefulWidget {
  const PatientMemoriesScreen({super.key});

  @override
  State<PatientMemoriesScreen> createState() => _PatientMemoriesScreenState();
}

class _PatientMemoriesScreenState extends State<PatientMemoriesScreen> {
  MemoryModel? _selected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemoryProvider>().fetchMemories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MemoryProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _selected != null
          ? _MemoryDetailView(
        memory: _selected!,
        onBack: () => setState(() => _selected = null),
      )
          : _MemoryGalleryView(
        memories: prov.memories,
        isLoading: prov.isLoading,
        onSelect: (m) => setState(() => _selected = m),
      ),
    );
  }
}

class _MemoryGalleryView extends StatelessWidget {
  final List<MemoryModel> memories;
  final bool isLoading;
  final ValueChanged<MemoryModel> onSelect;
  const _MemoryGalleryView({
    required this.memories,
    required this.isLoading,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 150,
          pinned: true,
          backgroundColor: Colors.transparent,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.cardGradient2,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: const Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Memories', style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.w800,
                        color: Colors.white, letterSpacing: -0.5,
                      )),
                      SizedBox(height: 4),
                      Text('Photos and people who love you', style: TextStyle(
                        color: Colors.white70, fontSize: 14,
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        if (isLoading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator(color: AppColors.secondary)),
            ),
          )
        else if (memories.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: Column(
                children: [
                  SizedBox(height: 40),
                  Icon(Icons.photo_library_outlined, size: 64, color: AppColors.textHint),
                  SizedBox(height: 16),
                  Text('No memories yet', style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
                  )),
                  SizedBox(height: 8),
                  Text('Your caregiver will add memories for you',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.80,
              ),
              delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _MemoryTile(
                  memory: memories[i],
                  onTap: () => onSelect(memories[i]),
                ),
                childCount: memories.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _MemoryTile extends StatelessWidget {
  final MemoryModel memory;
  final VoidCallback onTap;
  const _MemoryTile({required this.memory, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imgUrl = memory.imageUrl ?? (memory.imagePath != null
        ? 'http://10.0.2.2:8080/${memory.imagePath!.replaceAll('\\', '/')}'
        : null);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: imgUrl != null
                    ? Image.network(imgUrl, width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _NoPhoto())
                    : _NoPhoto(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(memory.title, style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (memory.relationInfo != null && memory.relationInfo!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(memory.relationInfo!, style: const TextStyle(
                        fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w600,
                      )),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoPhoto extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.surfaceVariant,
    child: const Center(child: Icon(Icons.person_rounded, size: 48, color: AppColors.textHint)),
  );
}

class _MemoryDetailView extends StatefulWidget {
  final MemoryModel memory;
  final VoidCallback onBack;

  const _MemoryDetailView({
    required this.memory,
    required this.onBack,
  });

  @override
  State<_MemoryDetailView> createState() =>
      _MemoryDetailViewState();
}

class _MemoryDetailViewState
    extends State<_MemoryDetailView> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {

      final text =
          '${widget.memory.title}. '
          '${widget.memory.relationInfo != null ? "This is ${widget.memory.relationInfo}." : ""} '
          '${widget.memory.description ?? ""}';

      context.read<VoiceProvider>().speak(text);
    });
  }

  @override
  Widget build(BuildContext context) {

    final imgUrl =
        widget.memory.imageUrl ??
            (widget.memory.imagePath != null
                ? 'http://10.0.2.2:8080/${widget.memory.imagePath!.replaceAll('\\', '/')}'
                : null);

    return SafeArea(
      child: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [

                GestureDetector(
                  onTap: () {

                    context.read<VoiceProvider>().stopAll();

                    widget.onBack();
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: 18,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    widget.memory.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {

                    final text =
                        '${widget.memory.title}. '
                        '${widget.memory.relationInfo != null ? "This is ${widget.memory.relationInfo}." : ""} '
                        '${widget.memory.description ?? ""}';

                    context.read<VoiceProvider>().speak(text);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.volume_up_rounded,
                      color: AppColors.secondary,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 5,
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: imgUrl != null
                    ? Image.network(
                  imgUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                    : Container(
                  color: AppColors.surfaceVariant,
                  child: const Center(
                    child: Icon(
                      Icons.person_rounded,
                      size: 100,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                BorderRadius.circular(24),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  if (widget.memory.relationInfo != null &&
                      widget.memory.relationInfo!.isNotEmpty)

                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6),
                      decoration: BoxDecoration(
                        gradient:
                        AppColors.cardGradient2,
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.memory.relationInfo!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  Text(
                    widget.memory.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  if (widget.memory.description != null &&
                      widget.memory.description!.isNotEmpty)
                    Padding(
                      padding:
                      const EdgeInsets.only(top: 10),
                      child: Text(
                        widget.memory.description!,
                        style: const TextStyle(
                          fontSize: 16,
                          color:
                          AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}