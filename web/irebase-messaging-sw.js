importScripts("https://www.gstatic.com/firebasejs/9.6.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/9.6.0/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyABCdefGHIjklMNOPqrstUVWxyz123456",
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456789012",
  appId: "1:123456789012:web:abc123def456ghi789"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
});