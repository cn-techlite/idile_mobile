import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:idile_mobile_app/core/network/api_client_provider.dart';
import 'package:idile_mobile_app/features/more/data/repository/documents/document_repository_impl.dart';
import 'package:idile_mobile_app/features/more/data/service/documents/document_remote_service.dart';
import 'package:idile_mobile_app/features/more/domain/controller/documents/document_controller.dart';
import 'package:idile_mobile_app/features/more/domain/usecases/documents/document_repository.dart';
import 'package:idile_mobile_app/features/more/presentation/state/state_model/document_state.dart';

final documentRemoteServiceProvider = Provider<DocumentRemoteService>(
  (ref) => DocumentRemoteService(ref.read(apiClientProvider)),
);

final documentRepositoryProvider = Provider<DocumentRepository>(
  (ref) => DocumentRepositoryImpl(ref.read(documentRemoteServiceProvider)),
);

final documentControllerProvider =
    AsyncNotifierProvider<DocumentController, DocumentState>(
      DocumentController.new,
    );
