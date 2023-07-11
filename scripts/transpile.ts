// Always require --allow-net https://github.com/denoland/deno_emit/issues/81
import { transpile } from 'https://deno.land/x/emit@0.24.0/mod.ts';
import { parse } from 'https://deno.land/std@0.193.0/flags/mod.ts';
import { assertIsDefined } from '../src/typeguards.ts';

const flags = parse(Deno.args);
const entrypoint = flags.entrypoint;
if (typeof entrypoint !== 'string') {
  throw new Error('Need to specify entrypoint');
}

const url = new URL(entrypoint, import.meta.url);
const result = await transpile(url);

const code = result.get(url.href);
assertIsDefined(code);
console.log(code);
