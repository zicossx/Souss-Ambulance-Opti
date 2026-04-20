import json
import os
import django
import sys
import re
from django.utils.text import slugify

# Setup Django environment
sys.path.append('/home/wanaim/Documents/hospital_dashboard')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'hospital_dashboard.settings')
django.setup()

from django.contrib.auth.models import User
from dashboard.models import Hospital, HospitalUser

def generate_hospital_data(geojson_path):
    with open(geojson_path, 'r') as f:
        data = json.load(f)
    
    hospitals_to_create = []
    
    # Keywords for public hospitals
    keywords = ['hopital', 'hospital', 'chu', 'provincial', 'regional', 'centre hospitalier', 'maternite']
    
    for feature in data['features']:
        props = feature['properties']
        geom = feature['geometry']
        
        if props.get('amenity') != 'hospital':
            continue
            
        name = props.get('name') or props.get('name:en') or props.get('name:ar')
        if not name or len(name) < 3:
            continue
            
        # Basic filtering for public/major hospitals
        name_lower = name.lower()
        if not any(kw in name_lower for kw in keywords):
            continue
            
        coords = geom['coordinates'] # [lon, lat]
        
        hospital_data = {
            'name': name,
            'address': props.get('addr:full') or f"Quartier {props.get('addr:city', 'Maroc')}",
            'city': props.get('addr:city') or 'Inconnu',
            'region': props.get('region') or 'Maroc',
            'phone': props.get('phone') or '+212 500-000000',
            'email': f"contact@{slugify(name).replace('-', '_')}@sante.gov.ma",
            'latitude': coords[1],
            'longitude': coords[0],
            'license_number': f"MAR-{props.get('osm_id')}"
        }
        hospitals_to_create.append(hospital_data)
        
    return hospitals_to_create

def run_import(dry_run=True):
    geojson_path = '/home/wanaim/Documents/ambulance_app/assets/data/morocco_hospitals.geojson'
    hospitals = generate_hospital_data(geojson_path)
    
    print(f"{'[DRY RUN]' if dry_run else '[LIVE]'} Found {len(hospitals)} public hospitals to process.")
    
    for h_data in hospitals:
        username = f"hosp_{slugify(h_data['name']).replace('-', '_')}"[:150]
        
        if dry_run:
            print(f"Would create: {h_data['name']} (User: {username})")
            continue
            
        # LIVE EXECUTION
        try:
            # 1. Create Hospital
            hospital, created = Hospital.objects.get_or_create(
                license_number=h_data['license_number'],
                defaults={
                    'name': h_data['name'],
                    'address': h_data['address'],
                    'city': h_data['city'],
                    'phone': h_data['phone'],
                    'email': h_data['email'],
                    'latitude': h_data['latitude'],
                    'longitude': h_data['longitude'],
                    'emergency_capacity': 50,
                    'is_active': True
                }
            )
            
            if created:
                # 2. Create User
                if not User.objects.filter(username=username).exists():
                    user = User.objects.create_user(
                        username=username,
                        password='Maroc@2026',
                        email=h_data['email']
                    )
                    # 3. Create HospitalUser link
                    HospitalUser.objects.create(
                        user=user,
                        hospital=hospital,
                        role='admin',
                        phone=h_data['phone']
                    )
                    print(f"Created: {h_data['name']} (User: {username})")
                else:
                    print(f"Hospital created, but user {username} already exists. Skipping user creation.")
            else:
                print(f"Skipped (exists): {h_data['name']}")
                
        except Exception as e:
            print(f"Error creating {h_data['name']}: {e}")

if __name__ == '__main__':
    # Default to dry run unless --live flag is passed
    is_live = '--live' in sys.argv
    run_import(dry_run=not is_live)
