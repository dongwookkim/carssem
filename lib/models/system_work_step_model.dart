class SystemWorkStepModel {
  final String id;
  final String system;
  final int stepOrder;
  final String title;
  final List<String> subSteps;

  SystemWorkStepModel({
    required this.id,
    required this.system,
    required this.stepOrder,
    required this.title,
    required this.subSteps,
  });

  factory SystemWorkStepModel.fromJson(Map<String, dynamic> json) {
    return SystemWorkStepModel(
      id: json['id'] as String,
      system: json['system'] as String,
      stepOrder: json['step_order'] as int,
      title: json['title'] as String,
      subSteps: (json['sub_steps'] as List).cast<String>(),
    );
  }
}
