enum TaskStatus { COMPLETED, OMITTED, PENDING;

  @override
  String toString(){
    switch(this){
      case TaskStatus.COMPLETED:
        return "completed";
      case TaskStatus.OMITTED:
        return "omitted";
      case TaskStatus.PENDING:
        return "pending";
      default:
        return "";
    }
  }

  factory TaskStatus.fromString(String taskStatus){
    switch(taskStatus){
      case "completed":
        return TaskStatus.COMPLETED;
        break;
      case "omitted":
        return TaskStatus.OMITTED;
      case "pending":
        return TaskStatus.PENDING;
      default:
        throw UnimplementedError("This taskStatus doesn't exist");
    }
  }

}