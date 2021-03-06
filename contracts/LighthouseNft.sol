// Seascape NFT
// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

/// @title Lighthouse NFT
/// @notice LighthouseNFT is the NFT used in Lighthouse platform.
/// @author Medet Ahmetson
contract LighthouseNft is ERC721, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    // Base URI
    string private _baseURIextended;

    Counters.Counter private tokenId;

    uint256 public projectId;  // project to which it's used	

    struct Params {
	    uint256 scaledAllocation;       // allocation among total pool of investors.
        uint256 scaledCompensation;     // compensation
        uint8 mintType;                 // mint type: 1 = prefund pool, 2 = auction pool, 3 = private investor
    }

    mapping(address => bool) public minters;
    mapping(address => bool) public burners;

    /// @dev returns parameters of Seascape NFT by token id.
    mapping(uint256 => Params) public paramsOf;

    event Minted(address indexed owner, uint256 indexed id, uint256 allocation, uint256 compensation, uint8 mintType, uint256 projectId);
    
    /**
     * @dev Sets the {name} and {symbol} of token.
     * Mints all tokens.
     */
    constructor(uint256 _projectId, string memory nftName, string memory nftSymbol) ERC721(nftName, nftSymbol) {
	    require(_projectId > 0, "Lighthouse: ZERO_VALUE");
        tokenId.increment(); // set to 1 the incrementor, so first token will be with id 1.

        projectId = _projectId;
    }

    modifier onlyMinter() {
        require(minters[_msgSender()], "Lighthouse: NOT_MINTER");
        _;
    }

    modifier onlyBurner() {
        require(burners[_msgSender()], "Lighthouse: NOT_BURNER");
        _;
    }

    /// @dev ensure that all parameters are checked on factory smartcontract
    function mint(uint256 _projectId, uint256 _tokenId, address _to, uint256 _allocation, uint256 _compensation, uint8 _type) external onlyMinter returns(bool) {
	    require(_projectId == projectId, "Lighthouse: PROJECT_ID_MISMATCH");
        uint256 _nextTokenId = tokenId.current();
        require(_tokenId == _nextTokenId, "LighthouseNFT: INVALID_TOKEN");

        _safeMint(_to, _tokenId);

        paramsOf[_tokenId] = Params(_allocation, _compensation, _type);

        tokenId.increment();

        emit Minted(_to, _tokenId, _allocation, _compensation, _type, projectId);
        
        return true;
    }

    function burn(uint256 id) public virtual override onlyBurner {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), id), "ERC721Burnable: caller is not owner nor approved");
        _burn(id);
    }

    function getNextTokenId() external view returns(uint256) {
        return tokenId.current();
    }

    function setOwner(address _owner) external onlyOwner {
	    transferOwnership(_owner);
    }

    function setMinter(address _minter) external onlyOwner {
	    minters[_minter] = true;
    }

    function unsetMinter(address _minter) external onlyOwner {
	    minters[_minter] = false;
    }

    function setBurner(address _burner) external onlyOwner {
	    burners[_burner] = true;
    }

    function unsetBurner(address _burner) external onlyOwner {
	    burners[_burner] = false;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseURIextended = baseURI_;
    }

    function scaledAllocation(uint256 nftId) external view returns(uint256) {
        return paramsOf[nftId].scaledAllocation;
    }

    function scaledCompensation(uint256 nftId) external view returns(uint256) {
        return paramsOf[nftId].scaledCompensation;
    }

    function mintType(uint256 nftId) external view returns(uint8) {
        return paramsOf[nftId].mintType;
    }
}
