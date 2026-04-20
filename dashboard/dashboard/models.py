from django.db import models
from django.contrib.auth.models import User
from django.core.validators import RegexValidator

class Hospital(models.Model):
    name = models.CharField(max_length=200)
    address = models.TextField()
    city = models.CharField(max_length=100)
    region = models.CharField(max_length=100)
    phone = models.CharField(
        max_length=20,
        validators=[RegexValidator(r'^\+?1?\d{9,15}$')]
    )
    email = models.EmailField()
    license_number = models.CharField(max_length=50, unique=True)
    emergency_capacity = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    is_active = models.BooleanField(default=True)
    password = models.CharField(max_length=255, null=True, blank=True)
    
    # GPS Coordinates for map center
    latitude = models.DecimalField(max_digits=10, decimal_places=8, null=True, blank=True)
    longitude = models.DecimalField(max_digits=11, decimal_places=8, null=True, blank=True)
    
    class Meta:
        db_table = 'hospitals'
        ordering = ['name']
    
    def __str__(self):
        return self.name

class HospitalUser(models.Model):
    ROLE_CHOICES = [
        ('admin', 'Responsable'),
        ('doctor', 'Doctor'),
        ('nurse', 'Nurse'),
        ('staff', 'Staff'),
    ]
    
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    hospital = models.ForeignKey(Hospital, on_delete=models.CASCADE, related_name='staff')
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='staff')
    phone = models.CharField(max_length=20)
    department = models.CharField(max_length=100, blank=True)
    is_available = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"{self.user.get_full_name()} - {self.hospital.name}"

class BedAvailability(models.Model):
    BED_TYPES = [
        ('emergency', 'Emergency'),
        ('icu', 'ICU'),
        ('general', 'General Ward'),
        ('pediatric', 'Pediatric'),
        ('maternity', 'Maternity'),
        ('covid', 'COVID-19 Isolation'),
    ]
    
    hospital = models.ForeignKey(Hospital, on_delete=models.CASCADE, related_name='beds')
    bed_type = models.CharField(max_length=20, choices=BED_TYPES)
    total_beds = models.IntegerField(default=0)
    available_beds = models.IntegerField(default=0)
    updated_at = models.DateTimeField(auto_now=True)
    updated_by = models.ForeignKey(HospitalUser, on_delete=models.SET_NULL, null=True)
    
    class Meta:
        db_table = 'bed_availability'
        unique_together = ['hospital', 'bed_type']
    
    @property
    def occupied_beds(self):
        return self.total_beds - self.available_beds
    
    def __str__(self):
        return f"{self.hospital.name} - {self.get_bed_type_display()}"

class Ambulance(models.Model):
    STATUS_CHOICES = [
        ('en_route', 'En Route'),
        ('arrived', 'Arrived'),
        ('available', 'Available'),
        ('maintenance', 'Maintenance'),
    ]
    
    vehicle_number = models.CharField(max_length=20, unique=True)
    first_name = models.CharField(max_length=100, db_column='first_name')
    last_name = models.CharField(max_length=100, db_column='last_name')
    driver_phone = models.CharField(max_length=20, db_column='phone', null=True, blank=True)
    is_online = models.BooleanField(default=False, db_column='is_online', null=True, blank=True)
    current_latitude = models.DecimalField(max_digits=10, decimal_places=8, null=True, blank=True, db_column='latitude')
    current_longitude = models.DecimalField(max_digits=11, decimal_places=8, null=True, blank=True, db_column='longitude')
    destination_hospital = models.ForeignKey(
        Hospital, 
        on_delete=models.SET_NULL, 
        null=True, 
        blank=True,
        related_name='incoming_ambulances'
    )
    patient_name = models.CharField(max_length=100, blank=True)
    patient_condition = models.TextField(blank=True)
    eta_minutes = models.IntegerField(null=True, blank=True)
    last_updated = models.DateTimeField(auto_now=True)
    
    @property
    def driver_name(self):
        return f"{self.first_name} {self.last_name}"

    @property
    def status(self):
        return 'available' if self.is_online else 'maintenance'

    class Meta:
        db_table = 'drivers'
        ordering = ['-last_updated']
    
    def __str__(self):
        return f"Ambulance {self.vehicle_number} ({self.driver_name})"

class Patient(models.Model):
    GENDER_CHOICES = [
        ('M', 'Male'),
        ('F', 'Female'),
    ]
    
    STATUS_CHOICES = [
        ('waiting', 'Waiting'),
        ('in_treatment', 'In Treatment'),
        ('stable', 'Stable'),
        ('critical', 'Critical'),
        ('discharged', 'Discharged'),
    ]
    
    hospital = models.ForeignKey(Hospital, on_delete=models.CASCADE, related_name='patients')
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)
    age = models.IntegerField()
    gender = models.CharField(max_length=1, choices=GENDER_CHOICES)
    cin = models.CharField(max_length=20, verbose_name="CIN")  # Moroccan ID
    phone = models.CharField(max_length=20)
    address = models.TextField()
    condition = models.TextField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='waiting')
    admitted_at = models.DateTimeField(auto_now_add=True, db_column='created_at')
    assigned_doctor = models.ForeignKey(
        HospitalUser, 
        on_delete=models.SET_NULL, 
        null=True, 
        blank=True,
        limit_choices_to={'role__in': ['doctor', 'admin']}
    )
    ambulance = models.ForeignKey(
        Ambulance, 
        on_delete=models.SET_NULL, 
        null=True, 
        blank=True,
        related_name='patients'
    )
    
    @property
    def full_name(self):
        return f"{self.first_name} {self.last_name}"

    class Meta:
        db_table = 'patients'
        ordering = ['-admitted_at']
    
    def __str__(self):
        return f"{self.full_name} ({self.cin})"

class MedicalCondition(models.Model):
    SEVERITY_CHOICES = [
        ('low', 'Low'),
        ('medium', 'Medium'),
        ('high', 'High'),
        ('critical', 'Critical'),
    ]
    
    hospital = models.ForeignKey(Hospital, on_delete=models.CASCADE, related_name='conditions')
    name = models.CharField(max_length=200)
    description = models.TextField()
    severity = models.CharField(max_length=20, choices=SEVERITY_CHOICES)
    common_symptoms = models.TextField()
    treatment_protocol = models.TextField()
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'medical_conditions'
        ordering = ['-severity', 'name']
    
    def __str__(self):
        return f"{self.name} - {self.hospital.name}"