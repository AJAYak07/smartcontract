// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PatientData {
    
    // Define a Patient struct to hold patient data
    struct Patient {
        string name;
        uint age;
        string medicalHistory;
        address[] authorizedProviders;
    }
    
    // Mapping from patient address to their data
    mapping(address => Patient) private patients;
    
    // Events to log actions
    event PatientDataAdded(address patientAddress, string name);
    event AccessGranted(address patientAddress, address provider);
    event AccessRevoked(address patientAddress, address provider);
    
    // Modifier to restrict function to the patient only
    modifier onlyPatient(address _patientAddress) {
        require(msg.sender == _patientAddress, "Only the patient can perform this action");
        _;
    }
    
    // Function to register a new patient
    function registerPatient(string memory _name, uint _age, string memory _medicalHistory) public {
        Patient storage newPatient = patients[msg.sender];
        newPatient.name = _name;
        newPatient.age = _age;
        newPatient.medicalHistory = _medicalHistory;
        
        emit PatientDataAdded(msg.sender, _name);
    }

    // Function to grant access to a healthcare provider
    function grantAccess(address _provider) public onlyPatient(msg.sender) {
        Patient storage patient = patients[msg.sender];
        patient.authorizedProviders.push(_provider);
        
        emit AccessGranted(msg.sender, _provider);
    }
    
    // Function to revoke access from a healthcare provider
    function revokeAccess(address _provider) public onlyPatient(msg.sender) {
        Patient storage patient = patients[msg.sender];
        for (uint i = 0; i < patient.authorizedProviders.length; i++) {
            if (patient.authorizedProviders[i] == _provider) {
                // Remove provider by swapping with the last element and reducing array length
                patient.authorizedProviders[i] = patient.authorizedProviders[patient.authorizedProviders.length - 1];
                patient.authorizedProviders.pop();
                
                emit AccessRevoked(msg.sender, _provider);
                break;
            }
        }
    }
    
    // Function to view patient data if authorized
    function viewPatientData(address _patientAddress) public view returns (string memory name, uint age, string memory medicalHistory) {
        Patient storage patient = patients[_patientAddress];
        
        // Check if the caller is authorized
        bool isAuthorized = false;
        for (uint i = 0; i < patient.authorizedProviders.length; i++) {
            if (patient.authorizedProviders[i] == msg.sender) {
                isAuthorized = true;
                break;
            }
        }
        
        require(isAuthorized, "You are not authorized to view this data");
        
        return (patient.name, patient.age, patient.medicalHistory);
    }
}
