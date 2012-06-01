trigger bookingTrigger on Booking__c (before insert, before update) {
	if(Trigger.isBefore){
    	if(Trigger.isInsert || Trigger.isUpdate){
    		bookingUtility.calculateCodes(Trigger.new, Trigger.old);
    	}
    } 
}