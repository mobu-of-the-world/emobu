import { Elm } from './Main.elm';

declare const APP_COMMIT_REF: string;

const storedData = localStorage.getItem('mobu-model');
// eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
const flags = storedData
  ? { ...JSON.parse(storedData), commitRef: APP_COMMIT_REF }
  : { users: [], commitRef: APP_COMMIT_REF };
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
