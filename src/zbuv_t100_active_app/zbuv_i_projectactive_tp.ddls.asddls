@AbapCatalog.sqlViewName: 'ZBUVIPROJACTTP'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BUV: T100 - Interface View for Projects'

define root view ZBUV_I_ProjectActive_TP
  as select from zbuv_d_project as Project

  composition [0..*] of ZBUV_I_TaskActive_TP as _Task_TP 
  association [1]    to ZBUV_I_STATUS        as _Status 
                                             on $projection.ProjectStatus = _Status.StatusID

{ key projectuuid       as ProjectUUID,

      projectid         as ProjectID,
      projectname       as ProjectName,
      projectestimation as ProjectEstimation,
      projectstatus     as ProjectStatus,
      
      case projectstatus
        when 'NW' then 1
        when 'IN' then 2
        when 'DN' then 3
        else 0
      end as StatusCriticality,   
      
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

      _Task_TP,
      _Status

}
