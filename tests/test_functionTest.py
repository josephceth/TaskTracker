from brownie import exceptions
from scripts.deploy import deployContract
from scripts.helpers import getAccount
from web3 import Web3
import pytest


def initializeContract(contract):
    return contract.addTask(
        "Test Project",
        "Create first test",
        "Create a test for adding a task",
        168481151,
        getAccount(1),
        {"from": getAccount(), "value": 2500},
    )


def test_createTask():
    contract = deployContract()
    initializeContract(contract)
    assert contract._taskList(0)[0] == "Test Project"
    assert contract._taskList(0)[1] == "Create first test"
    assert contract._taskList(0)[2] == "Create a test for adding a task"
    assert contract._taskList(0)[3] == False
    assert contract._taskList(0)[4] == 168481151
    assert contract._taskList(0)[5] == getAccount(1)
    assert contract._taskList(0)[6] == 2500
    assert contract._taskList(0)[7] == getAccount()
    assert contract.getContractBalance() == 2500


def test_onlyOwnerCanEdit():
    contract = deployContract()
    txn = initializeContract(contract)
    txn.wait(1)

    with pytest.raises(exceptions.VirtualMachineError):
        contract.updateTask(
            0,
            "Test Project",
            "Create first test",
            "Create a test for adding a task",
            168481151,
            getAccount(),
            {"from": getAccount(1)},
        )


def test_updateTaskDataOnly():
    contract = deployContract()
    txn = initializeContract(contract)
    txn.wait(1)

    txn = contract.updateTask(
        0,
        "Test Project Updated",
        "Create first test Updated",
        "Create a test for adding a task Updated",
        168481152,
        getAccount(),
        {"from": getAccount(0)},
    )
    txn.wait(1)

    assert contract._taskList(0)[0] == "Test Project Updated"
    assert contract._taskList(0)[1] == "Create first test Updated"
    assert contract._taskList(0)[2] == "Create a test for adding a task Updated"
    assert contract._taskList(0)[3] == False
    assert contract._taskList(0)[4] == 168481152
    assert contract._taskList(0)[5] == getAccount()
    assert contract._taskList(0)[6] == 2500
    assert contract._taskList(0)[7] == getAccount()


def test_UpdateAssignedUser():
    contract = deployContract()
    txn = initializeContract(contract)
    txn.wait(1)
    assert len(contract.getUserTasks(getAccount(1))) == 1

    txn = contract.updateTask(
        0,
        "Test Project Updated",
        "Create first test Updated",
        "Create a test for adding a task Updated",
        168481152,
        getAccount(2),
        {"from": getAccount(0)},
    )
    txn.wait(1)

    assert len(contract.getUserTasks(getAccount(1))) == 0
    assert len(contract.getUserTasks(getAccount(2))) == 1


def test_UpdateProject():

    contract = deployContract()
    txn = initializeContract(contract)
    txn.wait(1)
    assert len(contract.getProjectTasks("Test Project")) == 1

    txn = contract.updateTask(
        0,
        "Test Project Updated",
        "Create first test Updated",
        "Create a test for adding a task Updated",
        168481152,
        getAccount(1),
        {"from": getAccount(0)},
    )
    txn.wait(1)

    assert len(contract.getProjectTasks("Test Project")) == 0
    assert len(contract.getProjectTasks("Test Project Updated")) == 1


def test_deleteTask():
    currentUser = getAccount()
    contract = deployContract()
    txn = initializeContract(contract)
    txn.wait(1)
    contractBalance = contract.balance()
    assert contractBalance == 2500
    currentUserBalance = currentUser.balance()
    txn = contract.deleteTask(0)
    txn.wait(1)
    assert contract.balance() == 0
    assert currentUser.balance() == (currentUserBalance + 2500)


def test_completeTask():
    contract = deployContract()
    txn = initializeContract(contract)
    txn.wait(1)

    contractBalance = contract.balance()
    assignedUserPreviousBalance = getAccount(1).balance()
    assert contractBalance == 2500

    txn = contract.completeTask(0)
    txn.wait(1)

    assert contract.balance() == 0
    assert getAccount(1).balance() == (assignedUserPreviousBalance + 2500)
