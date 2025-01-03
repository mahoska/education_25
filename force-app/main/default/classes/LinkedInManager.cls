/**
 * @description       : test connect LincedIn; controller linkedIn_VFP page
 * @author            : Hanna Makhovska
 * @group             : 
 * @last modified on  : 01-03-2025
 * @last modified by  : Hanna Makhovska
**/
public class LinkedInManager {

  public string authCodeFromURL{get;set;}
  public Boolean isCode{get;set;}
  public List<LinkedIn_Data__c> linkedInList{get;set;}

  public Final string costumerKey='77t4td0a3k5xh4';//client_id
  public Final string customerSecret='WPL_AP1.3QMsoh8yqFiumDz0.5dfUWg==';//client_secret
  public Final string customerSecretEnc = EncodingUtil.urlEncode(customerSecret, 'UTF-8');
  public Final string redirect_URI='https://makhovskaportfolio-dev-ed--c.develop.vf.force.com/apex/linkedIn_VFP';
  public Final string linkedIn_AuthUrl = 'https://www.linkedin.com/oauth/v2/authorization?';
  public Final string accessToken_Endpoint = 'https://www.linkedin.com/oauth/v2/accessToken';


    public LinkedInManager() {
      authCodeFromURL = ApexPages.currentPage().getParameters().get('code');

      if(authCodeFromURL==null || authCodeFromURL=='') {
        isCode = true;
      }else{
        isCode = false;
      }
      linkedInList = [SELECT Id, Name, Access_Token__c,Expires_In_Seconds__c FROM LinkedIn_Data__c WHERE Name='LinkedlnInfo'];
  }

  public PageReference getAuthCode(){
    /*https://www.linkedin.com/oauth/v2/authorization?response_type=code&
client_id={your_client_id}&
redirect_uri={your_callback_url}&
state=foobar&
scope=liteprofile%20emailaddress%20w_member_social*/

    /*
    string requesttoAuthURL = linkedIn_AuthUrl+'response_type=code&client_id='+costumerKey+'&redirect_uri='+redirect_URI+'&state=1234567dggd&scope=r_liteprofile%20r_emailaddress%20w_member_social';
    */
    string requesttoAuthURL = linkedIn_AuthUrl+'response_type=code&client_id='+costumerKey+'&redirect_uri='+redirect_URI+'&state=1234567dggd&scope=openid%20profile';

    System.debug('requesttoAuthURL: '+requesttoAuthURL);
     PageReference pageRef = new PageReference(requesttoAuthURL);
    return pageRef;
  }

  public void getAccessToken(){
    HTTP http = new HTTP();
    HttpRequest request = new HttpRequest();
    HttpResponse response = new HttpResponse();
    /*
    System.debug('authCodeFromURL ==> '+authCodeFromURL);
    System.debug('requestbody ==> '+requestbody);
    */
    string requestbody = 'grant_type=authorization_code&client_id='+costumerKey+'&client_secret='+customerSecretEnc+'&code='+authCodeFromURL+'&redirect_uri='+redirect_URI;
    request.setMethod('POST');
    request.setEndpoint(accessToken_Endpoint);
    request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    request.setBody(requestbody);
    string errorMessage = '';
    try{
      response = http.send(request);
      if(response.getStatusCode()==200){
        Map<string,Object> tokenInfoMap = (Map<string,Object>)JSON.deserializeUntyped(response.getBody());
        System.debug('Token info: '+ tokenInfoMap);

        LinkedIn_Data__c linkedInInfo = new LinkedIn_Data__c();
        linkedInInfo.Access_Token__c = String.valueOf(tokenInfoMap.get('access_token'));
        linkedInInfo.Expires_In_Seconds__c = Double.valueOf(tokenInfoMap.get('expires_in'));
        linkedInInfo.Name = 'LinkedlnInfo';

        if(linkedInList!=null && linkedInList.size()>0){
          linkedInInfo.Id = linkedInList[0].Id;
        }
        upsert linkedInInfo;

        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM,'Congratulation! Sucessfully Integration done with LinkedIn'));
        
      }else{
        errorMessage = 'Unexpected Error while communicating with LinkedIn API. '+
          'Status: '+response.getStatus()+' and Status Code '+response.getStatuscode()+' and XmlStreamReader '+response.getXmlStreamReader();
          System.debug(response.getXmlStreamReader());
          ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,errorMessage));
      }
    }catch(System.Exception e){
      System.debug('exception occured => '+e.getStackTraceString()+'  ; '+e.getMessage());
    }
  }

  /*public string authCodeFromURL{get;set;}
  public Boolean isCode{get;set;}
  public List<LinkedIn_Data__c> linkedInList{get;set;}

  public Final string costumerKey='77t4td0a3k5xh4';//client_id
  public Final string customerSecret='WPL_AP1.3QMsoh8yqFiumDz0.5dfUWg==';//client_secret
  public Final string redirect_URI='https://makhovskaportfolio-dev-ed--c.develop.vf.force.com/apex/linkedIn_VFP';
  public Final string linkedIn_AuthUrl = 'https://www.linkedin.com/oauth/v2/authorization?';
  public Final string accessToken_Endpoint = 'https://www.linkedin.com/oauth/v2/accessToken';


  public LinkedInManager() {
    authCodeFromURL = ApexPages.currentPage().getParameters().get('code');
    if(authCodeFromURL==null || authCodeFromURL=='') {
      isCode = true;
    }else{
       isCode = false;
    }
    linkedInList = [SELECT Id, Name, Access_Token__c,Expires_In_Seconds__c FROM LinkedIn_Data__c WHERE Name='LinkedInfo'];
  }

  public PageReference getAuthCode(){
    String requestToAuthURL = linkedIN_AuthUrl+'response_type=code&client_id='+costumerKey+'&redirect_uri='+redirect_URI+'&state=ASVRsf2318sfdxDeV28&scope=r_liteprofile%20r_emailaddress%20w_member_social';
    PageReference pageRef = new PageReference(requestToAuthURL);
    return pageRef;
  }

  public void getAccessToken(){
   HTTP http = new HTTP();
    HttpRequest request = new HttpRequest();
    HttpResponse response = new HttpResponse();
    String requestbody = 'code='+authCodeFromURL+'&grant_type=authorization_code&client_id='+costumerKey+'&client_secret='+customerSecret+'&redirect_uri='+redirect_URI;
    request.setMethod('POST');
    request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    request.setBody(requestbody);
    string errorMessage = '';
    try{
      response = http.send(request);
      if(response.getStatusCode()==200){
        Map<String,object> tokenInfoMap = (Map<String,object>)JSON.deserializeUntyped(response.getBody());
        System.debug('TokenInfo: '+ tokenInfoMap);

        LinkedIn_Data__c linkedInInfo = new LinkedIn_Data__c();
        linkedInInfo.Access_Token__c = (String)tokenInfoMap.get('access_token');
        linkedInInfo.Expires_In_Seconds__c = (Integer)tokenInfoMap.get('expires_in');
        linkedInInfo.Name = 'LinkedlnInfo';
        //System.debug('linkedInInfo: '+ linkedInInfo);

        if(linkedInList!=null && linkedInList.size()>0){
        linkedInInfo.Id = linkedInList[0].Id;
        }
        upsert linkedInInfo;
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM,'Congratulation! Your Access token is generated.'));

      }else{
          errorMessage = 'Unexpected Error while communicating with LinkedIn API. '+
          'Status: '+response.getStatus()+' and Status Code '+response.getStatuscode();
          ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,errorMessage));
      }
    }catch(system.Exception e){
      System.debug('exception occured => '+e.getStackTraceString()+'  ; '+e.getMessage());
    }
  }*/
    
}