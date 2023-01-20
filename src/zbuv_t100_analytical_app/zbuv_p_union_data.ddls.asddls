@AbapCatalog.sqlViewName: 'ZBUVPUNION'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BUV: T100 - Union Data'
@Analytics.dataCategory: #CUBE

define root view ZBUV_P_Union_Data 
--  as select from ZBUV_I_Project as _Project
    as select from zbuv_d_project as _Project
      inner join   zbuv_d_task    as _Task on _Project.projectuuid = _Task.projectuuid
--    inner join   ZBUV_I_Task    as _Task on _Project.ProjectUUID = _Task.ProjectUUID
--    inner join   zbuv_d_task    as _Task on _Project.projectid = _Task.projectid
//      inner join ZBUV_I_STATUS as _ProjectStatus on _Project.ProjectStatus = _ProjectStatus.StatusID
//      inner join ZBUV_I_STATUS as _TaskStatus    on _Task.TaskStatus = _TaskStatus.StatusID

  association [1]     to ZBUV_I_STATUS as _ProjectStatus on _Project.projectstatus = _ProjectStatus.StatusID 
  association [1]     to ZBUV_I_STATUS as _TaskStatus    on _Task.taskstatus = _TaskStatus.StatusID    
    
{
  key _Project.projectuuid,
      
      _Project.projectid as ProjectID,
      _Project.projectname as ProjectName,
      _ProjectStatus.StatusName as ProjectStatus,   
      _Project.projectestimation as ProjectEstimation, 
      
      _Task.taskid as TaskID, 
      _Task.taskname as TaskName,
      _TaskStatus.StatusName as TaskStatus,     
      _Task.taskdate as TaskDate,
      _Task.taskestimation as TaskEstimation      
}
