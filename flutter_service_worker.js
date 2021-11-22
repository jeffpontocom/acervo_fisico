'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "assets/AssetManifest.json": "251f4c22f70ca2a8ca018f3c77d5a2bd",
"assets/assets/etiqueta.svg": "7308869f93f1fe298b8dd16188877e1e",
"assets/assets/fonts/Baumans-Regular.ttf": "8cddfb2408535f88e0f6f5bef174181b",
"assets/assets/fonts/Exo-Regular.ttf": "93a360528be6205068ce031fba20416a",
"assets/assets/fonts/MavenPro-Bold.ttf": "b41936fbb703c9d0ea568eec670653b3",
"assets/assets/fonts/MavenPro-Regular.ttf": "d8607ba833ef2a4dd4fd9d296bad13a4",
"assets/assets/icons/band-aid.png": "09121cb1c737a62b99604825465ac90c",
"assets/assets/icons/data-management.png": "e58f28ed8a0beec970ae1da38864e1d6",
"assets/assets/icons/ic_launcher.png": "2463fe2d5be0255ffa7a62460536136a",
"assets/assets/icons/magician.png": "1a1b1454cd00d6df4df18d16a10590a9",
"assets/assets/icons/private-key.png": "306d6e0d03fb208b0ae13fd9733069a1",
"assets/assets/icons/ufo.png": "d7f54ab765ee2171e412b1e5285969aa",
"assets/assets/images/caixaA3.png": "7dfaaccce3cac583bb72031baf8f64b4",
"assets/assets/images/caixaA4.png": "13b5a3bc8313962b4ddb67db9dcdb996",
"assets/assets/images/gaveta.png": "d7e7b673c4ff3a06be26c8e17bd12e8c",
"assets/assets/images/indefinido.png": "12a62125e4f3a426d5f033c85fee127e",
"assets/assets/images/pastaA3.png": "8c0bdda99a50036291f6a75123af998a",
"assets/assets/images/tubo.png": "73766e40ce6878fe7e44a526a3380b45",
"assets/FontManifest.json": "24c8a5ee4d53756022c1e469bc493ef6",
"assets/fonts/MaterialIcons-Regular.otf": "4e6447691c9509f7acdbf8a931a85ca1",
"assets/NOTICES": "c236b2067e4e5a326e8d875fb914e2a6",
"favicon.png": "8eac394094e9e8768aa01478165f51ab",
"icons/Icon-192.png": "4ec60b189cc3d8cc6e5d7d0f43d5215a",
"icons/Icon-512.png": "af921d96a5d3e7bf7bc906a94340a73a",
"icons/Icon-maskable-192.png": "4ec60b189cc3d8cc6e5d7d0f43d5215a",
"icons/Icon-maskable-512.png": "af921d96a5d3e7bf7bc906a94340a73a",
"index.html": "4e973d0841f2fde019729fe60d8b5fbd",
"/": "4e973d0841f2fde019729fe60d8b5fbd",
"main.dart.js": "55ee867dd0c817832c222412deb7967a",
"manifest.json": "d524e64e979f068bc0fb1d0f51ecc1fc",
"version.json": "a9ac0da8fa15bb9827c5f48b24c7aaab"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
