import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eldcare/doctor/models/doctor.dart';
import 'package:eldcare/doctor/repositories/doctor_repository.dart';
import 'doctor_registration_event.dart';
import 'doctor_registration_state.dart';

class DoctorRegistrationBloc
    extends Bloc<DoctorRegistrationEvent, DoctorRegistrationState> {
  final DoctorRepository _doctorRepository;

  DoctorRegistrationBloc({
    required DoctorRepository doctorRepository,
  })  : _doctorRepository = doctorRepository,
        super(DoctorRegistrationInitial()) {
    on<SubmitDoctorRegistration>(_onSubmitRegistration);
    on<UpdateDocumentFile>(_onUpdateDocumentFile);
  }

  Map<String, File> documentFiles = {};

  Future<void> _onSubmitRegistration(
    SubmitDoctorRegistration event,
    Emitter<DoctorRegistrationState> emit,
  ) async {
    try {
      emit(DoctorRegistrationLoading());

      final doctor = Doctor(
        userId: event.userId,
        fullName: event.fullName,
        mobileNumber: event.mobileNumber,
        address: event.address,
        registrationNumber: event.registrationNumber,
        medicalCouncil: event.medicalCouncil,
        qualification: event.qualification,
        specialization: event.specialization,
        experience: event.experience,
        hospitalName: event.hospitalName,
        hospitalAddress: event.hospitalAddress,
        workContact: event.workContact,
        workEmail: event.workEmail,
        documents: {}, // Will be populated during upload
      );

      await _doctorRepository.registerDoctor(doctor, event.documents);
      emit(DoctorRegistrationSuccess());
    } catch (e) {
      emit(DoctorRegistrationFailure(e.toString()));
    }
  }

  Future<void> _onUpdateDocumentFile(
    UpdateDocumentFile event,
    Emitter<DoctorRegistrationState> emit,
  ) async {
    try {
      documentFiles[event.documentType] = event.file;
      emit(DocumentUploadProgress(
        documentType: event.documentType,
        progress: 1.0,
      ));
    } catch (e) {
      emit(DoctorRegistrationFailure(e.toString()));
    }
  }
}
