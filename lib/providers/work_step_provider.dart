import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/system_work_step_model.dart';
import '../services/supabase_service.dart';

final workStepsProvider =
    FutureProvider.family<List<SystemWorkStepModel>, String>(
        (ref, system) async {
  final response = await SupabaseService.client
      .from('system_work_steps')
      .select()
      .eq('system', system)
      .order('step_order');

  return (response as List)
      .map((e) => SystemWorkStepModel.fromJson(e))
      .toList();
});
