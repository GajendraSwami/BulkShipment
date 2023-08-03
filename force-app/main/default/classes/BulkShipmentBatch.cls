public with sharing class BulkShipmentBatch implements Database.batchable<sObject>, Database.AllowsCallouts{
    private Set<ID> accIds;
    private Decimal totalWeight;
    private String serviceType;
    private String packagingType;
    private Date shipDate;
    private String docType;
    private Decimal declaredValue;
    private String itemDescription;

    public BulkShipmentBatch(
        Set<ID> accIds,
        Decimal totalWeight,
        String serviceType,
        String packagingType,
        Date shipDate,
        String docType,
        Decimal declaredValue,
        String itemDescription
    ) {
        this.accIds = accIds;
        this.totalWeight = totalWeight;
        this.serviceType = serviceType;
        this.packagingType = packagingType;
        this.shipDate = shipDate;
        this.docType = docType;
        this.declaredValue = declaredValue;
        this.itemDescription = itemDescription;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('oppIds =>' + accIds);
        return Database.getQueryLocator(
            'SELECT Id, Name, ShippingStreet, ShippingState, Email__c, ShippingCountry, Phone, Shipping_Name_for_dose__c, ShippingCity, ShippingPostalCode, Email FROM Account WHERE ID IN:accIds'
        );
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Account> accList = new List<Account>();
        for (sObject obj : scope) {
            Account acc = (Account) obj;
            try {
                createShipment(acc);
                acc.shipping_Label_Log__c = 'Success';
            } catch (Exception ex) {
                acc.shipping_Label_Log__c = ex.getMessage();
            }
            accList.add(acc);
        }
        update accList;
    }

    public String createShipment(Account acc) {
        List<Astonous_SM.RatingRequest.ShippingPackage> pkgLst = new List<Astonous_SM.RatingRequest.ShippingPackage>();
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

        String shipmentID;
        Astonous_SM.RatingRequest.ShippingPackage pkg = new Astonous_SM.RatingRequest.ShippingPackage();
        pkg.quantity = 1;
        pkg.weight = totalWeight;
        pkgLst.add(pkg);

        Astonous_SM.RatingRequest rr = new Astonous_SM.RatingRequest();
        rr.serviceType = serviceType;
        rr.shippingCarrier = 'FedEx';
        rr.GoodsDescription = itemDescription;
        rr.totalWeight = String.valueOf(totalWeight);
        rr.weightUnit = 'LB';
        rr.linearUnit = 'IN';
        rr.packagingType = packagingType;
        rr.dropoffType = 'REGULAR_PICKUP';
        rr.labelType = 'PDF';
        rr.signatureOption = 'SERVICE_DEFAULT';
        rr.stockType = 'PAPER_4X6';
        rr.formatType = 'COMMON2D';
        rr.printing_Orientation = 'TOP_EDGE_OF_TEXT_FIRST';

        rr.recipientInfomration = BulkShipmentCreation.getToAddress(acc);
        rr.currencyUnit = 'USD';
        rr.senderInfomration = BulkShipmentCreation.getDefaultAddress();
        rr.shipDate = shipDate;
        rr.packageList = pkgLst;
        shipmentID = Astonous_SM.ShippingController.processShipment(rr, acc.id);
        return shipmentID;
    }

    public void finish(Database.BatchableContext BC) {
    }

}