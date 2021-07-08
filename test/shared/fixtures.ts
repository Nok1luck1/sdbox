import { Contract, Wallet } from 'ethers'
import { Web3Provider } from 'ethers/providers'
import { deployContract } from 'ethereum-waffle'

import { expandTo18Decimals } from './utilities'

import BEP20 from '../../build/BEP20.json'
import SDBswapFactory from '../../build/SDBswapFactory.json'
import ISDBswapPair from '../../build/ISDBswapPair.json'
import SDBswapRouter from '../../build/SDBswapRouter.json'
import WBNB9 from '../../build/WBNB9.json'

interface FactoryFixture {
  factory: Contract
}

const overrides = {
  gasLimit: 9999999
}

export async function factoryFixture(_: Web3Provider, [wallet]: Wallet[]): Promise<FactoryFixture> {
  const factory = await deployContract(wallet, SDBswapFactory, [wallet.address], overrides)
  return { factory }
}

interface PairFixture extends FactoryFixture {
  token0: Contract
  token1: Contract
  WBNB: Contract
  WBNBPartner: Contract
  pair: Contract
  WBNBPair: Contract
}

export async function pairFixture(provider: Web3Provider, [wallet]: Wallet[]): Promise<PairFixture> {
  const { factory } = await factoryFixture(provider, [wallet])

  const tokenA = await deployContract(wallet, BEP20, [expandTo18Decimals(10000)], overrides)
  const tokenB = await deployContract(wallet, BEP20, [expandTo18Decimals(10000)], overrides)
  const WBNB = await deployContract(wallet, WBNB9)
  const WBNBPartner = await deployContract(wallet, BEP20, [expandTo18Decimals(10000)])

  await factory.createPair(tokenA.address, tokenB.address, overrides)
  const pairAddress = await factory.getPair(tokenA.address, tokenB.address)
  const pair = new Contract(pairAddress, JSON.stringify(ISDBswapPair.abi), provider).connect(wallet)

  const token0Address = (await pair.token0()).address
  const token0 = tokenA.address === token0Address ? tokenA : tokenB
  const token1 = tokenA.address === token0Address ? tokenB : tokenA

  await factory.createPair(WBNB.address, WBNBPartner.address)
  const WBNBPairAddress = await factory.getPair(WBNB.address, WBNBPartner.address)
  const WBNBPair = new Contract(WBNBPairAddress, JSON.stringify(ISDBswapPair.abi), provider).connect(wallet)

  return { factory, token0, token1, WBNB, WBNBPartner, pair, WBNBPair }
}

interface RouterFixture extends PairFixture {
  router: Contract
}

export async function routerFixture(provider: Web3Provider, [wallet]: Wallet[]): Promise<RouterFixture> {
  const { factory, token0, token1, WBNB, WBNBPartner, pair, WBNBPair } = await pairFixture(provider, [wallet])

  const router = await deployContract(wallet, SDBswapRouter, [factory.address, WBNB.address], overrides)

  return { factory, token0, token1, WBNB, WBNBPartner, pair, WBNBPair, router }
}
