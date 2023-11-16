const { expect }  = require('chai')
const { ethers } = require('hardhat')
const { it } = require('mocha')

describe('Test User Contract', ()=>{

    let user, user1;
    const userContractAddress = '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512';
    const privateKeys = ['0x...', '0x...', '0x...'];
    let signers;
    beforeEach( async()=>{
        // Get the signers
        signers = privateKeys.map(key => new ethers.Wallet(key));

        // Get the contract instance
        user = await ethers.getContractAt('User', userContractAddress);
    })

    describe('test deployment', async()=>{
        it('should get the deployed contract', async()=>{
            expect(await user.test()).to.equal('hello from user contract')
        })

        console.log(await user1.target);
        
    })


describe('create Accounts', async()=>{
    it('sould create new account', async()=>{
        await user.connect(user1).createAccount('Yassine', 'yassineachraf222@gmail.com', 'yassine123', 'im trying here')
        console.log(await user.target);
        expect(await user.users(user1.address).userName).to.equal('Yassine')
    })
})
    
})
