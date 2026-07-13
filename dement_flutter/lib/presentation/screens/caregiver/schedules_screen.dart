// CREATE lib/presentation/screens/caregiver/schedules_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/schedule_model.dart';
import '../../../providers/schedule_provider.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/soft_text_field.dart';

class SchedulesScreen extends StatefulWidget {
  const SchedulesScreen({super.key});

  @override
  State<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends State<SchedulesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleProvider>().fetchSchedules();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ScheduleProvider>();

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
                  gradient: AppColors.cardGradient4,
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
                          'Daily Schedules',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Reminders and routines for your patient',
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
                    child: CircularProgressIndicator(color: AppColors.primary)),
              ),
            )
          else if (prov.schedules.isEmpty)
            SliverToBoxAdapter(child: _EmptySchedule(onAdd: () => _openAdd(context)))
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                        child: _ScheduleCard(

                          schedule: prov.schedules[i],

                          onToggle: () =>
                              prov.toggle(prov.schedules[i].id),

                          onDelete: () =>
                              _confirmDelete(
                                context,
                                prov.schedules[i].id,
                              ),

                          onEdit: () {

                            _openEdit(
                              context,
                              prov.schedules[i],
                            );

                          },
                        ),
                  ),
                  childCount: prov.schedules.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAdd(context),
        backgroundColor: const Color(0xFF5B6EF5),
        icon: const Icon(Icons.add_alarm_rounded, color: Colors.white),
        label: const Text('Add Schedule',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _openAdd(BuildContext context) {

    showModalBottomSheet(

      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (_) => const _AddScheduleSheet(),

    ).then((_) {

      context
          .read<ScheduleProvider>()
          .fetchSchedules();

    });
  }

  void _openEdit(
      BuildContext context,
      ScheduleModel schedule,
      ) {

    showModalBottomSheet(

      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (_) => _EditScheduleSheet(
        schedule: schedule,
      ),

    ).then((_) {

      context
          .read<ScheduleProvider>()
          .fetchSchedules();

    });
  }


  Future<void> _confirmDelete(BuildContext context, int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Schedule'),
        content: const Text('This schedule will be permanently removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      context.read<ScheduleProvider>().deleteSchedule(id);
    }
  }
}

class _ScheduleCard extends StatelessWidget {

  final ScheduleModel schedule;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ScheduleCard({
    required this.schedule,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {

    final color =
    schedule.active
        ? AppColors.primary
        : AppColors.textHint;

    final icon = _iconFor(schedule.title);

    return GestureDetector(

      onLongPress: () {

        showModalBottomSheet(

          context: context,

          builder: (_) {

            return SafeArea(

              child: Wrap(

                children: [

                  ListTile(

                    leading: const Icon(Icons.edit),

                    title: const Text('Edit Schedule'),

                    onTap: () {

                      Navigator.pop(context);

                      onEdit();
                    },
                  ),

                  ListTile(

                    leading: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),

                    title: const Text(
                      'Delete Schedule',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),

                    onTap: () {

                      Navigator.pop(context);

                      onDelete();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },

      child: Dismissible(

        key: Key('sched_${schedule.id}'),

        direction: DismissDirection.endToStart,

        onDismissed: (_) => onDelete(),

        background: Container(

          alignment: Alignment.centerRight,

          padding: const EdgeInsets.only(right: 20),

          decoration: BoxDecoration(

            color: AppColors.dangerSurface,

            borderRadius: BorderRadius.circular(20),
          ),

          child: const Icon(
            Icons.delete_rounded,
            color: AppColors.danger,
          ),
        ),

        child: Container(

          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(

            color: AppColors.surface,

            borderRadius: BorderRadius.circular(20),

            boxShadow: AppColors.cardShadow,

            border: Border.all(

              color: schedule.active
                  ? AppColors.primary.withOpacity(0.15)
                  : AppColors.borderLight,
            ),
          ),

          child: Row(

            children: [

              Container(

                width: 52,
                height: 52,

                decoration: BoxDecoration(

                  color: color.withOpacity(0.10),

                  borderRadius: BorderRadius.circular(16),
                ),

                child: Icon(
                  icon,
                  color: color,
                  size: 26,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(

                child: Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(

                      schedule.title,

                      style: TextStyle(

                        fontSize: 16,

                        fontWeight: FontWeight.w700,

                        color: schedule.active
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(

                      children: [

                        const Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: AppColors.textHint,
                        ),

                        const SizedBox(width: 4),

                        Text(

                          _formatTime(schedule.scheduledTime),

                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(width: 10),

                        _Chip(
                          label: schedule.repeatType,
                          color: AppColors.secondary,
                        ),
                      ],
                    ),

                    if (schedule.voiceDescription != null &&
                        schedule.voiceDescription!.isNotEmpty) ...[

                      const SizedBox(height: 4),

                      Text(

                        schedule.voiceDescription!,

                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),

                        maxLines: 1,

                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              Switch(

                value: schedule.active,

                onChanged: (_) => onToggle(),

                activeColor: AppColors.primary,

                inactiveThumbColor:
                AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String title) {

    final t = title.toLowerCase();

    if (t.contains('breakfast') ||
        t.contains('lunch') ||
        t.contains('dinner') ||
        t.contains('meal')) {

      return Icons.restaurant_rounded;
    }

    if (t.contains('medicine') ||
        t.contains('medication') ||
        t.contains('tablet') ||
        t.contains('pill')) {

      return Icons.medication_rounded;
    }

    if (t.contains('sleep') ||
        t.contains('bed') ||
        t.contains('rest')) {

      return Icons.bedtime_rounded;
    }

    if (t.contains('walk') ||
        t.contains('exercise')) {

      return Icons.directions_walk_rounded;
    }

    if (t.contains('call') ||
        t.contains('phone')) {

      return Icons.call_rounded;
    }

    if (t.contains('bath') ||
        t.contains('hygiene')) {

      return Icons.shower_rounded;
    }

    return Icons.alarm_rounded;
  }

  String _formatTime(String time) {

    try {

      final parts = time.split(':');

      int h = int.parse(parts[0]);

      final m = parts[1].padLeft(2, '0');

      final suffix =
      h >= 12 ? 'PM' : 'AM';

      h = h > 12
          ? h - 12
          : (h == 0 ? 12 : h);

      return '$h:$m $suffix';

    } catch (_) {

      return time;
    }
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptySchedule extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptySchedule({required this.onAdd});

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
              color: const Color(0xFF5B6EF5).withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calendar_today_rounded,
                size: 44, color: Color(0xFF5B6EF5)),
          ),
          const SizedBox(height: 20),
          const Text('No schedules yet',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text(
            'Create daily reminders for your patient',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          GradientButton(
            text: 'Create Schedule',
            onTap: onAdd,
            gradient: AppColors.cardGradient4,
            height: 52,
          ),
        ],
      ),
    );
  }
}

// ── Add Schedule Bottom Sheet ──────────────────────────────────────────
class _AddScheduleSheet extends StatefulWidget {
  const _AddScheduleSheet();

  @override
  State<_AddScheduleSheet> createState() => _AddScheduleSheetState();
}

class _AddScheduleSheetState extends State<_AddScheduleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _repeatType = 'DAILY';
  String _reminderType = 'VOICE';

  final List<String> _repeatOptions = [
    'ONCE', 'DAILY', 'WEEKLY', 'WEEKDAYS', 'WEEKENDS'
  ];
  final List<String> _reminderOptions = ['VOICE', 'VIBRATION', 'BOTH', 'VISUAL'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (t != null) setState(() => _selectedTime = t);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final h = _selectedTime.hour.toString().padLeft(2, '0');
    final m = _selectedTime.minute.toString().padLeft(2, '0');
    final timeStr = '$h:$m:00';

    final prov = context.read<ScheduleProvider>();
    final ok = await prov.addSchedule(
      title: _titleCtrl.text.trim(),
      scheduledTime: timeStr,
      voiceDescription: _descCtrl.text.trim(),
      repeatType: _repeatType,
      reminderType: _reminderType,
    );

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(prov.error ?? 'Failed to save schedule'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ScheduleProvider>();
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
                'New Schedule',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),

              // Common quick titles
              const Text('QUICK ADD',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHint,
                      letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Breakfast', 'Medicine', 'Sleep', 'Walk', 'Call family'
                ]
                    .map((q) => GestureDetector(
                  onTap: () => _titleCtrl.text = q,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(q,
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500)),
                  ),
                ))
                    .toList(),
              ),
              const SizedBox(height: 16),

              SoftTextField(
                hint: 'e.g. Morning medicine reminder',
                label: 'Schedule title',
                controller: _titleCtrl,
                prefixIcon: Icons.alarm_rounded,
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 14),

              // Time picker
              GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          color: AppColors.primary, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Reminder time',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.textHint)),
                            const SizedBox(height: 2),
                            Text(
                              _selectedTime.format(context),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textHint),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              SoftTextField(
                hint: 'What the voice assistant will say...',
                label: 'Voice description (optional)',
                controller: _descCtrl,
                prefixIcon: Icons.record_voice_over_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Repeat type
              const Text('REPEAT',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHint,
                      letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _repeatOptions.map((r) {
                  final sel = r == _repeatType;
                  return GestureDetector(
                    onTap: () => setState(() => _repeatType = r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.primary
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: sel
                                ? AppColors.primary
                                : AppColors.border),
                      ),
                      child: Text(r,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: sel
                                  ? Colors.white
                                  : AppColors.textSecondary)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Reminder type
              const Text('REMINDER TYPE',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHint,
                      letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _reminderOptions.map((r) {
                  final sel = r == _reminderType;
                  return GestureDetector(
                    onTap: () => setState(() => _reminderType = r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.secondary
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: sel
                                ? AppColors.secondary
                                : AppColors.border),
                      ),
                      child: Text(r,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: sel
                                  ? Colors.white
                                  : AppColors.textSecondary)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              GradientButton(
                text: 'Save Schedule',
                onTap: prov.isLoading ? null : _submit,
                isLoading: prov.isLoading,
                gradient: AppColors.cardGradient4,
                height: 54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditScheduleSheet extends StatefulWidget {

  final ScheduleModel schedule;

  const _EditScheduleSheet({
    required this.schedule,
  });

  @override
  State<_EditScheduleSheet> createState() =>
      _EditScheduleSheetState();
}

class _EditScheduleSheetState
    extends State<_EditScheduleSheet> {

  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;

  @override
  void initState() {

    super.initState();

    _titleCtrl = TextEditingController(
      text: widget.schedule.title,
    );

    _descCtrl = TextEditingController(
      text: widget.schedule.voiceDescription ?? '',
    );
  }

  @override
  void dispose() {

    _titleCtrl.dispose();
    _descCtrl.dispose();

    super.dispose();
  }

  Future<void> _save() async {

    try {

      await context
          .read<ScheduleProvider>()
          .updateSchedule(

        scheduleId: widget.schedule.id,

        title: _titleCtrl.text,

        scheduledTime:
        widget.schedule.scheduledTime,

        voiceDescription:
        _descCtrl.text,

        repeatType:
        widget.schedule.repeatType,

        reminderType:
        widget.schedule.reminderType,
      );

      if (mounted) {

        Navigator.pop(context);

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content:
            Text('Schedule updated'),
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
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(

      padding: EdgeInsets.only(

        left: 20,
        right: 20,
        top: 20,

        bottom:
        MediaQuery.of(context)
            .viewInsets
            .bottom + 20,
      ),

      decoration: const BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),

      child: Column(

        mainAxisSize: MainAxisSize.min,

        children: [

          const Text(

            'Edit Schedule',

            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          TextField(

            controller: _titleCtrl,

            decoration: const InputDecoration(
              labelText: 'Title',
            ),
          ),

          const SizedBox(height: 15),

          TextField(

            controller: _descCtrl,

            maxLines: 3,

            decoration: const InputDecoration(
              labelText: 'Voice Description',
            ),
          ),

          const SizedBox(height: 25),

          SizedBox(

            width: double.infinity,

            child: ElevatedButton(

              onPressed: _save,

              child: const Text(
                'Save Changes',
              ),
            ),
          ),
        ],
      ),
    );
  }
}