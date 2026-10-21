import { existsSync } from 'node:fs';
import { execSync } from 'node:child_process';
import { resolve } from 'node:path';

const targetDir = resolve('deps/open-abap-core');
const PINNED_COMMIT = '078fe07ba1c2860579b432288851a723c1e384af';

if (!existsSync(targetDir)) {
  console.log(`Cloning open-abap-core (pinned at ${PINNED_COMMIT.slice(0, 7)})...`);
  execSync('git clone https://github.com/open-abap/open-abap-core.git deps/open-abap-core', {
    stdio: 'inherit',
  });
  execSync(`git -C deps/open-abap-core checkout ${PINNED_COMMIT}`, {
    stdio: 'inherit',
  });
  console.log('✓ Successfully cloned and pinned open-abap-core.');
} else {
  console.log('✓ open-abap-core already present in deps/open-abap-core.');
}
