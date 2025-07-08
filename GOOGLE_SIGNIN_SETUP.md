# Google Sign-In Setup Guide for Andar Bahar Flutter Web App

## 🚀 **Gmail Login Features Added**

Your Andar Bahar game now includes:

- ✅ **Gmail-only authentication** - Users can only login via Google
- ✅ **User profile display** - Shows Google profile picture, name, and email
- ✅ **Logout functionality** - Clean logout with confirmation dialog
- ✅ **Fixed MaterialLocalizations issue** - App no longer crashes on dialogs
- ✅ **Authentication state management** - Seamless login/logout experience

---

## 🔧 **Required Setup Steps**

### **Step 1: Create Google Cloud Project**

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click "Create Project" or select an existing project
3. Give your project a name (e.g., "Andar Bahar Game")
4. Note your project ID

### **Step 2: Enable Google Sign-In API**

1. In Google Cloud Console, go to "APIs & Services" > "Library"
2. Search for "Google+ API" or "Google Sign-In API"
3. Click "Enable"

### **Step 3: Create OAuth 2.0 Client ID**

1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "OAuth client ID"
3. Select "Web application"
4. Set up authorized domains:

   - **Name**: Andar Bahar Web App
   - **Authorized JavaScript origins**:
     - `http://localhost:3000` (for development)
     - `http://localhost:8080` (alternative port)
     - `https://yourdomain.com` (for production)
   - **Authorized redirect URIs**:
     - `http://localhost:3000` (for development)
     - `https://yourdomain.com` (for production)

5. Click "Create"
6. **IMPORTANT**: Copy the Client ID (looks like: `123456789-abcdefg.apps.googleusercontent.com`)

### **Step 4: Update Web Configuration**

1. Open `web/index.html`
2. Find this line:
   ```html
   <meta
     name="google-signin-client_id"
     content="YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com"
   />
   ```
3. Replace `YOUR_GOOGLE_CLIENT_ID` with your actual Client ID:
   ```html
   <meta
     name="google-signin-client_id"
     content="123456789-abcdefg.apps.googleusercontent.com"
   />
   ```

### **Step 5: Add Google Logo (Optional)**

1. Download the official Google logo from [Google Brand Guidelines](https://developers.google.com/identity/branding-guidelines)
2. Save as `assets/images/google_logo.png` (20x20 pixels recommended)
3. If you skip this step, the app will use a fallback icon

---

## 🎮 **How It Works**

### **User Experience Flow**

1. **App Launch**:

   - App checks if user is already signed in
   - Shows loading screen while checking authentication

2. **Login Required**:

   - If not signed in, shows beautiful login screen
   - User clicks "Sign in with Google" button
   - Google popup opens for authentication

3. **After Login**:

   - User is redirected to the main game screen
   - Profile section shows user's photo, name, and email
   - Logout button available in top-right corner

4. **Logout Process**:
   - User clicks logout button
   - Confirmation dialog appears
   - Upon confirmation, user is signed out and returned to login screen

### **User Profile Display**

The home screen now shows:

- **Profile Picture**: User's Google profile photo (with fallback icon)
- **Display Name**: User's full name from Google account
- **Email Address**: User's Gmail address
- **Logout Button**: Red button with hover animation

---

## 🔧 **Testing the Implementation**

### **Development Testing**

1. **Start the Flutter app**:

   ```bash
   flutter run -d chrome
   ```

2. **Test Login Flow**:

   - App should show login screen initially
   - Click "Sign in with Google"
   - Complete Google authentication in popup
   - Should redirect to home screen with profile visible

3. **Test Profile Display**:
   - Verify profile picture loads (or shows fallback icon)
   - Check that name and email are displayed correctly
   - Test logout button functionality

### **Expected Behavior**

- ✅ **Login Screen**: Beautiful, animated login interface
- ✅ **Profile Section**: User info displayed prominently on home screen
- ✅ **Logout Dialog**: Confirmation dialog before signing out
- ✅ **No Crashes**: MaterialLocalizations error is fixed
- ✅ **Seamless Navigation**: Smooth transitions between login/logout states

---

## 🚨 **Troubleshooting**

### **Common Issues & Solutions**

#### **Issue 1: "Google Sign-In not configured"**

**Solution**: Make sure you've updated the Client ID in `web/index.html`

#### **Issue 2: "Unauthorized domain"**

**Solution**: Add your domain to authorized origins in Google Cloud Console

#### **Issue 3: Profile picture not loading**

**Solution**: This is normal - Google photos require proper CORS. The fallback icon will show.

#### **Issue 4: App crashes on dialog**

**Solution**: This should be fixed with the new localization setup. If still occurring, restart the app.

### **Debug Information**

Check browser console for these messages:

```javascript
// Successful login
Auth Service initialized. Current user: [User Name]
User signed in: [User Name]

// Logout
User signed out
```

---

## 🔐 **Security Notes**

### **Important Security Considerations**

1. **Client ID**: The client ID in `web/index.html` is public and safe to expose
2. **No Client Secret**: Web applications don't use client secrets
3. **Domain Restrictions**: OAuth is restricted to authorized domains only
4. **User Data**: Only basic profile info (name, email, photo) is accessed
5. **Local Storage**: User data is stored locally using SharedPreferences

### **Permissions Requested**

The app requests these Google permissions:

- `email`: To get user's email address
- `profile`: To get user's name and profile picture

---

## 🚀 **Production Deployment**

### **Before Going Live**

1. **Update Authorized Domains**: Add your production domain to Google Cloud Console
2. **Test on Production Domain**: Verify login works on your live site
3. **Update URLs**: Remove localhost URLs from authorized origins for security
4. **Monitor Usage**: Check Google Cloud Console for API usage

### **Environment Configuration**

For different environments, you can use different OAuth clients:

- **Development**: `dev-client-id.apps.googleusercontent.com`
- **Staging**: `staging-client-id.apps.googleusercontent.com`
- **Production**: `prod-client-id.apps.googleusercontent.com`

---

## 📱 **Features Overview**

### **What's Now Available**

- ✅ **Secure Authentication**: Gmail-only login system
- ✅ **User Profile Integration**: Display Google profile information
- ✅ **Session Management**: Persistent login across browser sessions
- ✅ **Clean Logout**: Proper sign-out with confirmation
- ✅ **Fixed Crashes**: No more MaterialLocalizations errors
- ✅ **Beautiful UI**: Animated login screen and profile display
- ✅ **Responsive Design**: Works on all screen sizes
- ✅ **Error Handling**: Graceful handling of login failures

### **Ready for Use**

Your Andar Bahar game is now ready with Gmail authentication! Users will have a professional login experience and their profile information will be displayed beautifully on the main screen.

---

## 🆘 **Need Help?**

If you encounter any issues:

1. **Check Browser Console**: Look for error messages
2. **Verify Configuration**: Double-check Client ID and authorized domains
3. **Test Incognito**: Try logging in using incognito/private mode
4. **Clear Cache**: Clear browser cache and cookies if needed

The authentication system is now fully integrated and should work seamlessly with your existing game features!
