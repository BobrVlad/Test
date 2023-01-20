@EndUserText.label: 'BUV: T100 - Projection View for Tasks with Draft'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true

define view entity ZBUV_C_TaskDraft_TP 
  as projection on ZBUV_I_TaskDraft_TP as Task_TP 
           
{     
  key TaskUUID,
      ProjectUUID,

      TaskID,     
      TaskName,
      TaskEstimation,
      
      @ObjectModel.text.element: [ 'StatusName' ]
      TaskStatus,     
      @UI.hidden: true      
      _Status.StatusName,
      
      @UI.hidden: true
      StatusCriticality,  
      
      TaskDate,  
            
      _Project_TP : redirected to parent ZBUV_C_ProjectDraft_TP
       
}
