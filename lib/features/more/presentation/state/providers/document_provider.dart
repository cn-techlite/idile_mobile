import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/features/more/presentation/controller/documents/document_controller.dart';
import 'package:idile_mobile_app/features/more/presentation/state/state_model/document_state.dart';

final documentControllerProvider =
    AsyncNotifierProvider<DocumentController, DocumentState>(
      DocumentController.new,
    );
