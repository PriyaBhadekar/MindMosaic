// CREATE lib/presentation/screens/caregiver/memories_screen.dart
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/memory_model.dart';
import '../../../providers/memory_provider.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/soft_text_field.dart';
import 'package:flutter/foundation.dart';

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
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
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: Colors.transparent,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.20),
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
                        Text(
                          'Memory Gallery',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Photos and stories to remember',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (prov.isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.secondary),
                ),
              ),
            )
          else if (prov.memories.isEmpty)
            SliverToBoxAdapter(child: _EmptyMemory(onAdd: () => _openAdd(context)))
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(

                  crossAxisCount:
                  MediaQuery.of(context).size.width > 900
                      ? 4
                      : MediaQuery.of(context).size.width > 600
                      ? 3
                      : 2,

                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _MemoryCard(
                    memory: prov.memories[i],
                    onDelete: () => _confirmDelete(context, prov.memories[i].id),
                  ),
                  childCount: prov.memories.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAdd(context),
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add_photo_alternate_rounded, color: Colors.white),
        label: const Text(
          'Add Memory',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _openAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddMemorySheet(),
    ).then((_) => context.read<MemoryProvider>().fetchMemories());
  }

  Future<void> _confirmDelete(BuildContext context, int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Memory'),
        content: const Text('This memory will be permanently removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<MemoryProvider>().deleteMemory(id);
    }
  }
}

class _MemoryCard extends StatelessWidget {

  final MemoryModel memory;
  final VoidCallback onDelete;

  const _MemoryCard({
    required this.memory,
    required this.onDelete,
  });

  void showEditMemoryDialog(
      BuildContext context,
      MemoryModel memory,
      ) {

    showModalBottomSheet(

      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (_) => _EditMemorySheet(
        memory: memory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final imgUrl = memory.imageUrl;
    print('CAREGIVER IMAGE URL = $imgUrl');

    return GestureDetector(

      onLongPress: onDelete,

      child: Container(

        decoration: BoxDecoration(

          color: AppColors.surface,

          borderRadius:
          BorderRadius.circular(20),

          boxShadow:
          AppColors.cardShadow,
        ),

        child: Stack(

          children: [

            /// MAIN CONTENT
            Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                /// IMAGE
                SizedBox(

                  height: 150,

                  width: double.infinity,

                  child: ClipRRect(

                    borderRadius:
                    const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),

                    child: imgUrl != null

                        ? Image.network(
                      imgUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (
                          context,
                          error,
                          stackTrace,
                          ) {

                        print("IMAGE ERROR = $error");

                        return Container(
                          color: AppColors.surfaceVariant,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: AppColors.textHint,
                              size: 40,
                            ),
                          ),
                        );
                      },
                    )

                        : Container(

                      color:
                      AppColors.surfaceVariant,

                      child: const Center(

                        child: Icon(

                          Icons.image_rounded,

                          size: 40,

                          color:
                          AppColors.textHint,
                        ),
                      ),
                    ),
                  ),
                ),

                /// CONTENT
                Expanded(

                  child: Padding(

                    padding:
                    const EdgeInsets.all(12),

                    child: Column(

                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [

                        /// TITLE
                        Text(

                          memory.title,

                          maxLines: 1,

                          overflow:
                          TextOverflow.ellipsis,

                          style: const TextStyle(

                            fontSize: 18,

                            fontWeight:
                            FontWeight.w700,

                            color:
                            AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 8),

                        /// RELATION
                        if (memory.relationInfo != null &&
                            memory.relationInfo!.isNotEmpty)

                          Container(

                            padding:
                            const EdgeInsets.symmetric(

                              horizontal: 10,

                              vertical: 5,
                            ),

                            decoration: BoxDecoration(

                              color:
                              AppColors.secondary
                                  .withOpacity(0.12),

                              borderRadius:
                              BorderRadius.circular(8),
                            ),

                            child: Text(

                              memory.relationInfo!,

                              style: const TextStyle(

                                fontSize: 11,

                                fontWeight:
                                FontWeight.w600,

                                color:
                                AppColors.secondary,
                              ),
                            ),
                          ),

                        const SizedBox(height: 10),

                        /// DESCRIPTION
                        if (memory.description != null &&
                            memory.description!.isNotEmpty)

                          Expanded(

                            child: Text(

                              memory.description!,

                              maxLines: 3,

                              overflow:
                              TextOverflow.ellipsis,

                              style: const TextStyle(

                                fontSize: 12,

                                height: 1.4,

                                color:
                                AppColors.textHint,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            /// MENU BUTTON
            Positioned(

              top: 10,

              right: 10,

              child: PopupMenuButton<String>(

                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),

                onSelected: (value) async {

                  /// EDIT
                  if (value == 'edit') {

                    showEditMemoryDialog(
                      context,
                      memory,
                    );
                  }

                  /// DELETE
                  if (value == 'delete') {

                    final confirm =
                    await showDialog<bool>(

                      context: context,

                      builder: (_) => AlertDialog(

                        title:
                        const Text('Delete Memory'),

                        content: const Text(
                          'Are you sure you want to delete this memory?',
                        ),

                        actions: [

                          TextButton(

                            onPressed: () {

                              Navigator.pop(
                                context,
                                false,
                              );
                            },

                            child: const Text('Cancel'),
                          ),

                          ElevatedButton(

                            onPressed: () {

                              Navigator.pop(
                                context,
                                true,
                              );
                            },

                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {

                      final success =
                      await context
                          .read<MemoryProvider>()
                          .deleteMemory(memory.id);

                      if (success) {

                        ScaffoldMessenger.of(context)
                            .showSnackBar(

                          const SnackBar(

                            content:
                            Text('Memory deleted'),
                          ),
                        );
                      }
                    }
                  }
                },

                itemBuilder: (context) => [

                  const PopupMenuItem(

                    value: 'edit',

                    child: Row(

                      children: [

                        Icon(Icons.edit),

                        SizedBox(width: 8),

                        Text('Edit'),
                      ],
                    ),
                  ),

                  const PopupMenuItem(

                    value: 'delete',

                    child: Row(

                      children: [

                        Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),

                        SizedBox(width: 8),

                        Text(

                          'Delete',

                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderImg extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.surfaceVariant,
    child: const Center(
      child: Icon(Icons.image_rounded, size: 40, color: AppColors.textHint),
    ),
  );
}

class _EmptyMemory extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyMemory({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.photo_library_outlined,
                size: 44, color: AppColors.secondary),
          ),
          const SizedBox(height: 20),
          const Text(
            'No memories yet',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add meaningful photos and stories\nfor your patient',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          GradientButton(
            text: 'Add First Memory',
            onTap: onAdd,
            gradient: AppColors.cardGradient2,
            height: 52,
          ),
        ],
      ),
    );
  }
}

// ── Add Memory Bottom Sheet ────────────────────────────────────────────
class _AddMemorySheet extends StatefulWidget {
  const _AddMemorySheet();

  @override
  State<_AddMemorySheet> createState() => _AddMemorySheetState();
}

class _AddMemorySheetState extends State<_AddMemorySheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _relationCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  XFile? _image;

  final List<String> _categories = [
    'Family', 'Wedding', 'Birthday', 'Childhood', 'Friends', 'Other'
  ];
  String _selectedCategory = 'Family';

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _relationCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final img = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 800,
    );

    if (img != null) {
      setState(() {
        _image = img;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final prov = context.read<MemoryProvider>();
    print('IMAGE PATH = ${_image?.path}');
    final ok = await prov.addMemory(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      relationInfo: _relationCtrl.text.trim(),
      category: _selectedCategory,
      imageFile: _image,
    );

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(prov.error ?? 'Failed to save memory'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MemoryProvider>();
    final kb = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + kb),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add a Memory',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),

              // Image picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.border, style: BorderStyle.solid),
                  ),
                  child: _image != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: kIsWeb
                        ? Image.network(
                      _image!.path,
                      fit: BoxFit.cover,
                    )
                        : Image.network(
                      _image!.path,
                      fit: BoxFit.cover,
                    ),
                  )
                      : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_rounded,
                          size: 40, color: AppColors.textHint),
                      SizedBox(height: 8),
                      Text('Tap to add photo',
                          style: TextStyle(
                              color: AppColors.textHint, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SoftTextField(
                hint: 'e.g. Daughter\'s wedding day',
                label: 'Memory title',
                controller: _titleCtrl,
                prefixIcon: Icons.title_rounded,
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 14),
              SoftTextField(
                hint: 'e.g. My daughter Sarah',
                label: 'Person / Relation',
                controller: _relationCtrl,
                prefixIcon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 14),
              SoftTextField(
                hint: 'Describe this memory...',
                label: 'Description (optional)',
                controller: _descCtrl,
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 14),

              // Category chips
              const Text(
                'CATEGORY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textHint,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((c) {
                  final sel = c == _selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.secondary
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel ? AppColors.secondary : AppColors.border,
                        ),
                      ),
                      child: Text(
                        c,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              GradientButton(
                text: 'Save Memory',
                onTap: prov.isLoading ? null : _submit,
                isLoading: prov.isLoading,
                gradient: AppColors.cardGradient2,
                height: 54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditMemorySheet extends StatefulWidget {

  final MemoryModel memory;

  const _EditMemorySheet({
    required this.memory,
  });

  @override
  State<_EditMemorySheet> createState() =>
      _EditMemorySheetState();
}

class _EditMemorySheetState
    extends State<_EditMemorySheet> {

  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _relationCtrl;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _titleCtrl =
        TextEditingController(text: widget.memory.title);

    _descCtrl =
        TextEditingController(
          text: widget.memory.description ?? '',
        );

    _relationCtrl =
        TextEditingController(
          text: widget.memory.relationInfo ?? '',
        );
  }

  @override
  void dispose() {

    _titleCtrl.dispose();
    _descCtrl.dispose();
    _relationCtrl.dispose();

    super.dispose();
  }

  Future<void> _updateMemory() async {

    setState(() {
      isLoading = true;
    });

    try {

      await context.read<MemoryProvider>()
          .updateMemory(
        memoryId: widget.memory.id,

        title: _titleCtrl.text.trim(),

        description:
        _descCtrl.text.trim(),

        relationInfo:
        _relationCtrl.text.trim(),
      );

      if (mounted) {

        Navigator.pop(context);

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content:
            Text('Memory updated'),
          ),
        );
      }

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(e.toString()),
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final kb =
        MediaQuery.of(context).viewInsets.bottom;

    return Container(

      padding:
      EdgeInsets.fromLTRB(
        24,
        20,
        24,
        24 + kb,
      ),

      decoration: const BoxDecoration(
        color: AppColors.background,

        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),

      child: SingleChildScrollView(

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            const Text(
              'Edit Memory',

              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            SoftTextField(
              label: 'Title',

              hint: 'Memory title',

              controller: _titleCtrl,

              prefixIcon:
              Icons.title_rounded,
            ),

            const SizedBox(height: 16),

            SoftTextField(
              label: 'Relation',

              hint: 'Relation',

              controller:
              _relationCtrl,

              prefixIcon:
              Icons.people_alt_rounded,
            ),

            const SizedBox(height: 16),

            SoftTextField(
              label: 'Description',

              hint: 'Description',

              controller: _descCtrl,

              prefixIcon:
              Icons.description_rounded,

              maxLines: 4,
            ),

            const SizedBox(height: 24),

            GradientButton(

              text: 'Update Memory',

              onTap:
              isLoading
                  ? null
                  : _updateMemory,

              isLoading: isLoading,

              gradient:
              AppColors.cardGradient2,
            ),
          ],
        ),
      ),
    );
  }
}