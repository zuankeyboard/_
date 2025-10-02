// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import "../practice/myToken/NFTmarket.sol";
// import "../practice/myToken/erc20tokenWithCallback.sol";
// import "../practice/myToken/erc721.sol";

// 简化的测试用 NFT 合约
contract TestNFT {
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function mint(address to, uint256 tokenId) external {
        require(to != address(0), "ERC721: mint to the zero address");
        require(_owners[tokenId] == address(0), "ERC721: token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function approve(address to, uint256 tokenId) external {
        address owner = _owners[tokenId];
        require(to != owner, "ERC721: approval to current owner");
        require(
            msg.sender == owner || _operatorApprovals[owner][msg.sender],
            "ERC721: approve caller is not owner nor approved for all"
        );

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) external view returns (address) {
        require(_owners[tokenId] != address(0), "ERC721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) external {
        require(operator != msg.sender, "ERC721: approve to caller");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) external view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) external {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_owners[tokenId] != address(0), "ERC721: operator query for nonexistent token");
        address owner = _owners[tokenId];
        return (spender == owner || _tokenApprovals[tokenId] == spender || _operatorApprovals[owner][spender]);
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        require(_owners[tokenId] == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        // Clear approvals from the previous owner
        _tokenApprovals[tokenId] = address(0);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }
}

contract NFTMarketTest is Test {
    NFTMarket public market;
    ERC20WithCallback public token;
    TestNFT public nft;

    address public seller = makeAddr("seller");
    address public buyer = makeAddr("buyer");
    address public other = makeAddr("other");

    uint256 public constant INITIAL_BALANCE = 10000 ether;

    function setUp() public {
        // 部署 ERC20 代币
        token = new ERC20WithCallback();

        // 部署 NFT 市场
        market = new NFTMarket(address(token));

        // 部署测试 NFT
        nft = new TestNFT();

        // 给用户分配代币 (从部署者转移)
        token.transfer(seller, INITIAL_BALANCE);
        token.transfer(buyer, INITIAL_BALANCE);
        token.transfer(other, INITIAL_BALANCE);

        // 铸造 NFT 给卖家
        nft.mint(seller, 1);
        nft.mint(seller, 2);
        nft.mint(seller, 3);

        // 授权市场合约转移 NFT
        vm.prank(seller);
        nft.setApprovalForAll(address(market), true);

        // 授权市场合约转移代币
        vm.prank(buyer);
        token.approve(address(market), type(uint256).max);

        vm.prank(other);
        token.approve(address(market), type(uint256).max);
    }

    // ========== NFT 上架测试 ==========

    function testListNFTSuccess() public {
        vm.prank(seller);
        vm.expectEmit(true, true, true, true);
        emit NFTMarket.NFTListed(address(nft), 1, seller, 100 ether);
        market.list(address(nft), 1, 100 ether);

        (address listedSeller, uint256 price, bool isListed) = market.listings(address(nft), 1);
        assertEq(listedSeller, seller);
        assertEq(price, 100 ether);
        assertTrue(isListed);
    }

    function testListNFTFailNotOwner() public {
        vm.prank(buyer);
        vm.expectRevert("Not NFT owner");
        market.list(address(nft), 1, 100 ether);
    }

    function testListNFTFailNotApproved() public {
        // 撤销授权
        vm.prank(seller);
        nft.setApprovalForAll(address(market), false);

        vm.prank(seller);
        vm.expectRevert("Market not approved to transfer NFT");
        market.list(address(nft), 1, 100 ether);
    }

    function testListNFTFailZeroPrice() public {
        vm.prank(seller);
        vm.expectRevert("Price must be > 0");
        market.list(address(nft), 1, 0);
    }

    function testListNFTFailAlreadyListed() public {
        vm.prank(seller);
        market.list(address(nft), 1, 100 ether);

        vm.prank(seller);
        vm.expectRevert("NFT already listed");
        market.list(address(nft), 1, 200 ether);
    }

    function testListNFTFailInvalidContract() public {
        vm.prank(seller);
        vm.expectRevert("Invalid NFT contract");
        market.list(address(0), 1, 100 ether);
    }

    // ========== NFT 购买测试 ==========

    function testBuyNFTSuccess() public {
        // 上架 NFT
        vm.prank(seller);
        market.list(address(nft), 1, 100 ether);

        uint256 sellerBalanceBefore = token.balanceOf(seller);
        uint256 buyerBalanceBefore = token.balanceOf(buyer);

        // 购买 NFT
        vm.prank(buyer);
        vm.expectEmit(true, true, true, true);
        emit NFTMarket.NFTPurchased(address(nft), 1, buyer, seller, 100 ether);
        market.buyNFT(address(nft), 1);

        // 检查 NFT 所有权转移
        assertEq(nft.ownerOf(1), buyer);

        // 检查代币转移
        assertEq(token.balanceOf(seller), sellerBalanceBefore + 100 ether);
        assertEq(token.balanceOf(buyer), buyerBalanceBefore - 100 ether);

        // 检查上架状态
        (,, bool isListed) = market.listings(address(nft), 1);
        assertFalse(isListed);
    }

    function testBuyNFTFailNotListed() public {
        vm.prank(buyer);
        vm.expectRevert("NFT not listed");
        market.buyNFT(address(nft), 1);
    }

    function testBuyNFTFailSelfPurchase() public {
        // 上架NFT
        vm.prank(seller);
        market.list(address(nft), 1, 100 ether);

        // 卖家尝试购买自己的NFT（应该失败）
        vm.prank(seller);
        vm.expectRevert("Cannot buy your own NFT");
        market.buyNFT(address(nft), 1);
    }

    function testBuyNFTFailAlreadySold() public {
        // 上架并购买 NFT
        vm.prank(seller);
        market.list(address(nft), 1, 100 ether);

        vm.prank(buyer);
        market.buyNFT(address(nft), 1);

        // 尝试再次购买
        vm.prank(other);
        vm.expectRevert("NFT not listed");
        market.buyNFT(address(nft), 1);
    }

    function testBuyNFTFailInsufficientTokens() public {
        // 上架 NFT
        vm.prank(seller);
        market.list(address(nft), 1, INITIAL_BALANCE + 1);

        vm.prank(buyer);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        market.buyNFT(address(nft), 1);
    }

    function testBuyNFTFailInsufficientAllowance() public {
        // 上架 NFT
        vm.prank(seller);
        market.list(address(nft), 1, 100 ether);

        // 减少授权额度
        vm.prank(buyer);
        token.approve(address(market), 50 ether);

        vm.prank(buyer);
        vm.expectRevert("ERC20: transfer amount exceeds allowance");
        market.buyNFT(address(nft), 1);
    }

    // ========== 回调购买测试 ==========

    function testBuyNFTWithCallback() public {
        // 上架 NFT
        vm.prank(seller);
        market.list(address(nft), 1, 100 ether);

        uint256 sellerBalanceBefore = token.balanceOf(seller);
        uint256 buyerBalanceBefore = token.balanceOf(buyer);

        // 通过回调购买
        bytes memory data = abi.encode(address(nft), uint256(1));

        vm.prank(buyer);
        vm.expectEmit(true, true, true, true);
        emit NFTMarket.NFTPurchased(address(nft), 1, buyer, seller, 100 ether);
        token.transferWithCallback(address(market), 100 ether, data);

        // 检查结果
        assertEq(nft.ownerOf(1), buyer);
        assertEq(token.balanceOf(seller), sellerBalanceBefore + 100 ether);
        assertEq(token.balanceOf(buyer), buyerBalanceBefore - 100 ether);

        (,, bool isListed) = market.listings(address(nft), 1);
        assertFalse(isListed);
    }

    function testBuyNFTWithCallbackFailSelfPurchase() public {
        // 上架 NFT
        vm.prank(seller);
        market.list(address(nft), 1, 100 ether);

        // 卖家尝试通过回调购买自己的NFT（应该失败）
        bytes memory data = abi.encode(address(nft), uint256(1));

        vm.prank(seller);
        vm.expectRevert("Cannot buy your own NFT");
        token.transferWithCallback(address(market), 100 ether, data);
    }

    // ========== 模糊测试 ==========

    function testFuzzListAndBuyNFT(uint256 price, address randomBuyer) public {
        // 限制价格范围和买家地址
        price = bound(price, 0.01 ether, 10000 ether);
        vm.assume(randomBuyer != address(0) && randomBuyer != seller);
        vm.assume(randomBuyer.code.length == 0); // 确保不是合约地址

        // 给随机买家分配代币和授权
        token.transfer(randomBuyer, price * 2);
        vm.prank(randomBuyer);
        token.approve(address(market), type(uint256).max);

        // 上架 NFT
        vm.prank(seller);
        market.list(address(nft), 1, price);

        // 购买 NFT
        vm.prank(randomBuyer);
        market.buyNFT(address(nft), 1);

        // 验证结果
        assertEq(nft.ownerOf(1), randomBuyer);
        (,, bool isListed) = market.listings(address(nft), 1);
        assertFalse(isListed);
    }

    // ========== 不变量测试 ==========

    function testInvariantMarketNeverHoldsTokens() public {
        // 上架多个 NFT
        vm.startPrank(seller);
        market.list(address(nft), 1, 100 ether);
        market.list(address(nft), 2, 200 ether);
        market.list(address(nft), 3, 300 ether);
        vm.stopPrank();

        // 购买一些 NFT
        vm.prank(buyer);
        market.buyNFT(address(nft), 1);

        vm.prank(other);
        market.buyNFT(address(nft), 2);

        // 市场合约不应该持有任何代币
        assertEq(token.balanceOf(address(market)), 0);
    }

    function testInvariantMarketNeverHoldsTokensWithCallback() public {
        // 上架 NFT
        vm.prank(seller);
        market.list(address(nft), 1, 100 ether);

        // 通过回调购买
        bytes memory data = abi.encode(address(nft), uint256(1));
        vm.prank(buyer);
        token.transferWithCallback(address(market), 100 ether, data);

        // 市场合约不应该持有任何代币
        assertEq(token.balanceOf(address(market)), 0);
    }

    // ========== 边界测试 ==========

    function testListNFTWithMinPrice() public {
        vm.prank(seller);
        market.list(address(nft), 1, 1 wei);

        (, uint256 price, bool isListed) = market.listings(address(nft), 1);
        assertEq(price, 1 wei);
        assertTrue(isListed);
    }

    function testListNFTWithMaxPrice() public {
        vm.prank(seller);
        market.list(address(nft), 1, type(uint256).max);

        (, uint256 price, bool isListed) = market.listings(address(nft), 1);
        assertEq(price, type(uint256).max);
        assertTrue(isListed);
    }

    function testListMultipleNFTs() public {
        vm.startPrank(seller);

        market.list(address(nft), 1, 100 ether);
        market.list(address(nft), 2, 200 ether);
        market.list(address(nft), 3, 300 ether);

        vm.stopPrank();

        // 检查所有上架信息
        (, uint256 price1, bool isListed1) = market.listings(address(nft), 1);
        (, uint256 price2, bool isListed2) = market.listings(address(nft), 2);
        (, uint256 price3, bool isListed3) = market.listings(address(nft), 3);

        assertEq(price1, 100 ether);
        assertEq(price2, 200 ether);
        assertEq(price3, 300 ether);
        assertTrue(isListed1);
        assertTrue(isListed2);
        assertTrue(isListed3);
    }
}
