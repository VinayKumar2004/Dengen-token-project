// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DegenToken {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address private _owner;

    struct Item {
    uint256 itemId;
    string itemName;
    uint256 price;
    }

    mapping(uint256 => Item) private _items;
    uint256 private _nextItemId = 1;


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Redemption(address indexed user, uint256 itemId, uint256 tokenAmount, string itemName);



    constructor() {
        _name = "Degen";
        _symbol = "DGN";
        _decimals = 18;
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only the owner can perform this action");
        _;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowances[from][msg.sender] - value);
        return true;
    }

   
    function redeem(uint256 itemId, uint256 tokenAmount, string memory itemName) external {
    require(itemId > 0, "Invalid item ID");
    require(bytes(itemName).length > 0, "Invalid item name");
    require(tokenAmount > 0, "Invalid token amount");
    require(_balances[msg.sender] >= tokenAmount, "Insufficient balance");

    // Deduct the cost of the item (token amount) from the user's account.
    _balances[msg.sender] -= tokenAmount;

    // Decrease the total supply of the token by the redeemed amount.
    _totalSupply -= tokenAmount;

    // Emit the Redemption event with the relevant information
    emit Redemption(msg.sender, itemId, tokenAmount, itemName);

    // Implement the logic to provide the redeemed item or reward to the user here.
    // You can use the `itemId`, `itemName`, and `tokenAmount` variables to handle the redemption.
    }

    function addItem(uint256 itemId, string memory itemName, uint256 price) external onlyOwner {
    require(itemId > 0, "Invalid item ID");
    require(bytes(itemName).length > 0, "Invalid item name");
    require(price > 0, "Invalid price");

    // Check if an item with the same itemId already exists
    require(_items[itemId].itemId == 0, "Item with this ID already exists");

    // Create a new item with the provided itemId, itemName, and price
    _items[itemId] = Item(itemId, itemName, price);
    _nextItemId++;
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == _owner, "Only the owner can mint tokens");
        require(to != address(0), "Mint to the zero address");
        
        _totalSupply += amount;
        _balances[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function burn(uint256 amount) external {
        require(amount <= _balances[msg.sender], "Insufficient balance");

        _totalSupply -= amount;
        _balances[msg.sender] -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(from != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address");
        require(value <= _balances[from], "Insufficient balance");

        _balances[from] -= value;
        _balances[to] += value;
        emit Transfer(from, to, value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
}
