from django.urls import path
from . import views

urlpatterns = [
    path('', views.dashboard_view, name='dashboard'),
    path('login/', views.login_view, name='login'),
    path('signup/', views.signup_view, name='signup'),  # NEW: Signup route
    path('logout/', views.logout_view, name='logout'),
    
    # Bed Management
    path('api/update-beds/', views.update_beds, name='update_beds'),
    path('api/adjust-bed/', views.adjust_bed_count, name='adjust_bed'),
    
    # Patient Management
    path('api/patients/', views.get_patients_api, name='get_patients'),
    path('api/patients/add/', views.add_patient, name='add_patient'),
    path('api/patients/<int:patient_id>/status/', views.update_patient_status, name='update_patient_status'),
    
    # Ambulance Management
    path('api/ambulances/', views.get_ambulances_api, name='get_ambulances'),
    path('api/ambulances/<int:ambulance_id>/status/', views.update_ambulance_status, name='update_ambulance_status'),
    
    # Staff Management
    path('api/staff/', views.get_staff_api, name='get_staff'),
    path('api/staff/<int:staff_id>/toggle/', views.toggle_staff_availability, name='toggle_staff'),
    
    # Conditions Management
    path('api/conditions/add/', views.add_condition, name='add_condition'),
    path('api/conditions/<int:condition_id>/delete/', views.delete_condition, name='delete_condition'),
]