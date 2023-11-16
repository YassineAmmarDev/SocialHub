// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {User} from "./User.sol";
import {Follow} from "./Follow.sol";

contract Post {

    address public Owner;
    User public user;

    constructor(address _userContractAddress){
        Owner = msg.sender;
        user = User(_userContractAddress);
    }

   

    struct PostData {
        uint postId;
        address author;
        string content;
        string description;
        uint[] likesIds;
        uint[] commentIds;
    }

     struct Like {
        uint likeId;
        address author;
        uint likes;
    }
    
    struct Comment {
        uint commentId;
        address author;
        string content;
        uint[] likesIds;
    }

     struct LikeForComment {
        uint likeId;
        address author;
        uint likes;
    }
    

    mapping (uint => PostData) public posts;
    mapping (uint => Comment) public comments;
    mapping (uint => Like) public likes;
    mapping (uint => LikeForComment) public commentlikes;

    mapping (address user => uint[] postIds) public userPosts;
    mapping (address user => uint[] likeIds) public userlikes;
    mapping (address user => uint[] commentIds) public userComments;
    
    uint256 public postCount;
    uint256 public likeCount;
    uint256 public commentLikeCount;
    uint256 public commentCount;

    function getuserComments(address _user) public view returns (uint[] memory) {
        return userComments[_user];
    }


    modifier verifyAccount {
        (address userAddress, , , , , ,) = user.getUser(msg.sender) ;
        require(userAddress == msg.sender, "User is not registered");
        _;
    }
    event postCreated(address indexed author, uint postId);
    event commentCreated(address indexed author, uint commentId);
    event likeCreated(address indexed author, uint likeId);

    event postupdated(address indexed author, uint postId);
    event commentupdated(address indexed author, uint commentId);

    event postDeleted(address indexed author, uint postId);
    event commentDeleted(address indexed author, uint commentId);
    

    function createPost(string memory _content, string memory _description) public verifyAccount returns (bool) {
        require(bytes(_content).length > 0, 'Content cannot be empty');

        PostData storage newPost = posts[postCount];

        newPost.postId = postCount;
        newPost.author = msg.sender;
        newPost.content = _content;
        newPost.description = _description;
        newPost.likesIds = new uint[](0);
        newPost.commentIds = new uint[](0);

        postCount++;

        userPosts[msg.sender].push(newPost.postId);

        emit postCreated(msg.sender, postCount);

        // create new Notification function when new post is created
        addNotification(msg.sender, user.getUserForNotif(msg.sender), 'Create new post');

        return true;
        
    }



    function getUserPostsIds(address userAddress) public view returns (uint[] memory) {
        return userPosts[userAddress];
    }
    
    function getPostLikesIds(uint postId) public view returns (uint[] memory) {
        return posts[postId].likesIds;
    }
    
    function getPostCommentIds(uint postId) public view returns (uint[] memory) {
        return posts[postId].commentIds;
    }


    // function postLikeAndComment(uint _postID) public view returns (Comment[] memory, Like[] memory){
    //     uint[] memory likeIds = posts[_postID].likesIds;
    //     uint[] memory commentIds = posts[_postID].commentIds;

    //     Comment[] memory _comments = new Comment[](commentIds.length);
    //     Like[] memory _likes = new Like[](likeIds.length);
        
    //     for (uint i = 0; i < likeIds.length; i++) {
    //         Like memory theLike = likes[likeIds[i]];
    //         _likes[i] = theLike;
    //         i++;
    //     }
        
    //     for (uint i = 0; i < commentIds.length; i++) {
    //         Comment memory theComment = comments[commentIds[i]];
    //         _comments[i] = theComment ;
    //         i++;
    //     }
    //     return (_comments, _likes);
    // }


    function updatePost(uint _postId, string memory _newContent, string memory _newdescription)  public {
        require(posts[_postId].author == msg.sender, 'only post author can update this post');
        require(bytes(_newContent).length > 0, 'Content cannot be empty');
        
        PostData storage post = posts[_postId];

        post.content = _newContent;
        post.description = _newdescription;

        emit postupdated(msg.sender, _postId);

    }

    function deletePost(uint _postId) public {
        require(_postId <= postCount, 'invalid post id');
        require(posts[_postId].author == msg.sender, 'only post author can delete this post');
        delete posts[_postId];

        // Remove postId from userPosts
        // userPostsIds is reference types so anything change will effect the original userPosts array
        uint[] storage userPostsIds = userPosts[msg.sender];
        uint postIndexToDelete;
        userPostsIds = userPosts[msg.sender];
        for (uint i = 0; i < userPostsIds.length; i++) {
            if (userPostsIds[i]==_postId) {
                postIndexToDelete = i;
            }
        }

        if (userPostsIds.length > postIndexToDelete) {
            userPostsIds[postIndexToDelete] = userPostsIds[userPostsIds.length - 1];
        }
        userPostsIds.pop();

        emit postDeleted(msg.sender, _postId);

    }
    


    function likePost(uint postId) public verifyAccount {
        require(postId <= postCount, 'invalid post id');
        for (uint i = 0; i < likeCount; i++) {
            require(likes[i].author != msg.sender, 'u can only like one time');
        }

        Like storage newLike = likes[likeCount];
        newLike.likeId = likeCount;
        newLike.author = msg.sender;
        newLike.likes ++;
        likes[likeCount] = newLike;
        posts[postId].likesIds.push(likeCount);
        userlikes[msg.sender].push(newLike.likeId);
        
        likeCount++;

        emit likeCreated(msg.sender, likeCount);
        // create new Notification function when new like is created
        addNotification(msg.sender, user.getUserForNotif(msg.sender), 'Like your post');
    }

    function unlikePost(uint _likeId, uint _postId) public {
        require(likes[_likeId].author == msg.sender, 'only like author can delete this like');
        delete likes[_likeId];
        // here i remove the likeId from the post's likedIds array attribute see line 23
        uint[] storage arr = posts[_postId].likesIds;
        uint indexToBeDeleted;
        for (uint i = 0; i < arr.length; i++) {
            if (arr[i] == _likeId) {
                indexToBeDeleted = i;
                break;
            }
        }

        // Shift elements to the left
        for (uint i = indexToBeDeleted; i < arr.length-1; i++){
            arr[i] = arr[i+1];
        }
        // Decrease array size
        arr.pop();
    }


    function createComment(uint postId, string memory  _content) public verifyAccount {
        require(postId <= postCount, 'invalid post id');
        require(bytes(_content).length > 0 , 'cant be empty');

        Comment storage newComment = comments[commentCount];

        newComment.commentId = commentCount;
        newComment.author = msg.sender;
        newComment.content = _content;
        comments[commentCount] = newComment;
        posts[postId].commentIds.push(commentCount);
        userComments[msg.sender].push(newComment.commentId);

        commentCount++;

        emit commentCreated(msg.sender, commentCount);

        // create new Notification function when new comment is created
        addNotification(msg.sender, user.getUserForNotif(msg.sender), 'Create new comment');
    }

    function updateComment(uint _commentId, string memory _newContent)  public {
        require(bytes(_newContent).length > 0, 'Comment cannot be empty');
        comments[_commentId].content = _newContent;

        emit commentupdated(msg.sender, _commentId);
    }

    function deleteComment(uint _commentId) public {
        require(comments[_commentId].author == msg.sender, 'only comment author can delete this comment');
        delete comments[_commentId];

        emit commentDeleted(msg.sender, _commentId);

    }

    function likeComment(uint _commentId) public verifyAccount {
        require(_commentId <= commentCount, 'invalid comment id');
        for (uint i = 0; i < commentLikeCount; i++) {
            require(commentlikes[i].author != msg.sender, 'u can only like one time');
        }

        LikeForComment memory newcommentLike = LikeForComment(commentLikeCount, msg.sender, 1);
        comments[_commentId].likesIds.push(commentLikeCount);
        commentlikes[commentLikeCount] = newcommentLike;
        commentLikeCount++;

        // create new Notification function when new like comment is created
        addNotification(msg.sender, user.getUserForNotif(msg.sender), 'Like your comment');
    }

    function unlikeComment( uint _likeId ) public verifyAccount {
        require(commentlikes[_likeId].author == msg.sender, 'only like author can unlike');
        delete commentlikes[_likeId];
        commentLikeCount--;

        // here i remove the likeId from the comments's likedIds array attribute see line 37
        uint[] storage arr = comments[_likeId].likesIds;
        uint indexToBeDeleted;
        for (uint i = 0; i < arr.length; i++) {
            if (arr[i] == _likeId) {
                indexToBeDeleted = i;
                break;
            }
        }

        // Shift elements to the left
        for (uint i = indexToBeDeleted; i < arr.length-1; i++){
            arr[i] = arr[i+1];
        }
        // Decrease array size
        arr.pop();
    }


        // Notifications  User Search

    struct Notification {
        string userName;
        string userImage;
        string msg;
    }

    mapping (address => Notification[]) public Notifications;

    function addNotification(address _userAddress, User.UserStruct memory _user,string memory _msg) public {
        Notifications[_userAddress].push(Notification(_user.userName, _user.avatar, _msg));
    }

    function getNotifications(address _user) public view returns (Notification[] memory   ) {
        return Notifications[_user];
    }

    // more notification managment in Follow.sol line 111 

}