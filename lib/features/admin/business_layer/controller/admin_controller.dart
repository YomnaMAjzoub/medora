import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart' hide Trans;
import 'package:medora_git/features/admin/data/models/admin_offer_model.dart';
import 'package:medora_git/features/admin/data/models/item_model.dart';
import 'package:medora_git/features/admin/data/src/admin_service.dart';
import 'package:medora_git/features/patient/data/models/doctor_model.dart';
import 'package:medora_git/features/patient/data/models/doctor_profile_model.dart';

/// Admin (Staff) panel state: the doctors managed by the logged-in admin
/// and the full doctor profiles (working hours, availability).
class AdminController extends GetxController {
  AdminController({AdminService? service})
      : _service = service ?? AdminService();

  final AdminService _service;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<DoctorModel> doctors = <DoctorModel>[].obs;
  final RxList<DoctorProfileModel> doctorProfiles = <DoctorProfileModel>[].obs;

  final RxBool isSubmitting = false.obs;
  final RxBool isLoadingItems = false.obs;
  final RxString itemsError = ''.obs;
  final RxList<ItemModel> items = <ItemModel>[].obs;
  final RxSet<int> usingItemIds = <int>{}.obs;

  /// Offers created during this session (POST /addOffer responses), newest
  /// first. Shown on the add-offer screen as confirmation cards; the step
  /// indicator grows with this list.
  final RxList<AdminOfferModel> createdOffers = <AdminOfferModel>[].obs;

  /// Distinct specializations fetched from the backend
  /// (GET /getSpcialization) — drives the Add/Edit Doctor dropdowns.
  final RxList<String> specialties = <String>[].obs;
  final RxBool isLoadingSpecialties = false.obs;
  final RxString specialtiesError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDoctors();
    fetchSpecializations();
  }

  Future<void> fetchSpecializations() async {
    isLoadingSpecialties.value = true;
    specialtiesError.value = '';
    try {
      specialties.assignAll(await _service.getSpecializations());
    } catch (e) {
      // Surface the failure to the forms (retry affordance) instead of
      // leaving a silently-empty dropdown.
      specialtiesError.value = e.toString();
    } finally {
      isLoadingSpecialties.value = false;
    }
  }

  Future<void> fetchDoctors() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _service.getAllDoctors();
      doctorProfiles.assignAll(result);
      doctors.assignAll(result.map((profile) => profile.toDoctorModel()));
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addDoctor({
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
    String? photoPath,
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
      return true;
    } catch (e) {
      Get.snackbar('error'.tr(), e.toString());
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateDoctor({
    required DoctorModel doctor,
    double? price,
    bool? homeVisit,
    String? specialization,
    String? photoPath,
    String? password,
    String? day,
    String? startTime,
    String? endTime,
  }) async {
    isSubmitting.value = true;
    try {
      final id = int.tryParse(doctor.id);
      if (id == null) {
        Get.snackbar('error'.tr(), 'invalid_doctor_id'.tr());
        return false;
      }
      await _service.updateDoctor(
        doctorId: id,
        price: price,
        homeVisit: homeVisit,
        specialization: specialization,
        photoPath: photoPath,
        password: password,
        day: day,
        startTime: startTime,
        endTime: endTime,
      );
      Get.snackbar('success'.tr(), 'doctor_updated'.tr());
      await fetchDoctors();
      return true;
    } catch (e) {
      Get.snackbar('error'.tr(), e.toString());
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> deleteDoctor(DoctorModel doctor) async {
    // The backend deleteDoctor endpoint expects the doctor's USER id
    // (appointments and tokens reference users), not the doctors row id.
    final id = doctor.userId ?? int.tryParse(doctor.id);
    if (id == null) {
      Get.snackbar('error'.tr(), 'invalid_doctor_id'.tr());
      return false;
    }
    try {
      await _service.deleteDoctor(id);
      Get.snackbar('success'.tr(), 'doctor_deleted'.tr());
      await fetchDoctors();
      return true;
    } catch (e) {
      Get.snackbar('error'.tr(), e.toString());
      return false;
    }
  }

  Future<void> fetchItems() async {
    isLoadingItems.value = true;
    itemsError.value = '';
    try {
      final result = await _service.getItems();
      items.assignAll(result);
    } catch (e) {
      itemsError.value = e.toString();
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      isLoadingItems.value = false;
    }
  }

  /// Consumes one unit of an item (useItem) and refreshes the list.
  Future<void> useItem(ItemModel item) async {
    usingItemIds.add(item.id);
    try {
      final used = await _service.useItem(item.id);
      if (!used) {
        Get.snackbar('error'.tr(), 'item_unavailable'.tr());
      } else {
        Get.snackbar('success'.tr(), 'item_used'.tr());
      }
      await fetchItems();
    } catch (e) {
      Get.snackbar('error'.tr(), e.toString());
    } finally {
      usingItemIds.remove(item.id);
    }
  }

  /// Creates a discount offer (addOffer). Returns true only after the
  /// backend confirms the offer was created (HTTP 200 with the offer
  /// object); the confirmed offer is kept for the success card + step
  /// indicator on the form.
  Future<bool> addOffer({
    required String title,
    required String description,
    required double discountPercentage,
    required DateTime validFrom,
    required DateTime validUntil,
  }) async {
    isSubmitting.value = true;
    try {
      final offer = await _service.addOffer(
        title: title,
        description: description,
        discountPercentage: discountPercentage,
        validFrom: validFrom,
        validUntil: validUntil,
      );
      createdOffers.insert(0, offer);
      Get.snackbar('success'.tr(), 'offer_added'.tr());
      return true;
    } catch (e) {
      Get.snackbar('error'.tr(), e.toString());
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}