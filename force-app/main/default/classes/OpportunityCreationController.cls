public with sharing class OpportunityCreationController {
    private ApexPages.StandardController stdCon;
    public OpportunityContactRole role{get;set;}

    public OpportunityCreationController(ApexPages.StandardController stdCon) {
        this.stdCon = stdCon;
        this.role = new OpportunityContactRole();

    }

    public PageReference save()
    {
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<Schema.SObjectType>{
            Opportunity.SObjectType,
            OpportunityContactRole.SObjectType
        }
        , new MyDML()
        );

        Opportunity opp = (Opportunity)stdCon.getRecord();
        opp.Name = '' + DateTime.now().format();
        opp.StageName = 'Closed Won';
        
        role.Role = 'Influencer';

        System.debug('Opp before DML: ' + opp);
        System.debug('OCR before DML: ' + role);

        uow.registerNew(opp);
        uow.registerNew(role);
        uow.registerRelationship(role,OpportunityContactRole.OpportunityId,opp);

        uow.commitWork();

        return (new ApexPages.StandardController(opp)).view();
    }

    private class MyDML implements fflib_SObjectUnitOfWork.IDML
    {
        List<SObject> sanitize(List<SObject> objList){
            SObjectAccessDecision decision = Security.stripInaccessible(
                AccessType.CREATABLE,
                objList
            );

            return decision.getRecords();
        }

        public void dmlInsert(List<SObject> objList){
            //This is the problem .... 
            objList = sanitize(objList);
            System.debug('in dmlInsert: ' + objList);
            insert objList;
        }
        public void dmlUpdate(List<SObject> objList){

        }
        public void dmlDelete(List<SObject> objList){

        }
        public void eventPublish(List<SObject> objList){
            EventBus.publish(objList);
        }
    }
}
