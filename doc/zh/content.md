# Content 使用说明

我们使用Relation Protocol部署好的Relation Content合约，可以实现用户身份数据的存储与查询。Relation Content合约是对Contract Standard里Content的实现。

## 构建Contract对象

Content的合约地址以及abi文件可以查询[Relation Protocol资源列表](./resource.md)获得，通过ethers构建Contract对象：

```javascript
import { ethers, providers } from 'ethers'

const getContractInstance = () => {
  // 合约地址
  const contractAddress = '0xAC0f863b66173E69b1C57Fec5e31c01c7C6959B7'
  const provider = new providers.Web3Provider(window.ethereum)
  const signer = provider.getSigner()
  const contract = new ethers.Contract(contractAddress, abi, signer)
  return contract
}
```

## 调用合约方法

1. 发布内容

用户可以将需要发布的内容上传至Arweave，内容格式为：
```json
{
  "content": {
    "body": "${The body of content}",
    "title": "${The title of content}"
  }
}
```
上传后得到的交易哈希，作为content记录至合约中

```javascript
const contract = getContractInstance()
const content = 'zX_Oa1...';
const accounts = await ethereum.request({ method: 'eth_requestAccounts' })

await (
    await contract.post(content)
).wait()
```



2. 查询用户发布的内容列表

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

3. 发布内容（代支付Gas费）

用户对数据进行签名，构建上链参数。任意地址可携带此上链参数发起交易，Gas费由发起交易的地址支付。


```javascript

const contract = getContractInstance()
const postContent = 'zX_Oa1...';
const accounts = await ethereum.request({ method: 'eth_requestAccounts' })
let name = await content.name();
let nonce = await content.nonces(accounts[0]);
let deadline = Date.parse(new Date()) / 1000 + 100;
let sign = await getSign(await buildPostParams(
        name,
        content.address.toLowerCase(),
        postContent,
        parseInt(nonce),
        deadline),
    accounts[0]);
//构建参数
let param = {
    "sig": {"v": sign.v, "r": sign.r, "s": sign.s, "deadline": deadline},
    "addr": accounts[0],
    "content": postContent
}
//实际场景中，这个方法由实际支付Gas的账户来调用
await content.connect(accounts[1]).postWithSign(param);



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


async function buildPostParams(name, contractAddress, content, nonce, deadline) {
    return {
        domain: {
            chainId: await getChainId(),
            name: name,
            verifyingContract: contractAddress,
            version: '1',
        },

        // Defining the message signing data content.
        message: {
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
                {name: 'content', type: 'string'},
                {name: 'nonce', type: 'uint256'},
                {name: 'deadline', type: 'uint256'},
            ],
        },
    };
}

```

