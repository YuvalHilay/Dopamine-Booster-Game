import 'dart:io';
import 'package:Dopamine_Booster/components/my_textfield.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:quiz_repository/quiz.repository.dart';

class AddQuizScreen extends StatefulWidget {
  const AddQuizScreen({Key? key}) : super(key: key);

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {

  final QuizRepository quizRepository = FirebaseQuizRepo(); // Initialize the quiz repository
  // Initially empty categories list
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();  // Load categories when the screen is initialized
  }
  final _formKey = GlobalKey<FormState>();
  // List of controllers for the option fields (4 options in total).
  final List<TextEditingController> _optionControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final TextEditingController _correctAnswerController = TextEditingController();
  final TextEditingController _quizQuestionController = TextEditingController();
  final TextEditingController _quizDescriptionController = TextEditingController();

  String? _selectedCategory;
  File? _selectedImage;
  bool _isLoading = false;
  
  // Instance of ImagePicker to pick images from the gallery.
  final ImagePicker _picker = ImagePicker();
  // Dispose method to clean up controllers when the widget is removed from the widget tree.
  @override
  void dispose() {
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    _correctAnswerController.dispose();
    super.dispose();
  }

Future<void> _loadCategories() async {
    try {
      // Fetch the categories asynchronously
      final categories = await quizRepository.getAllCategories();

      // If categories are loaded successfully, update the _categories list
      setState(() {
        _categories = categories.map((category) => category.categoryName).toList();
      });
    } catch (e) {
      // Handle error (e.g., show a snackbar with the error message)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories: $e')),
      );
    }
  }

Future<void> _submitQuiz() async {
  if (_formKey.currentState?.validate() ?? false) {
    setState(() => _isLoading = true);

    try {
      // Step 1: Collect data from the form fields.
      String question = _quizQuestionController.text.trim();
      String description = _quizDescriptionController.text.trim();
      String answer1 = _optionControllers[0].text.trim();
      String answer2 = _optionControllers[1].text.trim();
      String answer3 = _optionControllers[2].text.trim();
      String answer4 = _optionControllers[3].text.trim();
      String correctAnswer = _correctAnswerController.text.trim();
      String category = _selectedCategory ?? '';
      String author = "Author Name"; // You can replace this with the current user's name if needed

      // Step 2: Handle image upload if an image is selected.
      String? imageUrl;
      if (_selectedImage != null) {
        // Upload the image to Firebase Storage (or another service) and get the URL.
        imageUrl = await _uploadImage(_selectedImage!);
      }

      // Step 3: Create a new Quiz object.
      Quiz newQuiz = Quiz(
        quizId: "", // Firebase will generate the ID
        category: category,
        author: author,
        description: description,
        question: question,
        answer1: answer1,
        answer2: answer2,
        answer3: answer3,
        answer4: answer4,
        correctAnswer: correctAnswer,
        img: imageUrl,
      );

      // Step 4: Save the quiz to Firebase Firestore.
      // Here we're assuming you have a Firestore collection for quizzes.
      await quizRepository.addQuiz(newQuiz);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz added successfully!')),
        );
        _resetForm(); // Reset the form after successful submission.
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding quiz: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

// Helper method to upload an image to Firebase Storage and get the URL.
Future<String?> _uploadImage(File image) async {
  try {
    // Ensure the file exists
    if (!image.existsSync()) {
      throw Exception('File does not exist at the specified path.');
    }

    // Reference to Firebase Storage with a unique path
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('quiz_images')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    // Upload the image to Firebase Storage
    final uploadTask = storageRef.putFile(image);

    // Wait for the upload to complete and get the snapshot
    final snapshot = await uploadTask;

    // Retrieve the download URL
    final downloadUrl = await snapshot.ref.getDownloadURL();
    print('Image uploaded successfully: $downloadUrl');
    return downloadUrl;
  } catch (e) {
    print('Error uploading image: $e');
    return null;
  }
}
  
  
  
  // Method to handle picking an image from the gallery.
  Future<void> _pickImage() async {
    try {
      // Open the image picker and allow the user to select an image from the gallery.
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          // Update the selected image if a valid image is picked.
          _selectedImage = File(pickedFile.path);
        });
      } else {
        // Print message if no image was selected.
        print('No image selected.');
      }
    } catch (e) {
      // Print error if something goes wrong during image picking.
      print('Error picking image: $e');
    }
  }

  // Method to reset the form to its initial state.
  void _resetForm() {
    _formKey.currentState?.reset();
    for (var controller in _optionControllers) {
      controller.clear();
    }
    _correctAnswerController.clear();
    _quizDescriptionController.clear();
    _selectedCategory = null;
    _selectedImage = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.addQuizBtn,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  _buildPhotoUploadSection(),
                  const SizedBox(height: 20),
                  _buildQuizDescriptionField(),
                  const SizedBox(height: 10),
                  ..._buildOptionFields(),
                  const SizedBox(height: 20),
                  _buildCorrectAnswerField(),
                  const SizedBox(height: 20),
                  _buildCategoryDropdown(),
                  const SizedBox(height: 32),
                  _buildAddButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoUploadSection() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: _selectedImage == null
            ? Center(
                child: Text(
                  AppLocalizations.of(context)!.uploadPic,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
      ),
    );
  }

  Widget _buildQuizDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text('Quiz Question:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        MyTextField(
          controller: _quizQuestionController,
          hintText: 'Enter Quiz Question',
          obscureText: false,
          keyboardType: TextInputType.text,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter the quiz question';
            }
            return null;
          },
          errorMsg: '', // You can pass an error message if needed
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            AppLocalizations.of(context)!.quizDesc,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        MyTextField(
          controller: _quizDescriptionController,
          hintText: AppLocalizations.of(context)!.enterQuizDesc,
          obscureText: false,
          keyboardType: TextInputType.text,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter the quiz description';
            }
            return null;
          },
          errorMsg: '', // You can pass an error message if needed
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            AppLocalizations.of(context)!.category,
            style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          items: _categories
              .map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor:   Theme.of(context).colorScheme.onPrimary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please select a category';
            }
            return null;
          },
        ),
      ],
    );
  }

  List<Widget> _buildOptionFields() {
    return List.generate(
      4,
      (index) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                AppLocalizations.of(context)!.option(index + 1),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            MyTextField(
              controller: _optionControllers[index],
              hintText: AppLocalizations.of(context)!.enterOption(index + 1),
              obscureText: false,
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter option ${index + 1}';
                }
                return null;
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCorrectAnswerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            AppLocalizations.of(context)!.corrAns,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        MyTextField(
          controller: _correctAnswerController,
          hintText: AppLocalizations.of(context)!.corrAns,
          obscureText: false,
          keyboardType: TextInputType.text,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter the correct answer';
            }
            if (!_optionControllers
                .map((c) => c.text.trim())
                .contains(value.trim())) {
              return 'Correct answer must match one of the options';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitQuiz,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          //foregroundColor: Theme.of(context).colorScheme.inversePrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                AppLocalizations.of(context)!.addQuizBtn,
                style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
