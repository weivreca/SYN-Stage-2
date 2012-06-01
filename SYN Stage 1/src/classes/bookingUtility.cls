public class bookingUtility {

// adds a unique acceptance and rejection code for use in sites page
	public static void calculateCodes(List<Booking__c> bList, List<Booking__c> bListOld){
		for(Integer i=0; i<bList.size(); i++){
	        Boolean genCodes = true;
	        if(Trigger.isUpdate){ // old map exists
	        	if(bList[i].Trainer__c == bListOld[i].Trainer__c) genCodes = false;
	        }
	        if(genCodes) {
	        	// generate new codes - acceptance code first
	        	DateTime now = System.now();
	        	Integer randm = Integer.valueOf(math.random()*100000);
		        String formattednow = now.formatGmt('yyyy-MM-dd')+'T'+ now.formatGmt('HH:mm:ss')+'.'+now.formatGMT('SSS')+'Z';
		        String canonical = UserInfo.getUserId() + formattednow + String.valueOf(randm);
		        Blob bsig = Crypto.generateDigest('MD5', Blob.valueOf(canonical));
		        String token = EncodingUtil.base64Encode(bsig);
		        if(token.length() > 255){token=token.substring(0,254);}
		        bList[i].AcceptanceCode__c=Encodingutil.urlEncode(token,'UTF-8').replaceAll('%','_');
		        // then rejection code
		        now = System.now();
	        	randm = Integer.valueOf(math.random()*100000);
		        formattednow = now.formatGmt('yyyy-MM-dd')+'T'+ now.formatGmt('HH:mm:ss')+'.'+now.formatGMT('SSS')+'Z';
		        canonical = UserInfo.getUserId() + formattednow + String.valueOf(randm);
		        bsig = Crypto.generateDigest('MD5', Blob.valueOf(canonical));
		        token = EncodingUtil.base64Encode(bsig);
		        if(token.length() > 255){token=token.substring(0,254);}
		        bList[i].RejectionCode__c=Encodingutil.urlEncode(token,'UTF-8').replaceAll('%','_');
		        
	        }
	    }
    	return;
	}
}