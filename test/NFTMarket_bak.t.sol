// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import "../practice/myToken/NFTmarket.sol";
import "../practice/myToken/erc20tokenWithCallback.sol";
import "../practice/myToken/erc721.sol";

/**
 * @title NFTMarket 综合测试套件 - 完整版本
 * @dev 这是最初的完整版本，包含详细的测试用例和完整的合约实现
 * @author AI Assistant
 * @notice 包含20个完整的测试用例，覆盖所有功能和边界情况
 */
contract NFTMarketTestBak is Test {
    // ========== 合约实例 ==========
    NFTMarket public market;
    ERC20WithCallback public token;
    TestNFTComplete public nft;

    // ========== 测试账户 ==========
    address public deployer;
    address public seller;
    address public buyer;
    address public randomUser;

    // ========== 常量定义 ==========
    uint256 public constant INITIAL_TOKEN_SUPPLY = 1000000 ether;
    uint256 public constant DEFAULT_NFT_PRICE = 100 ether;
    uint256 public constant MIN_PRICE = 1 wei;
    uint256 public constant MAX_PRICE = type(uint256).max;

    // ========== 事件定义 ==========
    event NFTListed(address indexed nftContract, uint256 indexed tokenId, address indexed seller, uint256 price);

    event NFTPurchased(
        address indexed nftContract, uint256 indexed tokenId, address indexed buyer, address seller, uint256 price
    );

    /**
     * @dev 测试设置函数 - 初始化所有合约和账户
     */
    function setUp() public {
        // 设置测试账户
        deployer = address(this);
        seller = makeAddr("seller");
        buyer = makeAddr("buyer");
        randomUser = makeAddr("randomUser");

        // 部署合约
        token = new ERC20WithCallback();
        market = new NFTMarket(address(token));
        nft = new TestNFTComplete("Test NFT", "TNFT");

        // 为测试账户分配代币
        _distributeTokens();

        // 为测试账户铸造NFT
        _mintTestNFTs();

        // 设置初始授权
        _setupInitialApprovals();

        // 验证初始状态
        _verifyInitialState();
    }

    /**
     * @dev 分配测试代币给各个账户
     */
    function _distributeTokens() internal {
        // 给买家分配足够的代币
        vm.deal(buyer, 1000 ether);
        token.transfer(buyer, 500000 ether);

        // 给卖家分配一些代币
        token.transfer(seller, 100000 ether);

        // 给随机用户分配代币
        token.transfer(randomUser, 50000 ether);

        // 验证代币分配
        assertEq(token.balanceOf(buyer), 500000 ether, "Buyer token balance incorrect");
        assertEq(token.balanceOf(seller), 100000 ether, "Seller token balance incorrect");
        assertEq(token.balanceOf(randomUser), 50000 ether, "Random user token balance incorrect");
    }

    /**
     * @dev 为测试账户铸造NFT
     */
    function _mintTestNFTs() internal {
        // 为卖家铸造多个NFT
        for (uint256 i = 1; i <= 10; i++) {
            nft.mint(seller, i);
        }

        // 为买家铸造一个NFT（用于测试自购买）
        nft.mint(buyer, 11);

        // 验证NFT所有权
        assertEq(nft.ownerOf(1), seller, "NFT 1 ownership incorrect");
        assertEq(nft.ownerOf(11), buyer, "NFT 11 ownership incorrect");
    }

    /**
     * @dev 设置初始授权
     */
    function _setupInitialApprovals() internal {
        // 买家授权市场合约使用代币
        vm.prank(buyer);
        token.approve(address(market), type(uint256).max);

        // 卖家授权市场合约转移NFT
        vm.prank(seller);
        nft.setApprovalForAll(address(market), true);

        // 验证授权
        assertEq(token.allowance(buyer, address(market)), type(uint256).max, "Token allowance not set");
        assertTrue(nft.isApprovedForAll(seller, address(market)), "NFT approval not set");
    }

    /**
     * @dev 验证初始状态
     */
    function _verifyInitialState() internal {
        // 验证市场合约初始状态
        assertEq(address(market.paymentToken()), address(token), "Payment token not set correctly");

        // 验证没有NFT被上架
        (,, bool isListed) = market.listings(address(nft), 1);
        assertFalse(isListed, "NFT should not be listed initially");
    }

    // ========== NFT 上架功能测试 ==========

    /**
     * @dev 测试成功上架NFT
     */
    function testListNFTSuccess() public {
        uint256 tokenId = 1;
        uint256 price = DEFAULT_NFT_PRICE;

        // 记录上架前状态
        (,, bool isListedBefore) = market.listings(address(nft), tokenId);
        assertFalse(isListedBefore, "NFT should not be listed before");

        // 执行上架操作
        vm.prank(seller);
        vm.expectEmit(true, true, true, true);
        emit NFTListed(address(nft), tokenId, seller, price);
        market.list(address(nft), tokenId, price);

        // 验证上架后状态
        (address listedSeller, uint256 listedPrice, bool isListed) = market.listings(address(nft), tokenId);
        assertEq(listedSeller, seller, "Seller address incorrect");
        assertEq(listedPrice, price, "Listed price incorrect");
        assertTrue(isListed, "NFT should be listed");

        // 验证NFT仍在卖家手中
        assertEq(nft.ownerOf(tokenId), seller, "NFT ownership should not change during listing");
    }

    /**
     * @dev 测试非所有者尝试上架NFT失败
     */
    function testListNFTFailNotOwner() public {
        uint256 tokenId = 1;
        uint256 price = DEFAULT_NFT_PRICE;

        // 非所有者尝试上架
        vm.prank(buyer);
        vm.expectRevert("Not NFT owner");
        market.list(address(nft), tokenId, price);

        // 验证NFT未被上架
        (,, bool isListed) = market.listings(address(nft), tokenId);
        assertFalse(isListed, "NFT should not be listed");
    }

    /**
     * @dev 测试未授权情况下上架NFT失败
     */
    function testListNFTFailNotApproved() public {
        uint256 tokenId = 1;
        uint256 price = DEFAULT_NFT_PRICE;

        // 撤销授权
        vm.prank(seller);
        nft.setApprovalForAll(address(market), false);

        // 尝试上架
        vm.prank(seller);
        vm.expectRevert("Market not approved to transfer NFT");
        market.list(address(nft), tokenId, price);

        // 验证NFT未被上架
        (,, bool isListed) = market.listings(address(nft), tokenId);
        assertFalse(isListed, "NFT should not be listed");
    }

    /**
     * @dev 测试价格为0时上架失败
     */
    function testListNFTFailZeroPrice() public {
        uint256 tokenId = 1;
        uint256 price = 0;

        vm.prank(seller);
        vm.expectRevert("Price must be > 0");
        market.list(address(nft), tokenId, price);

        // 验证NFT未被上架
        (,, bool isListed) = market.listings(address(nft), tokenId);
        assertFalse(isListed, "NFT should not be listed");
    }

    /**
     * @dev 测试重复上架同一NFT失败
     */
    function testListNFTFailAlreadyListed() public {
        uint256 tokenId = 1;
        uint256 price = DEFAULT_NFT_PRICE;

        // 首次上架
        vm.prank(seller);
        market.list(address(nft), tokenId, price);

        // 尝试再次上架
        vm.prank(seller);
        vm.expectRevert("NFT already listed");
        market.list(address(nft), tokenId, price);
    }

    /**
     * @dev 测试无效NFT合约地址上架失败
     */
    function testListNFTFailInvalidContract() public {
        address invalidContract = address(0);
        uint256 tokenId = 1;
        uint256 price = DEFAULT_NFT_PRICE;

        vm.prank(seller);
        vm.expectRevert("Invalid NFT contract");
        market.list(invalidContract, tokenId, price);
    }

    /**
     * @dev 测试最小价格边界情况
     */
    function testListNFTWithMinPrice() public {
        uint256 tokenId = 2;
        uint256 price = MIN_PRICE;

        vm.prank(seller);
        vm.expectEmit(true, true, true, true);
        emit NFTListed(address(nft), tokenId, seller, price);
        market.list(address(nft), tokenId, price);

        (, uint256 listedPrice, bool isListed) = market.listings(address(nft), tokenId);
        assertEq(listedPrice, price, "Min price not set correctly");
        assertTrue(isListed, "NFT should be listed with min price");
    }

    /**
     * @dev 测试最大价格边界情况
     */
    function testListNFTWithMaxPrice() public {
        uint256 tokenId = 3;
        uint256 price = MAX_PRICE;

        vm.prank(seller);
        vm.expectEmit(true, true, true, true);
        emit NFTListed(address(nft), tokenId, seller, price);
        market.list(address(nft), tokenId, price);

        (, uint256 listedPrice, bool isListed) = market.listings(address(nft), tokenId);
        assertEq(listedPrice, price, "Max price not set correctly");
        assertTrue(isListed, "NFT should be listed with max price");
    }

    /**
     * @dev 测试上架多个不同NFT
     */
    function testListMultipleNFTs() public {
        uint256[] memory tokenIds = new uint256[](3);
        uint256[] memory prices = new uint256[](3);

        tokenIds[0] = 1;
        tokenIds[1] = 2;
        tokenIds[2] = 3;
        prices[0] = 100 ether;
        prices[1] = 200 ether;
        prices[2] = 300 ether;

        // 上架多个NFT
        for (uint256 i = 0; i < tokenIds.length; i++) {
            vm.prank(seller);
            vm.expectEmit(true, true, true, true);
            emit NFTListed(address(nft), tokenIds[i], seller, prices[i]);
            market.list(address(nft), tokenIds[i], prices[i]);
        }

        // 验证所有NFT都已上架
        for (uint256 i = 0; i < tokenIds.length; i++) {
            (address listedSeller, uint256 listedPrice, bool isListed) = market.listings(address(nft), tokenIds[i]);
            assertEq(listedSeller, seller, "Seller incorrect for multiple listings");
            assertEq(listedPrice, prices[i], "Price incorrect for multiple listings");
            assertTrue(isListed, "NFT should be listed in multiple listings");
        }
    }

    // ========== NFT 购买功能测试 ==========

    /**
     * @dev 测试成功购买NFT
     */
    function testBuyNFTSuccess() public {
        uint256 tokenId = 1;
        uint256 price = DEFAULT_NFT_PRICE;

        // 上架NFT
        vm.prank(seller);
        market.list(address(nft), tokenId, price);

        // 记录购买前余额
        uint256 sellerBalanceBefore = token.balanceOf(seller);
        uint256 buyerBalanceBefore = token.balanceOf(buyer);

        // 执行购买
        vm.prank(buyer);
        vm.expectEmit(true, true, true, true);
        emit NFTPurchased(address(nft), tokenId, buyer, seller, price);
        market.buyNFT(address(nft), tokenId);

        // 验证NFT所有权转移
        assertEq(nft.ownerOf(tokenId), buyer, "NFT ownership not transferred");

        // 验证代币转移
        assertEq(token.balanceOf(seller), sellerBalanceBefore + price, "Seller balance incorrect");
        assertEq(token.balanceOf(buyer), buyerBalanceBefore - price, "Buyer balance incorrect");

        // 验证上架状态更新
        (,, bool isListed) = market.listings(address(nft), tokenId);
        assertFalse(isListed, "NFT should not be listed after purchase");
    }

    /**
     * @dev 测试购买未上架NFT失败
     */
    function testBuyNFTFailNotListed() public {
        uint256 tokenId = 1;

        vm.prank(buyer);
        vm.expectRevert("NFT not listed");
        market.buyNFT(address(nft), tokenId);
    }

    /**
     * @dev 测试卖家购买自己的NFT失败
     */
    function testBuyNFTFailSelfPurchase() public {
        uint256 tokenId = 1;
        uint256 price = DEFAULT_NFT_PRICE;

        // 上架NFT
        vm.prank(seller);
        market.list(address(nft), tokenId, price);

        // 卖家尝试购买自己的NFT
        vm.prank(seller);
        vm.expectRevert("Cannot buy your own NFT");
        market.buyNFT(address(nft), tokenId);
    }

    /**
     * @dev 测试购买已售出NFT失败
     */
    function testBuyNFTFailAlreadySold() public {
        uint256 tokenId = 1;
        uint256 price = DEFAULT_NFT_PRICE;

        // 上架并购买NFT
        vm.prank(seller);
        market.list(address(nft), tokenId, price);

        vm.prank(buyer);
        market.buyNFT(address(nft), tokenId);

        // 尝试再次购买
        vm.prank(randomUser);
        vm.expectRevert("NFT not listed");
        market.buyNFT(address(nft), tokenId);
    }

    /**
     * @dev 测试余额不足购买失败
     */
    function testBuyNFTFailInsufficientTokens() public {
        uint256 tokenId = 1;
        uint256 price = DEFAULT_NFT_PRICE;

        // 上架NFT
        vm.prank(seller);
        market.list(address(nft), tokenId, price);

        // 创建余额不足的用户
        address poorUser = makeAddr("poorUser");
        token.transfer(poorUser, 50 ether); // 少于NFT价格

        vm.prank(poorUser);
        token.approve(address(market), type(uint256).max);

        vm.prank(poorUser);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        market.buyNFT(address(nft), tokenId);
    }

    /**
     * @dev 测试授权不足购买失败
     */
    function testBuyNFTFailInsufficientAllowance() public {
        uint256 tokenId = 1;
        uint256 price = DEFAULT_NFT_PRICE;

        // 上架NFT
        vm.prank(seller);
        market.list(address(nft), tokenId, price);

        // 撤销买家的授权
        vm.prank(buyer);
        token.approve(address(market), 0);

        vm.prank(buyer);
        vm.expectRevert("ERC20: transfer amount exceeds allowance");
        market.buyNFT(address(nft), tokenId);
    }

    /**
     * @dev 测试通过回调购买NFT
     */
    function testBuyNFTWithCallback() public {
        uint256 tokenId = 1;
        uint256 price = DEFAULT_NFT_PRICE;

        // 上架NFT
        vm.prank(seller);
        market.list(address(nft), tokenId, price);

        uint256 sellerBalanceBefore = token.balanceOf(seller);
        uint256 buyerBalanceBefore = token.balanceOf(buyer);

        // 通过回调购买
        bytes memory data = abi.encode(address(nft), tokenId);

        vm.prank(buyer);
        vm.expectEmit(true, true, true, true);
        emit NFTPurchased(address(nft), tokenId, buyer, seller, price);
        token.transferWithCallback(address(market), price, data);

        // 验证结果
        assertEq(nft.ownerOf(tokenId), buyer, "NFT ownership not transferred via callback");
        assertEq(token.balanceOf(seller), sellerBalanceBefore + price, "Seller balance incorrect via callback");
        assertEq(token.balanceOf(buyer), buyerBalanceBefore - price, "Buyer balance incorrect via callback");

        (,, bool isListed) = market.listings(address(nft), tokenId);
        assertFalse(isListed, "NFT should not be listed after callback purchase");
    }

    /**
     * @dev 测试回调购买中的自购买失败
     */
    function testBuyNFTWithCallbackFailSelfPurchase() public {
        uint256 tokenId = 1;
        uint256 price = DEFAULT_NFT_PRICE;

        // 上架NFT
        vm.prank(seller);
        market.list(address(nft), tokenId, price);

        // 卖家尝试通过回调购买自己的NFT
        bytes memory data = abi.encode(address(nft), tokenId);

        vm.prank(seller);
        vm.expectRevert("Cannot buy your own NFT");
        token.transferWithCallback(address(market), price, data);
    }

    // ========== 模糊测试 ==========

    /**
     * @dev 模糊测试：随机价格和买家的上架购买流程
     */
    function testFuzzListAndBuyNFT(uint256 fuzzPrice, address fuzzBuyer) public {
        // 限制价格范围
        uint256 price = bound(fuzzPrice, 0.01 ether, 10000 ether);

        // 确保买家地址有效且不是卖家
        vm.assume(fuzzBuyer != address(0));
        vm.assume(fuzzBuyer != seller);
        vm.assume(fuzzBuyer != address(market));
        vm.assume(fuzzBuyer != address(nft));
        vm.assume(fuzzBuyer != address(token));

        // 确保不是合约地址，避免onERC721Received调用问题
        vm.assume(fuzzBuyer.code.length == 0);

        uint256 tokenId = 5; // 使用固定的tokenId进行模糊测试

        // 为随机买家分配代币和授权
        token.transfer(fuzzBuyer, price * 2);
        vm.prank(fuzzBuyer);
        token.approve(address(market), type(uint256).max);

        // 上架NFT
        vm.prank(seller);
        market.list(address(nft), tokenId, price);

        // 记录购买前状态
        uint256 sellerBalanceBefore = token.balanceOf(seller);
        uint256 buyerBalanceBefore = token.balanceOf(fuzzBuyer);

        // 购买NFT
        vm.prank(fuzzBuyer);
        market.buyNFT(address(nft), tokenId);

        // 验证结果
        assertEq(nft.ownerOf(tokenId), fuzzBuyer, "Fuzz: NFT ownership not transferred");
        assertEq(token.balanceOf(seller), sellerBalanceBefore + price, "Fuzz: Seller balance incorrect");
        assertEq(token.balanceOf(fuzzBuyer), buyerBalanceBefore - price, "Fuzz: Buyer balance incorrect");

        (,, bool isListed) = market.listings(address(nft), tokenId);
        assertFalse(isListed, "Fuzz: NFT should not be listed after purchase");
    }

    // ========== 不变量测试 ==========

    /**
     * @dev 不变量测试：市场合约在正常购买后不应持有代币
     */
    function testInvariantMarketNeverHoldsTokens() public {
        uint256 tokenId = 6;
        uint256 price = DEFAULT_NFT_PRICE;

        // 上架并购买NFT
        vm.prank(seller);
        market.list(address(nft), tokenId, price);

        vm.prank(buyer);
        market.buyNFT(address(nft), tokenId);

        // 验证市场合约不持有代币
        assertEq(token.balanceOf(address(market)), 0, "Market should never hold tokens");
    }

    /**
     * @dev 不变量测试：通过回调购买后市场合约不应持有代币
     */
    function testInvariantMarketNeverHoldsTokensWithCallback() public {
        uint256 tokenId = 7;
        uint256 price = DEFAULT_NFT_PRICE;

        // 上架NFT
        vm.prank(seller);
        market.list(address(nft), tokenId, price);

        // 通过回调购买
        bytes memory data = abi.encode(address(nft), tokenId);
        vm.prank(buyer);
        token.transferWithCallback(address(market), price, data);

        // 验证市场合约不持有代币
        assertEq(token.balanceOf(address(market)), 0, "Market should never hold tokens after callback");
    }

    // ========== 辅助函数 ==========

    /**
     * @dev 辅助函数：获取当前区块时间戳
     */
    function getCurrentTimestamp() internal view returns (uint256) {
        return block.timestamp;
    }

    /**
     * @dev 辅助函数：验证事件发出
     */
    function expectNFTListedEvent(address nftContract, uint256 tokenId, address sellerAddr, uint256 price) internal {
        vm.expectEmit(true, true, true, true);
        emit NFTListed(nftContract, tokenId, sellerAddr, price);
    }

    /**
     * @dev 辅助函数：验证购买事件发出
     */
    function expectNFTPurchasedEvent(
        address nftContract,
        uint256 tokenId,
        address buyerAddr,
        address sellerAddr,
        uint256 price
    ) internal {
        vm.expectEmit(true, true, true, true);
        emit NFTPurchased(nftContract, tokenId, buyerAddr, sellerAddr, price);
    }
}

/**
 * @title 完整的测试用NFT合约
 * @dev 包含完整的ERC721实现，用于测试
 */
contract TestNFTComplete {
    // ========== 状态变量 ==========
    string private _name;
    string private _symbol;
    uint256 private _currentTokenId;

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // ========== 事件 ==========
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // ========== 构造函数 ==========
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    // ========== 查询函数 ==========
    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function balanceOf(address owner) external view returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function getApproved(uint256 tokenId) external view returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }

    function isApprovedForAll(address owner, address operator) external view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    // ========== 授权函数 ==========
    function approve(address to, uint256 tokenId) external {
        address owner = _owners[tokenId];
        require(to != owner, "ERC721: approval to current owner");
        require(
            msg.sender == owner || _operatorApprovals[owner][msg.sender],
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) external {
        require(operator != msg.sender, "ERC721: approve to caller");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // ========== 转移函数 ==========
    function transferFrom(address from, address to, uint256 tokenId) external {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    // ========== 铸造函数 ==========
    function mint(address to, uint256 tokenId) external {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    // ========== 内部函数 ==========
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = _owners[tokenId];
        return (spender == owner || _tokenApprovals[tokenId] == spender || _operatorApprovals[owner][spender]);
    }

    function _approve(address to, uint256 tokenId) internal {
        _tokenApprovals[tokenId] = to;
        emit Approval(_owners[tokenId], to, tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        require(_owners[tokenId] == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        // 清除授权
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private
        returns (bool)
    {
        if (to.code.length > 0) {
            try IERC721ReceiverInterface(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval)
            {
                return retval == IERC721ReceiverInterface.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
}

/**
 * @title IERC721Receiver 接口
 */
interface IERC721ReceiverInterface {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4);
}
