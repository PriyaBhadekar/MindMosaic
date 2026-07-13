// CREATE lib/presentation/screens/caregiver/emergency_contacts_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/emergency_contact_model.dart';
import '../../../providers/emergency_provider.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/soft_text_field.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmergencyProvider>().fetchContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<EmergencyProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────────────
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
                  gradient: AppColors.sosGradient,
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
                          'Emergency Contacts',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.4,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'People to notify in an emergency',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── SOS demo banner ──────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: const _InfoBanner(),
            ),
          ),

          // ── Content ──────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: prov.isLoading
                ? const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: CircularProgressIndicator(
                      color: AppColors.danger),
                ),
              ),
            )
                : prov.contacts.isEmpty
                ? SliverToBoxAdapter(
              child: _EmptyContacts(
                onAdd: () => _openAddSheet(context),
              ),
            )
                : SliverList(
              delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ContactCard(
                    contact: prov.contacts[i],
                    onEdit: () {

                      final nameCtrl =
                      TextEditingController(
                        text: prov.contacts[i].name,
                      );

                      final phoneCtrl =
                      TextEditingController(
                        text: prov.contacts[i].phoneNumber,
                      );

                      final relCtrl =
                      TextEditingController(
                        text: prov.contacts[i].relationship ?? '',
                      );

                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(

                          title: const Text(
                            'Edit Contact',
                          ),

                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              TextField(
                                controller: nameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Name',
                                ),
                              ),

                              const SizedBox(height: 12),

                              TextField(
                                controller: phoneCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Phone',
                                ),
                              ),

                              const SizedBox(height: 12),

                              TextField(
                                controller: relCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Relationship',
                                ),
                              ),
                            ],
                          ),

                          actions: [

                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),

                            ElevatedButton(
                              onPressed: () async {

                                final success =
                                await context
                                    .read<EmergencyProvider>()
                                    .updateContact(

                                  id: prov.contacts[i].id!,

                                  name: nameCtrl.text,

                                  phoneNumber: phoneCtrl.text,

                                  relationship: relCtrl.text,

                                  primary:
                                  prov.contacts[i].primary,
                                );

                                if (context.mounted) {
                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(

                                    SnackBar(
                                      content: Text(
                                        success
                                            ? 'Contact updated'
                                            : 'Update failed',
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      );
                    },
                    onDelete: () => _confirmDelete(
                        context, prov.contacts[i].id),
                  ),
                ),
                childCount: prov.contacts.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddSheet(context),
        backgroundColor: AppColors.danger,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Add Contact',
            style:
            TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _openAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddContactSheet(),
    ).then((_) => context.read<EmergencyProvider>().fetchContacts());
  }

  Future<void> _confirmDelete(BuildContext context, int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Contact'),
        content:
        const Text('This contact will be removed from the emergency list.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<EmergencyProvider>().deleteContact(id);
    }
  }
}

// ── SOS demo banner ────────────────────────────────────────────────────
// In emergency_contacts_screen.dart, replace the _SosDemoBanner widget class with:
class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.20)),
      ),
      child: const Row(children: [
        Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 22),
        SizedBox(width: 12),
        Expanded(child: Text(
          'These contacts are notified when your patient sends an SOS alert. '
              'Add family members, doctors, and emergency responders.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
        )),
      ]),
    );
  }
}

// ── Contact card ───────────────────────────────────────────────────────
class _ContactCard extends StatelessWidget {
  final EmergencyContactModel contact;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  const _ContactCard({required this.contact, required this.onDelete,required this.onEdit,});

  @override
  Widget build(BuildContext context) {
    final color = contact.primary ? AppColors.danger : AppColors.primary;
    final initials = contact.name.isNotEmpty
        ? contact.name.trim().split(' ').map((w) => w[0]).take(2).join()
        : '?';

    return Dismissible(
      key: Key('ec_${contact.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.dangerSurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: AppColors.danger),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow,
          border: contact.primary
              ? Border.all(color: AppColors.danger.withOpacity(0.25))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials.toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        contact.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (contact.primary) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'PRIMARY',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.danger,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contact.phoneNumber,
                    style: TextStyle(
                      fontSize: 14,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (contact.relationship != null &&
                      contact.relationship!.isNotEmpty)
                    Text(
                      contact.relationship!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textHint),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [

                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Calling ${contact.name}...'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.call_rounded,
                      color: color,
                      size: 20,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────
class _EmptyContacts extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyContacts({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.contact_emergency_outlined,
                size: 44, color: AppColors.danger),
          ),
          const SizedBox(height: 20),
          const Text('No emergency contacts',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text(
            'Add contacts who will be notified\nin case of an emergency',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: GradientButton(
              text: 'Add First Contact',
              onTap: onAdd,
              gradient: AppColors.sosGradient,
              height: 52,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add contact bottom sheet ───────────────────────────────────────────
class _AddContactSheet extends StatefulWidget {
  const _AddContactSheet();

  @override
  State<_AddContactSheet> createState() => _AddContactSheetState();
}

class _AddContactSheetState extends State<_AddContactSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _relCtrl = TextEditingController();
  bool _isPrimary = false;

  final List<String> _relationships = [
    'Son', 'Daughter', 'Spouse', 'Sibling', 'Friend', 'Doctor', 'Nurse', 'Other'
  ];
  String _selectedRel = 'Son';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _relCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final prov = context.read<EmergencyProvider>();
    final ok = await prov.addContact(
      name: _nameCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      relationship: _selectedRel,
      primary: _isPrimary,
    );

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(prov.error ?? 'Failed to add contact'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<EmergencyProvider>();
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
              const Text('Add Emergency Contact',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 20),

              SoftTextField(
                hint: "Contact's full name",
                label: 'Full name',
                controller: _nameCtrl,
                prefixIcon: Icons.person_outline_rounded,
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 14),
              SoftTextField(
                hint: '+91 98765 43210',
                label: 'Phone number',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Phone number is required' : null,
              ),
              const SizedBox(height: 16),

              const Text('RELATIONSHIP',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHint,
                      letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _relationships.map((r) {
                  final sel = r == _selectedRel;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedRel = r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.danger
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: sel
                                ? AppColors.danger
                                : AppColors.border),
                      ),
                      child: Text(r,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: sel
                                  ? Colors.white
                                  : AppColors.textSecondary)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Primary toggle
              GestureDetector(
                onTap: () => setState(() => _isPrimary = !_isPrimary),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isPrimary
                        ? AppColors.danger.withOpacity(0.06)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isPrimary
                          ? AppColors.danger.withOpacity(0.3)
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.warning, size: 22),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Set as primary contact',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            Text('Will be contacted first in an emergency',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textHint)),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: _isPrimary
                              ? AppColors.danger
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: _isPrimary
                                  ? AppColors.danger
                                  : AppColors.border),
                        ),
                        child: _isPrimary
                            ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 14)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              GradientButton(
                text: 'Save Contact',
                onTap: prov.isLoading ? null : _submit,
                isLoading: prov.isLoading,
                gradient: AppColors.sosGradient,
                height: 54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}