// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./erc20tokenWithCallback.sol";
import "./erc721.sol";

// 扩展ERC20接口（带回调功能）
// interface IERC20WithCallback is IERC20 {
//     function transferWithCallback(
//         address to,
//         uint256 value,
//         bytes calldata data
//     ) external returns (bool);
// }

// Token接收者接口（用于处理回调）  erc20tokenWithCallback.sol已实现
// interface ITokenReceiver {
//     function tokensReceived(
//         address sender,
//         address receiver,
//         uint256 amount,
//         bytes calldata data
//     ) external returns (bytes4);
// }

// contract NFTMarket is ITokenReceiver {
contract NFTMarket {
    // 支付用的ERC20扩展Token合约
    // IERC20WithCallback public immutable paymentToken;
    ERC20WithCallback public immutable paymentToken;

    // 上架信息结构体
    struct Listing {
        address seller; // NFT卖家
        uint256 price; // 售价（ERC20 Token数量）
        bool isListed; // 是否在售
    }

    // 用NFT合约地址+tokenId作为唯一键，存储上架信息
    mapping(address => mapping(uint256 => Listing)) public listings;

    // 事件：记录上架和购买行为
    event NFTListed(
        address indexed nftContract,
        uint256 indexed tokenId,
        address indexed seller,
        uint256 price
    );
    event NFTPurchased(
        address indexed nftContract,
        uint256 indexed tokenId,
        address indexed buyer,
        address seller,
        uint256 price
    );

    // 回调函数选择器（验证回调有效性）
    bytes4 public constant TOKENS_RECEIVED_SELECTOR =
        bytes4(keccak256("tokensReceived(address,address,uint256,bytes)"));

    constructor(address _paymentToken) {
        require(_paymentToken != address(0), "Invalid payment token");
        // paymentToken = IERC20WithCallback(_paymentToken);
        paymentToken = ERC20WithCallback(_paymentToken);
    }

    /**
     * @dev 上架NFT
     * @param nftContract NFT合约地址
     * @param tokenId NFT的tokenId
     * @param price 售价（ERC20 Token数量）
     */
    function list(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) external {
        require(nftContract != address(0), "Invalid NFT contract");
        require(price > 0, "Price must be > 0");

        IERC721 nft = IERC721(nftContract);
        address seller = msg.sender;

        // 检查调用者是否为NFT所有者
        require(nft.ownerOf(tokenId) == seller, "Not NFT owner");
        // 检查市场是否被授权转移该NFT
        require(
            nft.isApprovedForAll(seller, address(this)) ||
                nft.getApproved(tokenId) == address(this),
            "Market not approved to transfer NFT"
        );
        // 检查是否已上架
        require(!listings[nftContract][tokenId].isListed, "NFT already listed");

        // 存储上架信息
        listings[nftContract][tokenId] = Listing({
            seller: seller,
            price: price,
            isListed: true
        });

        emit NFTListed(nftContract, tokenId, seller, price);
    }

    /**
     * @dev 普通购买NFT（直接调用购买）
     * @param nftContract NFT合约地址
     * @param tokenId NFT的tokenId
     */
    function buyNFT(address nftContract, uint256 tokenId) external {
        Listing storage listing = listings[nftContract][tokenId];
        // 检查上架状态和价格
        require(listing.isListed, "NFT not listed");
        require(listing.price > 0, "Invalid price");

        address buyer = msg.sender;
        address seller = listing.seller;
        uint256 price = listing.price;

        // 1. 转移ERC20 Token（买家 -> 卖家）
        require(
            paymentToken.transferFrom(buyer, seller, price),
            "Token transfer failed"
        );

        // 2. 转移NFT（卖家 -> 买家）
        IERC721(nftContract).safeTransferFrom(seller, buyer, tokenId);

        // 3. 标记为已售出
        listing.isListed = false;

        emit NFTPurchased(nftContract, tokenId, buyer, seller, price);
    }

    /**
     * @dev 实现ITokenReceiver接口，处理通过ERC20回调的购买
     * 当用户调用transferWithCallback向市场转账时触发
     */
    function tokensReceived(
        address sender,
        address receiver,
        uint256 amount,
        bytes calldata data
    ) external returns (bytes4) {
        // 验证调用者是支付Token合约
        require(
            msg.sender == address(paymentToken),
            "Only accept payment token"
        );
        // 验证接收者是市场自身
        require(receiver == address(this), "Invalid receiver");
        // 解析附加数据（包含NFT合约地址和tokenId）
        (address nftContract, uint256 tokenId) = abi.decode(
            data,
            (address, uint256)
        );
        require(nftContract != address(0) && tokenId > 0, "Invalid data");

        Listing storage listing = listings[nftContract][tokenId];
        // 检查上架状态和金额是否匹配
        require(listing.isListed, "NFT not listed");
        require(amount == listing.price, "Incorrect token amount");

        address buyer = sender;
        address seller = listing.seller;

        // 1. 将市场收到的Token转移给卖家
        require(
            paymentToken.transfer(seller, amount),
            "Transfer to seller failed"
        );

        // 2. 转移NFT（卖家 -> 买家）
        IERC721(nftContract).safeTransferFrom(seller, buyer, tokenId);

        // 3. 标记为已售出
        listing.isListed = false;

        emit NFTPurchased(nftContract, tokenId, buyer, seller, amount);

        // 返回选择器表示回调成功
        return TOKENS_RECEIVED_SELECTOR;
    }
}

// myNFT address 0xf5eF066dd8c24B47eEF57754b457bd32C03fa086

// token contract address 0xfbff32a4bc762c255f2364d6d0c8cc7af3621f51
// NFT market address 0xD5d641BE97F54E6e6C89aBb3a82aF088F14b077D


// token contract address 0xD5Db7d1b082fc824dB209613Bc4C9C53DdFDfF7e
// NFT market address 0x7BBD25eEe62a083F207636375f5498A00675e6e3