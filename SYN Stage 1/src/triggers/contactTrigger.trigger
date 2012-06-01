trigger contactTrigger on Contact (before insert,before update) {
    if(Trigger.isBefore){
    	if(Trigger.isInsert || Trigger.isUpdate){
    		contactUtility.calculateInviteCode(Trigger.new);
    	}
    } 
}