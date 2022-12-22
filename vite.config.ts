// eslint-disable-next-line import/no-extraneous-dependencies
import { defineConfig, loadEnv } from 'vite';
// eslint-disable-next-line import/no-extraneous-dependencies
import elmPlugin from 'vite-plugin-elm';
import { execSync } from 'child_process';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd());
  const commitRef = env['VITE_COMMIT_REF'] ?? execSync('git rev-parse --short HEAD').toString().trim();
  const commitShortRef = commitRef.slice(
    0,
    7,
  );

  return {
    plugins: [elmPlugin()],
    define: {
      APP_COMMIT_REF: JSON.stringify(commitShortRef),
    },
  };
});
