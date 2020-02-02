'use strict';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "/assets\AssetManifest.json": "f0d72e6eda07f8abc2a46fba9e86f8fb",
"/assets\assets\failed.jpg": "dfe8dd807e09431646087324a89e9002",
"/assets\assets\image.jpg": "321a9e61608ab12ff40d04e2c222dfdb",
"/assets\assets\loading.gif": "ed16f917eed78d2045ae03bcd8242ad5",
"/assets\FontManifest.json": "f7161631e25fbd47f3180eae84053a51",
"/assets\fonts\MaterialIcons-Regular.ttf": "56d3ffdef7a25659eab6a68a3fbfaf16",
"/assets\LICENSE": "1671130944123dcd6241a7ef277c83c7",
"/assets\packages\cupertino_icons\assets\CupertinoIcons.ttf": "115e937bb829a890521f72d2e664b632",
"/assets\packages\flutter_candies_demo_library\assets\40.png": "d31f4ff6176bedac2101b1cbb9083f36",
"/assets\packages\flutter_candies_demo_library\assets\avatar.jpg": "c1916ddb1a8e3f82054850e79c24ac84",
"/assets\packages\flutter_candies_demo_library\assets\flutterCandies_grey.png": "5fac6a25f94b0f5e26acaa5bf75433b2",
"/assets\packages\flutter_candies_demo_library\assets\love.png": "5370bcbe694c796309acc76760288878",
"/assets\packages\flutter_candies_demo_library\assets\sun_glasses.png": "c2e38170a5e3a0883b0c436f6e799e36",
"/assets\packages\loading_more_list\assets\empty.jpeg": "52a69bab9f87bcf0052d8e55ea314977",
"/icons\Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"/icons\Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"/index.html": "cd45f73ca1b5a7b0686f989043bf61c2",
"/main.dart.js": "7529c80d7689a5950f5d8d740b2bac83",
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
