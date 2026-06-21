// =============================================
// SC-ELROM - Supabase Client Configuration
// =============================================

const SUPABASE_URL = 'https://uvdmxnklmefvsxfbyomc.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV2ZG14bmtsbWVmdnN4ZmJ5b21jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIwNTUzNzIsImV4cCI6MjA5NzYzMTM3Mn0.23SaO2wQOT85-LqdEmIbvlB0YuJkayj1IWsTijt60Aw';

// Initializam clientul Supabase
const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// =============================================
// Auth Helpers
// =============================================

/**
 * Returneaza userul curent autentificat sau null
 */
async function getCurrentUser() {
    const { data: { user } } = await supabase.auth.getUser();
    return user;
}

/**
 * Verifica daca userul curent este admin
 */
async function isAdmin() {
    const user = await getCurrentUser();
    if (!user) return false;
    
    const { data, error } = await supabase
        .from('admin_users')
        .select('id')
        .eq('user_id', user.id)
        .single();
    
    return !!data && !error;
}

/**
 * Autentificare cu email si parola
 */
async function loginUser(email, password) {
    const { data, error } = await supabase.auth.signInWithPassword({
        email: email,
        password: password
    });
    return { data, error };
}

/**
 * Inregistrare cont nou
 */
async function registerUser(email, password) {
    const { data, error } = await supabase.auth.signUp({
        email: email,
        password: password
    });
    return { data, error };
}

/**
 * Deconectare
 */
async function logoutUser() {
    const { error } = await supabase.auth.signOut();
    return { error };
}

// =============================================
// Navbar Auth UI - actualizare pe toate paginile
// =============================================

/**
 * Actualizeaza navbar-ul in functie de starea de autentificare
 */
async function updateNavbarAuth() {
    const user = await getCurrentUser();
    const navbarNav = document.querySelector('.navbar-nav');
    
    if (!navbarNav) return;
    
    // Sterge elementele de auth existente
    const existingAuthItems = navbarNav.querySelectorAll('.nav-item-auth');
    existingAuthItems.forEach(item => item.remove());
    
    if (user) {
        const admin = await isAdmin();
        
        // Adauga link Admin daca e admin
        if (admin) {
            const adminItem = document.createElement('li');
            adminItem.className = 'nav-item nav-item-auth';
            adminItem.innerHTML = '<a href="admin.html" class="nav-link nav-link-admin">⚙ Admin</a>';
            navbarNav.appendChild(adminItem);
        }
        
        // Adauga info user + buton logout
        const userItem = document.createElement('li');
        userItem.className = 'nav-item nav-item-auth';
        userItem.innerHTML = `
            <span class="nav-user-email">${user.email}</span>
            <button class="btn-logout" onclick="handleLogout()">Deconectare</button>
        `;
        navbarNav.appendChild(userItem);
    }
}

/**
 * Handler pentru butonul de logout
 */
async function handleLogout() {
    const { error } = await logoutUser();
    if (error) {
        showToast('Eroare la deconectare: ' + error.message, 'error');
    } else {
        showToast('Te-ai deconectat cu succes!', 'success');
        // Redirectare catre pagina principala dupa logout
        setTimeout(() => {
            window.location.href = 'index.html';
        }, 1000);
    }
}

// Ascultam schimbarile de autentificare
supabase.auth.onAuthStateChange((event, session) => {
    updateNavbarAuth();
});

// Actualizam navbar-ul la incarcarea paginii
document.addEventListener('DOMContentLoaded', () => {
    updateNavbarAuth();
});
