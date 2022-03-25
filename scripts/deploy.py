from scripts.helpers import getAccount
from brownie import TaskTracker, network, config


def deployContract():
    account = getAccount()
    contract = TaskTracker.deploy(
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify", False),
    )
    print("Contract Deployed Successfully")
    return contract


def main():
    deployContract()
