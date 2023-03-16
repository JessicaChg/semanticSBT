# Follow 使用说明

我们使用Relation Protocol部署好的FollowRegister合约，可以实现为用户创建Follow合约。Follow合约可以进行关注与取消关注。FollowRegister与Follow合约均实现了Contract Standard定义的合约接口。

## 构建Contract对象

FollowRegister的合约地址以及abi文件可以查询[Relation Protocol资源列表](doc/zh/resource.md)获得，Follow合约的地址需要通过FollowRegister查到，每个地址拥有自己的Follow合约。
通过ethers构建FollowRegisterContract对象：

```javascript
import { ethers, providers } from 'ethers'

const getFollowRegisterContractInstance = () => {
  // FollowRegister合约地址
  const contractAddress = '0xef865Ed50447c253EFb9Ac9a9deDe3b4CBaaA9cE'
  const provider = new providers.Web3Provider(window.ethereum)
  const signer = provider.getSigner()
  const contract = new ethers.Contract(contractAddress, followRegisterAbi, signer)
  return contract
}
```

## 调用合约方法

### FollowRegister

1. 部署Follow合约


```javascript
const followRegisterContract = getFollowRegisterContractInstance()
const accounts = await ethereum.request({ method: 'eth_requestAccounts' })
await (
    await followRegisterContract.deployFollowContract(accounts[0])
).wait()
```

2. 查询用户的Follow合约，并构建Contract对象

用户部署过Follow合约后，可以通过地址查询到Follow合约的地址

```javascript
const addr = '0x000...';
const followRegisterContract = getFollowRegisterContractInstance()
const followContractAddress = await followRegisterContract.ownedFollowContract(addr);

const getFollowContractInstance = (followContractAddress) => {
    const provider = new providers.Web3Provider(window.ethereum)
    const signer = provider.getSigner()
    const contract = new ethers.Contract(followContractAddress, followAbi, signer)
    return contract
}
```

### Follow

1. 关注

用户关注某个地址，需要调用对方的Follow合约   

```javascript
const addr = '0x000...';
const followRegisterContract = getFollowRegisterContractInstance()
const followContractAddress = await followRegisterContract.ownedFollowContract(addr);
const followContract = getFollowContractInstance(followContractAddress

await (
    await followContract.follow()
).wait()
```


2. 取消关注


```javascript
const addr = '0x000...';
const followRegisterContract = getFollowRegisterContractInstance()
const followContractAddress = await followRegisterContract.ownedFollowContract(addr);
const followContract = getFollowContractInstance(followContractAddress)

await (
    await followContract.unfollow()
).wait()
```


3. 用户的粉丝列表

遍历用户Follow合约的token owner，即可得到他的粉丝列表

```javascript
const addr = '0x000...';
const followRegisterContract = getFollowRegisterContractInstance()
const followContractAddress = await followRegisterContract.ownedFollowContract(addr);
const followContract = getFollowContractInstance(followContractAddress)

const numOfFollower = await followContract.totalSupply();
var followerList = [];
for(var i = 0; i < numOfFollower;i++){
    const tokenId = await followContract.tokenByIndex(i);
    const follower = await followContract.ownerOf(tokenId);
    followerList.push(follower);
}
```


