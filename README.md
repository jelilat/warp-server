This is a simple nodejs server that transpiles Solidity smart contracts into Cairo using Nethermind's [Warp](https://github.com/NethermindEth/warp). 

## Usage

1. Clone the repo
2. Run `npm install` or `yarn install`
3. Run `npm run dev` or `yarn dev`

```
If you are running the server with the Warp Remix Plugin, skip step 4.
```

4. Send a GET request to `localhost:6060/transpile` with the following parameters:

```json
{
    "content": "CONTENT_OF_THE_CONTRACT",
    "filename": "NAME_OF_THE_CONTRACT.sol"
}
```

