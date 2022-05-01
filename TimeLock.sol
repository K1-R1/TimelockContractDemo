// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

contract TimeLock {
    error NotOwnerError();
    error AlreadyQueuedError(bytes32 txId);

    address public immutable OWNER;

    mapping(bytes32 => bool) public isTxQueued; //Checks if a specific Transaction Id is currently queued

    constructor() {
        OWNER = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != OWNER) {
            revert NotOwnerError();
        }
        _;
    }

    //Queue a valid transaction, that can only be executed after some delay
    function queue(
        address _target, //address to call
        uint256 _value, //value of ETH (wei) to send
        string calldata _func, //function on target to call
        bytes calldata _data, //data to pass to _func
        uint256 _timestamp //timestamp after which transaction can be executed
    ) external onlyOwner {
        //Create tx id
        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);
        //check txid is unique (not already queued)
        if (isTxQueued[txId]) {
            revert AlreadyQueuedError(txId);
        }
        //check timestamp
        //queue tx
    }

    //Get ID of transaction derived from inputs via hashing
    function getTxId(
        address _target, //address to call
        uint256 _value, //value of ETH (wei) to send
        string calldata _func, //function on target to call
        bytes calldata _data, //data to pass to _func
        uint256 _timestamp //timestamp after which transaction can be executed
    ) public pure returns (bytes32 txId) {
        return keccak256(abi.encode(_target, _value, _func, _data, _timestamp));
    }

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
