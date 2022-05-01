// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

contract TimeLock {
    error NotOwnerError();
    error AlreadyQueuedError(bytes32 txId);
    error TimestampNotInRangeError(
        uint256 blockTimestamp,
        uint256 inputTimestamp
    );

    uint256 public immutable MIN_DELAY; //Minimum delay between queeuing and executing a transaction
    uint256 public immutable MAX_DELAY; //Maximum delay between queeuing and executing a transaction
    address public immutable OWNER;

    mapping(bytes32 => bool) public isTxQueued; //Checks if a specific Transaction Id is currently queued

    constructor(uint256 _minDelay, uint256 _maxDelay) {
        OWNER = msg.sender;
        MIN_DELAY = _minDelay;
        MAX_DELAY = _maxDelay;
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
        //check timestamp is within valid range
        if (
            _timestamp < block.timestamp + MIN_DELAY ||
            _timestamp > block.timestamp + MAX_DELAY
        ) {
            revert TimestampNotInRangeError(block.timestamp, _timestamp);
        }
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
