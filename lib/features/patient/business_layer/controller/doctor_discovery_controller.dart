import 'package:get/get.dart';
import 'package:medora_git/features/patient/data/models/doctor_model.dart';
import 'package:medora_git/features/patient/data/models/specialty_model.dart';
import 'package:medora_git/features/patient/data/src/patient_service.dart';

class DoctorDiscoveryController extends GetxController {
  DoctorDiscoveryController({PatientService? service})
      : _service = service ?? PatientService();

  final PatientService _service;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<DoctorModel> doctors = <DoctorModel>[].obs;

  final RxBool isLoadingSpecializations = false.obs;
  final RxString specializationsError = ''.obs;
  final RxList<SpecialtyModel> specialties = <SpecialtyModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDoctors();
    fetchSpecializations();
  }

  Future<void> fetchDoctors() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _service.getAllDoctorsForPatient();
      doctors.assignAll(result.map((profile) => profile.toDoctorModel()));
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSpecializations() async {
    isLoadingSpecializations.value = true;
    specializationsError.value = '';
    try {
      final result = await _service.getSpecializations();
      // Only the specializations the backend actually returned
      // (GET /getSpcialization = distinct doctors.specialization values).
      // Blank rows (null/'' specialization on a doctor) are skipped so no
      // extra placeholder tiles appear.
      specialties.assignAll(
        result
            .where((s) => s.name.trim().isNotEmpty)
            .toList()
            .asMap()
            .entries
            .map(
              (entry) => SpecialtyModel(
                id: entry.key.toString(),
                name: entry.value.name,
                icon: SpecialtyModel.iconFor(entry.value.name),
              ),
            ),
      );
    } catch (e) {
      specializationsError.value = e.toString();
      Get.snackbar('Error', e.toString());
    } finally {
      isLoadingSpecializations.value = false;
    }
  }

  String? _specializationFilter;
  String? _genderFilter;

  Future<void> applyFilter({String? specialization, String? gender}) async {
    _specializationFilter = specialization;
    _genderFilter = gender;
    if (_specializationFilter == null && _genderFilter == null) {
      await fetchDoctors();
      return;
    }
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _service.filterDoctors(
        specialization: _specializationFilter,
        gender: _genderFilter,
      );
      doctors.assignAll(result.map((profile) => profile.toDoctorModel()));
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> clearFilters() async {
    _specializationFilter = null;
    _genderFilter = null;
    await fetchDoctors();
  }
}