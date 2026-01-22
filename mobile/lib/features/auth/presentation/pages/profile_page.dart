import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../bloc/auth_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _fullNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _bloodTypeCtrl;
  late TextEditingController _allergiesCtrl;
  late TextEditingController _conditionsCtrl;
  late TextEditingController _medicationsCtrl;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    User? user;
    if (state is AuthAuthenticated) {
      user = state.user;
    } else if (state is AuthPasswordChangeFailure) {
       user = state.user;
    }

    _fullNameCtrl = TextEditingController(text: user?.fullName ?? '');
    _phoneCtrl = TextEditingController(text: user?.phoneNumber ?? '');
    _bloodTypeCtrl = TextEditingController(text: user?.profile?.bloodType ?? '');
    _allergiesCtrl = TextEditingController(text: user?.profile?.allergies.join(', ') ?? '');
    _conditionsCtrl = TextEditingController(text: user?.profile?.medicalConditions.join(', ') ?? '');
    _medicationsCtrl = TextEditingController(text: user?.profile?.medications.join(', ') ?? '');
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _bloodTypeCtrl.dispose();
    _allergiesCtrl.dispose();
    _conditionsCtrl.dispose();
    _medicationsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Profile updated successfully')),
             );
          } else if (state is AuthError) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text(state.message)),
             );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          User? user;
          if (state is AuthAuthenticated) user = state.user;
          // Handle other states if necessary
          
          if (user == null) return const Center(child: Text("User data unavailable"));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Personal Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _fullNameCtrl,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _phoneCtrl,
                    decoration: const InputDecoration(labelText: 'Phone Number', prefixText: '+1 '), // Simple placeholder
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  
                  const SizedBox(height: 20),
                  const Text("Medical Profile (For Emergencies)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _bloodTypeCtrl,
                    decoration: const InputDecoration(labelText: 'Blood Type (e.g. O+)'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _allergiesCtrl,
                    decoration: const InputDecoration(labelText: 'Allergies (comma separated)'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _conditionsCtrl,
                    decoration: const InputDecoration(labelText: 'Medical Conditions (comma separated)'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _medicationsCtrl,
                    decoration: const InputDecoration(labelText: 'Medications (comma separated)'),
                  ),

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final updatedProfile = Profile(
                            bloodType: _bloodTypeCtrl.text,
                            allergies: _allergiesCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                            medicalConditions: _conditionsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                            medications: _medicationsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                          );

                          final updatedUser = User(
                             id: user!.id,
                             email: user.email, // read only
                             fullName: _fullNameCtrl.text,
                             phoneNumber: _phoneCtrl.text,
                             universityId: user.universityId, // read only
                             isVerified: user.isVerified,
                             role: user.role,
                             profile: updatedProfile,
                          );

                          context.read<AuthBloc>().add(UpdateProfileEvent(updatedUser));
                        }
                      },
                      child: const Text('Save Changes'),
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
}
