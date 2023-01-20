@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BUV: T100 - Projection View for Project Analitics'
@Metadata.allowExtensions: true
@ObjectModel: { semanticKey: ['ProjectID', 'TaskID'] }

define root view entity ZBUV_C_ProjectAnalytics 
  as projection on  ZBUV_P_Union_Data 
{
     key projectuuid,
   
         @ObjectModel.text.element: [ 'ProjectName' ] 
         ProjectID,
         ProjectName,
         ProjectStatus,
         ProjectEstimation,
         
         @ObjectModel.text.element: [ 'TaskName' ]
         TaskID,
         TaskName, 
         TaskStatus,
         @Aggregation.default: #MAX      
         TaskDate, 
         @Aggregation.default: #SUM    
         TaskEstimation
}
