const { expect }  = require('chai')
const { ethers } = require('hardhat')
const { it } = require('mocha')

describe('Test Follow Contract', async()=>{

    let User, userContract
    let Post, postContract
    let Follow, followContract
    let accounts, owner, user1, user2, user3


    beforeEach(async()=>{
        User = await ethers.getContractFactory('User')
        userContract =  await User.deploy()

        Post = await ethers.getContractFactory('Post')
        postContract = await Post.deploy(userContract.target)

        Follow = await ethers.getContractFactory('Follow')
        followContract = await Follow.deploy(postContract.target, userContract.target)

        accounts = await ethers.getSigners()
        owner = accounts[0]
        user1 = accounts[1]
        user2 = accounts[2]
        user3 = accounts[3]

        // create user1 & user2 Account : 
        await userContract.connect(user1).createAccount('Yassine', 'yassine@gmail.com', 'pass321@#', 'im trying', '/test/pic/yassine')
        await userContract.connect(user2).createAccount('John', 'john@gmail.com', 'XXX999@#v', 'john the killer', '/test/pic/yassine')

        //create User1 & user2 Posts : 
        await postContract.connect(user1).createPost('link/post1', 'Free Palestine 🌏')
        await postContract.connect(user2).createPost('link/post2', 'save Earth 🌏')
        await postContract.connect(user2).createPost('link/post3', 'one day or day one !')
        await postContract.connect(user2).createPost('link/post4', 'what a movie')
        
        // user1 follow user2
        await followContract.connect(user1).followUser(user2.address)

    })

    it('Post & User & Follow deployed', async()=>{
        console.log(`User contract deployd at :     ${userContract.target}`);
        console.log(`Post contract deployd at :     ${postContract.target}`);
        console.log(`Follow contract deployd at :   ${followContract.target}`);
    })


    it('follow & unfollwo user', async()=>{
        // await followContract.connect(user1).followUser(user2.address)
        let following = await followContract.getFollowing(user1.address)
        let followers = await followContract.getFollowers(user2.address)
        expect(following).to.include(user2.address)
        expect(followers).to.include(user1.address)
    
        await followContract.connect(user1).unfollowUser(user2.address)
        following = await followContract.getFollowing(user1.address)
        // expect(following).to.not.include(user2.address)
    })

    it('test activityFeed', async()=>{
        let followingPosts = await followContract.connect(user1).activityFeed();
        console.log(`followingPosts:  ${followingPosts}`);
    })

    it('test notification', async()=>{
        // await followContract.connect(user2).followUser(user1.address)
        await postContract.connect(user2).createComment(0, 'comment 1')
        await postContract.connect(user2).createComment(0, 'comment 2')
        await postContract.connect(user2).likePost(0)
        await postContract.connect(user1).likeComment(1)

        await followContract.connect(user2).followUser(user1.address)
        let user1Notif = await postContract.getNotifications(user1);
        let user2Notif = await postContract.getNotifications(user2);
        console.log(`user1 notif:  ${user1Notif}`);
        console.log(`user2 notif:  ${user2Notif}`);
    })

    it('test userNotifications', async()=>{
        await followContract.connect(user2).followUser(user1.address)
        await followContract.AddUserNotif(user2.address)
        let user2Notif = await followContract.getUserNotifications(user2.address);
        console.log(`user2 notif:  ${user2Notif}`);
    })


})