/*
    Created by TrueCloud Consulting
    
    Purpose is to return a list of events to a page, that in turn acts as a JSON feed to the fullCalendar app in main UI.
    used via javascript remoting.
    History:
    

*/

public with sharing class SYN_eventsJSONController{

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
    public SYN_eventsJSONController(){sel = ApexPages.currentPage().getParameters().get('r');} // empty as is for remoting
    
    
    @RemoteAction
    public static List<Booking__c> getBookings(String bStart,String bEnd, String btype, String res){
            //system.debug('sel='+selxx);
            //selxx = ApexPages.currentPage().getParameters().get('r');
            String selShort = res.substring(0,15);
            Datetime s = datetime.valueOf(bStart);
            Datetime e = datetime.valueOf(bEnd);
            List<Booking__c> bList = new List<Booking__c>();
            List<Booking__c> bb = new List<Booking__c>();
            bb = [select Id,name,start__c, Resource__r.MaxDuration__c, UserIsOwner__c, end__c,StartDateTime__c, EndDateTime__c,CreatedById,CreatedBy.Name from Booking__c where StartDateTime__c >=:s and Booking_Type__c =:btype and Resource__c =:selShort ];
                for(Booking__c b : bb){
                   b.start__c = b.StartDateTime__c.format('MM-dd-yyyy HH:mm:ss');
                   b.end__c = b.EndDateTime__c.format('MM-dd-yyyy HH:mm:ss');
                   bList.add(b);
                }
            
            return bList;
    }
    
    @RemoteAction
    public static String createBooking(String bStart,String bEnd, String btype, String res, String prog){
            system.debug('res='+res);
            String selShort = res.substring(0,15);
            system.debug(bStart);
            system.debug(bEnd);
            Datetime s = datetime.parse(bStart);
            Datetime e = datetime.parse(bEnd);
            Booking__c newBooking = new Booking__c(StartDateTime__c = s, EndDateTime__c = e, Booking_Type__c = btype, Resource__c = res);
            
            // TODO - ? check prior to insert, or is this done client side?
            
            try {
                insert newBooking;
            } catch (exception ex){
            return 'Error';
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
                    return 'Error';
                }
                return String.valueOf(uBooking.id);
            } catch (exception ex){
                return 'Error';
            }
            
            
    }
    
    
    @RemoteAction
    public static String deleteBooking(String bId){
            Booking__c delBooking = [Select id from Booking__c where id=:bId limit 1];
            try {
                delete delBooking;
            } catch (exception ex){
            return 'Error';
            }
            return 'Success';
    }
    
    
    // used to confirm whether a booking overlaps other bookings
    @RemoteAction
    public static String isOverlapping(String bStart,String bEnd, String res){
            Datetime s = datetime.parse(bStart);
            Datetime e = datetime.parse(bEnd);
            String resShort = res.substring(0,15);
            Integer c = 0;
            // if c > 0 then we have a conflict
            try{
                c = [Select COUNT() from Booking__c where Resource__c =:resShort 
                                                            and (
                                                            (StartDateTime__c >:s and StartDateTime__c <:e and EndDateTime__c >:e)
                                                         or (StartDateTime__c <:s and EndDateTime__c >:s and EndDateTime__c <:e ) 
                                                         or (StartDateTime__c >:s and StartDateTime__c <:e and EndDateTime__c <:e)
                                                         or (StartDateTime__c <:s and EndDateTime__c >:e)
                                                            )];
                if(c>0){
                    return 'TRUE';
                } else {
                    return 'FALSE';
                }
            } catch(Exception ex){
                return 'ERROR';
            }
    }
    
    // used to check if a booking exceeds maximum allowed booking time
    @RemoteAction
    public static String isPastDuration(String bStart,String bEnd, String res){
        Datetime s = datetime.parse(bStart);
        Datetime e = datetime.parse(bEnd);
        try{
            Decimal dur = [Select MaxDuration__c from Resource__c where id =:res limit 1].MaxDuration__c;
            system.debug('dur='+dur);
            if( dur != null){
            system.debug('check='+(e.getTime() - s.getTime())/1000/60/60);
                if((e.getTime() - s.getTime())/1000/60/60 > dur){
                    return 'TRUE'; // exceeds time allowed
                } else {
                    return 'FALSE';
                } 
            } else {
                return 'FALSE'; // no maximum time, so always false.
            }
        } catch (exception ex){
            return 'ERROR';
        }
    }
    
    
    // checks to see if user has already logged max number of forward bookings for a given resource
    @RemoteAction
    public static String isPastMaxBooking(String res){
        String resShort = res.substring(0,15); 
        system.debug('res='+resShort);
        try{
        
            List<Booking__c> bookings = new List<Booking__c>();
            // look for forward bookings by this user for this resource
            bookings = [select id, Resource__r.MaxBookings__c from Booking__c where StartDateTime__c >:datetime.now() and Resource__c =:resShort and CreatedById =:UserInfo.getUserId()];
            if(bookings.size()>0){
                if(bookings[0].Resource__r.MaxBookings__c != null){
                    if(bookings.size() >= bookings[0].Resource__r.MaxBookings__c){
                        return 'TRUE'; // exceeds time allowed
                    } else {
                        return 'FALSE';
                    } 
                } else {
                    return 'FALSE'; // null, so no maximum bookings enforced.
                }
            } else {
                return 'FALSE'; // no bookings, so ok to add one.
            }
        } catch (exception ex){
            return 'ERROR';
        }
    }
    
    @RemoteAction
    public static String validateBookingDrop(String bStart,String bEnd, String res)
    {
        return 'TRUE';      
    }
    
    @RemoteAction
    public static String validateBookingResize(String bStart,String bEnd, String res)
    {
        return 'TRUE';      
    }
    
    @RemoteAction
    public static String validateBookingCreate(String bStart,String bEnd, String res)
    {
        return 'TRUE';      
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
        
        o.add(new SelectOption('','-- None --'));
        o.add(new SelectOption('1','Program 1'));
        o.add(new SelectOption('2','Program 2'));
        o.add(new SelectOption('3','Program 3'));
        o.add(new SelectOption('4','Program 4'));
        o.add(new SelectOption('5','Other'));
                
        return o;
    }
       
    
}