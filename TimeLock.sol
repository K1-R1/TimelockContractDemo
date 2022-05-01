// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

contract TimeLock {
    function queue(
        address _target, //address to call
        uint256 _value, //value of ETH (wei) to send
        string calldata _func, //function on target to call
        bytes calldata _data, //data to pass to _func
        uint256 _timestamp //timestamp after which transaction can be executed
    ) external {}

    function execute() external {}
}

contract TestTimeLock {
    address public timeLock;

    constructor(address _timeLock) {
        timeLock = _timeLock;
    }

    function test() external {
        require(msg.sender == timeLock);
        // potentially malicious code
    }
}
