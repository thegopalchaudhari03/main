public with sharing class OpenCageGeocoderService {
    public static void reverseGeoCoding(String accId){
        try {
                Account accRec = [SELECT Id, Location__Latitude__s, Location__Longitude__s 
                                    FROM 
                                        Account 
                                    WHERE Id =: accId WITH System_mode LIMIT 1];
                String queryParam = accRec.Location__Latitude__s + ',' + accRec.Location__Longitude__s;
                HttpRequest httpReq = new HttpRequest();
                httpReq.setEndpoint(System.Label.OPENCAGE_API_URL+'?key='+System.Label.OPENCAGE_API_KEY+'&q='+queryParam+'&pretty=1');
                httpReq.setMethod('GET');
                httpReq.setHeader('Content-Type', 'application/json');
                httpReq.setHeader('Accept', 'application/json');
    
                Http http = new Http();
                HttpResponse response = http.send(httpReq);
                String responseBody = response.getBody();
                Integer statusCode = response.getStatusCode();
    
                if(statusCode == 200) {
                    OpenCageGeocoderService wrapper = (OpenCageGeocoderService)JSON.deserialize(responseBody, OpenCageGeocoderService.class);
                    if(wrapper?.results?.size() > 0){
                        accRec.BillingStreet = wrapper?.results[0]?.components?.house_number + ' ' + wrapper?.results[0]?.components?.road;
                        accRec.BillingCity = wrapper?.results[0]?.components?.city;
                        accRec.BillingPostalCode = wrapper?.results[0]?.components?.postcode;
                        accRec.BillingCountry = wrapper?.results[0]?.components?.country;
                        accRec.BillingCountryCode = wrapper?.results[0]?.components?.country_code;
                        update accRec; 
                    }
                    
                } else {
                    System.debug('Error: ' + responseBody);
                }
            } catch (System.CalloutException e) {
                System.debug('Callout error: ' + e.getMessage());
            } catch (Exception e) {
            	System.debug('Error: ' + e.getMessage());
        	}
    }
	
    public static void forwardGeocoding(String accId){
        Account accRec = [Select Id, BillingStreet, BillingCity, BillingPostalCode, BillingCountry From Account Where Id =: accId With System_mode Limit 1];
        String address = accRec.BillingStreet +', '+ accRec.BillingPostalCode +''+ accRec.BillingCity + ', '+ accRec.BillingCountry;
        try{
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            
            req.setEndpoint(System.Label.OPENCAGE_API_URL + '?key='+System.Label.OPENCAGE_API_KEY+'&q='+ EncodingUtil.urlEncode(address, 'UTF-8')+'&pretty=1');
        	req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            req.setMethod('GET');
            res = http.send(req);
            String responseBody = res.getBody();
            Integer statusCode = res.getStatusCode();
            system.debug('>>>ResponseBody' + responseBody);
            try{
            	if(statusCode == 200) {
                    OpenCageGeocoderService wrapper = (OpenCageGeocoderService)JSON.deserializeStrict(responseBody, OpenCageGeocoderService.class);
                    if(wrapper?.results?.size() > 0){
                        accRec.ShippingStreet = wrapper?.results[0]?.components?.road;
                        accRec.ShippingCity = wrapper?.results[0]?.components?.city;
                        accRec.ShippingPostalCode = wrapper?.results[0]?.components?.postcode;
                        accRec.ShippingCountry = wrapper?.results[0]?.components?.country;
                        accRec.ShippingCountryCode = wrapper?.results[0]?.components?.country_code;
                        update accRec; 
                    }
                    
                } else {
                    System.debug('Error: ' + responseBody);
                }
            }catch(System.JSONException e){
                System.debug('>>>json exception' + e.getMessage());
            }
        }Catch(System.calloutException cx){
            System.debug('>>>Callout Exception:'+ cx.getMessage());
        }
    }
	public results[] results;
	public class results {
		public components components;
		public Integer confidence;	
		public String formatted;	
		public geometry geometry;
	}
	public class components {
		public String borough;	//Pankow
		public String city;	//Berlin
		public String continent;	//Europe
		public String country;	//Germany
		public String country_code;	//de
		public String coworking_space;	//Office Club
		public String house_number;	//78/79
		public String neighbourhood;	//Bremer Höhe
		public String political_union;	//European Union
		public String postcode;	//10437
		public String quarter;	//Helmholtzkiez
		public String road;	//Pappelallee
		public String state;	//Berlin
		public String state_code;	//BE
		public String suburb;	//Prenzlauer Berg
	}
	public class geometry {
		public Double lat;	//52.5432379
		public Double lng;	//13.4142133
	}
}