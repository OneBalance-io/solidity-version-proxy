import { BuidlerConfig } from '@nomiclabs/buidler/config'

export default {
  solc: {
    version: '0.6.12',
    optimizer: { enabled: true, runs: 9000 },
  },
} as BuidlerConfig
