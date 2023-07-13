import { defineConfig, loadEnv } from 'vite';
import { plugin } from 'vite-plugin-elm';
import { execSync } from 'child_process';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd());
  const gitRef = env['VITE_COMMIT_REF'] ?? execSync('git rev-parse --short HEAD').toString().trim();
  const shortRef = gitRef.slice(
    0,
    7,
  );

  return {
    plugins: [plugin()],
    define: {
      APP_COMMIT_REF: JSON.stringify(shortRef),
    },
  };
});
