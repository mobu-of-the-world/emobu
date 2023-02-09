import { defineConfig, loadEnv } from 'npm:vite@3.2.5';
import elmPlugin from 'npm:vite-plugin-elm@2.7.2';
import { execSync } from "https://deno.land/std@0.173.0/node/child_process.ts";

console.info(elmPlugin.default())

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, Deno.cwd());
  const gitRef = env['VITE_COMMIT_REF'] ?? execSync('git rev-parse --short HEAD').toString().trim();
  const shortRef = gitRef.slice(
    0,
    7,
  );

  return {
    plugins: [elmPlugin.default()],
    define: {
      APP_COMMIT_REF: JSON.stringify(shortRef),
    },
  };
});
