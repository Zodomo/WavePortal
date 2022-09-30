pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint public totalWaves; // Total wave count
    mapping(address => bool) hasWaved; // Lets us know if someone has waved before

    struct Waver { // Waver struct created to hold attributes about waver
        bool waved;
        uint waveCount;
        uint waverIndex; // Index value in waverList, initializes to 0x0000000000000000000000000000000000000000
        string username;
    }

    mapping(address => Waver) public waverStructs; // Mapping of waver structs for easy access "Waver API"
    address[] public waverList; // An array we populate with waver addresses so waverStructs is iterable

    mapping(string => address) public claimedUsernames; // Mapping that we can use to check if usernames are taken

    event LogNewWaver(address waver); // Event to track new wavers as they're added in the front-end

    constructor() {
        console.log("[constructor] WavePortal initializing..."); // Console output
        waverList.push(0x0000000000000000000000000000000000000000); // Ensures non-wavers don't show an address
    }

    function wave() public { // Function call to wave to the contract
        if (!hasWaved[msg.sender]) { // Check if it's the waver's first time
            waverList.push(msg.sender); // Add waver address to our array
            waverStructs[msg.sender].waverIndex = waverList.length - 1; // Store waverList index position

            hasWaved[msg.sender] = true; // Set our general wave check mapping to true
            waverStructs[msg.sender].waved = true; // Set the waved property in the Waver object itself as true
            // Keeping both of the above two "wave checks" allows us to repurpose the Waver struct if necessary

            totalWaves += 1; // Increment global wave count
            waverStructs[msg.sender].waveCount += 1; // Increment Waver's wave count

            waverStructs[msg.sender].username = "N/A"; // Sets placeholder for username field

            emit LogNewWaver(msg.sender); // Emit new waver event for front-end
            console.log("[wave] %s (%s) has waved for the first time!",
                msg.sender, waverStructs[msg.sender].username);
        } else {
            waverStructs[msg.sender].waveCount += 1; // Since waver isn't new, just increment count
            totalWaves += 1; // Also increment global count
            console.log("[wave] %s (%s) has waved %d times!",
                msg.sender, waverStructs[msg.sender].username, waverStructs[msg.sender].waveCount);
        }
    }

    function setUsername(string memory _username) public { // Allows addresses to assign themselves a username
        // No check for waver status so those who haven't can still interact
        require(claimedUsernames[_username] == address(0), "Username taken."); // Check to see if username is taken
        if (waverStructs[msg.sender].waverIndex == 0) { // If user hasn't waved, adds them to the WavePortal user list
            waverList.push(msg.sender);
            waverStructs[msg.sender].waverIndex = waverList.length - 1;
            console.log("[setUsername] %s set username before waving!", msg.sender);
        }
        console.log("[setUsername] %s has changed their username to '%s'", msg.sender, _username);
        waverStructs[msg.sender].username = _username; // Process username change
        claimedUsernames[_username] = msg.sender; // Sets owner of username
    }

    function getUsername(address _waver) public view returns (string memory _username) { // Prints waver's username
        if (waverStructs[_waver].waverIndex == 0) { // Check if address has interacted at all
            console.log("[getUsername] %s has not interacted with the contract yet!", _waver);
            return("N/A");
        }
        else if (keccak256(abi.encodePacked(waverStructs[_waver].username)) == 
            keccak256(abi.encodePacked("N/A"))) { // See if username set
            console.log("[getUsername] %s has not set a username yet!", _waver);
            return("N/A");
        } else { // Output username
            console.log("[getUsername] %s's username is %s", _waver, waverStructs[_waver].username);
            return(_username);
        }
    }

    function checkUsername(string memory _username) public view returns (address) { // See username address
        if (claimedUsernames[_username] ==  address(0)) { // Check to see if username is claimed
            console.log("[checkUsername] %s hasn't been taken!", _username);
            return(address(0));
        } else { // Output wallet address belonging to username
            console.log("[checkUsername] %s's address is %s", _username, claimedUsernames[_username]);
            return(claimedUsernames[_username]);
        }
    }

    function getTotalWaves() public view returns (uint) { // Output global wave count to console and return it
        console.log("[getTotalWaves] We have %d total waves!", totalWaves);
        return totalWaves;
    }

    function getWaverCount() public view returns(uint count) { // Output unique waver count to console and return it
        console.log("[getWaverCount] There are %d unique wavers!", waverList.length);
        return waverList.length;
    }

    function getWaverAtIndex(uint _index) public view returns(address waver) { // Output waver address at index in waverList
        console.log("[getWaverAtIndex] Waver address at waverList index %d: %s", _index, waverList[_index]);
        return waverList[_index];
    }

    function isWaver(address _waver) public view returns(bool answer) { // Utilize global wave check to output status
        console.log("[isWaver] Has %s waved before? %s", _waver, hasWaved[_waver]);
        return hasWaved[_waver];
    }

    function getWaverStruct(address _waver) public view returns(bool, uint, uint) { // Output a specific Waver struct object's data
        if (waverStructs[_waver].waverIndex == 0) {
            console.log("[getWaverStruct] %s has not interacted with the contract!", _waver);
            return(false, 0, 0);
        } else {
            console.log("[getWaverStruct] %s (%s) WaverStruct:", _waver, waverStructs[_waver].username);
            console.log("[getWaverStruct] {Waved: %s, Count: %d, waverList Index: %d}",
                waverStructs[_waver].waved, waverStructs[_waver].waveCount, waverStructs[_waver].waverIndex);
            return(waverStructs[_waver].waved, waverStructs[_waver].waveCount, waverStructs[_waver].waverIndex);
        }
    }
}