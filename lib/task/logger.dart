class Logger {
  static List<String> logs = [];

  static void logDeletedTask(int taskId) {
    log("Deleted Task with ID: $taskId");
  }

  static void logCreatedTask(String taskTitle) {
    log("Created Task: $taskTitle");
  }

  static void logCompletedTask(int taskId) {
    log("Completed Task with ID: $taskId");
  }

  static void log(String message) {
    logs.add(message);
    print(message);
  }

  static List<String> getAllLogs() {
    return List.from(logs);
  }
}
