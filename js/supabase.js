// =============================================
// SC-ELROM - Supabase Client Configuration
// =============================================

const SUPABASE_URL = 'https://uvdmxnklmefvsxfbyomc.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV2ZG14bmtsbWVmdnN4ZmJ5b21jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIwNTUzNzIsImV4cCI6MjA5NzYzMTM3Mn0.23SaO2wQOT85-LqdEmIbvlB0YuJkayj1IWsTijt60Aw';

let supabaseClient;
try {
    if (typeof window.supabase !== 'undefined') {
        supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
    } else {
        console.error("Supabase CDN failed to load.");
    }
} catch (e) {
    console.error("Supabase client init failed: ", e);
}

// Auth Helpers exposed globally IMMEDIATELY
window.getCurrentUser = async () => {
    if (!supabaseClient) return null;
    const { data: { user } } = await supabaseClient.auth.getUser();
    return user;
};

window.isAdmin = async () => {
    if (!supabaseClient) return false;
    const user = await window.getCurrentUser();
    if (!user) return false;
    const { data, error } = await supabaseClient.from('admin_users').select('id').eq('user_id', user.id).single();
    return !!data && !error;
};

window.loginUser = async (email, password) => {
    if (!supabaseClient) return { error: { message: "Supabase not connected" } };
    return await supabaseClient.auth.signInWithPassword({ email, password });
};

window.registerUser = async (email, password) => {
    if (!supabaseClient) return { error: { message: "Supabase not connected" } };
    return await supabaseClient.auth.signUp({ email, password });
};

window.logoutUser = async () => {
    if (!supabaseClient) return { error: null };
    return await supabaseClient.auth.signOut();
};

window.handleLogout = async () => {
    const { error } = await window.logoutUser();
    if (error) {
        if(typeof showToast === 'function') showToast('Eroare la deconectare: ' + error.message, 'error');
    } else {
        if(typeof showToast === 'function') showToast('Te-ai deconectat cu succes!', 'success');
        setTimeout(() => { window.location.href = 'index.html'; }, 1000);
    }
};

window.updateNavbarAuth = async () => {
    if (!supabaseClient) return;
    const user = await window.getCurrentUser();
    const navbarNav = document.querySelector('.navbar-nav');
    if (!navbarNav) return;
    
    const existingAuthItems = navbarNav.querySelectorAll('.nav-item-auth');
    existingAuthItems.forEach(item => item.remove());
    
    if (user) {
        const admin = await window.isAdmin();
        if (admin) {
            const adminItem = document.createElement('li');
            adminItem.className = 'nav-item nav-item-auth';
            adminItem.innerHTML = '<a href="admin.html" class="nav-link nav-link-admin">⚙ Admin</a>';
            navbarNav.appendChild(adminItem);
        }
        const userItem = document.createElement('li');
        userItem.className = 'nav-item nav-item-auth';
        userItem.innerHTML = `<span class="nav-user-email">${user.email}</span><button class="btn-logout" onclick="window.handleLogout()">Deconectare</button>`;
        navbarNav.appendChild(userItem);
    }
};

if (supabaseClient && supabaseClient.auth) {
    supabaseClient.auth.onAuthStateChange((event, session) => {
        window.updateNavbarAuth();
    });
}

document.addEventListener('DOMContentLoaded', () => {
    if (window.updateNavbarAuth) window.updateNavbarAuth();
});
