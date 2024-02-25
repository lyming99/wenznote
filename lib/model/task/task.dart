class BaseTask {
  bool cancel = false;
  Future<void> Function(BaseTask task) task;

  BaseTask({
    required this.task,
  });

  void stopTask(){
    cancel=true;
  }

  Future<void> doTask() async {
    await task.call(this);
  }
}
