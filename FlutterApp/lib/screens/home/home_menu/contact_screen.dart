import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Dopamine_Booster/utils/validators/form_validators.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'dopamineboosterapp@gmail.com',
        query: encodeQueryParameters(<String, String>{
          'subject': 'Dopamine Booster App Feedback',
          'body': 'Name: ${_nameController.text}\n'
              'Email: ${_emailController.text}\n\n'
              'Message: ${_messageController.text}',
        }),
      );

      try {
        if (await canLaunchUrl(emailLaunchUri)) {
          await launchUrl(emailLaunchUri);
        } else {
          throw 'Could not launch email client';
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('emailClientError'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
      .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6A11CB),
              Color(0xFF2575FC),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    AppLocalizations.of(context)!.contactUs,
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  background: Image.asset(
                    'assets/images/contactImage.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.contactMsg1,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6A11CB),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppLocalizations.of(context)!.contactMsg2,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.inversePrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            _buildTextField(
                              maxLines: 1,
                              controller: _nameController,
                              label: AppLocalizations.of(context)!.name,
                              icon: Icons.person,
                              validator: (value) => FormValidators.validateName(value, maxLength: 30),
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              maxLines: 1,
                              controller: _emailController,
                              label: AppLocalizations.of(context)!.email,
                              icon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              validator: FormValidators.validateEmail,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _messageController,
                              label: AppLocalizations.of(context)!.message,
                              icon: Icons.message,
                              maxLines: 8,
                              validator: (value) => FormValidators.validateMessage(value, minLength: 20, maxWords: 150),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : _sendEmail,
                              icon: _isLoading 
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.send),
                              label: Text(
                                _isLoading 
                                  ? 'sending'
                                  : AppLocalizations.of(context)!.sendFeedback,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white, 
                                backgroundColor: Color(0xFF6A11CB),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.arrow_back, color: Color(0xFF6A11CB)),
                              label: Text(
                                AppLocalizations.of(context)!.backBtn,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF6A11CB),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
        prefixIcon: Icon(icon, color: Color(0xFF6A11CB)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xFF6A11CB)),
        ),
      ),
      style: GoogleFonts.poppins(),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }
}

