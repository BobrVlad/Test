@AbapCatalog.sqlViewName: 'ZBUVITASKDRFTP'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BUV: T100 - Interface View for Tasks with Draft Capabilities'

define view ZBUV_I_TaskDraft_TP
  as select from zbuv_d_task as Task

  association     to parent ZBUV_I_ProjectDraft_TP as _Project_TP 
                                                   on $projection.ProjectUUID = _Project_TP.ProjectUUID
  association [1] to        ZBUV_I_STATUS          as _Status     
                                                   on $projection.TaskStatus = _Status.StatusID                                             

{
  key taskuuid       as TaskUUID,
      projectuuid    as ProjectUUID,

      taskid         as TaskID,
      taskname       as TaskName,
      taskestimation as TaskEstimation,
      taskstatus     as TaskStatus,
      taskdate       as TaskDate,
      
      case taskstatus
        when 'NW' then 1
        when 'IN' then 2
        when 'DN' then 3
        else 0
      end                as StatusCriticality,  
      
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.lastChangedBy: true
      local_last_changed_by as LocalLastChangedby,
      //local ETag field --> OData ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      
      //total ETag field
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,          

      _Project_TP,
      _Status

}
