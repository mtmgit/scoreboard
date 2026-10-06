self.addEventListener('push', (e) => {
  const data = e.data ? e.data.json() : { title: 'SMZ Vehicle Match', body: 'New vehicle match available at partsagain.com' };
  e.waitUntil(
    self.registration.showNotification(data.title, {
      body: data.body,
      icon: '/icon.png',
      data: { url: data.url || '/' }
    })
  );
});

self.addEventListener('notificationclick', (e) => {
  e.notification.close();
  e.waitUntil(clients.openWindow(e.notification.data.url || '/'));
});
