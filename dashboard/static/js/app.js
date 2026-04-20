// ====================
// ATLAS Hospital Dashboard - Clean JavaScript
// ====================

document.addEventListener('DOMContentLoaded', function() {
    // Load Django data from data attributes
    const djangoData = document.getElementById('django-data');
    window.HOSPITAL_LAT = parseFloat(djangoData.dataset.hospitalLat) || 31.7917;
    window.HOSPITAL_LNG = parseFloat(djangoData.dataset.hospitalLng) || -7.0926;
    window.HOSPITAL_NAME = djangoData.dataset.hospitalName || 'Hospital';
    window.IS_ADMIN = djangoData.dataset.isAdmin === 'true';
    
    initClock();
    initMap();
    initBedProgressBars();
    initEventListeners();
    startAutoRefresh();
    initMobileToggle();
});

// ==================== CLOCK ====================

function initClock() {
    function updateTime() {
        const now = new Date();
        const timeString = now.toLocaleTimeString('en-US', { 
            hour: '2-digit', 
            minute: '2-digit',
            hour12: false 
        });
        const dateString = now.toLocaleDateString('en-US', { 
            day: '2-digit',
            month: '2-digit',
            year: 'numeric'
        });
        
        const timeEl = document.querySelector('.datetime .time');
        const dateEl = document.querySelector('.datetime .date');
        
        if (timeEl) timeEl.textContent = timeString;
        if (dateEl) dateEl.textContent = dateString;
    }
    
    updateTime();
    setInterval(updateTime, 1000);
}

// ==================== BED PROGRESS BARS ====================

function initBedProgressBars() {
    document.querySelectorAll('.bed-progress').forEach(el => {
        const available = parseInt(el.dataset.percentage) || 0;
        const total = parseInt(el.dataset.total) || 1;
        const pct = total > 0 ? Math.round((available / total) * 100) : 0;
        el.style.width = pct + '%';
    });
}

// ==================== MAP ====================

let map;
let ambulanceMarkers = {};
let hospitalMarker;

function initMap() {
    map = L.map('ambulance-map').setView([window.HOSPITAL_LAT, window.HOSPITAL_LNG], 13);
    
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors',
        maxZoom: 19
    }).addTo(map);
    
    const hospitalIcon = L.divIcon({
        className: 'custom-marker',
        html: `<div style="
            width: 40px; height: 40px; background: #1a472a;
            border: 3px solid #4ade80; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            box-shadow: 0 4px 6px rgba(0,0,0,0.3);
        "><i class="fas fa-hospital" style="color: white; font-size: 18px;"></i></div>`,
        iconSize: [40, 40],
        iconAnchor: [20, 20]
    });
    
    hospitalMarker = L.marker([window.HOSPITAL_LAT, window.HOSPITAL_LNG], { icon: hospitalIcon })
        .addTo(map)
        .bindPopup(`<b>${window.HOSPITAL_NAME}</b><br>Main Hospital`);
    
    loadAmbulances();
}

function loadAmbulances() {
    fetch('/api/ambulances/')
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                updateAmbulanceMarkers(data.ambulances);
                updateAmbulanceList(data.ambulances);
            }
        })
        .catch(e => console.error('Error loading ambulances:', e));
}

function updateAmbulanceMarkers(ambulances) {
    Object.values(ambulanceMarkers).forEach(m => map.removeLayer(m));
    ambulanceMarkers = {};
    
    ambulances.forEach(amb => {
        if (!amb.current_latitude || !amb.current_longitude) return;
        
        const icon = L.divIcon({
            className: 'custom-marker',
            html: `<div style="
                width: 36px; height: 36px; background: #3b82f6;
                border: 3px solid #60a5fa; border-radius: 50%;
                display: flex; align-items: center; justify-content: center;
                box-shadow: 0 4px 6px rgba(0,0,0,0.3);
                animation: pulse 2s infinite;
            "><i class="fas fa-ambulance" style="color: white; font-size: 14px;"></i></div>`,
            iconSize: [36, 36],
            iconAnchor: [18, 18]
        });
        
        const driverName = `${amb.first_name || ''} ${amb.last_name || ''}`.trim() || 'N/A';
        const marker = L.marker([amb.current_latitude, amb.current_longitude], { icon })
            .addTo(map)
            .bindPopup(`
                <b>Ambulance ${amb.vehicle_number}</b><br>
                Driver: ${driverName}<br>
                Patient: ${amb.patient_name || 'N/A'}<br>
                ETA: ${amb.eta_minutes} min
            `);
        
        ambulanceMarkers[amb.id] = marker;
    });
}

function updateAmbulanceList(ambulances) {
    const container = document.getElementById('ambulance-list');
    const count = document.getElementById('incoming-count');
    
    if (count) count.textContent = `${ambulances.length} Active`;
    
    if (!container) return;
    
    if (ambulances.length === 0) {
        container.innerHTML = `
            <div class="empty-state">
                <i class="fas fa-check-circle"></i>
                <p>No incoming ambulances</p>
            </div>`;
        return;
    }
    
    container.innerHTML = ambulances.map(amb => {
        const driverName = `${amb.first_name || ''} ${amb.last_name || ''}`.trim() || 'N/A';
        return `
        <div class="ambulance-item" data-id="${amb.id}">
            <div class="ambulance-icon">
                <i class="fas fa-ambulance"></i>
            </div>
            <div class="ambulance-info">
                <h4>${amb.vehicle_number}</h4>
                <p>${driverName}</p>
                <span class="condition-tag">${amb.patient_condition || 'No condition specified'}</span>
            </div>
            <div class="ambulance-meta">
                <span class="eta">
                    <i class="fas fa-clock"></i> <span class="eta-time">${amb.eta_minutes}</span> min
                </span>
                <button class="btn-sm btn-arrived" data-ambulance-id="${amb.id}">
                    Arrived
                </button>
            </div>
        </div>
    `}).join('');
}

function centerMap() {
    if (hospitalMarker && map) {
        map.setView(hospitalMarker.getLatLng(), 13);
    }
}

function markAmbulanceArrived(id) {
    fetch(`/api/ambulances/${id}/status/`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRFToken': getCookie('csrftoken')
        },
        body: JSON.stringify({ status: 'arrived' })
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            showNotification('Ambulance marked as arrived', 'success');
            loadAmbulances();
        } else {
            showNotification(data.error || 'Failed to update', 'error');
        }
    })
    .catch(e => showNotification('Network error', 'error'));
}

// ==================== EVENT LISTENERS ====================

function initEventListeners() {
    // Map controls
    document.getElementById('btn-center-map')?.addEventListener('click', centerMap);
    document.getElementById('btn-refresh-ambulances')?.addEventListener('click', loadAmbulances);
    
    // Notifications & Settings
    document.getElementById('btn-notifications')?.addEventListener('click', () => {
        showNotification('No new notifications', 'info');
    });
    document.getElementById('btn-settings')?.addEventListener('click', () => {
        showNotification('Settings panel coming soon', 'info');
    });
    
    // Bed management
    document.getElementById('btn-edit-beds')?.addEventListener('click', openBedModal);
    document.getElementById('btn-add-beds-empty')?.addEventListener('click', openBedModal);
    document.getElementById('btn-close-bed-modal')?.addEventListener('click', closeBedModal);
    document.getElementById('btn-cancel-bed')?.addEventListener('click', closeBedModal);
    document.getElementById('bedForm')?.addEventListener('submit', saveBed);
    
    // Bed adjustment buttons (event delegation)
    document.getElementById('beds-container')?.addEventListener('click', function(e) {
        if (e.target.classList.contains('btn-bed-adjust')) {
            const bedType = e.target.dataset.bedType;
            const action = e.target.dataset.action;
            adjustBed(bedType, action, 'available');
        }
    });
    
    // Sidebar Navigation (Smooth Scroll)
    document.querySelectorAll('.sidebar-nav .nav-item[data-scroll-to]').forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            document.querySelectorAll('.sidebar-nav .nav-item').forEach(n => n.classList.remove('active'));
            this.classList.add('active');
            
            const targetId = this.getAttribute('data-scroll-to');
            const targetEl = document.getElementById(targetId);
            if (targetEl) {
                targetEl.scrollIntoView({ behavior: 'smooth', block: 'start' });
            }
        });
    });
    
    // Staff management
    document.getElementById('btn-refresh-staff')?.addEventListener('click', refreshStaff);
    document.getElementById('btn-add-staff')?.addEventListener('click', openStaffModal);
    document.getElementById('btn-close-staff-modal')?.addEventListener('click', closeStaffModal);
    document.getElementById('btn-cancel-staff')?.addEventListener('click', closeStaffModal);
    document.getElementById('staffForm')?.addEventListener('submit', saveStaff);
    
    document.getElementById('staff-list')?.addEventListener('click', function(e) {
        const btn = e.target.closest('.btn-toggle-staff');
        if (btn) {
            const staffId = btn.dataset.staffId;
            toggleStaff(staffId, btn);
        }
    });
    
    // Patient management
    document.getElementById('btn-add-patient')?.addEventListener('click', openPatientModal);
    document.getElementById('btn-close-patient-modal')?.addEventListener('click', closePatientModal);
    document.getElementById('btn-cancel-patient')?.addEventListener('click', closePatientModal);
    document.getElementById('patientForm')?.addEventListener('submit', savePatient);
    
    // Patient status changes (event delegation)
    document.getElementById('patients-tbody')?.addEventListener('change', function(e) {
        if (e.target.classList.contains('status-select')) {
            const patientId = e.target.dataset.patientId;
            updatePatientStatus(patientId, e.target.value);
        }
    });
    
    // Patient filters
    document.querySelector('.header-filters')?.addEventListener('click', function(e) {
        if (e.target.classList.contains('filter-btn')) {
            const filter = e.target.dataset.filter;
            filterPatients(filter, e.target);
        }
    });
    
    // View patient buttons
    document.getElementById('patients-tbody')?.addEventListener('click', function(e) {
        const btn = e.target.closest('.btn-view-patient');
        if (btn) {
            const patientId = btn.dataset.patientId;
            viewPatient(patientId);
        }
    });
    document.getElementById('btn-close-patient-view-modal')?.addEventListener('click', closePatientViewModal);
    document.getElementById('btn-close-patient-view')?.addEventListener('click', closePatientViewModal);
    
    // Condition management
    document.getElementById('btn-add-condition')?.addEventListener('click', openConditionModal);
    document.getElementById('btn-close-condition-modal')?.addEventListener('click', closeConditionModal);
    document.getElementById('btn-cancel-condition')?.addEventListener('click', closeConditionModal);
    document.getElementById('conditionForm')?.addEventListener('submit', saveCondition);
    
    // Delete condition buttons (event delegation)
    document.getElementById('conditions-list')?.addEventListener('click', function(e) {
        const btn = e.target.closest('.btn-delete-condition');
        if (btn) {
            const conditionId = btn.dataset.conditionId;
            deleteCondition(conditionId);
        }
    });
    
    // Ambulance arrived buttons (event delegation)
    document.getElementById('ambulance-list')?.addEventListener('click', function(e) {
        const btn = e.target.closest('.btn-arrived');
        if (btn) {
            const ambulanceId = btn.dataset.ambulanceId;
            markAmbulanceArrived(ambulanceId);
        }
    });
}

// ==================== BED MANAGEMENT ====================

function openBedModal() {
    document.getElementById('bedModal')?.classList.add('active');
}

function closeBedModal() {
    document.getElementById('bedModal')?.classList.remove('active');
}

function saveBed(e) {
    e.preventDefault();
    const form = e.target;
    const data = {
        bed_type: form.bed_type.value,
        total_beds: parseInt(form.total_beds.value),
        available_beds: parseInt(form.available_beds.value)
    };
    
    fetch('/api/update-beds/', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRFToken': getCookie('csrftoken')
        },
        body: JSON.stringify(data)
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            showNotification('Bed availability updated', 'success');
            updateBedUI(data.bed);
            closeBedModal();
        } else {
            showNotification(data.error || 'Update failed', 'error');
        }
    })
    .catch(e => showNotification('Network error', 'error'));
}

function adjustBed(bedType, action, field) {
    fetch('/api/adjust-bed/', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRFToken': getCookie('csrftoken')
        },
        body: JSON.stringify({ bed_type: bedType, action: action, field: field })
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            updateBedUI(data.bed);
        } else {
            showNotification(data.error || 'Failed to adjust', 'error');
        }
    })
    .catch(e => showNotification('Network error', 'error'));
}

function updateBedUI(bed) {
    const availEl = document.querySelector(`[data-bed-avail="${bed.type}"]`);
    const totalEl = document.querySelector(`[data-bed-total="${bed.type}"]`);
    const progressEl = document.querySelector(`[data-bed-progress="${bed.type}"]`);
    
    if (availEl) availEl.textContent = bed.available;
    if (totalEl) totalEl.textContent = bed.total;
    if (progressEl) {
        const total = bed.total || 1;
        const pct = Math.round((bed.available / total) * 100);
        progressEl.style.width = pct + '%';
        progressEl.dataset.percentage = bed.available;
        progressEl.dataset.total = bed.total;
    }
}

// ==================== PATIENT MANAGEMENT ====================

function openPatientModal() {
    document.getElementById('patientModal')?.classList.add('active');
}

function closePatientModal() {
    document.getElementById('patientModal')?.classList.remove('active');
    document.getElementById('patientForm')?.reset();
}

function savePatient(e) {
    e.preventDefault();
    const form = e.target;
    const data = {
        full_name: form.full_name.value,
        cin: form.cin.value,
        age: parseInt(form.age.value),
        gender: form.gender.value,
        phone: form.phone.value,
        status: form.status.value,
        condition: form.condition.value
    };
    
    fetch('/api/patients/add/', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRFToken': getCookie('csrftoken')
        },
        body: JSON.stringify(data)
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            showNotification('Patient added successfully', 'success');
            closePatientModal();
            location.reload();
        } else {
            showNotification(data.error || 'Failed to add patient', 'error');
        }
    })
    .catch(e => showNotification('Network error', 'error'));
}

function updatePatientStatus(id, status) {
    fetch(`/api/patients/${id}/status/`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRFToken': getCookie('csrftoken')
        },
        body: JSON.stringify({ status: status })
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            showNotification(`Status updated to ${data.patient.status_display}`, 'success');
            const row = document.querySelector(`tr[data-patient-id="${id}"]`);
            if (row) row.setAttribute('data-patient-status', status);
        } else {
            showNotification(data.error || 'Update failed', 'error');
        }
    })
    .catch(e => showNotification('Network error', 'error'));
}

function filterPatients(filter, btn) {
    document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    
    const rows = document.querySelectorAll('#patients-tbody tr');
    rows.forEach(row => {
        if (row.classList.contains('empty-row')) return;
        
        const status = row.getAttribute('data-patient-status');
        if (filter === 'all' || status === filter) {
            row.style.display = '';
        } else {
            row.style.display = 'none';
        }
    });
}

function closePatientViewModal() {
    document.getElementById('patientViewModal')?.classList.remove('active');
}

function viewPatient(id) {
    document.getElementById('patientViewContent').innerHTML = `
        <div class="text-center" style="padding: 2rem;">
            <i class="fas fa-spinner fa-spin fa-2x" style="color: var(--primary);"></i>
            <p style="margin-top: 1rem;">Loading details...</p>
        </div>
    `;
    document.getElementById('patientViewModal')?.classList.add('active');

    fetch(`/api/patients/${id}/history/`)
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                const p = data.patient;
                document.getElementById('patientViewContent').innerHTML = `
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
                        <div>
                            <p><strong>Name:</strong> ${p.full_name}</p>
                            <p><strong>CIN:</strong> ${p.cin}</p>
                            <p><strong>Age/Gender:</strong> ${p.age} / ${p.gender}</p>
                            <p><strong>Phone:</strong> ${p.phone || 'N/A'}</p>
                        </div>
                        <div>
                            <p><strong>Status:</strong> <span class="status-badge">${p.status}</span></p>
                            <p><strong>Admitted:</strong> ${p.admitted_at}</p>
                            <p><strong>Doctor:</strong> ${p.assigned_doctor}</p>
                            <p><strong>Ambulance:</strong> ${p.ambulance}</p>
                        </div>
                    </div>
                    <div style="margin-top: 1rem; padding: 1rem; background: var(--gray-50); border-radius: 0.5rem;">
                        <p><strong>Condition/Symptoms:</strong></p>
                        <p style="margin-top: 0.5rem; color: var(--gray-700);">${p.condition || 'No condition details provided.'}</p>
                    </div>
                `;
            } else {
                document.getElementById('patientViewContent').innerHTML = `
                    <div class="text-center" style="padding: 2rem; color: var(--danger);">
                        <i class="fas fa-exclamation-circle fa-2x"></i>
                        <p style="margin-top: 1rem;">${data.error || 'Failed to load details'}</p>
                    </div>
                `;
            }
        })
        .catch(e => {
            document.getElementById('patientViewContent').innerHTML = `
                <div class="text-center" style="padding: 2rem; color: var(--danger);">
                    <i class="fas fa-wifi fa-2x"></i>
                    <p style="margin-top: 1rem;">Network error. Please try again.</p>
                </div>
            `;
        });
}

// ==================== STAFF MANAGEMENT ====================

function refreshStaff() {
    fetch('/api/staff/')
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                location.reload();
            }
        })
        .catch(e => console.error('Error loading staff:', e));
}

function openStaffModal() {
    document.getElementById('staffModal')?.classList.add('active');
}

function closeStaffModal() {
    document.getElementById('staffModal')?.classList.remove('active');
    document.getElementById('staffForm')?.reset();
}

function saveStaff(e) {
    e.preventDefault();
    const form = e.target;
    const data = {
        first_name: form.first_name.value,
        last_name: form.last_name.value,
        username: form.username.value,
        password: form.password.value,
        email: form.email.value,
        phone: form.phone.value,
        role: form.role.value,
        department: form.department.value
    };
    
    fetch('/api/staff/add/', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRFToken': getCookie('csrftoken')
        },
        body: JSON.stringify(data)
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            showNotification(data.message || 'Staff added successfully', 'success');
            closeStaffModal();
            setTimeout(() => location.reload(), 1000);
        } else {
            showNotification(data.error || 'Failed to add staff', 'error');
        }
    })
    .catch(e => showNotification('Network error', 'error'));
}

function toggleStaff(id, btn) {
    fetch(`/api/staff/${id}/toggle/`, {
        method: 'POST',
        headers: {
            'X-CSRFToken': getCookie('csrftoken')
        }
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            const icon = btn.querySelector('i');
            if (data.staff.is_available) {
                icon.className = 'fas fa-toggle-on';
                btn.classList.add('active');
            } else {
                icon.className = 'fas fa-toggle-off';
                btn.classList.remove('active');
            }
            showNotification('Staff availability updated', 'success');
        }
    })
    .catch(e => showNotification('Network error', 'error'));
}

// ==================== CONDITIONS MANAGEMENT ====================

function openConditionModal() {
    document.getElementById('conditionModal')?.classList.add('active');
}

function closeConditionModal() {
    document.getElementById('conditionModal')?.classList.remove('active');
    document.getElementById('conditionForm')?.reset();
}

function saveCondition(e) {
    e.preventDefault();
    const form = e.target;
    const data = {
        name: form.name.value,
        severity: form.severity.value,
        description: form.description.value
    };
    
    fetch('/api/conditions/add/', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRFToken': getCookie('csrftoken')
        },
        body: JSON.stringify(data)
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            showNotification('Condition added successfully', 'success');
            closeConditionModal();
            location.reload();
        } else {
            showNotification(data.error || 'Failed to add', 'error');
        }
    })
    .catch(e => showNotification('Network error', 'error'));
}

function deleteCondition(id) {
    if (!confirm('Are you sure you want to delete this condition?')) return;
    
    fetch(`/api/conditions/${id}/delete/`, {
        method: 'POST',
        headers: {
            'X-CSRFToken': getCookie('csrftoken')
        }
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            showNotification('Condition deleted', 'success');
            const el = document.querySelector(`[data-condition-id="${id}"]`);
            if (el) el.remove();
        } else {
            showNotification(data.error || 'Delete failed', 'error');
        }
    })
    .catch(e => showNotification('Network error', 'error'));
}

// ==================== UTILITIES ====================

function getCookie(name) {
    let cookieValue = null;
    if (document.cookie && document.cookie !== '') {
        const cookies = document.cookie.split(';');
        for (let i = 0; i < cookies.length; i++) {
            const cookie = cookies[i].trim();
            if (cookie.substring(0, name.length + 1) === (name + '=')) {
                cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                break;
            }
        }
    }
    return cookieValue;
}

function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.innerHTML = `
        <i class="fas fa-${type === 'success' ? 'check-circle' : type === 'error' ? 'exclamation-circle' : 'info-circle'}"></i>
        <span>${message}</span>
    `;
    
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${type === 'success' ? '#dcfce7' : type === 'error' ? '#fecaca' : '#dbeafe'};
        color: ${type === 'success' ? '#166534' : type === 'error' ? '#991b1b' : '#1e40af'};
        padding: 1rem 1.5rem;
        border-radius: 8px;
        box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1);
        display: flex;
        align-items: center;
        gap: 0.75rem;
        z-index: 9999;
        animation: slideIn 0.3s ease;
        max-width: 400px;
        word-wrap: break-word;
    `;
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => notification.remove(), 300);
    }, 3000);
}

function startAutoRefresh() {
    setInterval(loadAmbulances, 30000);
    setInterval(refreshStaff, 60000);
}

function initMobileToggle() {
    if (!document.querySelector('.mobile-toggle')) {
        const toggle = document.createElement('button');
        toggle.className = 'mobile-toggle';
        toggle.innerHTML = '<i class="fas fa-bars"></i>';
        toggle.onclick = () => {
            document.getElementById('sidebar').classList.toggle('active');
        };
        document.body.appendChild(toggle);
    }
}

// Add CSS animations
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
    @keyframes slideOut {
        from { transform: translateX(0); opacity: 1; }
        to { transform: translateX(100%); opacity: 0; }
    }
    @keyframes pulse {
        0%, 100% { transform: scale(1); }
        50% { transform: scale(1.1); }
    }
    .btn-tiny {
        padding: 0.25rem 0.5rem;
        border: 1px solid var(--gray-200);
        background: var(--white);
        border-radius: 0.25rem;
        cursor: pointer;
        font-size: 0.75rem;
    }
    .btn-tiny:hover {
        background: var(--gray-100);
    }
    .btn-tiny.btn-danger {
        background: var(--danger);
        color: white;
        border-color: var(--danger);
    }
    .bed-controls {
        display: flex;
        gap: 0.25rem;
        margin-left: auto;
    }
    .status-select {
        padding: 0.25rem 0.5rem;
        border-radius: 0.25rem;
        border: 1px solid var(--gray-200);
        font-size: 0.875rem;
    }
`;
document.head.appendChild(style);