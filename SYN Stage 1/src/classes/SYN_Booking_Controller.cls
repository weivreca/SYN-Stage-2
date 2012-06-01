/***********************************
 *
 * Created by TrueCloud Consulting
 *
 * Purpose - container class for all logic required within MMS replacement portal environment
 *
 * History
 *
 *
 ***********************************/


public class SYN_Booking_Controller
{
    
    public Booking__c booking {get;set;}
    public String res {get;set;}
    
    
    // method to convert into US format, so can utilise std methods on apex datetime.
    public Datetime convertToDateTime(String s){
    // format provided by fullcalendar is 'MM-dd-yyyy HH:mm:ss' 
        String [] components = s.split(' '); // break into date and time
        String [] dateParts = components[0].split('-'); // split into day/month/year
        String [] timeParts = components[1].split(':'); // split into hrs/min/sec
        
        // reconstruct
        datetime dt = datetime.newInstance(Integer.valueOf(dateParts[2]),Integer.valueOf(dateParts[0]),Integer.valueOf(dateParts[1]),
                                           Integer.valueOf(timeParts[0]),Integer.valueOf(timeParts[1]),Integer.valueOf(timeParts[2])
                                          );
        return dt;
    }
    
    // page controller
    public SYN_Booking_Controller(){
    
        if(booking == null){
            Datetime sdt = convertToDateTime(EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('start'),'UTF-8'));
            Datetime edt = convertToDateTime(EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('end'),'UTF-8'));
            res = ApexPages.currentPage().getParameters().get('r');
            
            booking = new Booking__c(Booking_Type__c = ApexPages.currentPage().getParameters().get('type'),
                                     StartDateTime__c = sdt,
                                     EndDateTime__c = edt,
                                     Resource__c = res
                                    );                    
        }
        
        
        
        
    }
    
    // booking page 
    public PageReference save() 
    {
        PageReference pr;
       try 
       {
           insert booking;
           if(booking.Booking_Type__c == 'studio')
           {
               pr = Page.SYN_Home_StudioBook;
           }
           else
           {
               pr = new PageReference('/SYN_Home_EquipBook?type=equipment&r=' + res);   //Page.SYN_Home_EquipBook?r=res;   
           }   
       } 
       catch(System.DMLException e)
       {
           ApexPages.addMessages(e);
           return null;
       }
       return pr;
    }
    //Is the booking in the allowable booking range?
    
    //Is the booking longer than the allowable booking duration?
    
    //Does the booking overlap an existing booking?
    
    //Has the user reached their max number of bookings allowed?
    
    // booking page
    public pageReference cancel(){
        return new PageReference('/SYN_Home');
    }
    
   

}