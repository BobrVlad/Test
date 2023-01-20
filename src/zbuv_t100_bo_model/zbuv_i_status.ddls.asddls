@AbapCatalog.sqlViewName: 'ZBUVISTATUS'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BUV:100 - Interface View for Statuses'
@ObjectModel.resultSet.sizeCategory: #XS
define view ZBUV_I_STATUS
  as select from zbuv_d_status as Status
{
--  @UI.textArrangement: #TEXT_ONLY
--  @ObjectModel.text.element: [ 'StatusName' ]
  key statusid as StatusID,
  
  statusname as StatusName
}
