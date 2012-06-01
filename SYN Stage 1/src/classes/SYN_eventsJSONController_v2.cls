/*
    Created by TrueCloud Consulting
    
    Purpose is to return a list of events to a page, that in turn acts as a JSON feed to the fullCalendar app in main UI.
    used via javascript remoting.
    History:
    

*/

public class SYN_eventsJSONController_v2{

    @RemoteAction
    public static String validateBookingDrop(String bStart,String bEnd, String res, String eId, Boolean allDay)
    {
        if(!allDay){
	        String r1 = isOverlapping(bStart,bEnd, res, eId);
	        	if(r1.substring(0,3) == 'Err') return r1; // a DML error has occured
	        	if(r1 == 'TRUE') return 'Sorry. Cant drop bookings over other bookings. Please try again.'; // prevent overlap
	        	// ignore false - all ok
	        String r3 = isPastMaxBooking(bStart,bEnd,res,eId);
	        	if(r3.substring(0,3) == 'Err') return r3; // a DML error has occured
	        	if(r3 == 'TRUE') return 'Sorry. You have reached the maximum bookings allowed for this resource.'; // prevent overlap
	        	// ignore false - all ok
	        
	        return 'TRUE'; // all good - confirmation msg on vf page.
	        } else {
	        	return 'Sorry - can\'t make all day bookings';
	        }
    }
    
    @RemoteAction
    public static String validateBookingResize(String bStart,String bEnd, String res, String eId)
    {
        String r1 = isOverlapping(bStart,bEnd, res, eId);
        	if(r1.substring(0,3) == 'Err') return r1; // a DML error has occuredif(r1 == 'TRUE') return 'Sorry. Cant drop bookings over other bookings. Please try again.'; // prevent overlap
        	if(r1 == 'TRUE') return 'Sorry. Cant drop bookings over other bookings. Please try again.'; // prevent overlap
        	// ignore false - all ok
        String r2 = isPastDuration(bStart,bEnd, res);
        	if(r2.substring(0,3) == 'Err') return r2; // a DML error has occured
        	if(r2 == 'TRUE') return 'Sorry. Cant book this resource for that long. Please reduce booking time.'; // prevent overlap
       		// ignore false - all ok
          
        return 'TRUE'; // all good - confirmation msg on vf page.    
    }
    
    @RemoteAction
    public static String validateBookingCreate(String bStart,String bEnd, String res, Boolean allDay, String prog)
    {
        if(!allDay){
        	if(prog != ''){
		        String r1 = isOverlapping(bStart,bEnd, res, ''); 
		        	if(r1.substring(0,3) == 'Err') return r1; // a DML error has occured
		        	if(r1 == 'TRUE') return 'Sorry. Cant drop bookings over other bookings. Please try again.'; // prevent overlap
		        	// ignore false - all ok
		        String r2 = isPastDuration(bStart,bEnd, res);
		        	if(r2.substring(0,3) == 'Err') return r2; // a DML error has occured
		        	if(r2 == 'TRUE') return 'Sorry. Cant book this resource for that long. Please reduce booking time.'; // prevent overlap
		       		// ignore false - all ok
		        String r3 = isPastMaxBooking(bStart,bEnd,res,'');
		        	if(r3.substring(0,3) == 'Err') return r3; // a DML error has occured
		        	if(r3 == 'TRUE') return 'Sorry. You have reached the maximum bookings allowed for this resource.'; // prevent overlap
		        	// ignore false - all ok
		        
	        	return 'TRUE'; // all good - confirmation msg on vf page.  
        	} else {
        		return 'Please select the Program that this booking relates to from picklist. If the program is not in list or the booking is not related to a program please contact SYN.';
        	}    
        } else {
        	return 'Sorry - can\'t make all day bookings.';
        }
    }
    
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
    
    @RemoteAction
    public static String createBooking(String bStart,String bEnd, String btype, String res, String prog){
         	String selShort = res.substring(0,15);
            Datetime s = datetime.parse(bStart);
            Datetime e = datetime.parse(bEnd);
            Booking__c newBooking = new Booking__c(StartDateTime__c = s, EndDateTime__c = e, Booking_Type__c = btype, Resource__c = res, Program__c = prog);
            try {
                insert newBooking;
            } catch (exception ex){
            return 'Error:'+ex;
            }
            return String.valueOf(newBooking.id);
    }
    
    @RemoteAction
    public static String updateBooking(String bStart,String bEnd, String bId){
            Datetime s = datetime.parse(bStart);
            Datetime e = datetime.parse(bEnd);
            try{
                Booking__c uBooking = [Select Id,StartDateTime__c,EndDateTime__c from Booking__c where Id=:bId limit 1];
                uBooking.StartDateTime__c = s;
                uBooking.EndDateTime__c = e;
                try {
                    update uBooking;
                } catch (exception ex){
                    return 'Error:'+ex;
                }
                return String.valueOf(uBooking.id);
            } catch (exception ex){
                return 'Error:'+ex;
            }
            
            
    }
    
    
    @RemoteAction
    public static String deleteBooking(String bId){
            Booking__c delBooking = [Select id from Booking__c where id=:bId limit 1];
            try {
                delete delBooking;
            } catch (exception ex){
            return 'Error:'+ex;
            }
            return 'SUCCESS';
    }
    
    public String resourceLabel {
    get{
    if (resourceLabel == null){
        resourceLabel = '';
        if(sel != null && sel != ''){
            resourceLabel = [Select name from Resource__c where id =:sel limit 1].name;
        }
    }
    return resourceLabel;
    }
    private set;
    }
    public String resourceNotes {
    get{
    if (resourceNotes == null){
        resourceNotes = '';
        if(sel != null && sel != ''){
            resourceNotes = [Select Notes__c from Resource__c where id =:sel limit 1].Notes__c;
        }
    }
    return resourceNotes;
    }
    private set;
    }
    
    public String sel {get; set;}
    public String resourceId {get;set;}
    public List<Booking__c> bookings {get;set;}
    public String booking{get;set;}
    public String programId {
    	get{
    		if (programId == null) programId = '';
    		return programId; 
    	} 
    	set;
    }
    public SYN_eventsJSONController_v2(){sel = ApexPages.currentPage().getParameters().get('r');} // empty as is for remoting
    
    // used to confirm whether a booking overlaps other bookings
    public static String isOverlapping(String bStart,String bEnd, String res, String eId){
            Datetime s = datetime.parse(bStart);
            Datetime e = datetime.parse(bEnd);
            Integer c = 0;
            // if c > 0 then we have a conflict
            try{
                c = [Select COUNT() from Booking__c where Resource__c =:res 
                                                            and (
                                                            (StartDateTime__c >=:s and StartDateTime__c <:e and EndDateTime__c >=:e)
                                                         or (StartDateTime__c <:s and EndDateTime__c >:s and EndDateTime__c <=:e ) 
                                                         or (StartDateTime__c >=:s and StartDateTime__c <:e and EndDateTime__c <=:e)
                                                         or (StartDateTime__c <=:s and EndDateTime__c >=:e)
                                                            )
                                                            and id !=:eId];
                system.debug('total overlap records found for resource '+res+' ='+c);
                if(c>0){
                	system.debug('overlap returns TRUE');
                    return 'TRUE';
                } else {
                	system.debug('overlap returns FALSE');
                    return 'FALSE';
                }
            } catch(Exception ex){
            	system.debug('overlap returns Error:'+ex);
                return 'Error:'+ex;
            }
    }
    
    // used to check if a booking exceeds maximum allowed booking time
    public static String isPastDuration(String bStart,String bEnd, String res){
        Datetime s = datetime.parse(bStart);
        Datetime e = datetime.parse(bEnd);
        try{
        	Resource__c r;
            r = [Select id,MaxDuration__c from Resource__c where id =:res limit 1];
            if( r.id != null){
            Decimal dur = r.MaxDuration__c; // this is in hrs
            system.debug('check='+(e.getTime() - s.getTime())/1000/60/60);
                if((e.getTime() - s.getTime())/1000/60/60 > dur){
                    system.debug('ispastduration returns TRUE');
                    return 'TRUE'; // exceeds time allowed
                } else {
                    system.debug('ispastduration returns FALSE');
                    return 'FALSE';
                } 
            } else {
                system.debug('ispastduration returns FALSE');
                return 'FALSE'; // no maximum time, so always false.
            }
        } catch (exception ex){
            system.debug('ispastduration returns Error:'+ex);
            return 'Error:'+ex;
        }
    }
    
    
    // checks to see if user has already logged max number of forward bookings for a given resource
    public static String isPastMaxBooking(String bStart, String bEnd, String res, String eId){
        Datetime s = datetime.parse(bStart);
        Datetime e = datetime.parse(bEnd);
        try{
        	List<Booking__c> bookings = new List<Booking__c>();
            // look for forward bookings by this user for this resource
            bookings = [select id, Resource__r.MaxBookings__c from Booking__c where StartDateTime__c >:datetime.now() and Resource__c =:res and CreatedById =:UserInfo.getUserId() and id !=:eId];
            Integer newPos = 0;
            if(s>=datetime.now()) newPos = 1;
            Integer forwardBookings = bookings.size() + newPos;
            system.debug('forwardbookings ='+forwardBookings);
            system.debug('bookingscount='+bookings.size());
            if(bookings.size()>0){
                if(bookings[0].Resource__r.MaxBookings__c != null){
                    if(forwardBookings > bookings[0].Resource__r.MaxBookings__c){
                        system.debug('isPastBooking returns TRUE');
                        return 'TRUE'; // exceeds bookings allowed
                    } else {
                        system.debug('isPastBooking returns FALSE');
                        return 'FALSE';
                    } 
                } else {
                    system.debug('isPastBooking returns FALSE');
                    return 'FALSE'; // null, so no maximum bookings enforced.
                }
            } else {
                system.debug('isPastBooking returns FALSE');
                return 'FALSE'; // no bookings, so ok to add one.
            }
        } catch (exception ex){
            system.debug('isPastBooking returns Error:'+ex);
            return 'Error:'+ex;
        }
    }
    
    
    
    
    public pageReference refreshView(){
        sel = ApexPages.currentPage().getParameters().get('r');
        return null;
    }
    
    public List<SelectOption> getChoices(){
        
        // populates a picklist with resources that the user has access to
        
        String btype = ApexPages.currentPage().getParameters().get('type');
        List<SelectOption> o = new List<SelectOption>();
        
        List<Resource__c> rList = new List<Resource__c>();
        rList = [Select r.Id, r.Name,r.Requires_Endorsement__c, (Select User__c From Endorsements__r) From Resource__c r where r.Type__c =: btype];
        if(rList.size()>1) o.add(new SelectOption('','-- None --'));
        for(Resource__c r : rList){
            if(!r.Requires_Endorsement__c){
                o.add(new SelectOption(r.Id, r.Name));
            } else {
                for(Endorsement__c e : r.Endorsements__r){
                    if(e.User__c == UserInfo.getUserId()) o.add(new SelectOption(r.name, r.name));
                }
            }
        }
        return o;
    }
    
    
    public List<SelectOption> getPrograms(){
        
        // populates a picklist with programs
        
        List<SelectOption> o = new List<SelectOption>();
        
        List<Program__c> pList = new List<Program__c>();
        pList = [Select p.Id, p.Name From Program__c p ];
        if(pList.size()>1) o.add(new SelectOption('','-- None --'));
        for(Program__c p : pList) o.add(new SelectOption(p.Id, p.Name));
        return o;
    }
    
    
       
    
}