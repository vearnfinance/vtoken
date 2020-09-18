pragma solidity ^0.5.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract ReentrancyGuard {
    uint256 private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface vERC20 {
  function deposit(uint256 _amount) external;
  function withdraw(uint256 _amount) external;
  function getPricePerFullShare() external view returns (uint256);
}

// Solidity Interface

interface CurveFi {
  function exchange(
    int128 i,
    int128 j,
    uint256 dx,
    uint256 min_dy
  ) external;
  function get_dx_underlying(
    int128 i,
    int128 j,
    uint256 dy
  ) external view returns (uint256);
  function get_dy_underlying(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);
  function get_dx(
    int128 i,
    int128 j,
    uint256 dy
  ) external view returns (uint256);
  function get_dy(
    int128 i,
    int128 j,
    uint256 dx
  ) external view returns (uint256);
  function get_virtual_price() external view returns (uint256);
}

interface vCurveFi {
  function add_liquidity(
    uint256[4] calldata amounts,
    uint256 min_mint_amount
  ) external;
  function remove_liquidity(
    uint256 _amount,
    uint256[4] calldata amounts
  ) external;
  function calc_token_amount(
    uint256[4] calldata amounts,
    bool deposit
  ) external view returns (uint256);
}

interface sCurveFi {
  function add_liquidity(
    uint256[2] calldata amounts,
    uint256 min_mint_amount
  ) external;
  function remove_liquidity(
    uint256 _amount,
    uint256[2] calldata amounts
  ) external;
  function calc_token_amount(
    uint256[2] calldata amounts,
    bool deposit
  ) external view returns (uint256);
}

contract vCurveExchange is ReentrancyGuard, Ownable {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint256;

  address public constant DAI = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
  address public constant vDAI = address(0x16de59092dAE5CcF4A1E6439D611fd0653f0Bd01);
  address public constant USDC = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
  address public constant vUSDC = address(0xd6aD7a6750A7593E092a9B218d66C0A814a3436e);
  address public constant USDT = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);
  address public constant vUSDT = address(0x83f798e925BcD4017Eb265844FDDAbb448f1707D);
  address public constant TUSD = address(0x0000000000085d4780B73119b644AE5ecd22b376);
  address public constant vTUSD = address(0x73a052500105205d34Daf004eAb301916DA8190f);
  address public constant vSUSD = address(0xF61718057901F84C4eEC4339EF8f0D86D2B45600);
  address public constant SUSD = address(0x57Ab1ec28D129707052df4dF418D58a2D46d5f51);
  address public constant vSWAP = address(0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51);
  address public constant vCURVE = address(0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8);
  address public constant sSWAP = address(0xeDf54bC005bc2Df0Cc6A675596e843D28b16A966);
  address public constant sCURVE = address(0x2b645a6A426f22fB7954dC15E583e3737B8d1434);

  constructor () public {
    approveToken();
  }

  function approveToken() public {
      IERC20(DAI).safeApprove(vDAI, uint(-1));
      IERC20(vDAI).safeApprove(vSWAP, uint(-1));

      IERC20(USDC).safeApprove(vUSDC, uint(-1));
      IERC20(vUSDC).safeApprove(vSWAP, uint(-1));

      IERC20(USDT).safeApprove(vUSDT, uint(-1));
      IERC20(vUSDT).safeApprove(vSWAP, uint(-1));

      IERC20(TUSD).safeApprove(vTUSD, uint(-1));
      IERC20(vTUSD).safeApprove(vSWAP, uint(-1));

      IERC20(SUSD).safeApprove(vSUSD, uint(-1));
      IERC20(vSUSD).safeApprove(vSWAP, uint(-1));

      IERC20(vCURVE).safeApprove(sSWAP, uint(-1));
  }

  // 0 = DAI, 1 = USDC, 2 = USDT, 3 = TUSD, 4 = SUSD
  function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 min_dy) external nonReentrant {
    address _ui = get_address_underlying(i);
    IERC20(_ui).safeTransferFrom(msg.sender, address(this), dx);
    address _i = get_address(i);
    vERC20(_i).deposit(IERC20(_ui).balanceOf(address(this)));

    _exchange(i, j);

    address _j = get_address(j);
    vERC20(_j).withdraw(IERC20(_j).balanceOf(address(this)));
    address _uj = get_address_underlying(j);
    uint256 _dy = IERC20(_uj).balanceOf(address(this));
    require(_dy >= min_dy, "slippage");
    IERC20(_uj).safeTransfer(msg.sender, _dy);
  }
  function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external nonReentrant {
    IERC20(get_address(i)).safeTransferFrom(msg.sender, address(this), dx);

    _exchange(i, j);

    address _j = get_address(j);
    uint256 _dy = IERC20(_j).balanceOf(address(this));
    require(_dy >= min_dy, "slippage");
    IERC20(_j).safeTransfer(msg.sender, _dy);
  }
  // 0 = vDAI, 1 = vUSDC, 2 = vUSDT, 3 = vTUSD, 4 = vSUSD
  function _exchange(int128 i, int128 j) internal {
    if (i == 4) {
      CurveFi(sSWAP).exchange(0, 1, IERC20(get_address(i)).balanceOf(address(this)), 0);
      vCurveFi(ySWAP).remove_liquidity(IERC20(vCURVE).balanceOf(address(this)), [uint256(0),0,0,0]);
      _swap_to(j);
    } else if (j == 4) {
      uint256[4] memory amounts;
      amounts[uint256(i)] = IERC20(get_address(i)).balanceOf(address(this));
      vCurveFi(vSWAP).add_liquidity(amounts, 0);
      CurveFi(sSWAP).exchange(1, 0, IERC20(vCURVE).balanceOf(address(this)), 0);
    } else {
      CurveFi(vSWAP).exchange(i, j, IERC20(get_address(i)).balanceOf(address(this)), 0);
    }
  }
  function _swap_to(int128 j) internal {
    if (j == 0) {
      _swap_to_dai();
    } else if (j == 1) {
      _swap_to_usdc();
    } else if (j == 2) {
      _swap_to_usdt();
    } else if (j == 3) {
      _swap_to_tusd();
    }
  }
  function _swap_to_dai() internal {
    uint256 _vusdc = IERC20(vUSDC).balanceOf(address(this));
    uint256 _vusdt = IERC20(vUSDT).balanceOf(address(this));
    uint256 _vtusd = IERC20(vTUSD).balanceOf(address(this));

    if (_vusdc > 0) {
      CurveFi(vSWAP).exchange(1, 0, _vusdc, 0);
    }
    if (_vusdt > 0) {
      CurveFi(vSWAP).exchange(2, 0, _vusdt, 0);
    }
    if (_vtusd > 0) {
      CurveFi(vSWAP).exchange(3, 0, _vtusd, 0);
    }
  }
  function _swap_to_usdc() internal {
    uint256 _vdai = IERC20(vDAI).balanceOf(address(this));
    uint256 _vusdt = IERC20(vUSDT).balanceOf(address(this));
    uint256 _vtusd = IERC20(vTUSD).balanceOf(address(this));

    if (_vdai > 0) {
      CurveFi(ySWAP).exchange(0, 1, _ydai, 0);
    }
    if (_vusdt > 0) {
      CurveFi(ySWAP).exchange(2, 1, _yusdt, 0);
    }
    if (_vtusd > 0) {
      CurveFi(ySWAP).exchange(3, 1, _ytusd, 0);
    }
  }
  function _swap_to_usdt() internal {
    uint256 _vdai = IERC20(vDAI).balanceOf(address(this));
    uint256 _vusdc = IERC20(vUSDC).balanceOf(address(this));
    uint256 _vtusd = IERC20(vTUSD).balanceOf(address(this));

    if (_vdai > 0) {
      CurveFi(vSWAP).exchange(0, 2, _vdai, 0);
    }
    if (_vusdc > 0) {
      CurveFi(vSWAP).exchange(1, 2, _vusdc, 0);
    }
    if (_vtusd > 0) {
      CurveFi(vSWAP).exchange(3, 2, _vtusd, 0);
    }
  }
  function _swap_to_tusd() internal {
    uint256 _vdai = IERC20(vDAI).balanceOf(address(this));
    uint256 _vusdc = IERC20(vUSDC).balanceOf(address(this));
    uint256 _vusdt = IERC20(vUSDT).balanceOf(address(this));

    if (_vdai > 0) {
      CurveFi(vSWAP).exchange(0, 3, _vdai, 0);
    }
    if (_vusdc > 0) {
      CurveFi(vSWAP).exchange(1, 3, _vusdc, 0);
    }
    if (_vusdt > 0) {
      CurveFi(vSWAP).exchange(2, 3, _vusdt, 0);
    }
  }

  function get_address_underlying(int128 index) public pure returns (address) {
    if (index == 0) {
      return DAI;
    } else if (index == 1) {
      return USDC;
    } else if (index == 2) {
      return USDT;
    } else if (index == 3) {
      return TUSD;
    } else if (index == 4) {
      return SUSD;
    }
  }
  function get_address(int128 index) public pure returns (address) {
    if (index == 0) {
      return vDAI;
    } else if (index == 1) {
      return vUSDC;
    } else if (index == 2) {
      return vUSDT;
    } else if (index == 3) {
      return vTUSD;
    } else if (index == 4) {
      return vSUSD;
    }
  }
  function add_liquidity_underlying(uint256[5] calldata amounts, uint256 min_mint_amount) external nonReentrant {
    uint256[5] memory _amounts;
    if (amounts[0] > 0) {
      IERC20(DAI).safeTransferFrom(msg.sender, address(this), amounts[0]);
      vERC20(vDAI).deposit(IERC20(DAI).balanceOf(address(this)));
      _amounts[0] = IERC20(vDAI).balanceOf(address(this));
    }
    if (amounts[1] > 0) {
      IERC20(USDC).safeTransferFrom(msg.sender, address(this), amounts[1]);
      vERC20(vUSDC).deposit(IERC20(USDC).balanceOf(address(this)));
      _amounts[1] = IERC20(vUSDC).balanceOf(address(this));
    }
    if (amounts[2] > 0) {
      IERC20(USDT).safeTransferFrom(msg.sender, address(this), amounts[2]);
      vERC20(vUSDT).deposit(IERC20(USDT).balanceOf(address(this)));
      _amounts[2] = IERC20(vUSDT).balanceOf(address(this));
    }
    if (amounts[3] > 0) {
      IERC20(TUSD).safeTransferFrom(msg.sender, address(this), amounts[3]);
      vERC20(vTUSD).deposit(IERC20(TUSD).balanceOf(address(this)));
      _amounts[3] = IERC20(vTUSD).balanceOf(address(this));
    }
    if (amounts[4] > 0) {
      IERC20(SUSD).safeTransferFrom(msg.sender, address(this), amounts[4]);
      vERC20(ySUSD).deposit(IERC20(SUSD).balanceOf(address(this)));
      _amounts[4] = IERC20(vSUSD).balanceOf(address(this));
    }
    _add_liquidity(_amounts, min_mint_amount);
    IERC20(sCURVE).safeTransfer(msg.sender, IERC20(sCURVE).balanceOf(address(this)));
  }
  function _add_liquidity(uint256[5] memory amounts, uint256 min_mint_amount) internal {
    uint256[4] memory _v;
    _v[0] = amounts[0];
    _v[1] = amounts[1];
    _v[2] = amounts[2];
    _v[3] = amounts[3];
    uint256[2] memory _s;
    _s[0] = amounts[4];

    vCurveFi(vSWAP).add_liquidity(_v, 0);
    _s[1] = IERC20(vCURVE).balanceOf(address(this));
    sCurveFi(sSWAP).add_liquidity(_s, min_mint_amount);
  }
  function remove_liquidity_underlying(uint256 _amount, uint256[5] calldata min_amounts) external nonReentrant {
    IERC20(sCURVE).safeTransferFrom(msg.sender, address(this), _amount);
    _remove_liquidity(min_amounts);
    uint256 _vdai = IERC20(vDAI).balanceOf(address(this));
    uint256 _vusdc = IERC20(vUSDC).balanceOf(address(this));
    uint256 _vusdt = IERC20(vUSDT).balanceOf(address(this));
    uint256 _vtusd = IERC20(vTUSD).balanceOf(address(this));
    uint256 _vsusd = IERC20(vSUSD).balanceOf(address(this));

    if (_vdai > 0) {
      vERC20(vDAI).withdraw(_vdai);
      IERC20(DAI).safeTransfer(msg.sender, IERC20(DAI).balanceOf(address(this)));
    }
    if (_vusdc > 0) {
      vERC20(vUSDC).withdraw(_vusdc);
      IERC20(USDC).safeTransfer(msg.sender, IERC20(USDC).balanceOf(address(this)));
    }
    if (_vusdt > 0) {
      vERC20(vUSDT).withdraw(_vusdt);
      IERC20(USDT).safeTransfer(msg.sender, IERC20(USDT).balanceOf(address(this)));
    }
    if (_vtusd > 0) {
      vERC20(vTUSD).withdraw(_vtusd);
      IERC20(TUSD).safeTransfer(msg.sender, IERC20(TUSD).balanceOf(address(this)));
    }
    if (_vsusd > 0) {
      vERC20(vSUSD).withdraw(_vsusd);
      IERC20(SUSD).safeTransfer(msg.sender, IERC20(SUSD).balanceOf(address(this)));
    }
  }
  function remove_liquidity_underlying_to(int128 j, uint256 _amount, uint256 _min_amount) external nonReentrant {
    IERC20(sCURVE).safeTransferFrom(msg.sender, address(this), _amount);
    _remove_liquidity([uint256(0),0,0,0,0]);
    _swap_to(j);
    vERC20(get_address(j)).withdraw(IERC20(j).balanceOf(address(this)));
    address _uj = get_address_underlying(j);
    uint256 _dy = IERC20(_uj).balanceOf(address(this));
    require(_dy >= _min_amount, "slippage");
    IERC20(_uj).safeTransfer(msg.sender, _dy);
  }
  function _remove_liquidity(uint256[5] memory min_amounts) internal {
    uint256[2] memory _s;
    _s[0] = min_amounts[4];
    sCurveFi(sSWAP).remove_liquidity(IERC20(sCURVE).balanceOf(address(this)), _s);
    uint256[4] memory _v;
    _v[0] = min_amounts[0];
    _v[1] = min_amounts[1];
    _v[2] = min_amounts[2];
    _v[3] = min_amounts[3];
    vCurveFi(vSWAP).remove_liquidity(IERC20(vCURVE).balanceOf(address(this)), _y);
  }

  function get_dy_underlying(int128 i, int128 j, uint256 dx) external view returns (uint256) {
    if (i == 4) { // How much j (USDT) will I get, if I sell dx SUSD (i)
      uint256 _vt = dx.mul(1e18).div(vERC20(get_address(i)).getPricePerFullShare());
      uint256 _v = CurveFi(sSWAP).get_dy(0, 1, _vt);
      return calc_withdraw_amount_v(_v, j);
      //return _v.mul(1e18).div(CurveFi(vSWAP).get_virtual_price()).div(decimals[uint256(j)]);
    } else if (j == 4) { // How much SUSD (j) will I get, if I sell dx USDT (i)
      uint256[4] memory _amounts;
      _amounts[uint256(i)] = dx.mul(1e18).div(yERC20(get_address(i)).getPricePerFullShare());
      uint256 _v = vCurveFi(ySWAP).calc_token_amount(_amounts, true);
      uint256 _fee = _v.mul(4).div(10000);
      return CurveFi(sSWAP).get_dy_underlying(1, 0, _v.sub(_fee));
    } else {
      uint256 _dy = CurveFi(vSWAP).get_dy_underlying(i, j, dx);
      return _dy.sub(_dy.mul(4).div(10000));
    }
  }

  function get_dy(int128 i, int128 j, uint256 dx) external view returns (uint256) {
    if (i == 4) { // How much j (USDT) will I get, if I sell dx SUSD (i)
      uint256 _y = CurveFi(sSWAP).get_dy(0, 1, dx);
      uint256 _j = calc_withdraw_amount_v(_v, j);
      return _j.mul(vERC20(get_address(j)).getPricePerFullShare()).div(1e18);
    } else if (j == 4) { // How much SUSD (j) will I get, if I sell dx USDT (i)
      uint256[4] memory _amounts;
      _amounts[uint256(i)] = dx;
      uint256 _v = vCurveFi(vSWAP).calc_token_amount(_amounts, true);
      uint256 _fee = _v.mul(4).div(10000);
      return CurveFi(sSWAP).get_dy(1, 0, _v.sub(_fee));
    } else {
      uint256 _dy = CurveFi(vSWAP).get_dy(i, j, dx);
      return _dy.sub(_dy.mul(4).div(10000));
    }
  }

  function calc_withdraw_amount_y(uint256 amount, int128 j) public view returns (uint256) {
    uint256 _vtotal = IERC20(vCURVE).totalSupply();

    uint256 _vDAI = IERC20(vDAI).balanceOf(vSWAP);
    uint256 _vUSDC = IERC20(vUSDC).balanceOf(vSWAP);
    uint256 _vUSDT = IERC20(vUSDT).balanceOf(vSWAP);
    uint256 _vTUSD = IERC20(vTUSD).balanceOf(vSWAP);

    uint256[4] memory _amounts;
    _amounts[0] = _vDAI.mul(amount).div(_vtotal);
    _amounts[1] = _vUSDC.mul(amount).div(_vtotal);
    _amounts[2] = _vUSDT.mul(amount).div(_vtotal);
    _amounts[3] = _vTUSD.mul(amount).div(_vtotal);

    uint256 _base = _calc_to(_amounts, j).mul(vERC20(get_address(j)).getPricePerFullShare()).div(1e18);
    uint256 _fee = _base.mul(4).div(10000);
    return _base.sub(_fee);
  }
  function _calc_to(uint256[4] memory _amounts, int128 j) public view returns (uint256) {
    if (j == 0) {
      return _calc_to_dai(_amounts);
    } else if (j == 1) {
      return _calc_to_usdc(_amounts);
    } else if (j == 2) {
      return _calc_to_usdt(_amounts);
    } else if (j == 3) {
      return _calc_to_tusd(_amounts);
    }
  }

  function _calc_to_dai(uint256[4] memory _amounts) public view returns (uint256) {
    uint256 _from_usdc = CurveFi(vSWAP).get_dy(1, 0, _amounts[1]);
    uint256 _from_usdt = CurveFi(vSWAP).get_dy(2, 0, _amounts[2]);
    uint256 _from_tusd = CurveFi(vSWAP).get_dy(3, 0, _amounts[3]);
    return _amounts[0].add(_from_usdc).add(_from_usdt).add(_from_tusd);
  }
  function _calc_to_usdc(uint256[4] memory _amounts) public view returns (uint256) {
    uint256 _from_dai = CurveFi(vSWAP).get_dy(0, 1, _amounts[0]);
    uint256 _from_usdt = CurveFi(vSWAP).get_dy(2, 1, _amounts[2]);
    uint256 _from_tusd = CurveFi(vSWAP).get_dy(3, 1, _amounts[3]);
    return _amounts[1].add(_from_dai).add(_from_usdt).add(_from_tusd);
  }
  function _calc_to_usdt(uint256[4] memory _amounts) public view returns (uint256) {
    uint256 _from_dai = CurveFi(vSWAP).get_dy(0, 2, _amounts[0]);
    uint256 _from_usdc = CurveFi(vSWAP).get_dy(1, 2, _amounts[1]);
    uint256 _from_tusd = CurveFi(vSWAP).get_dy(3, 2, _amounts[3]);
    return _amounts[2].add(_from_dai).add(_from_usdc).add(_from_tusd);
  }
  function _calc_to_tusd(uint256[4] memory _amounts) public view returns (uint256) {
    uint256 _from_dai = CurveFi(vSWAP).get_dy(0, 3, _amounts[0]);
    uint256 _from_usdc = CurveFi(vSWAP).get_dy(1, 3, _amounts[1]);
    uint256 _from_usdt = CurveFi(vSWAP).get_dy(2, 3, _amounts[2]);
    return _amounts[3].add(_from_dai).add(_from_usdc).add(_from_usdt);
  }

  function calc_withdraw_amount(uint256 amount) external view returns (uint256[5] memory) {
    uint256 _stotal = IERC20(sCURVE).totalSupply();
    uint256 _vtotal = IERC20(vCURVE).totalSupply();
    uint256 _vCURVE = IERC20(vCURVE).balanceOf(sSWAP);

    uint256 _vshares = _vCURVE.mul(amount).div(_stotal);

    uint256[5] memory _amounts;
    _amounts[0] = IERC20(vDAI).balanceOf(vSWAP);
    _amounts[1] = IERC20(vUSDC).balanceOf(vSWAP);
    _amounts[2] = IERC20(vUSDT).balanceOf(vSWAP);
    _amounts[3] = IERC20(vTUSD).balanceOf(vSWAP);
    _amounts[4] = IERC20(vSUSD).balanceOf(sSWAP);

    _amounts[0] = _amounts[0].mul(_vshares).div(_vtotal);
    _amounts[0] = _amounts[0].sub(_amounts[0].mul(4).div(10000));
    _amounts[1] = _amounts[1].mul(_vshares).div(_vtotal);
    _amounts[1] = _amounts[1].sub(_amounts[1].mul(4).div(10000));
    _amounts[2] = _amounts[2].mul(_vshares).div(_vtotal);
    _amounts[2] = _amounts[2].sub(_amounts[2].mul(4).div(10000));
    _amounts[3] = _amounts[3].mul(_vshares).div(_vtotal);
    _amounts[3] = _amounts[3].sub(_amounts[3].mul(4).div(10000));
    _amounts[4] = _amounts[4].mul(amount).div(_stotal);
    _amounts[4] = _amounts[4].sub(_amounts[4].mul(4).div(10000));

    return _amounts;
  }

  function calc_deposit_amount(uint256[5] calldata amounts) external view returns (uint256) {
    uint256[4] memory _v;
    _v[0] = amounts[0].mul(1e18).div(vERC20(vDAI).getPricePerFullShare());
    _v[1] = amounts[1].mul(1e18).div(vERC20(vUSDC).getPricePerFullShare());
    _v[2] = amounts[2].mul(1e18).div(vERC20(vUSDT).getPricePerFullShare());
    _v[3] = amounts[3].mul(1e18).div(vERC20(vTUSD).getPricePerFullShare());
    uint256 _v_output = vCurveFi(vSWAP).calc_token_amount(_v, true);
    uint256[2] memory _s;
    _s[0] = amounts[4].mul(1e18).div(vERC20(vSUSD).getPricePerFullShare());
    _s[1] = _v_output.mul(1e18).div(CurveFi(vSWAP).get_virtual_price());
    uint256 _base = sCurveFi(sSWAP).calc_token_amount(_s, true);
    uint256 _fee = _base.mul(4).div(10000);
    return _base.sub(_fee);
  }

  // incase of half-way error
  function inCaseTokenGetsStuck(IERC20 _TokenAddress) onlyOwner public {
      uint qty = _TokenAddress.balanceOf(address(this));
      _TokenAddress.safeTransfer(msg.sender, qty);
  }
}
