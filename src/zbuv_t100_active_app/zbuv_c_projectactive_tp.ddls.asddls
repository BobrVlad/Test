@EndUserText.label: 'BUV: T100 - Projection View for Projects'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true 
define root view entity ZBUV_C_ProjectActive_TP 
  provider contract transactional_query
  as projection on ZBUV_I_ProjectActive_TP

{     
  key ProjectUUID,
  
      ProjectID,
      ProjectName,
      ProjectEstimation,
      
      @ObjectModel.text.element: [ 'StatusName' ]
      ProjectStatus,     
      @UI.hidden: true      
      _Status.StatusName,
      
      @UI.hidden: true
      StatusCriticality,        
            
      _Task_TP : redirected to composition child ZBUV_C_TaskActive_TP  
       
}
