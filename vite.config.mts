import { defineConfig, loadEnv } from 'npm:vite';
import elmPlugin from 'npm:vite-plugin-elm';
import { execSync } from 'https://deno.land/std@0.177.0/node/child_process.ts';

// import 'npm:elm@latest-0.19.1';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, Deno.cwd());
  const gitRef = env['VITE_COMMIT_REF'] ?? execSync('git rev-parse --short HEAD', {})!.toString().trim();
  const shortRef = gitRef.slice(
    0,
    7,
  );

  return {
    plugins: [elmPlugin],
    define: {
      APP_COMMIT_REF: JSON.stringify(shortRef),
    },
  };
});
