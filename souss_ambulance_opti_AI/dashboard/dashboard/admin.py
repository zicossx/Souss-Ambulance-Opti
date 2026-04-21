from django.contrib import admin
from .models import Hospital, HospitalUser, BedAvailability, Ambulance, Patient, MedicalCondition

@admin.register(Hospital)
class HospitalAdmin(admin.ModelAdmin):
    list_display = ['name', 'city', 'region', 'phone', 'emergency_capacity', 'is_active']
    list_filter = ['region', 'is_active', 'city']
    search_fields = ['name', 'license_number']
    fields = [
        'name', 'license_number', 'address', 'city', 'region',
        'phone', 'email', 'emergency_capacity',
        'latitude', 'longitude', 'is_active'
    ]

@admin.register(HospitalUser)
class HospitalUserAdmin(admin.ModelAdmin):
    list_display = ['user', 'hospital', 'role', 'department', 'is_available']
    list_filter = ['role', 'hospital', 'is_available']
    search_fields = ['user__first_name', 'user__last_name', 'user__email']

@admin.register(BedAvailability)
class BedAvailabilityAdmin(admin.ModelAdmin):
    list_display = ['hospital', 'bed_type', 'available_beds', 'total_beds', 'updated_at']
    list_filter = ['bed_type', 'hospital']

@admin.register(Ambulance)
class AmbulanceAdmin(admin.ModelAdmin):
    list_display = ['vehicle_number', 'driver_name', 'status', 'destination_hospital', 'eta_minutes']
    list_filter = ['status', 'destination_hospital']
    search_fields = ['vehicle_number', 'driver_name']

@admin.register(Patient)
class PatientAdmin(admin.ModelAdmin):
    list_display = ['full_name', 'cin', 'hospital', 'status', 'assigned_doctor', 'admitted_at']
    list_filter = ['status', 'hospital', 'gender']
    search_fields = ['full_name', 'cin', 'phone']

@admin.register(MedicalCondition)
class MedicalConditionAdmin(admin.ModelAdmin):
    list_display = ['name', 'hospital', 'severity', 'is_active']
    list_filter = ['severity', 'is_active', 'hospital']