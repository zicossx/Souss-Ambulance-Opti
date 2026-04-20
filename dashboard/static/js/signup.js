// Signup Page Map Handler
document.addEventListener('DOMContentLoaded', function() {
    initSignupMap();
    initFormValidation();
});

let signupMap;
let selectedMarker = null;
let defaultLocation = [31.7917, -7.0926]; // Center of Morocco

function initSignupMap() {
    // Initialize map
    signupMap = L.map('signup-map').setView(defaultLocation, 6);
    
    // Add OpenStreetMap tiles
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors',
        maxZoom: 19
    }).addTo(signupMap);
    
    // Try to get user's location
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
            (position) => {
                const userLoc = [position.coords.latitude, position.coords.longitude];
                signupMap.setView(userLoc, 13);
            },
            () => {
                console.log('Geolocation denied or unavailable');
            }
        );
    }
    
    // Handle map clicks
    signupMap.on('click', function(e) {
        placeMarker(e.latlng);
    });
}

function placeMarker(latlng) {
    // Remove existing marker
    if (selectedMarker) {
        signupMap.removeLayer(selectedMarker);
    }
    
    // Create custom hospital marker
    const hospitalIcon = L.divIcon({
        className: 'custom-marker',
        html: `<div style="
            width: 40px; height: 40px; background: #1a472a;
            border: 3px solid #4ade80; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            box-shadow: 0 4px 6px rgba(0,0,0,0.3);
            animation: dropIn 0.3s ease;
        "><i class="fas fa-hospital" style="color: white; font-size: 18px;"></i></div>`,
        iconSize: [40, 40],
        iconAnchor: [20, 20]
    });
    
    // Add new marker
    selectedMarker = L.marker(latlng, { icon: hospitalIcon })
        .addTo(signupMap)
        .bindPopup('<b>Hospital Location</b><br>Lat: ' + latlng.lat.toFixed(6) + '<br>Lng: ' + latlng.lng.toFixed(6))
        .openPopup();
    
    // Update form fields
    document.getElementById('latitude').value = latlng.lat.toFixed(6);
    document.getElementById('longitude').value = latlng.lng.toFixed(6);
    
    // Update display
    document.getElementById('lat-display').textContent = latlng.lat.toFixed(6);
    document.getElementById('lng-display').textContent = latlng.lng.toFixed(6);
    
    // Visual feedback
    showNotification('Location selected!', 'success');
}

function initFormValidation() {
    const form = document.getElementById('signupForm');
    
    form.addEventListener('submit', function(e) {
        // Check if location is selected
        const lat = document.getElementById('latitude').value;
        const lng = document.getElementById('longitude').value;
        
        if (!lat || !lng) {
            e.preventDefault();
            showNotification('Please select your hospital location on the map', 'error');
            document.getElementById('signup-map').scrollIntoView({ behavior: 'smooth', block: 'center' });
            document.getElementById('signup-map').style.border = '2px solid #ef4444';
            return;
        }
        
        // Check password match
        const password = document.getElementById('password').value;
        const confirmPassword = document.getElementById('confirm_password').value;
        
        if (password !== confirmPassword) {
            e.preventDefault();
            showNotification('Passwords do not match', 'error');
            document.getElementById('confirm_password').focus();
            return;
        }
        
        // Check password length
        if (password.length < 8) {
            e.preventDefault();
            showNotification('Password must be at least 8 characters', 'error');
            return;
        }
    });
    
    // Phone validation
    const phoneInput = document.getElementById('phone');
    phoneInput.addEventListener('blur', function() {
        const phone = this.value.trim();
        const phoneRegex = /^[+]?[(]?[0-9]{1,4}[)]?[-\s\.]?[0-9]{1,4}[-\s\.]?[0-9]{1,9}$/;
        
        if (phone && !phoneRegex.test(phone)) {
            showNotification('Please enter a valid phone number', 'warning');
        }
    });
}

function showNotification(message, type = 'info') {
    // Remove existing notifications
    const existing = document.querySelector('.signup-notification');
    if (existing) existing.remove();
    
    const notification = document.createElement('div');
    notification.className = `signup-notification notification-${type}`;
    notification.innerHTML = `
        <i class="fas fa-${type === 'success' ? 'check-circle' : type === 'error' ? 'exclamation-circle' : 'info-circle'}"></i>
        <span>${message}</span>
    `;
    
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${type === 'success' ? '#dcfce7' : type === 'error' ? '#fecaca' : type === 'warning' ? '#fef3c7' : '#dbeafe'};
        color: ${type === 'success' ? '#166534' : type === 'error' ? '#991b1b' : type === 'warning' ? '#92400e' : '#1e40af'};
        padding: 1rem 1.5rem;
        border-radius: 8px;
        box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1);
        display: flex;
        align-items: center;
        gap: 0.75rem;
        z-index: 9999;
        animation: slideIn 0.3s ease;
        max-width: 400px;
    `;
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => notification.remove(), 300);
    }, 4000);
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
    @keyframes dropIn {
        0% { transform: scale(0) translateY(-20px); opacity: 0; }
        100% { transform: scale(1) translateY(0); opacity: 1; }
    }
`;
document.head.appendChild(style);