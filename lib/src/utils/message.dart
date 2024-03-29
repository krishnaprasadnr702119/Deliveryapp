class Message {
  static var RegistrationSucces = "Registration successful";
  static var RegistrationFailed = "Registration failed";
  static var LoginFailed = "Login failed";
  static var fill = "Please fill in all fields.";
  static var UserExist = "Email already exists. Please choose a different one.";
  static var Register = "Register";
  static var Login = "Login";
  static var Forget = " Forget Password";
  static var account = "Create an account";
  static var Forgetpassword = "Forget Password successful";
  static var Forgetpasswordfailed = "Forget Password failed";
  static var logs = 'Logs';
  static var userid = 'User ID';
  static var Status = 'Status';
  static var OrderNumber = 'Order Number';
  static var created = 'Created';
  static var expected = 'Expected Date to Completed';
  static var Nologs = 'No logs';
  static var completed = 'Completed';
  static var image = 'Image added to DB successfully.';
  static var updatetask = 'Update Task';
  static var location = 'Location';
  static var pin = 'Pin';
  static var date = 'Date';
  static var cancel = 'Cancel';
  static var addimage = 'Add Image';
  static var addpin = 'Please enter a valid 4-digit PIN for completion.';
  static var addlngandlong =
      'Please enter a valid location for the task. (Format: latitude, longitude)';
  static var taskupdated = 'Task updated';
  static var update = "Update";
  static var viewimage = 'View Image';
  static var tasksuccess = "Task successfully";
  static var allfill = "All fields must be filled";
  static var submit = "Submit";
  static var deleted = "Deleted Task";
  static var deleteconf = "Confirm Deletion";
  static var confdelete = "Are you sure you want to delete this task?";

  static String? validateRegistrationFields(
    String username,
    String email,
    String password,
    String confirmPassword,
  ) {
    // Check if any field is empty
    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      return 'Please fill in all fields.';
    }

    // Check if the email is valid
    if (!email.contains('@')) {
      return 'Please enter a valid email address.';
    }

    // Check if passwords match
    if (password != confirmPassword) {
      return 'Passwords do not match.';
    }

    // Check if the password meets the criteria
    if (!_isPasswordValid(password)) {
      return 'Password must be at least 6 characters long and include at least one uppercase letter, one lowercase letter, one number, and one special character.';
    }

    return null;
  }

  static bool _isPasswordValid(String password) {
    final RegExp passwordRegex = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$%^&*(),.?":{}|<>]).{6,}$',
    );

    return passwordRegex.hasMatch(password);
  }
}
