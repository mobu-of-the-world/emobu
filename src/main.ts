/// <reference lib="dom"/>

import { Elm } from './Main.elm';

declare const APP_COMMIT_REF: string;

const isSupportedNotification = 'Notification' in window;

const storedData = localStorage.getItem('mobu-model');
const flags = {
  // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
  persisted: storedData ? JSON.parse(storedData) : {},
  gitRef: APP_COMMIT_REF,
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
  if (!isSupportedNotification) {
    return;
  }

  switch (Notification.permission) {
    case 'denied':
      break;
    case 'granted':
      new Notification(message);
      break;
    default:
      void Notification.requestPermission().then((permission) => {
        if (permission === 'granted') {
          new Notification(message);
        }
      });
      break;
  }
});
