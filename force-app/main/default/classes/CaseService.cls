public without sharing class CaseService {
 
    @InvocableMethod(label='Retrieve Case Status based on user provided CaseNumber.'
                            description='Return Case Status based on user provided CaseNumber.')

    public static List<String> retrieveCaseStatus(List<String> caseNumberList) {
        List<Case> caseObjList = new List<Case>();
        caseObjList = [Select Id,Status FROM Case WHERE CaseNumber=:caseNumberList[0] LIMIT 1];
        
        if(caseObjList.size()>0){
            return (new List<String> {caseObjList[0].Status});
        }else{
            return (new List<String> {'Case Number is not valid.'});
        }
    }
}