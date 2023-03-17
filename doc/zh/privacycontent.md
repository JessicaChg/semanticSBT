# PrivacyContent 使用说明

我们使用Relation Protocol部署好的Relation PrivacyContent合约，可以实现用户身份数据的存储与查询。Relation PrivacyContent合约是对Contract Standard里PrivacyContent的实现。

## 构建Contract对象

PrivacyContent的合约地址以及abi文件可以查询[Relation Protocol资源列表](./resource.md)获得，通过ethers构建Contract对象：

```javascript
import { ethers, providers } from 'ethers'

const getContractInstance = () => {
  // 合约地址
  const contractAddress = '0x6A22794A1e2aBdEC057a6dc24A6BFB53F9518016'
  const provider = new providers.Web3Provider(window.ethereum)
  const signer = provider.getSigner()
  const contract = new ethers.Contract(contractAddress, abi, signer)
  return contract
}
```

## 调用合约方法

1. 预生成token

用户需要预生成token,在调用post方法时传入预生成的tokenId。当用户调用post方法，会消耗掉预生成的token。

```javascript
const contract = getContractInstance()
await (
    await contract.prepareToken()
).wait()
```

2. 查询用户预生成的token


```javascript
const contract = getContractInstance()
const accounts = await ethereum.request({ method: 'eth_requestAccounts' })
const tokenId = await contract.ownedPrepareToken(accounts[0]);
```


3. 发布内容

用户需要通过[Lit Protocol](https://developer.litprotocol.com/sdk/explanation/encryption/#encrypting)进行数据加密，然后将需要发布的内容上传至Arweave，内容格式为：
```json

"encryptionBy": "lit-protocol",
"accessCondition": [
    {
    "contractAddress": "${The contract address of Semantic SBT}",
    "standardContractType": "ERC721",
    "chain": "polygon",
    "method": "isViewerOf",
    "parameters": [
    ":userAddress",
    "${The tokenId}"
    ],
    "returnValueTest": {
    "comparator": "=",
    "value": true
    }
    }
],
"encryptedSymmetricKey": "${A hex string that LIT will use to decrypt your content as long as you satisfy the conditions}",
// encrypted content
"encryptedObject": "${The encrypted content}"
}
```
上传后得到的交易哈希，作为content记录至合约中

```javascript
const contract = getContractInstance()
const content = 'zX_Oa1...';
const accounts = await ethereum.request({ method: 'eth_requestAccounts' })
const tokenId = await contract.ownedPrepareToken(accounts[0]);

await (
    await contract.post(tokenId,content)
).wait()
```

3. 将内容分享给我的follower

用户可以将上传的隐私数据分享给follower

```javascript
const myFollowContractAddress = '0x000...';
const tokenId = '1';
const contract = getContractInstance()

await (
    await contract.shareToFollow(addr,tokenId,myFollowContractAddress)
).wait()
```


4. 将内容分享给指定的Dao

用户可以将上传的隐私数据分享给指定的Dao，那么所有的Dao成员将可以通过Lit Protocol解密出隐私数据

```javascript
const myDaoContractAddress = '0x000...';
const tokenId = '1';
const contract = getContractInstance()

await (
    await contract.shareToDao(tokenId,myDaoContractAddress)
).wait()
```


5. 查询用户发布的内容列表

遍历出用户的token列表，即可得到其发布的内容列表

```javascript
const addr = '0x000...';
const contract = getContractInstance()

const balance = await contract.balanceOf(addr);
var contentList = [];
for(var i = 0; i < balance;i++){
    const tokenId = await contract.tokenOfOwnerByIndex(addr,i);
    const content = await contract.contentOf(tokenId);
    contentList.push(content);
}
```

6. 预生成token(代付Gas费)

用户对数据进行签名，构建上链参数。任意地址可携带此上链参数发起交易，Gas费由发起交易的地址支付。

```javascript
const name = await privacyContent.name();
const nonce = await privacyContent.nonces(owner.address);
const deadline = Date.parse(new Date()) / 1000 + 100;
const sign = await getSign(buildPrepareParams(name, privacyContent.address.toLowerCase(), parseInt(nonce), deadline), owner.address);
var param = {"sig": {"v": sign.v, "r": sign.r, "s": sign.s, "deadline": deadline}, "addr": owner.address}
//实际场景中，这个方法由实际支付Gas的账户来调用
await privacyContent.connect(addr1).prepareTokenWithSign(param);

async function getSign(msgParams, signerAddress) {
    const params = [signerAddress, msgParams];
    const trace = await hre.network.provider.send(
        "eth_signTypedData_v4", params);
    return Bytes.splitSignature(trace);
}

async function getChainId() {
    return await ethereum.request({
        method: 'eth_chainId',
      });
}

function buildPrepareParams(name, contractAddress, nonce, deadline) {
    return {
        domain: {
            chainId: getChainId(),
            name: name,
            verifyingContract: contractAddress,
            version: '1',
        },

        // Defining the message signing data content.
        message: {
            nonce: nonce,
            deadline: deadline,
        },
        // Refers to the keys of the *types* object below.
        primaryType: 'PrepareTokenWithSign',
        types: {
            EIP712Domain: [
                {name: 'name', type: 'string'},
                {name: 'version', type: 'string'},
                {name: 'chainId', type: 'uint256'},
                {name: 'verifyingContract', type: 'address'},
            ],
            PrepareTokenWithSign: [
                {name: 'nonce', type: 'uint256'},
                {name: 'deadline', type: 'uint256'},
            ],
        },
    };
}
```

6. 发布内容(代付Gas费)

用户上传内容到Arweave，对数据进行签名，构建上链参数。任意地址可携带此上链参数发起交易，Gas费由发起交易的地址支付。

```javascript
const content = 'zX_Oa1...';
const accounts = await ethereum.request({ method: 'eth_requestAccounts' })

let name = await privacyContent.name();
let nonce = await privacyContent.nonces(accounts[0]);
let deadline = Date.parse(new Date()) / 1000 + 100;
const tokenId = await privacyContent.ownedPrepareToken(accounts[0]);
let sign = await getSign(buildPostParams(
        name,
        privacyContent.address.toLowerCase(),
        parseInt(tokenId),
        content,
        parseInt(nonce),
        deadline),
    accounts[0]);
let param = {
    "sig": {"v": sign.v, "r": sign.r, "s": sign.s, "deadline": deadline},
    "addr": accounts[0],
    "tokenId": parseInt(tokenId),
    "content": content
}
//实际场景中，这个方法由实际支付Gas的账户来调用
await privacyContent.connect(addr1).postWithSign(param);


async function getSign(msgParams, signerAddress) {
    const params = [signerAddress, msgParams];
    const trace = await hre.network.provider.send(
        "eth_signTypedData_v4", params);
    return Bytes.splitSignature(trace);
}

async function getChainId() {
    return await ethereum.request({
        method: 'eth_chainId',
      });
}

function buildPostParams(name, contractAddress, tokenId, content, nonce, deadline) {
    return {
        domain: {
            chainId: getChainId(),
            name: name,
            verifyingContract: contractAddress,
            version: '1',
        },

        // Defining the message signing data content.
        message: {
            tokenId: tokenId,
            content: content,
            nonce: nonce,
            deadline: deadline,
        },
        // Refers to the keys of the *types* object below.
        primaryType: 'PostWithSign',
        types: {
            EIP712Domain: [
                {name: 'name', type: 'string'},
                {name: 'version', type: 'string'},
                {name: 'chainId', type: 'uint256'},
                {name: 'verifyingContract', type: 'address'},
            ],
            PostWithSign: [
                {name: 'tokenId', type: 'uint256'},
                {name: 'content', type: 'string'},
                {name: 'nonce', type: 'uint256'},
                {name: 'deadline', type: 'uint256'},
            ],
        },
    };
}
```

7. 将内容分享给我的follower(代支付Gas费)

用户对需要分享的tokenId以及Follow合约地址进行签名，构建上链参数。任意地址可携带此上链参数发起交易，Gas费由发起交易的地址支付。

```javascript
const privacyContent = '';
const followContractAddress = '0x0001...';
const tokenId = '1'
const accounts = await ethereum.request({ method: 'eth_requestAccounts' })

const privacyContent = getContractInstance()
 let name = await privacyContent.name();
let nonce = await privacyContent.nonces(owner.address);
let deadline = Date.parse(new Date()) / 1000 + 100;
let sign = await getSign(buildShareToFollowerParams(
        name,
        privacyContent.address.toLowerCase(),
        tokenId,
        followContractAddress,
        parseInt(nonce),
        deadline),
    accounts[0]);
param = {
    "sig": {"v": sign.v, "r": sign.r, "s": sign.s, "deadline": deadline},
    "addr": accounts[0],
    "tokenId": parseInt(tokenId),
    "followContractAddress": followContractAddress
}
//实际场景中，这个方法由实际支付Gas的账户来调用
await privacyContent.connect(addr1).shareToFollowerWithSign(param);


async function getSign(msgParams, signerAddress) {
    const params = [signerAddress, msgParams];
    const trace = await hre.network.provider.send(
        "eth_signTypedData_v4", params);
    return Bytes.splitSignature(trace);
}

async function getChainId() {
    return await ethereum.request({
        method: 'eth_chainId',
      });
}

function buildShareToFollowerParams(name, contractAddress, tokenId, followContractAddress, nonce, deadline) {
    return {
        domain: {
            chainId: getChainId(),
            name: name,
            verifyingContract: contractAddress,
            version: '1',
        },

        // Defining the message signing data content.
        message: {
            tokenId: tokenId,
            followContractAddress: followContractAddress,
            nonce: nonce,
            deadline: deadline,
        },
        // Refers to the keys of the *types* object below.
        primaryType: 'ShareToFollowerWithSign',
        types: {
            EIP712Domain: [
                {name: 'name', type: 'string'},
                {name: 'version', type: 'string'},
                {name: 'chainId', type: 'uint256'},
                {name: 'verifyingContract', type: 'address'},
            ],
            ShareToFollowerWithSign: [
                {name: 'tokenId', type: 'uint256'},
                {name: 'followContractAddress', type: 'address'},
                {name: 'nonce', type: 'uint256'},
                {name: 'deadline', type: 'uint256'},
            ],
        },
    };
}
```


8. 将内容分享给指定的dao(代支付Gas费)

用户对需要分享的tokenId以及dao合约地址进行签名，构建上链参数。任意地址可携带此上链参数发起交易，Gas费由发起交易的地址支付。

```javascript
const privacyContent = '';
const daoContractAddress = '0x0001...';
const tokenId = '1'
const accounts = await ethereum.request({ method: 'eth_requestAccounts' })

const privacyContent = getContractInstance()
let name = await privacyContent.name();
let nonce = await privacyContent.nonces(owner.address);
let deadline = Date.parse(new Date()) / 1000 + 100;
let sign = await getSign(buildShareToDaoParams(
        name,
        privacyContent.address.toLowerCase(),
        tokenId,
        daoContractAddress,
        parseInt(nonce),
        deadline),
    accounts[0]);
param = {
    "sig": {"v": sign.v, "r": sign.r, "s": sign.s, "deadline": deadline},
    "addr": accounts[0],
    "tokenId": parseInt(tokenId),
    "followContractAddress": followContractAddress
}
//实际场景中，这个方法由实际支付Gas的账户来调用
await privacyContent.connect(addr1).shareToDaoWithSign(param);


async function getSign(msgParams, signerAddress) {
    const params = [signerAddress, msgParams];
    const trace = await hre.network.provider.send(
        "eth_signTypedData_v4", params);
    return Bytes.splitSignature(trace);
}

async function getChainId() {
    return await ethereum.request({
        method: 'eth_chainId',
      });
}

function buildShareToDaoParams(name, contractAddress, tokenId, daoContractAddress, nonce, deadline) {
    return {
        domain: {
            chainId: getChainId(),
            name: name,
            verifyingContract: contractAddress,
            version: '1',
        },

        // Defining the message signing data content.
        message: {
            tokenId: tokenId,
            daoContractAddress: daoContractAddress,
            nonce: nonce,
            deadline: deadline,
        },
        // Refers to the keys of the *types* object below.
        primaryType: 'ShareToDaoWithSign',
        types: {
            EIP712Domain: [
                {name: 'name', type: 'string'},
                {name: 'version', type: 'string'},
                {name: 'chainId', type: 'uint256'},
                {name: 'verifyingContract', type: 'address'},
            ],
            ShareToDaoWithSign: [
                {name: 'tokenId', type: 'uint256'},
                {name: 'daoContractAddress', type: 'address'},
                {name: 'nonce', type: 'uint256'},
                {name: 'deadline', type: 'uint256'},
            ],
        },
    };
}
```

