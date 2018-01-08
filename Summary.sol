pragma solidity ^0.4.0;
import "./AdminController.sol";
import "./ClaimsRegistry.sol";

contract Summary{
    
    AdminController adminController ;
    ClaimsRegistry claimsRegistry ;
    
    event PermissionHashShared(address patient, address doctor, bytes32 data, string uri);
    
    modifier isAppprovedProvider (address _checkIfApproved){
        require(adminController.isState(_checkIfApproved));
        _;
    }
    
    
    struct sharedHash{
        bytes32 data;
        string uri;
        bool isShared;
    }
    
    function Summary(address _adminController){
        if (_adminController != 0x0 ) {
            adminController = AdminController(_adminController);
        }
        else {
            revert(); //the admin controller address is wrong
        }
    }
    
    mapping(address => mapping(address =>  sharedHash )) sharedHashes;
    mapping(address => address[]) public AddressOfPatients;
    
    function sharePermissionHash (address _providerAdd, bytes32 _data, string _uri, uint256 _claimType)
    isAppprovedProvider(_providerAdd)
    {   
        sharedHashes[msg.sender][_providerAdd].data = _data;
        sharedHashes[msg.sender][_providerAdd].uri = _uri;
        if (sharedHashes[msg.sender][_providerAdd].isShared != true){
            sharedHashes[msg.sender][_providerAdd].isShared = true;
            AddressOfPatients[_providerAdd].push(msg.sender);
        }
        
        PermissionHashShared(msg.sender, _providerAdd, _data, _uri);
        
    }
    // shall be called by the approved provider only
    function returnSharedHash(address _patientAdd) 
    isAppprovedProvider(msg.sender)
    constant returns(bytes32 , string ){
        return (sharedHashes[_patientAdd][msg.sender].data, sharedHashes[_patientAdd][msg.sender].uri);
        
    }
    
    // one can fetch the list of Patients here.
    function getListOfPatientsForThisDoctor() constant returns(address[]){
        return AddressOfPatients[msg.sender];
        
    }
}