public with sharing class AccountEditController{
	public Account acc{get;set;}
	public String mode{get;set;}
	private ApexPages.StandardController con{get;set;}

	public AccountEditController(ApexPages.StandardController con){
		this.con = con;
		Id aId = con.getId();
		this.acc = [SELECT Id, Name, Importance__c, Badge__c FROM Account WHERE Id = :aId];
		mode = 'display';
	}

	public PageReference save(){
		//Doesn't enforce CRUD/FLS
		//update acc;
		
		//Enforces CRUD/FLS
		
		SObjectAccessDecision decision = Security.stripInaccessible(
			AccessType.UPDATABLE,
			new Account[]{acc}
		);

		acc = (Account)decision.getRecords()[0];

		update acc;

		acc.recalculateFormulas();
		mode = 'display';
		return null;
	}

	public PageReference edit(){
		mode = 'edit';
		return null;
	}
}