# TaskTracker
Task Tracker with basic task assignment and funding capabilities
Uses solidity and NatSpec documentation pattern https://docs.soliditylang.org/en/v0.8.13/natspec-format.html

This is an experimental contract only and is for my own learning purposes

1 - A user can create a task and assign it to a project and a user
2 - At the time of creation, they can also choose to fund the task with some ETH, which is transfered to the contract
3 - The owner of the task can update all the fields, but cannot change the funding amount
4 - Once the owner completes the task, the payment amount will be transferred to the assigned user
