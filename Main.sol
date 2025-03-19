// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RideSharing {
    // Ride status options
    enum RideStatus { NotStarted, Ongoing, Completed }

    // Ride struct
    struct Ride {
        uint id;
        address payable driver;
        string source;
        string destination;
        uint seats;
        uint amount; // in wei
        RideStatus status;
        address payable user;
    }

    uint public rideCount;
    mapping(uint => Ride) public rides;

    // Events
    event RideProposed(
        uint indexed id,
        address indexed driver,
        string source,
        string destination,
        uint seats,
        uint amount
    );
    event RideSelected(uint indexed id, address indexed user);
    event RideCompleted(uint indexed id);

    // Driver proposes a new ride
    function proposeRide(
        string memory _source,
        string memory _destination,
        uint _seats,
        uint _amount
    ) public {
        rideCount++;
        rides[rideCount] = Ride({
            id: rideCount,
            driver: payable(msg.sender),
            source: _source,
            destination: _destination,
            seats: _seats,
            amount: _amount,
            status: RideStatus.NotStarted,
            user: payable(address(0))
        });
        emit RideProposed(rideCount, msg.sender, _source, _destination, _seats, _amount);
    }

    // User selects a ride and pays the exact amount
    function selectRide(uint _rideId) public payable {
        require(_rideId > 0 && _rideId <= rideCount, "Invalid ride ID");
        Ride storage ride = rides[_rideId];
        require(ride.status == RideStatus.NotStarted, "Ride not available");
        require(msg.value == ride.amount, "Incorrect amount sent");

        ride.user = payable(msg.sender);
        ride.status = RideStatus.Ongoing;
        emit RideSelected(_rideId, msg.sender);
    }

    // Driver completes an ongoing ride and gets paid
    function completeRide(uint _rideId) public {
        require(_rideId > 0 && _rideId <= rideCount, "Invalid ride ID");
        Ride storage ride = rides[_rideId];
        require(msg.sender == ride.driver, "Only driver can complete ride");
        require(ride.status == RideStatus.Ongoing, "Ride not ongoing");

        ride.status = RideStatus.Completed;
        ride.driver.transfer(ride.amount);
        emit RideCompleted(_rideId);
    }
}
