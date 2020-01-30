'use strict';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "/assets\AssetManifest.json": "7ccffe8be853f45edc32522c37fb4445",
"/assets\assets\avatar.jpg": "c1916ddb1a8e3f82054850e79c24ac84",
"/assets\assets\failed.jpg": "dfe8dd807e09431646087324a89e9002",
"/assets\assets\flutterCandies.png": "9068d4b084b58d44551290d9ce3bdaa9",
"/assets\assets\flutterCandies_grey.png": "5fac6a25f94b0f5e26acaa5bf75433b2",
"/assets\assets\loading.gif": "d411e3bde0fe7f5020ab54727b0ffd06",
"/assets\assets\loading1.gif": "271702698f39aa0e236f578fd02e0653",
"/assets\assets\love.png": "aab039e13f0874664fb2f2d4e4ee68e7",
"/assets\assets\sun_glasses.png": "d85a636c9c5b608637780f969c058a85",
"/assets\FontManifest.json": "f7161631e25fbd47f3180eae84053a51",
"/assets\fonts\MaterialIcons-Regular.ttf": "56d3ffdef7a25659eab6a68a3fbfaf16",
"/assets\LICENSE": "fbf86279f20786f93b509b8bd188972d",
"/assets\packages\cupertino_icons\assets\CupertinoIcons.ttf": "115e937bb829a890521f72d2e664b632",
"/assets\packages\loading_more_list\assets\empty.jpeg": "52a69bab9f87bcf0052d8e55ea314977",
"/favicon.png": "5dcef449791fa27946b3d35ad8803796",
"/icons\Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"/icons\Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"/index.html": "217e7323c3818f7be319c0b007124b27",
"/main.dart.js": "d24c733ed40c531e9f0cf6c1b3aeb674",
"/manifest.json": "8e35f4c50b4f0b36c6903f5acde238a1",
"/save_web_plugin.js": "07582df3150510adde548e8f3118f526"
};

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys().then(function (cacheName) {
      return caches.delete(cacheName);
    }).then(function (_) {
      return caches.open(CACHE_NAME);
    }).then(function (cache) {
      return cache.addAll(Object.keys(RESOURCES));
    })
  );
});

self.addEventListener('fetch', function (event) {
  event.respondWith(
    caches.match(event.request)
      .then(function (response) {
        if (response) {
          return response;
        }
        return fetch(event.request, {
          credentials: 'include'
        });
      })
  );
});
