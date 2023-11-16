// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Post} from "./Post.sol";
import {User} from "./User.sol";

contract Follow {
  
    address public Owner;
    Post public post;
    User public user;


    constructor(address _postRef, address _userRef) {
        Owner = msg.sender;
        post = Post(_postRef);
        user = User(_userRef);
    }

    mapping (address => address[]) public Following;
    mapping (address => address[]) public Followers;

    mapping (address following => uint[] postIds) activityPosts;
    mapping (address following => uint[] commentId) activityComments;

    modifier verifyAccount {
        (address userAddress, , , , , ,) = user.getUser(msg.sender) ;
        require(userAddress == msg.sender, "User is not registered");
        _;
    }

    event followEvent( address indexed userAddress, address indexed followingAddress, uint timestamp );
    event unFollowEvent( address indexed userAddress, address indexed followingAddress, uint timestamp );

    function followUser(address _userAddress) public verifyAccount {
        for (uint i = 0; i < Following[msg.sender].length; i++) {
            require(Following[msg.sender][i] != _userAddress, "You are already following this user");
        }
        require(_userAddress != msg.sender, "You can't follow yourself" );
        Following[msg.sender].push(_userAddress);
        Followers[_userAddress].push(msg.sender);
        emit followEvent(msg.sender, _userAddress, block.timestamp);

        // create new Notification function when new follow is created
        post.addNotification(msg.sender, user.getUserForNotif(msg.sender), 'Start following you');

    }

    function unfollowUser(address _userAddress) public verifyAccount {
        require(_userAddress != msg.sender, "You can't unfollow yourself" );
        for (uint i = 0; i < Following[msg.sender].length; i++) {
            require(Following[msg.sender][i] == _userAddress, "You  already not following this user");
        }
        address[] storage followingArr = Following[msg.sender];
        uint indexOfFollowing;
        for (uint i = 0; i <= followingArr.length -1; i++) {
            if (followingArr[i] == _userAddress) {
                indexOfFollowing = i;
                break;
            }
        }
        
        if (indexOfFollowing < followingArr.length) {
            followingArr[indexOfFollowing] = followingArr[followingArr.length -1];
            followingArr.pop();   
        }
        address[] storage followersArr = Followers[_userAddress];
        uint indexOfFollower ;
        for (uint i = 0; i <= followersArr.length -1; i++) {
            if (followersArr[i] == msg.sender) {
                indexOfFollower = i;
            }
        }
        if (indexOfFollower < followersArr.length) {
            followersArr[indexOfFollower] = followersArr[followersArr.length -1];
            followersArr.pop();
        }

        emit unFollowEvent(msg.sender, _userAddress, block.timestamp);
    
    
    }

    function getFollowing(address _userAddress) public view returns (address[] memory) {
        return Following[_userAddress];        
    }

    function getFollowers(address _userAddress) public view returns (address[] memory) {
        return Followers[_userAddress];        
    }

    function activityFeed() public view returns (Post.PostData[] memory) {
        address[] memory following = Following[msg.sender];
        uint postCount = 0;
        for (uint i = 0; i < following.length; i++) {
            postCount += post.getUserPostsIds(following[i]).length;
        }
        Post.PostData[] memory followingPosts = new Post.PostData[](postCount);
        for (uint i = 0; i < following.length; i++) {
            address followingUser = following[i];
            uint[] memory postIds = post.getUserPostsIds(followingUser);
            for (uint j = 0; j < postIds.length; j++) {
                (uint256 postId, address author, string memory content, string memory description) = post.posts(postIds[j]);
                uint[] memory likes = post.getPostLikesIds(postId);
                uint[] memory comments = post.getPostCommentIds(postId);
                followingPosts[j] = Post.PostData(postId, author, content, description, likes, comments);
            }
        }
        return followingPosts;
    }

    mapping (address => Post.Notification[]) public userNotifications;

    function getUserNotifications(address _userAddress) public view returns (Post.Notification[] memory) {
        return userNotifications[_userAddress];
    }
    // notification managment
    function AddUserNotif(address _owner)  public{
        require(Following[_owner].length > 0, "You are not following anyone");

        address[] memory following = Following[_owner];
        for (uint i = 0; i < following.length; i++) {
            
            Post.Notification[] memory notifications = post.getNotifications(following[i]);
            for (uint j = 0; j < notifications.length; j++) {
                userNotifications[_owner].push(notifications[j]);
            }
        }
    }
}