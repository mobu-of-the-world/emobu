import { Elm } from './Main.elm';

declare const APP_COMMIT_REF: string;

// https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-7.html#assertion-functions
function assertIsDefined<T>(val: T): asserts val is NonNullable<T> {
  if (val === undefined || val === null) {
    // eslint-disable-next-line @typescript-eslint/restrict-template-expressions
    throw new Error(`Expected 'val' to be defined, but received ${val}`);
  }
}

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

app.ports.dragstart.subscribe((data) => {
  const { effectAllowed, event: { dataTransfer } } = data;
  debugger;
  assertIsDefined(dataTransfer);
  dataTransfer.setData('text/plain', ''); // needed
  dataTransfer.effectAllowed = effectAllowed;
});

app.ports.dragover.subscribe((data) => {
  const { dropEffect, event: { dataTransfer } } = data;
  assertIsDefined(dataTransfer);
  dataTransfer.dropEffect = dropEffect;
});
