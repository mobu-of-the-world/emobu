// @deno-types="./main.d.ts"
import { Elm } from '../public/main.js';
import { assertIsDefined } from './typeguards.ts';

declare const APP_COMMIT_REF: string;

const isSupportedNotification = 'Notification' in window;

const storedData = localStorage.getItem('mobu-model');
const flags = {
  persisted: storedData ? JSON.parse(storedData) : {},
  gitRef: APP_COMMIT_REF,
};
const mobuNode = document.getElementById('mobu');
assertIsDefined(mobuNode);

const app = Elm.Main.init({
  node: mobuNode,
  flags,
});

// test

app.ports.setStorage.subscribe((state: Record<string, unknown>) => {
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
