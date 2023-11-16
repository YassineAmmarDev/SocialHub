const { expect }  = require('chai')
const { ethers } = require('hardhat')
const { it } = require('mocha')

describe('Test Post Contract', async()=>{

    let User, userContract
    let Post, postContract
    let accounts, owner, user1, user2, user3


    beforeEach(async()=>{
        User = await ethers.getContractFactory('User')
        userContract =  await User.deploy()

        Post = await ethers.getContractFactory('Post')
        postContract = await Post.deploy(userContract.target)

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
        
        //get post struct members
        const [post0Id, post0author, post0content, post0description, post0likesIds, post0commentIds] = await postContract.posts(0);
        // const [pos2Id, post2author, post2content, post2description, post2likesIds, post2commentIds] = await postContract.posts(0);
        // const [pos3Id, post3author, post3content, post3description, post3likesIds, post3commentIds] = await postContract.posts(0);

    })

    it('Post & User deployed', async()=>{
        console.log(`User contract deployd at :     ${userContract.target}`);
        console.log(`Post contract deployd at :     ${postContract.target}`);
    })

    it('create Posts ', async()=>{
        firstPost = await postContract.posts(0);
        expect(firstPost.author).to.equal(user1.address)
    
        // let x = await postContract.connect(user3).createPost('link/post1', 'Free Palestine 🌏')
        // expect(await x).to.be.reverted
    })

    it('update Post2 ', async()=>{
        let post = await postContract.posts(1);
        await postContract.connect(user2).updatePost(post.postId, '/link/post22', 'save erath again and again')
        expect(await post.author).to.equal(user2.address)

        post = await postContract.posts(1);
        console.log(`post 2 after update:   ${await post}`);
        expect( await post.description).to.equal('save erath again and again')
    
    })
    
    it('delete post', async()=>{
        await postContract.connect(user2).deletePost(2);
        console.log(`post2:     ${await postContract.posts(2)}`);
    })

    it('like & unlike post', async()=>{
        await postContract.connect(user2).likePost(0)
        await postContract.connect(user1).likePost(0)
        console.log(`like : ${await postContract.likes(0)}`);

        let postLikeIds = await postContract.getPostLikesIds(0)
        console.log(`post 0 like ids :   ${postLikeIds}`);
        console.log(`like of id 0 :   ${await postContract.likes(0)}`);

        await postContract.connect(user2).unlikePost(0, 0)

        postLikeIds = await postContract.getPostLikesIds(0)
        console.log(`post 0 like ids after unlike : ${await postLikeIds}`);
    })

    it(' comment post & update it', async()=>{
        await postContract.connect(user1).createComment(1, 'nice pic')
        await postContract.connect(user1).createComment(1, 'my seconed comment')
        
        let [, , comment1content, ] = await postContract.comments(0);
        console.log(`user1 comments:   ${await postContract.getuserComments(user1.address)}`);
        expect(await comment1content).to.eq('nice pic')

        //update the comment with id 0

        await postContract.updateComment(0, 'this an updated comment')
        let [, , updatedComment1content, ] = await postContract.comments(0);

        expect(updatedComment1content).to.eq('this an updated comment')

    })

    it('delete comment with id 0', async()=>{
        await postContract.connect(user1).createComment(1, 'nice pic')
        let comment1 = await postContract.comments(0);
        console.log(`before delete :   ${comment1}`);
        await postContract.connect(user1).deleteComment(0)
        let comment1delete = await postContract.comments(0);
        console.log(comment1delete);
    })

    it('like & unlike comment', async()=>{
        await postContract.connect(user1).createComment(1, 'nice pic')
        let comment1 = await postContract.comments(0);
        console.log(`before like :   ${comment1}`);

        await postContract.connect(user2).likeComment(0)
        let likesIdsArray = await comment1.likesIds;

        let [, , , comment1like] = comment1;
        console.log(`likesIds after like :   ${ await comment1like}`);

        // unlike
        await postContract.connect(user2).unlikeComment(0)

        let [, , , Comment1like] = await postContract.comments(0);
        console.log(`likesIds after like :   ${ await Comment1like}`);
    })


})