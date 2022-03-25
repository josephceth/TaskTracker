from brownie import accounts, config, network


def getAccount(index=None, id=None):
    if index:
        return accounts[index]
    if id:
        return accounts.load(id)
    if network.show_active() in _localBlockChainEnvironments:
        return accounts[0]
    return accounts.add(config["wallets"]["devPrivateKey"])


_localBlockChainEnvironments = ["development", "ganace-local"]
