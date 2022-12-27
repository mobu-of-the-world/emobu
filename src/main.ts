import { Elm } from './Main.elm';

declare const APP_COMMIT_REF: string;

const isSupportedNotification = 'Notification' in window;

const storedData = localStorage.getItem('mobu-model');
const flags = {
  // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
  persisted: storedData ? JSON.parse(storedData) : {},
  gitRef: APP_COMMIT_REF,
  enabledNotification: isSupportedNotification && (Notification.permission === 'granted'),
};
const mobuNode = document.getElementById('mobu');
if (!mobuNode) {
  throw Error('Not found node');
}
const app = Elm.Main.init({
  node: mobuNode,
  // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
  flags,
});

app.ports.setStorage.subscribe((state: object) => {
  localStorage.setItem('mobu-model', JSON.stringify(state));
});

app.ports.playSound.subscribe((url: string) => {
  const meowing = new Audio(url);
  void meowing.play();
});

app.ports.notify.subscribe((message: string) => {
  if (isSupportedNotification) {
    new Notification(message);
  }
});

app.ports.requestNotificationPermission.subscribe((_) => {
  if (isSupportedNotification) {
    // This style might not work in safari...
    void Notification.requestPermission();
  }
});
