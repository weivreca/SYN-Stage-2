/*
    Created by TrueCloud Consulting
    
    Purpose is to return a list of events to a page, that in turn acts as a JSON feed to the fullCalendar app in main UI.
    used via javascript remoting.
    History:
    

*/

public class SYN_soaJSONController{

    @RemoteAction
    public static List<Booking__c> getBookings(String bStart,String bEnd, String btype, String res){
            //system.debug('sel='+selxx);
            //selxx = ApexPages.currentPage().getParameters().get('r');
            Datetime s = datetime.valueOf(bStart);
            Datetime e = datetime.valueOf(bEnd);
            List<Booking__c> bList = new List<Booking__c>();
            List<Booking__c> bb = new List<Booking__c>();
            bb = [select Id,name,start__c, Resource__r.MaxDuration__c, Program__r.Name, UserIsOwner__c, end__c,StartDateTime__c, EndDateTime__c,CreatedById,CreatedBy.Name,Booking_Name__c from Booking__c where Resource__c =:res ];
                for(Booking__c b : bb){
                   b.start__c = b.StartDateTime__c.format('MM-dd-yyyy HH:mm:ss');
                   b.end__c = b.EndDateTime__c.format('MM-dd-yyyy HH:mm:ss');
                   bList.add(b);
                }
            
            return bList;
    }
    
 
}