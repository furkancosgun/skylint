import { existsSync } from 'node:fs';
import { execSync } from 'node:child_process';
import { resolve } from 'node:path';

const targetDir = resolve('deps/open-abap-core');

if (!existsSync(targetDir)) {
  console.log('Cloning open-abap-core into deps/open-abap-core...');
  execSync('git clone --depth 1 https://github.com/open-abap/open-abap-core.git deps/open-abap-core', {
    stdio: 'inherit',
  });
  console.log('✓ Successfully cloned open-abap-core.');
} else {
  console.log('✓ open-abap-core already present in deps/open-abap-core.');
}
