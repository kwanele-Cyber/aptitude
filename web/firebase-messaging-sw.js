importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyB-B5Gr3oNiTdM7Ir8M8iV8EPbHcLpvCpQ',
  appId: '1:889008953890:web:48e2d64c5b48fde69a487b',
  messagingSenderId: '889008953890',
  projectId: 'aptitude-5c28c',
});

const messaging = firebase.messaging();
