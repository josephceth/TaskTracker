// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/// @title A basic task tracker with payment mechanism
/// @author josephc.eth
/// @notice This is not production ready code, just a learning exercise
/// @dev All function calls are currently implemented without side effects
/// @custom:experimental This is an experimental contract.

contract TaskTracker {
    event Change(string message);

    struct Task {
        string project;
        string title;
        string description;
        bool isCompleted;
        uint256 dueDate;
        address assignedUser;
        uint256 payment;
        address owner;
    }

    Task[] public _taskList;
    mapping(address => uint256[]) _userTasks;
    mapping(string => uint256[]) _projectTasks;
    mapping(address => uint256[]) _ownerTasks;

    /// @notice Returns the amount of ETH stored in teh contract
    /// @dev Returns amount in Wei
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /// @notice Adds a Task to the _userTask map
    /// @param assignedUser The address of the user to which the task is assigned
    /// @param taskIndex The index of the task in the _taskList array
    function addToUserTasks(address assignedUser, uint256 taskIndex) internal {
        _userTasks[assignedUser].push(taskIndex);
    }

    /// @notice Adds a Task to the _projectTask map
    /// @param projectName The name of the project associated with the Task
    /// @param taskIndex The index of the task in the _taskList array
    function addToProjectTasks(string memory projectName, uint256 taskIndex)
        internal
    {
        _projectTasks[projectName].push(taskIndex);
    }

    /// @notice Adds a Task to the _ownerTasks map
    /// @param owner The address of the owner who created the Task
    /// @param taskIndex The index of the task in the _taskList array
    function addToOwnerTasks(address owner, uint256 taskIndex) internal {
        _ownerTasks[owner].push(taskIndex);
    }

    /** @notice Adds a Task to the primary TaskList array and also add the index references to the 
        _userTasks, _ownerTasks, _projectTasks mapping arrays */
    /// @param project The project name
    /// @param title The task's title
    /// @param description The task's description
    /// @param dueDate The task's due date
    /// @param assignedUser The tasks's assigned user
    function addTask(
        string memory project,
        string memory title,
        string memory description,
        uint256 dueDate,
        address assignedUser
    ) public payable {
        require(bytes(project).length > 0, "Project is required");
        require(bytes(title).length > 0, "Title is required");
        require(bytes(description).length > 0, "Description is required");
        require(dueDate > 0, "DueDate is required");
        require(assignedUser != address(0), "Assigned User is required");

        uint256 newIndex = _taskList.length;
        _taskList.push(
            Task(
                project,
                title,
                description,
                false,
                dueDate,
                assignedUser,
                msg.value,
                msg.sender
            )
        );
        addToUserTasks(assignedUser, newIndex);
        addToProjectTasks(project, newIndex);
        addToOwnerTasks(msg.sender, newIndex);
    }

    /// @notice Returns an array of Task indexes for a given address for the assigned user
    /// @param user The address of the assigned User
    /// @return An array of indexes from the _taskList array corresponding to the task's assigned to the provided user
    function getUserTasks(address user) public view returns (uint256[] memory) {
        return _userTasks[user];
    }

    /// @notice Returns an array of Task indexes for a given project name
    /// @param projectName The Project name for the tasks
    /// @return An array of indexes from the _taskList array corresponding to the task's project name
    function getProjectTasks(string memory projectName)
        public
        view
        returns (uint256[] memory)
    {
        return _projectTasks[projectName];
    }

    /// @notice Returns an array of Task indexes for a given address for the task's owner
    /// @param owner The address of the task's owner
    /// @return An array of indexes from the _taskList array corresponding to the task's owner
    function getOwnerTasks(address owner)
        public
        view
        returns (uint256[] memory)
    {
        return _ownerTasks[owner];
    }

    /** @notice updates in the _taskList array and also modifies the indexes in 
    _userTasks, _projectTasks mapping arrays if the assigned user or project name changed */
    /// @param index The index of the item beeing updated in _taskList
    /// @param project The project name
    /// @param title The task's title
    /// @param description The task's description
    /// @param dueDate The task's due date
    /// @param assignedUser The tasks's assigned user
    /// @dev Investigage adding payable functionality to this function, would have to increase the Task.payment value based on the original value + msg.value
    function updateTask(
        uint256 index,
        string memory project,
        string memory title,
        string memory description,
        uint256 dueDate,
        address assignedUser
    ) public {
        require(bytes(project).length > 0, "Project is required");
        require(bytes(title).length > 0, "Title is required");
        require(bytes(description).length > 0, "Description is required");
        require(dueDate > 0, "DueDate is required");
        require(assignedUser != address(0), "Assigned User is required");

        Task memory foundTask = _taskList[index];
        require(
            foundTask.owner == msg.sender,
            "You do not have permission to update this task"
        );

        //Updates the _userTasks array if the assigned user is changed from the original
        if (foundTask.assignedUser != assignedUser) {
            emit Change("Assigned user changing");
            uint256 arrayLength = _userTasks[foundTask.assignedUser].length;
            for (uint256 i = 0; i <= arrayLength - 1; i++) {
                if (_userTasks[foundTask.assignedUser][i] == index) {
                    _userTasks[foundTask.assignedUser][i] ==
                        _userTasks[foundTask.assignedUser][
                            _userTasks[foundTask.assignedUser].length - 1
                        ];
                    _userTasks[foundTask.assignedUser].pop();
                    _userTasks[assignedUser].push(index);
                    break;
                }
            }
        }

        //Updates the _projectTasks array if the project name user is changed from the original
        if (
            keccak256(abi.encodePacked((foundTask.project))) !=
            keccak256(abi.encodePacked((project)))
        ) {
            uint256 arrayLength = _projectTasks[foundTask.project].length;
            for (uint256 i = 0; i <= arrayLength - 1; i++) {
                if (_projectTasks[foundTask.project][i] == index) {
                    _projectTasks[foundTask.project][i] ==
                        _projectTasks[foundTask.project][
                            _projectTasks[foundTask.project].length - 1
                        ];
                    _projectTasks[foundTask.project].pop();
                    _projectTasks[project].push(index);
                    break;
                }
            }
        }

        //updates the task
        _taskList[index] = Task(
            project,
            title,
            description,
            false,
            dueDate,
            assignedUser,
            foundTask.payment,
            msg.sender
        );
    }

    /// @notice Deletes a task from the taskList, projectTask, userTask, ownerTask arrays
    /// @param taskIndex The index of the task in the _taskList array
    function deleteTask(uint256 taskIndex) public {
        require(taskIndex < _taskList.length, "Item does not exist in array");

        Task memory foundTask = _taskList[taskIndex];
        require(
            foundTask.owner == msg.sender,
            "You do not have permission to update this task"
        );

        //TODO Discover why this is failing
        // require(
        //     foundTask.isCompleted == true,
        //     "You cannot delete a completed task"
        // );

        if (foundTask.payment > 0) {
            payable(foundTask.owner).transfer(foundTask.payment);
        }

        delete _taskList[taskIndex];
    }

    /**@notice Completes a task, transfers any applicable ETH from the contract to the assigned user
      and removes the task from the taskList, projectTask, userTask, ownerTask arrays */
    /// @param taskIndex The index of the task in the _taskList array
    function completeTask(uint256 taskIndex) public {
        require(taskIndex < _taskList.length, "Item does not exist in array");

        Task memory foundTask = _taskList[taskIndex];
        require(
            foundTask.owner == msg.sender,
            "You do not have permission to update this task"
        );

        //TODO Discover why this is failing
        // require(
        //     foundTask.isCompleted == true,
        //     "You cannot complete a completed task"
        // );

        if (foundTask.payment > 0) {
            payable(foundTask.assignedUser).transfer(foundTask.payment);
        }

        _taskList[taskIndex] = Task(
            foundTask.project,
            foundTask.title,
            foundTask.description,
            true,
            foundTask.dueDate,
            foundTask.assignedUser,
            foundTask.payment,
            msg.sender
        );
    }
}
