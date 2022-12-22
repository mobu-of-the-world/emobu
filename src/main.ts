import { Elm } from './Main.elm';

declare const APP_COMMIT_REF: string;

const storedData = localStorage.getItem('mobu-model');
const flags = storedData ? { ...JSON.parse(storedData), commitRef: APP_COMMIT_REF } : null;
const app = Elm.Main.init({
  node: document.getElementById('mobu')!,
  flags,
});
app.ports.setStorage.subscribe((state: object) => {
  localStorage.setItem('mobu-model', JSON.stringify(state));
});
app.ports.playSound.subscribe((url: string) => {
  const meowing = new Audio(url);
  meowing.play();
});
