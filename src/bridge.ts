// @deno-types="./main.d.ts"
import { Elm } from '../public/main.js';

// Write here without external modules because deno bundler can not correctly handle it
// https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-7.html#assertion-functions
function assertIsDefined<T>(val: T): asserts val is NonNullable<T> {
  if (val === undefined || val === null) {
    throw new Error(`Expected 'val' to be defined, but received ${val}`);
  }
}

const isSupportedNotification = 'Notification' in window;

const storedData = localStorage.getItem('mobu-model');
const flags = {
  persisted: storedData ? JSON.parse(storedData) : {},
  gitRef: 'dummy_ref',
};

if (typeof document !== 'undefined') {
  const mobuNode = document.getElementById('mobu');
  assertIsDefined(mobuNode);

  const app = Elm.Main.init({
    node: mobuNode,
    flags,
  });

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
}
