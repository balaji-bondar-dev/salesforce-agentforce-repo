public with sharing class WeatherAPICalloutOperations {
    public static void getInformation(String city) {
        System.debug('@@@@@@ Inside getInformation Method');
        String apiKey = '675f387fbad371dac9e42ce3107ab72f';
        String endpoint = 'https://openmap.org?city=' + city + '&appid=' + apiKey + '&units=metric';

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        System.debug('@@@@@@@request '+request);
        
        HttpResponse response = http.send(request);
        System.debug('@@@@@@response '+response.getBody());//response
        
        if (response.getStatusCode() == 200) {
            //Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            // Map your  logic here
            //System.debug('@@@@@@results '+results);//response
        }
   }
}