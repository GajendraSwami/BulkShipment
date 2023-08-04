How to implement bulk shipment

Bulk shipment will let you create shipments from any objects list view. You need to call Asotnous shipping app global methods and write your decorator to call Astonous global methods. Here are steps outlined for self developing this feature and as an alternative you can always ask our support to implement it for you.


Step1: Copy code from below Repository. 

Repo has the following 3 resources that will be adjusted according to your  
           specific needs. Those classes are made for adding Bulk Shipment on Standard 
           Account Object.

 GitHub: https://github.com/GajendraSwami/BulkShipment

BulkShipmentCreationPage.page :- This is a VF page where you can customize Service name, carrier name, packaging type, total weight and ship date etc.

BulkShipmentCreation.cls :-  In this Apex controller you can change names according to  your object and its fields. Also you can change the hardcoded things like Service type, Packaging type, Shipping Carrier etc.

BulkShipmentBatch.cls:-  In this Batch class you can change the hardcoded things like shipping carrier, weight unit, linear unit, label type, dropoffType etc. according to your specific needs.

 Create Shipping Label Log field on Account object to show success or error message.

 Here is the Link for detailed documentation: https://docs.google.com/document/d/1fsUdTSwz0ZCq3P8fVyUzqVcquhoW9JGXNYfrArMU-EE/edit
