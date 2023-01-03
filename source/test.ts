import { transpile, compileSolFiles, AST } from '@nethermindeth/warp';
import { createIframeClient, remixApi } from 'remix-plugin'

const b = compileSolFiles(['example_contracts/array_length.sol'], { warnings: false })
const a = transpile(b, { strict: true, dev: true })

console.log(a, b)

// const client = createIframeClient({ customApi: remixApi })
// client.fileManager.setFile('testing.ts', "test")