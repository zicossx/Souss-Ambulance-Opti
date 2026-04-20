from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import User
from django.contrib import messages
from django.http import JsonResponse
from django.views.decorators.http import require_http_methods
from django.db.models import Count, Q, F
from django.db import transaction
from .models import Hospital, HospitalUser, BedAvailability, Ambulance, Patient, MedicalCondition
import json
from datetime import datetime

def login_view(request):
    if request.user.is_authenticated:
        return redirect('dashboard')
    
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        user = authenticate(request, username=username, password=password)
        
        if user is not None:
            try:
                hospital_user = HospitalUser.objects.get(user=user)
                if hospital_user.hospital.is_active:
                    login(request, user)
                    return redirect('dashboard')
                else:
                    messages.error(request, 'Hospital account is inactive.')
            except HospitalUser.DoesNotExist:
                messages.error(request, 'Access denied. Not a hospital user.')
        else:
            messages.error(request, 'Invalid username or password.')
    
    return render(request, 'dashboard/login.html')

# NEW: Signup view for hospital registration
def signup_view(request):
    if request.user.is_authenticated:
        return redirect('dashboard')
    
    if request.method == 'POST':
        try:
            with transaction.atomic():
                # Get form data
                hospital_name = request.POST.get('hospital_name')
                city = request.POST.get('city')
                region = request.POST.get('region')
                address = request.POST.get('address')
                phone = request.POST.get('phone')
                email = request.POST.get('email')
                license_number = request.POST.get('license_number')
                latitude = request.POST.get('latitude')
                longitude = request.POST.get('longitude')
                emergency_capacity = request.POST.get('emergency_capacity', 50)
                
                # Admin user data
                first_name = request.POST.get('first_name')
                last_name = request.POST.get('last_name')
                username = request.POST.get('username')
                password = request.POST.get('password')
                confirm_password = request.POST.get('confirm_password')
                admin_phone = request.POST.get('admin_phone')
                
                # Validate required fields
                if not all([hospital_name, city, region, address, phone, email, 
                           license_number, latitude, longitude, first_name, 
                           last_name, username, password, admin_phone]):
                    messages.error(request, 'All fields are required.')
                    return render(request, 'dashboard/signup.html')
                
                # Check passwords match
                if password != confirm_password:
                    messages.error(request, 'Passwords do not match.')
                    return render(request, 'dashboard/signup.html')
                
                if len(password) < 8:
                    messages.error(request, 'Password must be at least 8 characters.')
                    return render(request, 'dashboard/signup.html')
                
                # Check if username exists
                if User.objects.filter(username=username).exists():
                    messages.error(request, 'Username already exists. Please choose another.')
                    return render(request, 'dashboard/signup.html')
                
                # Check if license number exists
                if Hospital.objects.filter(license_number=license_number).exists():
                    messages.error(request, 'License number already registered.')
                    return render(request, 'dashboard/signup.html')
                
                # Check if email exists
                if Hospital.objects.filter(email=email).exists():
                    messages.error(request, 'Email already registered.')
                    return render(request, 'dashboard/signup.html')
                
                # Create Hospital — store password directly in hospitals table
                hospital = Hospital.objects.create(
                    name=hospital_name,
                    address=address,
                    city=city,
                    region=region,
                    phone=phone,
                    email=email,
                    license_number=license_number,
                    emergency_capacity=int(emergency_capacity),
                    latitude=float(latitude),
                    longitude=float(longitude),
                    password=password,   # store plain password in hospitals table
                    is_active=True
                )
                
                # Create Django User (handles hashed auth password)
                user = User.objects.create_user(
                    username=username,
                    password=password,
                    first_name=first_name,
                    last_name=last_name,
                    email=email
                )
                
                # Create HospitalUser (Admin)
                HospitalUser.objects.create(
                    user=user,
                    hospital=hospital,
                    role='admin',
                    phone=admin_phone,
                    department='Administration',
                    is_available=True
                )
                
                # Initialize default bed types
                default_beds = [
                    ('emergency', 8),
                    ('icu', 5),
                    ('general', 30),
                    ('pediatric', 8),
                    ('maternity', 6),
                    ('covid', 4)
                ]
                
                for bed_type, total in default_beds:
                    BedAvailability.objects.create(
                        hospital=hospital,
                        bed_type=bed_type,
                        total_beds=total,
                        available_beds=total,
                        updated_by=None
                    )
                
                messages.success(request, f'✅ Hospital "{hospital_name}" registered! You can now log in with username: {username}')
                return redirect('login')
                
        except Exception as e:
            messages.error(request, f'Registration failed: {str(e)}')
            return render(request, 'dashboard/signup.html')
    
    return render(request, 'dashboard/signup.html')

@login_required
def dashboard_view(request):
    try:
        hospital_user = HospitalUser.objects.select_related('hospital').get(user=request.user)
        hospital = hospital_user.hospital
        
        # Get all dashboard data
        beds = BedAvailability.objects.filter(hospital=hospital)
        ambulances = Ambulance.objects.filter(
            destination_hospital=hospital,
            is_online=True
        ).select_related('destination_hospital')
        
        patients = Patient.objects.filter(
            hospital=hospital
        ).exclude(status='discharged').select_related('assigned_doctor')
        
        staff = HospitalUser.objects.filter(hospital=hospital, is_available=True)
        conditions = MedicalCondition.objects.filter(hospital=hospital, is_active=True)
        
        # Statistics
        critical_count = patients.filter(status='critical').count()
        total_beds = sum(b.total_beds for b in beds)
        available_beds = sum(b.available_beds for b in beds)
        occupancy_rate = round(((total_beds - available_beds) / total_beds * 100), 1) if total_beds > 0 else 0
        
        context = {
            'hospital': hospital,
            'user': hospital_user,
            'beds': beds,
            'ambulances': ambulances,
            'patients': patients,
            'staff': staff,
            'conditions': conditions,
            'is_admin': hospital_user.role == 'admin',
            'critical_count': critical_count,
            'total_beds': total_beds,
            'available_beds': available_beds,
            'occupancy_rate': occupancy_rate,
        }
        
        return render(request, 'dashboard/dashboard.html', context)
        
    except HospitalUser.DoesNotExist:
        logout(request)
        return redirect('login')

# ==================== BED MANAGEMENT API ====================

@login_required
@require_http_methods(["POST"])
def update_beds(request):
    try:
        data = json.loads(request.body)
        bed_type = data.get('bed_type')
        available = int(data.get('available_beds', 0))
        total = int(data.get('total_beds', 0))
        
        hospital_user = HospitalUser.objects.get(user=request.user)
        
        if hospital_user.role != 'admin':
            return JsonResponse({'error': 'Permission denied'}, status=403)
        
        if available > total:
            return JsonResponse({'error': 'Available beds cannot exceed total beds'}, status=400)
        
        bed, created = BedAvailability.objects.update_or_create(
            hospital=hospital_user.hospital,
            bed_type=bed_type,
            defaults={
                'total_beds': total,
                'available_beds': available,
                'updated_by': hospital_user
            }
        )
        
        return JsonResponse({
            'success': True,
            'bed': {
                'type': bed.bed_type,
                'type_display': bed.get_bed_type_display(),
                'available': bed.available_beds,
                'total': bed.total_beds,
                'percentage': int((bed.available_beds / bed.total_beds * 100)) if bed.total_beds > 0 else 0
            }
        })
        
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)

@login_required
@require_http_methods(["POST"])
def adjust_bed_count(request):
    """Quick adjust bed count (+1 or -1)"""
    try:
        data = json.loads(request.body)
        bed_type = data.get('bed_type')
        action = data.get('action')  # 'increment' or 'decrement'
        field = data.get('field', 'available')  # 'available' or 'total'
        
        hospital_user = HospitalUser.objects.get(user=request.user)
        
        if hospital_user.role != 'admin':
            return JsonResponse({'error': 'Permission denied'}, status=403)
        
        bed = BedAvailability.objects.get(hospital=hospital_user.hospital, bed_type=bed_type)
        
        if field == 'available':
            if action == 'increment' and bed.available_beds < bed.total_beds:
                bed.available_beds += 1
            elif action == 'decrement' and bed.available_beds > 0:
                bed.available_beds -= 1
        else:  # total
            if action == 'increment':
                bed.total_beds += 1
                bed.available_beds += 1
            elif action == 'decrement' and bed.total_beds > 0:
                bed.total_beds -= 1
                if bed.available_beds > bed.total_beds:
                    bed.available_beds = bed.total_beds
        
        bed.updated_by = hospital_user
        bed.save()
        
        return JsonResponse({
            'success': True,
            'bed': {
                'type': bed.bed_type,
                'available': bed.available_beds,
                'total': bed.total_beds
            }
        })
        
    except BedAvailability.DoesNotExist:
        return JsonResponse({'error': 'Bed type not found'}, status=404)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)

# ==================== PATIENT MANAGEMENT API ====================

@login_required
@require_http_methods(["POST"])
def add_patient(request):
    try:
        data = json.loads(request.body)
        hospital_user = HospitalUser.objects.get(user=request.user)
        hospital = hospital_user.hospital
        
        # Split full_name into first and last name for the legacy table
        name_parts = data.get('full_name', '').split(' ', 1)
        f_name = name_parts[0]
        l_name = name_parts[1] if len(name_parts) > 1 else ''

        patient = Patient.objects.create(
            hospital=hospital,
            first_name=f_name,
            last_name=l_name,
            cin=data.get('cin'),
            age=int(data.get('age', 0)),
            gender=data.get('gender'),
            phone=data.get('phone', ''),
            address=data.get('address', ''),
            condition=data.get('condition', ''),
            status=data.get('status', 'waiting'),
            assigned_doctor_id=data.get('assigned_doctor') if data.get('assigned_doctor') else None
        )
        
        return JsonResponse({
            'success': True,
            'patient': {
                'id': patient.id,
                'name': patient.full_name,
                'status': patient.status,
                'status_display': patient.get_status_display()
            }
        })
        
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)

@login_required
@require_http_methods(["POST"])
def update_patient_status(request, patient_id):
    try:
        data = json.loads(request.body)
        hospital_user = HospitalUser.objects.get(user=request.user)
        
        patient = Patient.objects.get(
            id=patient_id,
            hospital=hospital_user.hospital
        )
        
        old_status = patient.status
        patient.status = data.get('status')
        if data.get('status') == 'discharged':
            patient.assigned_doctor = None
        patient.save()
        
        return JsonResponse({
            'success': True,
            'patient': {
                'id': patient.id,
                'name': patient.full_name,
                'old_status': old_status,
                'new_status': patient.status,
                'status_display': patient.get_status_display()
            }
        })
        
    except Patient.DoesNotExist:
        return JsonResponse({'error': 'Patient not found'}, status=404)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)

@login_required
def get_patients_api(request):
    """Get patients list with filtering"""
    try:
        hospital_user = HospitalUser.objects.get(user=request.user)
        hospital = hospital_user.hospital
        
        status_filter = request.GET.get('status', '')
        search = request.GET.get('search', '')
        
        patients = Patient.objects.filter(hospital=hospital).exclude(status='discharged')
        
        if status_filter:
            patients = patients.filter(status=status_filter)
        
        if search:
            patients = patients.filter(
                Q(first_name__icontains=search) | 
                Q(last_name__icontains=search) | 
                Q(cin__icontains=search)
            )
        
        patients_data = list(patients.values(
            'id', 'first_name', 'last_name', 'cin', 'age', 'gender',
            'status', 'condition', 'admitted_at',
            assigned_doctor_name=F('assigned_doctor__user__first_name')
        ))
        
        return JsonResponse({
            'success': True,
            'patients': patients_data,
            'count': len(patients_data)
        })
        
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)

@login_required
def get_patient_history(request, patient_id):
    try:
        hospital_user = HospitalUser.objects.get(user=request.user)
        patient = Patient.objects.get(id=patient_id, hospital=hospital_user.hospital)
        
        doctor_name = patient.assigned_doctor.user.get_full_name() if patient.assigned_doctor else 'Unassigned'
        ambulance_number = patient.ambulance.vehicle_number if patient.ambulance else 'None'

        return JsonResponse({
            'success': True,
            'patient': {
                'id': patient.id,
                'full_name': patient.full_name,
                'cin': patient.cin,
                'age': patient.age,
                'gender': patient.get_gender_display(),
                'phone': patient.phone,
                'address': patient.address,
                'condition': patient.condition,
                'status': patient.get_status_display(),
                'admitted_at': patient.admitted_at.strftime("%b %d, %Y %I:%M %p"),
                'assigned_doctor': doctor_name,
                'ambulance': ambulance_number
            }
        })
    except Patient.DoesNotExist:
        return JsonResponse({'error': 'Patient not found or access denied'}, status=404)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)

# ==================== AMBULANCE API ====================

@login_required
def get_ambulances_api(request):
    try:
        hospital_user = HospitalUser.objects.get(user=request.user)
        hospital = hospital_user.hospital
        
        ambulances = Ambulance.objects.filter(
            destination_hospital=hospital
        ).exclude(is_online=False).values(
            'id', 'vehicle_number', 'first_name', 'last_name', 'driver_phone',
            'current_latitude', 'current_longitude',
            'patient_condition', 'eta_minutes', 'patient_name'
        )
        
        return JsonResponse({
            'success': True,
            'ambulances': list(ambulances),
            'hospital_location': {
                'lat': float(hospital.latitude) if hospital.latitude else 31.7917,
                'lng': float(hospital.longitude) if hospital.longitude else -7.0926
            }
        })
        
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)

@login_required
@require_http_methods(["POST"])
def update_ambulance_status(request, ambulance_id):
    try:
        data = json.loads(request.body)
        hospital_user = HospitalUser.objects.get(user=request.user)
        
        ambulance = Ambulance.objects.get(
            id=ambulance_id,
            destination_hospital=hospital_user.hospital
        )
        
        # ambulance.status is now a property based on is_online
        new_status = data.get('status')
        if new_status == 'arrived':
            ambulance.eta_minutes = 0
            # If arrived and trip complete, we might set is_online or just update last_updated
            ambulance.save()
        
        return JsonResponse({
            'success': True,
            'ambulance': {
                'id': ambulance.id,
                'vehicle_number': ambulance.vehicle_number,
                'status': ambulance.status
            }
        })
        
    except Ambulance.DoesNotExist:
        return JsonResponse({'error': 'Ambulance not found'}, status=404)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)

# ==================== STAFF API ====================

@login_required
def get_staff_api(request):
    try:
        hospital_user = HospitalUser.objects.get(user=request.user)
        hospital = hospital_user.hospital
        
        staff = HospitalUser.objects.filter(
            hospital=hospital
        ).select_related('user').values(
            'id', 'user__first_name', 'user__last_name',
            'role', 'department', 'is_available', 'phone'
        )
        
        return JsonResponse({
            'success': True,
            'staff': list(staff)
        })
        
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)

@login_required
@require_http_methods(["POST"])
def toggle_staff_availability(request, staff_id):
    try:
        hospital_user = HospitalUser.objects.get(user=request.user)
        
        if hospital_user.role != 'admin':
            return JsonResponse({'error': 'Permission denied'}, status=403)
        
        staff = HospitalUser.objects.get(id=staff_id, hospital=hospital_user.hospital)
        staff.is_available = not staff.is_available
        staff.save()
        
        return JsonResponse({
            'success': True,
            'staff': {
                'id': staff.id,
                'name': staff.user.get_full_name(),
                'is_available': staff.is_available
            }
        })
        
    except HospitalUser.DoesNotExist:
        return JsonResponse({'error': 'Staff not found'}, status=404)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)

@login_required
@require_http_methods(["POST"])
def add_staff(request):
    try:
        data = json.loads(request.body)
        hospital_user = HospitalUser.objects.get(user=request.user)
        
        if hospital_user.role != 'admin':
            return JsonResponse({'error': 'Permission denied. Admins only.'}, status=403)
            
        username = data.get('username')
        email = data.get('email', '')
        password = data.get('password')
        
        if User.objects.filter(username=username).exists():
            return JsonResponse({'error': 'Username already exists'}, status=400)
            
        with transaction.atomic():
            user = User.objects.create_user(
                username=username,
                email=email,
                password=password,
                first_name=data.get('first_name', ''),
                last_name=data.get('last_name', '')
            )
            
            new_staff = HospitalUser.objects.create(
                user=user,
                hospital=hospital_user.hospital,
                role=data.get('role', 'staff'),
                phone=data.get('phone', ''),
                department=data.get('department', ''),
                is_available=True
            )
            
        return JsonResponse({
            'success': True,
            'message': f'Staff member {user.username} created successfully.'
        })
        
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)

# ==================== CONDITIONS API ====================

@login_required
@require_http_methods(["POST"])
def add_condition(request):
    try:
        data = json.loads(request.body)
        hospital_user = HospitalUser.objects.get(user=request.user)
        
        condition = MedicalCondition.objects.create(
            hospital=hospital_user.hospital,
            name=data.get('name'),
            description=data.get('description', ''),
            severity=data.get('severity', 'medium'),
            common_symptoms=data.get('symptoms', ''),
            treatment_protocol=data.get('protocol', '')
        )
        
        return JsonResponse({
            'success': True,
            'condition': {
                'id': condition.id,
                'name': condition.name,
                'severity': condition.severity
            }
        })
        
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)

@login_required
@require_http_methods(["POST"])
def delete_condition(request, condition_id):
    try:
        hospital_user = HospitalUser.objects.get(user=request.user)
        
        if hospital_user.role != 'admin':
            return JsonResponse({'error': 'Permission denied'}, status=403)
        
        condition = MedicalCondition.objects.get(
            id=condition_id,
            hospital=hospital_user.hospital
        )
        condition.is_active = False
        condition.save()
        
        return JsonResponse({'success': True})
        
    except MedicalCondition.DoesNotExist:
        return JsonResponse({'error': 'Condition not found'}, status=404)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)

def logout_view(request):
    logout(request)
    return redirect('login')