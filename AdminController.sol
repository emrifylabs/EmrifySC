pragma solidity ^0.4.0;
// this controller shall allow Hostpital's entry in the system. 
// & then only the hospitals shall be able to start functioning in the etheruem ecosystem.

contract AdminController {
    // Emrify shall be admin here
    address public admin;
    
    //New Variables from yesterday
    enum State { Pending, Accepted, Rejected, Terminated } 
    uint256 totalPendingCount;
    // Emrify shall add those people who can push claim against the registered Providers, Nobody Else should be able to do it    
    mapping(address => bool ) public AdminGroup; 
    
    
    struct providerDetail{
    address providerAddress;
    State state;
    bool isRegistered;
    bool isOrganization;
    string IPFSApprovalDocumentHash;
    string IPFSRemovalDocumentHash;
    // address[] sisteBranchesOfHospital;// will use later to add multiple branches of the same hospital
}
    
    modifier onlyAdmin() {
        require(isAdmin(msg.sender));
        _;
    }

    // this condition makes sure that the operation can be done by any of the designated address
    // they are having Admin previlleges
    function isAdmin(address addr) public returns(bool) { 
        return addr == admin ||  AdminGroup[addr] == true ; 
        
    }

    // transfer ownership function
    function transferOwnership(address _newAdmin) public onlyAdmin {
        if (_newAdmin != address(this)) {
            admin = _newAdmin;
        }
    }
    
    function AdminController(){
        admin = msg.sender; 
    }
    

    
    mapping (address => providerDetail) public WhiteListedProviders;
    
    
    // this group tomorrow shall handle the pressure of 
    function addAdminGroup(address _newAdminAddress) onlyAdmin {
        AdminGroup[_newAdminAddress] = true;
    }
    
    // Step 1:
    function submitRequestForApproval(bool _isOrg, string _ProviderDetailsIPFShash){
        WhiteListedProviders[msg.sender].isOrganization = _isOrg;
        WhiteListedProviders[msg.sender].state = State.Pending;
        WhiteListedProviders[msg.sender].providerAddress = msg.sender;
        WhiteListedProviders[msg.sender].IPFSApprovalDocumentHash = _ProviderDetailsIPFShash;
        totalPendingCount++;
    }
    
    //Step 2-a:
    //this function shall be called by Emrify to add the address of the hospital in the whitelist hospitals
    function approveProviderApplication(address _providerAddress) onlyAdmin  {
        WhiteListedProviders[_providerAddress].state = State.Accepted;
        WhiteListedProviders[_providerAddress].isRegistered = true;
        totalPendingCount--;
        // fire an event with `isORg` variable so that we can identify that he is and org or not
        
        
    }
    
    
    //Step 2-b:
    function rejectProviderApplication(address _providerAddress) onlyAdmin  {
        WhiteListedProviders[_providerAddress].state = State.Rejected;
        WhiteListedProviders[_providerAddress].isRegistered = false;
        totalPendingCount--;
        
    } 
    
    
    // This is the case when we want to terminate the relationship from the Network 
    function terminateProviderFromNetwork(address _providerAddress, string _supportingRejectingDocument) onlyAdmin {
        WhiteListedProviders[_providerAddress].state = State.Terminated;
        WhiteListedProviders[_providerAddress].isRegistered = false;
        WhiteListedProviders[_providerAddress].IPFSRemovalDocumentHash = _supportingRejectingDocument;
        
    }
    
    
    
    
}
