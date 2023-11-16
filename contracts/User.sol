// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

contract User {
    address public Owner;
    bytes32 public salt;
    uint public userCounter;
    address[] public userAddressess;

    constructor() {
        Owner = msg.sender;
    }

    struct UserStruct{
        address userAddress;
        string userName;
        bytes32 email;
        bytes32 password;
        string bio;
        string avatar;
        uint timestamp;
    }


    mapping(address => UserStruct) public users;
    mapping(string => bool) private usernameExists;
    mapping(string => bool) private emailExists;
    mapping(address => string) public addressToEmail;

    event createAccountEvent(address indexed user, string userName);
    event updateAccountEvent(address indexed user, string indexed action);
    event deleteAccountEvent(address indexed user, string msg);
    
    // create account function
    function createAccount(string memory _userName,string memory _email,string memory _password,string memory _bio, string memory _avatar) public {
        require(bytes(_userName).length >= 3,"Username must be at least 3 characters long");
        require(!containsSpecialCharacters(_userName),"Username cannot contain special characters");
        require(bytes(_email).length > 0, "Email cannot be empty");
        require(bytes(_password).length > 8,"Password must be more than 8 characters long");
        require(bytes(_avatar).length > 0,"upload avatar !");
        require(bytes(_bio).length <= 160,"Bio cannot be more than 160 characters long");
        require(!usernameExists[_userName], 'Username already exists');
        require(!emailExists[_email], 'Email already exists');

        salt = keccak256(abi.encodePacked(block.timestamp, msg.sender));
        bytes32 hashPassword = keccak256(abi.encodePacked(salt, _password));
        bytes32 hashEmail = keccak256(abi.encodePacked(salt, _email));



        UserStruct memory newUser = UserStruct(
            msg.sender,
            _userName,
            hashEmail,
            hashPassword,
            _bio,
            _avatar,
            block.timestamp
        );
        users[msg.sender] = newUser;
        userCounter++;
        addressToEmail[msg.sender] = _email;
        usernameExists[_userName] = true;
        emailExists[_email] = true;


        //for the search function
        userAddressess.push(msg.sender);

        emit createAccountEvent(msg.sender, _userName);
    }

    function getUser(address _address) public view returns (address, string memory, bytes32, bytes32, string memory, string memory, uint) {
        return (users[_address].userAddress, users[_address].userName, users[_address].email, users[_address].password, users[_address].bio, users[_address].avatar, users[_address].timestamp);
    }

    function getUserForNotif(address _user) public view returns (UserStruct memory) {
        return users[_user];
    }


    function containsSpecialCharacters(string memory str) private pure returns (bool) {
        bytes memory strBytes = bytes(str);
        for (uint i = 0; i < strBytes.length; i++) {
            if (
                strBytes[i] < 0x30 ||
                (strBytes[i] > 0x39 && strBytes[i] < 0x41) ||
                (strBytes[i] > 0x5A && strBytes[i] < 0x61) ||
                strBytes[i] > 0x7A
            ) {
                return true;
            }
        }
        return false;
    }

    function verifyPassword(string memory EnteredPassword, bytes32 userPassword) public view returns (bool) {
        bytes32 hashToCheck = keccak256(abi.encodePacked(salt, EnteredPassword));
        if (hashToCheck == userPassword) {
            return true;
        } else {
            return false;
        }
    }

    // login function
    function login(string memory _userName, string memory _password) public view returns (bool) {
        bytes32 userPassword = users[msg.sender].password;
        require(verifyPassword(_password, userPassword), 'wrong password');
        require( bytes(_userName).length >= 3, "Username must be at least 3 characters long");
        require(!containsSpecialCharacters(_userName), "Username cannot contain special characters");
        require( bytes(_password).length > 8, "Password must be more than 8 characters long");
        require(keccak256(abi.encodePacked(_userName)) == keccak256(abi.encodePacked(users[msg.sender].userName)), "Username does not exist");
        return true;
    }

    function updateName(string memory _userName) public returns (bool) {
        require(
            bytes(_userName).length >= 3,
            "Username must be at least 3 characters long"
        );
        require(
            !containsSpecialCharacters(_userName),
            "Username cannot contain special characters"
        );
        users[msg.sender].userName = _userName;
        emit updateAccountEvent(msg.sender, 'update Name');
        return true;
    }

    function updatePassword(string memory _password) public returns (bool) {
        require( bytes(_password).length > 8, "Password must be more than 8 characters long");
        bytes32 hashPassword = keccak256(abi.encodePacked(salt, _password));
        users[msg.sender].password = hashPassword;
        emit updateAccountEvent(msg.sender, 'update Password');
        return true;
    }

    function updateBio(string memory _bio) public returns (bool) {
        require( bytes(_bio).length <= 160, "Bio cannot be more than 160 characters long");
        users[msg.sender].bio = _bio;
        emit updateAccountEvent(msg.sender, 'update Bio');
        return true;
    }

    function updateAvatar(string memory _avatar) public returns (bool) {
        require( bytes(_avatar).length > 0, "must upload avatar");
        users[msg.sender].avatar = _avatar;
        emit updateAccountEvent(msg.sender, 'update Avatar');
        return true;
    }

    function updateEmail(string memory  _email) public returns (bool) {
        require(bytes(_email).length > 0, "Email cannot be empty");
        require(!emailExists[_email], 'Email already exists');

        bytes32 hashEmail = keccak256(abi.encodePacked(salt, _email));

        users[msg.sender].email = hashEmail;
        emit updateAccountEvent(msg.sender, 'update Email');
        return true;
    }

    function deleteAccount() public returns (bool) {
        delete users[msg.sender];
        emit deleteAccountEvent(msg.sender, 'has deleted his account');
        return true;
    }

    // user search logic

//     function searchUser(string memory _userName) public view returns (address[] memory) {
//     address[] memory matchUsers = new address[](userCounter);
//     uint counter = 0;
//     for (uint i = 0; i < userCounter; i++) {
//         address currnetAddress = userAddressess[i];
//         if (keccak256(abi.encodePacked(users[currnetAddress].userName)) == keccak256(abi.encodePacked(_userName))) {
//             matchUsers[counter] = currnetAddress;
//             counter++;
//         }
//     }
//     return matchUsers;
// }

    function searchUser(string memory _userName) public view returns (address[] memory) {
    address[] memory matchUsersTemp = new address[](userCounter);
    uint counter = 0;
    for (uint i = 0; i < userCounter; i++) {
        address currnetAddress = userAddressess[i];
        if (keccak256(abi.encodePacked(users[currnetAddress].userName)) == keccak256(abi.encodePacked(_userName))) {
            matchUsersTemp[counter] = currnetAddress;
            counter++;
        }
    }
    address[] memory matchUsers = new address[](counter);
    for (uint i = 0; i < counter; i++) {
        matchUsers[i] = matchUsersTemp[i];
    }
    return matchUsers;
}


}
