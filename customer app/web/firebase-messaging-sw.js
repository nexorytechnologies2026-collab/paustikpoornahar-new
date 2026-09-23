importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyCwExuTburoBNnB1a3W-3y_kLoGWLDEUB4",
  authDomain: "paushtikpoornaahar-576be.firebaseapp.com",
  projectId: "paushtikpoornaahar-576be",
  storageBucket: "paushtikpoornaahar-576be.firebasestorage.app",
  messagingSenderId: "859076248736",
  appId: "1:859076248736:web:7a3a972180d0e636a3f5c5",
  measurementId: "G-71TBYZYXHZ"
});

const messaging = firebase.messaging();

messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            const title = payload.notification.title;
            const options = {
                body: payload.notification.score
              };
            return registration.showNotification(title, options);
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});