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
                    accRec.BillingState = wrapper?.results[0]?.components?.state;
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