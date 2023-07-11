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
const decoder = new TextDecoder();
const gitCommandResult = (new Deno.Command('git', { args: ['rev-parse', '--short', 'HEAD'] })).outputSync();
const gitRef = gitCommandResult.success ? decoder.decode(gitCommandResult.stdout) : '???????-dev';
const shortRef = gitRef.slice(
  0,
  7,
);

const embedded = code.replace(
  "const APP_COMMIT_REF = 'THIS_LINE_WILL_BE_REPLACED_AFTER_TRANSPILE';",
  `const APP_COMMIT_REF = '${shortRef}';`,
);

if (code === embedded) {
  throw new Error('handmade template did not work, please check and update');
}

console.log(embedded);
