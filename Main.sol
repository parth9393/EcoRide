// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RideSharing {
    struct Driver {
        string name;
        string vehicle;
        address driverAddress;
        bool isAvailable;
    }

    struct RideRequest {
        string pickup;
        string destination;
        address requester;
        bool isAccepted;
        address driver;
    }

    mapping(address => Driver) public drivers;
    RideRequest[] public rideRequests;

    event DriverRegistered(address indexed driver, string name, string vehicle);
    event RideRequested(address indexed requester, string pickup, string destination);
    event RideAccepted(address indexed driver, uint256 rideIndex);
    event PaymentCompleted(address indexed passenger, address indexed driver, uint256 amount);

    modifier onlyDriver() {
        require(bytes(drivers[msg.sender].name).length > 0, "You are not a registered driver.");
        _;
    }

    function registerDriver(string memory _name, string memory _vehicle) public {
        require(bytes(drivers[msg.sender].name).length == 0, "Driver already registered.");
        drivers[msg.sender] = Driver(_name, _vehicle, msg.sender, true);
        emit DriverRegistered(msg.sender, _name, _vehicle);
    }

    function getRegisteredDrivers() public view returns (address[] memory, string[] memory, string[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < rideRequests.length; i++) {
            if (drivers[rideRequests[i].driver].driverAddress != address(0)) {
                count++;
            }
        }

        address[] memory driverAddresses = new address[](count);
        string[] memory driverNames = new string[](count);
        string[] memory vehicleDetails = new string[](count);
        uint256 index = 0;

        for (uint256 i = 0; i < rideRequests.length; i++) {
            if (drivers[rideRequests[i].driver].driverAddress != address(0)) {
                driverAddresses[index] = rideRequests[i].driver;
                driverNames[index] = drivers[rideRequests[i].driver].name;
                vehicleDetails[index] = drivers[rideRequests[i].driver].vehicle;
                index++;
            }
        }
        return (driverAddresses, driverNames, vehicleDetails);
    }

    function createRideRequest(string memory _pickup, string memory _destination) public {
        rideRequests.push(RideRequest(_pickup, _destination, msg.sender, false, address(0)));
        emit RideRequested(msg.sender, _pickup, _destination);
    }

    function getAvailableRides() public view returns (RideRequest[] memory) {
        return rideRequests;
    }

    function acceptRideRequest(uint256 _rideIndex) public onlyDriver {
        require(_rideIndex < rideRequests.length, "Invalid ride index.");
        require(!rideRequests[_rideIndex].isAccepted, "Ride already accepted.");
        
        rideRequests[_rideIndex].isAccepted = true;
        rideRequests[_rideIndex].driver = msg.sender;
        emit RideAccepted(msg.sender, _rideIndex);
    }

    function makePayment(uint256 _rideIndex) public payable {
        require(_rideIndex < rideRequests.length, "Invalid ride index.");
        require(rideRequests[_rideIndex].isAccepted, "Ride not accepted yet.");
        require(msg.value > 0, "Payment amount must be greater than 0.");
        require(rideRequests[_rideIndex].driver != address(0), "No driver assigned.");

        address payable driver = payable(rideRequests[_rideIndex].driver);
        driver.transfer(msg.value);

        emit PaymentCompleted(msg.sender, driver, msg.value);
    }
}
