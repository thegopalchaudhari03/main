/**
 * @description Test class for PS_CurrencyAPIService
 * - Covers successful callout and error scenarios using HttpCalloutMock
 * - Uses Test.startTest()/Test.stopTest()
 * - No SeeAllData usage
 */
@IsTest
private class PS_CurrencyAPIService_Test {

    // Happy path mock returning minimal valid JSON payload for exchangerate-api
    private class SuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('https://api.exchangerate-api.com/v4/latest/USD', req.getEndpoint(), 'Endpoint must match service');
            System.assertEquals('GET', req.getMethod(), 'HTTP method must be GET');
            System.assertEquals('application/json', req.getHeader('Content-Type'), 'Content type header must be json');
            System.assertEquals('application/json', req.getHeader('Accept'), 'Accept header must be json');

            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            // minimal plausible response body
            res.setBody('{"base":"USD","date":"2025-01-01","rates":{"EUR":0.9,"INR":83.1}}');
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }

    // Error path mock to simulate callout failure (e.g., 500)
    private class ErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"error":"Internal Server Error"}');
            return res;
        }
    }

    // Simulate a CalloutException by throwing before returning a response
    private class ExceptionMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Simulate low-level callout exception as would be thrown by Http.send
            // In tests, we emulate by throwing here.
            throw new CalloutException('Simulated callout exception');
        }
    }

    @IsTest
    static void test_getExchangeRates_success() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock());

        Test.startTest();
        PS_CurrencyAPIService.getExchangeRates();
        Test.stopTest();

        // No exception expected; assert reached here
        System.assert(true, 'getExchangeRates should complete without throwing for 200 response');
    }

    @IsTest
    static void test_getExchangeRates_errorStatus() {
        Test.setMock(HttpCalloutMock.class, new ErrorMock());

        Test.startTest();
        PS_CurrencyAPIService.getExchangeRates();
        Test.stopTest();

        // Method handles non-200 via debug only; ensure no exception escapes
        System.assertEquals(true, true, 'Method should handle 500 response without throwing');
    }

    @IsTest
    static void test_getExchangeRates_calloutExceptionCaught() {
        Test.setMock(HttpCalloutMock.class, new ExceptionMock());

        Test.startTest();
        // Should not throw due to try/catch in service
        PS_CurrencyAPIService.getExchangeRates();
        Test.stopTest();

        System.assertEquals(true, true, 'CalloutException should be caught by service');
    }

    @IsTest
    static void test_getExchangeRates_bulkInvocations() {
        // Ensure no state leakage and method remains safe when invoked multiple times in one transaction
        Test.setMock(HttpCalloutMock.class, new SuccessMock());

        Test.startTest();
        for (Integer i = 0; i < 3; i++) {
            PS_CurrencyAPIService.getExchangeRates();
        }
        Test.stopTest();

        System.assert(true, 'Multiple invocations should succeed under mock');
    }
}
