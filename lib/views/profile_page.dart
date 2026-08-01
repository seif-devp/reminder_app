import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:reminder_app/controllers/profile_controller.dart';
import 'package:reminder_app/data/entity/users.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final h = media.size.height;
    final w = media.size.width;

    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: SpinKitPumpingHeart(
                color: theme.primaryColor,
                size: 50,
              ),
            );
          }

          final u = controller.user.value;
          if (u == null) {
            return Center(
              child: Text(
                'No user data found',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.textTheme.bodyMedium!.color,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.06,
              vertical: h * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 48,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Name
                Text(
                  u.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.bodyLarge!.color,
                  ),
                ),
                const SizedBox(height: 4),

                Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.textTheme.bodyMedium!.color,
                  ),
                ),

                SizedBox(height: h * 0.03),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Get.toNamed('/documents');                        },
                        child: _smallCard(
                          icon: Icons.description_outlined,
                          title: 'Documents',
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: h * 0.02),

                // Personal info card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header + Edit
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodyLarge!.color,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: theme.primaryColor,
                            ),
                            onPressed: () => _showEditDialog(context, u),
                          ),
                          Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      _infoRow('Full Name', u.name),
                      _infoRow('Age', u.age ?? '—'),
                      _infoRow('Email', u.email),
                      _infoRow('Gender', u.gender ?? '—'),
                      const SizedBox(height: 4),
                      _infoRow('Blood Type', u.bloodType ?? '—'),
                      _infoRow('Height', u.height ?? '—'),
                      _infoRow('Weight', u.weight ?? '—'),
                    ],
                  ),
                ),

                SizedBox(height: h * 0.03),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) {
                          final w = MediaQuery.of(ctx).size.width;

                          return Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: w * 0.9,
                                maxHeight: MediaQuery.of(ctx)
                                    .size
                                    .height *
                                    0.85,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      // Header gradient
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              theme.primaryColor,
                                              theme.primaryColor.withOpacity(0.6)
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.logout,
                                              color: theme.colorScheme.onPrimary,
                                              size: 22,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                'Logout',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  color: theme.colorScheme.onPrimary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 18),

                                      Text(
                                        'Are you sure you want to log out?',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: theme.textTheme.bodyLarge!.color,
                                        ),
                                      ),

                                      const SizedBox(height: 22),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              height: 44,
                                              child: OutlinedButton(
                                                onPressed: () =>
                                                    Navigator.of(ctx)
                                                        .pop(false),
                                                style: OutlinedButton.styleFrom(
                                                  side: BorderSide(
                                                    color: theme.primaryColor,
                                                    width: 1.5,
                                                  ),
                                                  shape:
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        12),
                                                  ),
                                                ),
                                                child: Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: theme.primaryColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: SizedBox(
                                              height: 44,
                                              child: ElevatedButton(
                                                onPressed: () =>
                                                    Navigator.of(ctx)
                                                        .pop(true),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                  const Color(0xFFE57373),
                                                  shape:
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        12),
                                                  ),
                                                  elevation: 1,
                                                ),
                                                child: const Text(
                                                  'Logout',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );

                      if (confirmed == true) {
                        await controller.authService.logout();
                        Get.offAllNamed('/login');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE57373),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

Widget _smallCard({required IconData icon, required String title}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
    decoration: BoxDecoration(
      color: Get.theme.cardColor,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      children: [
        Icon(icon, size: 22, color: Get.theme.primaryColor),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Get.theme.textTheme.bodyLarge!.color,
          ),
        ),
      ],
    ),
  );
}

Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Get.theme.textTheme.bodyMedium!.color,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Get.theme.textTheme.bodyLarge!.color,
            ),
            softWrap: true,
          ),
        ),
      ],
    ),
  );
}

void _showEditDialog(BuildContext context, User u) {
  final nameCtrl = TextEditingController(text: u.name);
  final ageCtrl = TextEditingController(text: u.age ?? '');
  final emailCtrl = TextEditingController(text: u.email);
  final genderCtrl = TextEditingController(text: u.gender ?? '');
  final bloodCtrl = TextEditingController(text: u.bloodType ?? '');
  final heightCtrl = TextEditingController(text: u.height ?? '');
  final weightCtrl = TextEditingController(text: u.weight ?? '');

  final controller = Get.find<ProfileController>();
  final theme = Theme.of(context);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      final w = MediaQuery.of(context).size.width;
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: w * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            color: theme.colorScheme.onPrimary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Edit Personal Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Full name + Age
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _textField('Full Name', nameCtrl),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: _textField(
                            'Age',
                            ageCtrl,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    _textField(
                      'Email',
                      emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 12),

                    _textField('Gender', genderCtrl),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _textField('Blood Type', bloodCtrl),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _textField('Height', heightCtrl),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _textField('Weight', weightCtrl),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Save button
                    Obx(
                          () => SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () {
                            final updated = User(
                              userId: u.userId,
                              name: nameCtrl.text.trim(),
                              email: emailCtrl.text.trim(),
                              password: u.password,
                              gender:
                              genderCtrl.text.trim().isEmpty
                                  ? null
                                  : genderCtrl.text.trim(),
                              age: ageCtrl.text.trim().isEmpty
                                  ? null
                                  : ageCtrl.text.trim(),
                              bloodType:
                              bloodCtrl.text.trim().isEmpty
                                  ? null
                                  : bloodCtrl.text.trim(),
                              height:
                              heightCtrl.text.trim().isEmpty
                                  ? null
                                  : heightCtrl.text.trim(),
                              weight:
                              weightCtrl.text.trim().isEmpty
                                  ? null
                                  : weightCtrl.text.trim(),
                              syncStatus: 'not_synced',
                            );
                            controller.saveUser(updated);
                            Future.delayed(
                              const Duration(milliseconds: 500),
                                  () {
                                if (Navigator.canPop(context)) {
                                  Navigator.of(context).pop();
                                }
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: SpinKitPumpingHeart(
                                    color: Colors.white,
                                    size: 25.0,
                                  )
                          )
                              : Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: theme.textTheme.bodyMedium!.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _textField(
    String label,
    TextEditingController controller, {
      TextInputType keyboardType = TextInputType.text,
    }) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Get.theme.textTheme.bodyMedium!.color,
        ),
      ),
      const SizedBox(height: 4),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          isDense: true,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    ],
  );
}