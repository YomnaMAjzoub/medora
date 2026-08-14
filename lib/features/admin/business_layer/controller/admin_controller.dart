import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart' hide Trans;
import 'package:medora_git/features/admin/data/src/admin_service.dart';
import 'package:medora_git/features/patient/data/models/doctor_model.dart';
import 'package:medora_git/features/patient/data/models/specialization_model.dart';
import 'package:medora_git/features/patient/data/src/patient_service.dart';

/// Admin panel state: the doctors managed by the logged-in admin and the
/// specializations available for the add/edit doctor forms.
class AdminController extends GetxController {
  AdminController({AdminService? service})
      : _service = service ?? AdminService();

  final AdminService _service;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<DoctorModel> doctors = <DoctorModel>[].obs;

  final RxBool isSubmitting = false.obs;

  final RxBool isLoadingSpecializations = false.obs;
  final RxList<SpecializationModel> specialties = <SpecializationModel>[].obs;

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
      final result = await _service.getAllDoctors();
      doctors.assignAll(result.map((profile) => profile.toDoctorModel()));
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSpecializations() async {
    isLoadingSpecializations.value = true;
    try {
      final result = await PatientService().getSpecializations();
      specialties.assignAll(result);
    } catch (e) {
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      isLoadingSpecializations.value = false;
    }
  }

  Future<void> addDoctor({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String specialization,
    required String phone,
    required String gender,
    required String day,
    required String startTime,
    required String endTime,
    required bool homeVisit,
    required double price,
    required String photoPath,
  }) async {
    isSubmitting.value = true;
    try {
      await _service.addDoctor(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        specialization: specialization,
        phone: phone,
        gender: gender,
        day: day,
        startTime: startTime,
        endTime: endTime,
        homeVisit: homeVisit,
        price: price,
        photoPath: photoPath,
      );
      Get.snackbar('success'.tr(), 'doctor_added'.tr());
      await fetchDoctors();
    } catch (e) {
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> updateDoctor({
    required DoctorModel doctor,
    double? price,
    bool? homeVisit,
    String? specialization,
    String? photoPath,
    String? password,
  }) async {
    isSubmitting.value = true;
    try {
      final id = int.tryParse(doctor.id);
      if (id == null) {
        Get.snackbar('error'.tr(), 'Invalid doctor id.');
        return;
      }
      await _service.updateDoctor(
        doctorId: id,
        price: price,
        homeVisit: homeVisit,
        specialization: specialization,
        photoPath: photoPath,
        password: password,
      );
      Get.snackbar('success'.tr(), 'doctor_updated'.tr());
      await fetchDoctors();
    } catch (e) {
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteDoctor(DoctorModel doctor) async {
    final id = int.tryParse(doctor.id);
    if (id == null) {
      Get.snackbar('error'.tr(), 'Invalid doctor id.');
      return;
    }
    try {
      await _service.deleteDoctor(id);
      Get.snackbar('success'.tr(), 'doctor_deleted'.tr());
      await fetchDoctors();
    } catch (e) {
      Get.snackbar('error'.tr(), e.toString());
    }
  }

  Future<void> addOffer({
    required String title,
    required String description,
    required double discountPercentage,
    required DateTime validFrom,
    required DateTime validUntil,
  }) async {
    isSubmitting.value = true;
    try {
      await _service.addOffer(
        title: title,
        description: description,
        discountPercentage: discountPercentage,
        validFrom: validFrom,
        validUntil: validUntil,
      );
      Get.snackbar('success'.tr(), 'offer_added'.tr());
    } catch (e) {
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }
}