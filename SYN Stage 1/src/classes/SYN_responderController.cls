public class SYN_responderController{
	// strip off the param and confirm if accepted or rejected against booking
	public void processResponse(){
		String resp = ApexPages.currentPage().getParameters().get('r');
		Booking__c b;
		try {
				b = [Select id, Status__c from Booking__c where AcceptanceCode__c =:resp limit 1];
			if(b.id != null){
				b.Status__c = 'Confirmed';
				update b;
			} else 
			{
				b = [Select id,Status__c from Booking__c where RejectionCode__c =:resp limit 1];
				if(b.id != null){
					b.Status__c = 'Rejected';
					update b;
				}
			}
		}
		catch (exception e){
			system.debug('DML error - no record with this token, so ignore');
		}
	}
	
	
	
}