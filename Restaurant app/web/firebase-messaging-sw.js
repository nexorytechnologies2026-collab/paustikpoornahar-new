importScripts("https://www.gstatic.com/firebasejs/7.20.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/7.20.0/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyCwExuTburoBNnB1a3W-3y_kLoGWLDEUB4",
  authDomain: "paushtikpoornaahar-576be.firebaseapp.com",
  projectId: "paushtikpoornaahar-576be",
  storageBucket: "paushtikpoornaahar-576be.firebasestorage.app",
  messagingSenderId: "859076248736",
  appId: "1:859076248736:web:7a3a972180d0e636a3f5c5",
  measurementId: "G-71TBYZYXHZ",
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});