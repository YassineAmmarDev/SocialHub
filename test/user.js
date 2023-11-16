const { expect }  = require('chai')
const { ethers } = require('hardhat')
const { it } = require('mocha')

describe('Test User Contract', async()=>{

    let User, userContract
    let accounts, owner, user1, user2


    beforeEach(async()=>{
        User = await ethers.getContractFactory('User')
        userContract =  await User.deploy()

        accounts = await ethers.getSigners()
        owner = accounts[0]
        user1 = accounts[1]
        user2 = accounts[2]

        // create user1 account : 
        await userContract.connect(user1).createAccount('Yassine', 'yassine@gmail.com', 'pass321@#', 'im trying', 'pics/yassine')
    })

    it('should User be deployed', async()=>{
        expect(await userContract.Owner()).to.eq(owner.address)
    })

    it('should create new user account', async()=>{
        await userContract.connect(user2).createAccount('Achraf', 'Achraf@gmail.com', 'passAchraf', 'im Achraf', 'pics/Achraf')
        // expect(await userContract.users(user1.address).userName).to.eq('Yassine')
        const userDetails = await userContract.getUser(user2.address);
        const userEmail = await userContract.addressToEmail(user2.address);
        console.log(`user address :     ${userDetails[0]}`);
        console.log(`user name :     ${userDetails[1]}`);
        console.log(`user email :     ${userEmail}`);   
        console.log(`user password :     ${userDetails[3]}`);
        console.log(`user bio :     ${userDetails[4]}`);
        console.log(`user timestamp :     ${userDetails[5]}`);
     
    })
    it('login', async()=>{
        await userContract.connect(user1).login('Yassine', 'pass321@#')
    })

    it('updateName', async()=>{
        await userContract.connect(user1).updateName('jhon')
        let userDetails = await userContract.getUser(user1.address);

        console.log(`user name :     ${userDetails[1]}`);
    })

    it('updatePassword', async()=>{
        await userContract.connect(user1).updatePassword('jhon99988')
        let userDetails = await userContract.getUser(user1.address);

        console.log(`user password :     ${userDetails[3]}`);
    })

    it('updateBio', async()=>{
        await userContract.connect(user1).updateBio('Time is precious, waste it wisely.')
        let userDetails = await userContract.getUser(user1.address);

        console.log(`user Bio :     ${userDetails[4]}`);
    })


    it('updateEmail', async()=>{
        await userContract.connect(user1).updateEmail('jhon@gmail.com')
        let userDetails = await userContract.getUser(user1.address);

        console.log(`user email :     ${userDetails[2]}`);
    })

    it('delete account', async()=>{
        await userContract.connect(user1).deleteAccount()
        let userDetails = await userContract.getUser(user1.address);

        console.log(`user name :     ${userDetails[1]}`);
    })


    it('search user', async()=>{
        await userContract.connect(user1).createAccount('ahmed', 'ahmed@gmail.com', 'passAhmed@999', 'im ahmed', 'pics/ahmed')
        await userContract.connect(user2).createAccount('hamada', 'hamada@gmail.com', 'passAhmed@999', 'im ahmed', 'pics/ahmed')

        let search = await userContract.searchUser('hamada')
        console.log(`user search :     ${search}`);
    })
})

