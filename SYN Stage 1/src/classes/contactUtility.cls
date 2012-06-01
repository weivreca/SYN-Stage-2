public  class contactUtility {

	// adds a unique id for use in sites page
	public static void calculateInviteCode(List<Contact> cList){
		for(Contact c : cList){
	        if(c.External_Contact_Code__c == null) {
	        	DateTime now = System.now();
	        	Integer randm = Integer.valueOf(math.random()*100000);
		        String formattednow = now.formatGmt('yyyy-MM-dd')+'T'+ now.formatGmt('HH:mm:ss')+'.'+now.formatGMT('SSS')+'Z';
		        String canonical = UserInfo.getUserId() + c.LastName + formattednow + String.valueOf(randm);
		        Blob bsig = Crypto.generateDigest('MD5', Blob.valueOf(canonical));
		        String token = EncodingUtil.base64Encode(bsig);
		        if(token.length() > 255){token=token.substring(0,254);}
		        c.External_Contact_Code__c=Encodingutil.urlEncode(token,'UTF-8').replaceAll('%','_');
	        }
	    }
    	return;
	}
}