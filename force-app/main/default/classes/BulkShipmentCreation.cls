public with sharing class BulkShipmentCreation {
    public List<Account> accList { get; set; }
    public Astonous_SM__Shipment__c shipment { get; set; }
    public Decimal declaredValue { get; set; }
    public String docType { get; set; }
    public Decimal totalWeight { get; set; }
    public Boolean shipmentCreated { get; set; }

    public BulkShipmentCreation(ApexPages.StandardSetController stdSetController) {
        accList = (List<Account>) stdSetController.getSelected();
        accList = [
            SELECT ID, Name, ShippingCity, Shipping_Name_for_dose__c, Email__c, Phone, ShippingStreet, ShippingState, ShippingCountry, ShippingPostalCode
            FROM Account
            WHERE ID IN :accList
        ];
        shipment = new Astonous_SM__Shipment__c();
        shipment.Astonous_SM__Shipping_Career__c = 'FedEx';
        shipment.Astonous_SM__Shipment_Packaging_Type__c = 'YOUR_PACKAGING';
        shipment.Astonous_SM__Ship_Date__c = system.today();
        shipment.Astonous_SM__Shipment_Service_Type__c = 'PRIORITY_OVERNIGHT';
        totalWeight = 1;
        shipment.Astonous_SM__Goods_Description__c = 'Document Papers';
        shipmentCreated = false;
    }

    public PageReference createShipments() {
        if (shipment.Astonous_SM__Shipment_Service_Type__c.equalsIgnoreCase('All')) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please select Shipment Service Type'));
        }
        try {
            for (Account acc : accList) {
                validateAddress(getToAddress(acc), acc);
            }
            if (ApexPages.getMessages().size() > 0) {
                return null;
            }
            Set<ID> accIds = new Set<ID>();
            for (Account acc : accList) {
                accIds.add(acc.id);
            }
            BulkShipmentBatch shippingBatch = new BulkShipmentBatch(
                accIds,
                totalWeight,
                shipment.Astonous_SM__Shipment_Service_Type__c,
                shipment.Astonous_SM__Shipment_Packaging_Type__c,
                shipment.Astonous_SM__Ship_Date__c,
                docType,
                declaredValue,
                shipment.Astonous_SM__Goods_Description__c
            );
            Database.executeBatch(shippingBatch, 1);

            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.Info, 'Shipping Label creation request has been submitted for all selected records.')
            );
            shipmentCreated = true;
        } catch (Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error, ex.getMessage()));
        }
        return null;
    }

    public static Astonous_SM.Address getDefaultAddress() {
        List<Astonous_SM__Shipping_Preference__c> preferenceList = [
            SELECT
                ID,
                Name,
                Astonous_SM__Company__c,
                Astonous_SM__Contact_Person_Name__c,
                Astonous_SM__City__c,
                Astonous_SM__Country__c,
                Astonous_SM__Email__c,
                Astonous_SM__Is_it_Residential_Address__c,
                Astonous_SM__Phone__c,
                Astonous_SM__Postal_Code__c,
                Astonous_SM__State__c,
                Astonous_SM__Street__c
            FROM Astonous_SM__Shipping_Preference__c
            WHERE Astonous_SM__Default__c = TRUE
        ];
        Astonous_SM.RatingRequest rr = new Astonous_SM.RatingRequest();
        Astonous_SM.Address addressInstance = rr.recipientInfomration;
        addressInstance.city = preferenceList[0].Astonous_SM__City__c;
        addressInstance.contactPersonName = preferenceList[0].Astonous_SM__Contact_Person_Name__c;
        addressInstance.email = preferenceList[0].Astonous_SM__Email__c;
        addressInstance.companyName = preferenceList[0].Astonous_SM__Company__c;
        addressInstance.phoneNumber = preferenceList[0].Astonous_SM__Phone__c;
        addressInstance.streetLine = preferenceList[0].Astonous_SM__Street__c;
        addressInstance.state = preferenceList[0].Astonous_SM__State__c;
        addressInstance.country = preferenceList[0].Astonous_SM__Country__c;
        addressInstance.postalCode = preferenceList[0].Astonous_SM__Postal_Code__c;
        return addressInstance;
    }
    public static Astonous_SM.Address getToAddress(Account acc) {
        Astonous_SM.RatingRequest rr = new Astonous_SM.RatingRequest();
        Astonous_SM.Address addressInstance = rr.recipientInfomration;
        addressInstance.city = acc.ShippingCity; // city
        addressInstance.contactPersonName = acc.Shipping_Name_for_dose__c; // name
        addressInstance.email = acc.Email__c;
        addressInstance.phoneNumber = acc.Phone; //phone
        addressInstance.streetLine = acc.ShippingStreet;
        addressInstance.state = acc.ShippingState;
        addressInstance.country = acc.ShippingCountry;
        addressInstance.postalCode = acc.ShippingPostalCode;
        return addressInstance;
    }

    private static void validateAddress(Astonous_SM.Address addressInstance, Account acc) {
        if (String.isBlank(addressInstance.contactPersonName)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error, acc.Name + ': Contact person name missing.'));
        }
        if (String.isBlank(addressInstance.city)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error, acc.Name + ': City is missing.'));
        }
        if (String.isBlank(addressInstance.phoneNumber)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error, acc.Name + ': Phone number is missing.'));
        }
        if (String.isBlank(addressInstance.state)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error, acc.Name + ': State is missing.'));
        }
        if (String.isBlank(addressInstance.postalCode)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error, acc.Name + ': Postal Code is missing.'));
        }
        if (String.isBlank(addressInstance.country)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error, acc.Name + ': Country is missing.'));
        }
        if (String.isBlank(addressInstance.streetLine)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.error, acc.Name + ': Address Street is missing.'));
        }
    }

}