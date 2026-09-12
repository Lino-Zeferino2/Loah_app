   importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
   importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

   firebase.initializeApp({
     apiKey: 'AIzaSyDuK1TdrHJhGxLhXa7gQPrn7DXG7CRhgko',
     authDomain: 'loahapp.firebaseapp.com',
     projectId: "loahapp",
     storageBucket: 'loahapp.firebasestorage.app',
     messagingSenderId: '475079305382',
     appId: '1:475079305382:web:6c87c6864789aedec22c67',
   });

   const messaging = firebase.messaging();

