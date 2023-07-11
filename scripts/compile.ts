import { compileToModuleString } from 'https://deno.land/x/deno_elm_compiler@0.1.0/compiler.ts';

console.log(await compileToModuleString('./src/Main.elm'));
