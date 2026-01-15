public with sharing class PS_CurrencyAPIService {
    public static void getExchangeRates() {
        try {
            HttpRequest httpReq = new HttpRequest();
            httpReq.setEndpoint('https://api.exchangerate-api.com/v4/latest/USD');
            httpReq.setMethod('GET');
            httpReq.setHeader('Content-Type', 'application/json');
            httpReq.setHeader('Accept', 'application/json');

            Http http = new Http();
            HttpResponse response = http.send(httpReq);
            System.debug('Response: ' + response.getBody());
            System.debug('Status code: ' + response.getStatusCode());
        } catch (System.CalloutException e) {
            System.debug('Callout error: ' + e.getMessage());
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }  
    }
}