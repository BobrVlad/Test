CLASS lhc_Project DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Project RESULT result.

    METHODS completeProject FOR MODIFY
      IMPORTING keys FOR ACTION Project~completeProject RESULT result.

    METHODS createDefaultTask FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Project~createDefaultTask.

    METHODS checkDuplicatetName FOR VALIDATE ON SAVE
      IMPORTING keys FOR Project~checkDuplicatetName.

    METHODS checkProjectEstimation FOR VALIDATE ON SAVE
      IMPORTING keys FOR Project~checkProjectEstimation.
    METHODS createProjectWithTask FOR MODIFY
      IMPORTING keys FOR ACTION Project~createProjectWithTask RESULT result.

ENDCLASS.

CLASS lhc_Project IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD completeProject.

*    " Modify in local mode
*    MODIFY ENTITIES OF ZBUV_I_ProjectActive_TP IN LOCAL MODE
*           ENTITY Project
*              UPDATE FROM VALUE #( for key in keys ( ProjectUUID = key-ProjectUUID
*                                                     ProjectStatus = 'DN'
*                                                     %control-ProjectStatus = if_abap_behv=>mk-on ) )
*           FAILED   failed
*           REPORTED reported.

    MODIFY ENTITIES OF ZBUV_I_ProjectActive_TP IN LOCAL MODE
      ENTITY Project
        UPDATE
          FIELDS ( ProjectStatus )
          WITH VALUE #( FOR key IN keys
                          ( %key = key-%key
                            ProjectStatus = 'DN' ) )
    FAILED   failed
    REPORTED reported.

    READ ENTITIES OF ZBUV_I_ProjectActive_TP IN LOCAL MODE
      ENTITY Project
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_projects).

    result = VALUE #( FOR ls_project IN lt_projects
                        ( %tky   = ls_project-%tky
                          %param = ls_project ) ).

  ENDMETHOD.

  METHOD createDefaultTask.

    READ ENTITIES OF ZBUV_I_ProjectActive_TP IN LOCAL MODE
      ENTITY Project
        FIELDS ( ProjectID )
          WITH CORRESPONDING #( keys )
    RESULT DATA(lt_projects).

    DATA(ls_project) = lt_projects[ 1 ].

    CHECK ls_project-ProjectID IS INITIAL.

    SELECT
        MAX( projectid )
      FROM zbuv_d_project
      INTO @DATA(lv_maxID).

    DATA(lv_nextID) = condense( val = CONV string( lv_maxID + 1 ) ).

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    DATA lt_create TYPE TABLE FOR CREATE ZBUV_I_ProjectActive_TP.

    lt_create = VALUE #( (  %cid              = ls_project-ProjectUUID
                            "%is_draft        = if_abap_behv=>mk-off
                            ProjectID         = lv_nextID
                            ProjectName       = |Project { lv_nextID }|
                            ProjectEstimation = 3
                            ProjectStatus     = 'NW' ) ).

    MODIFY ENTITIES OF ZBUV_I_ProjectActive_TP IN LOCAL MODE
        ENTITY Project
          CREATE
             FIELDS ( ProjectID
                      ProjectName
                      ProjectEstimation
                      ProjectStatus )
             WITH lt_create

***********    MODIFY ENTITIES OF ZBUV_I_ProjectActive_TP IN LOCAL MODE
***********      ENTITY Project
***********        UPDATE
***********          FIELDS ( ProjectID
***********                   ProjectName
***********                   ProjectEstimation
***********                   ProjectStatus )
***********          WITH VALUE #( ( %key              = ls_project-%key
***********                          ProjectID         = lv_nextID
***********                          ProjectName       = |Project { lv_nextID }|
***********                          ProjectEstimation = 3
***********                          ProjectStatus     = 'NW' ) )
***********    FAILED   DATA(lt_failed_update)
***********    REPORTED DATA(lt_reported_update).

*    MODIFY ENTITIES OF ZBUV_I_ProjectActive_TP IN LOCAL MODE
*        ENTITY Project
           CREATE BY \_Task_TP
             FIELDS ( Taskid
                      TaskName
                      TaskEstimation
                      TaskStatus
                      TaskDate )
             WITH VALUE #( ( %cid_ref = ls_project-ProjectUUID
                             %target = VALUE #( ( %cid           = 'create_task'
                                                  "%is_draft      = if_abap_behv=>mk-off
                                                  Taskid         = |{ lv_nextID }-DefaultTaskID |
                                                  TaskName       = 'Default Task Name'
                                                  TaskEstimation = 3
                                                  TaskStatus     = 'NW'
                                                  TaskDate       = lv_today ) ) ) )
         MAPPED   DATA(lt_mapped)
         FAILED   DATA(lt_failed_create)
         REPORTED DATA(lt_reported_create).

********    DATA lt_new_task TYPE TABLE FOR CREATE ZBUV_I_TaskActive_TP.
********
********    lt_new_task = VALUE #( (  %cid         = ls_project-ProjectUUID
********                            "%is_draft     = if_abap_behv=>mk-off
********                            Taskid         = |{ lv_nextID }-DefaultTaskID |
********                            TaskName       = 'Default Task Name'
********                            TaskEstimation = 3
********                            TaskStatus     = 'NW'
********                            TaskDate       = lv_today ) ).
********
********    MODIFY ENTITIES OF ZBUV_I_ProjectActive_TP IN LOCAL MODE
********        ENTITY Project
********           CREATE BY \_Task_TP
********             FIELDS ( Taskid
********                      TaskName
********                      TaskEstimation
********                      TaskStatus
********                      TaskDate )
********             WITH lt_new_task
********         MAPPED   DATA(lt_mapped)
********         FAILED   DATA(lt_failed_create)
********         REPORTED DATA(lt_reported_create).

  ENDMETHOD.

  METHOD checkDuplicatetName.

    READ ENTITIES OF ZBUV_I_ProjectActive_TP IN LOCAL MODE
      ENTITY Project
        FIELDS ( ProjectName )
          WITH CORRESPONDING #( keys )
    RESULT DATA(lt_projects).

    DATA(ls_project) = lt_projects[ 1 ].

    SELECT SINGLE @abap_true
      FROM zbuv_i_project
      WHERE projectname = @ls_project-projectname
      INTO @DATA(lv_result).

    CHECK lv_result = abap_true.

*    APPEND VALUE #( %tky        = ls_project-%tky
*                    %state_area = 'checkDuplicatetName' )
*       TO reported-project.

    APPEND VALUE #( %tky        = ls_project-%tky )
       TO failed-project.

    APPEND VALUE #( %tky                 = ls_project-%tky
                    %state_area          = 'checkDuplicatetName'
                    %msg                 = NEW zcm_buv_t100(
                                               severity = if_abap_behv_message=>severity-error
                                               textid   = zcm_buv_t100=>duplicate_project_name )
                    %element-ProjectName = if_abap_behv=>mk-on )
       TO reported-project.

  ENDMETHOD.

  METHOD checkProjectEstimation.

    READ ENTITIES OF ZBUV_I_ProjectActive_TP IN LOCAL MODE
      ENTITY Project
        FIELDS ( ProjectEstimation )
          WITH CORRESPONDING #( keys )
    RESULT DATA(lt_projects).

    DATA(ls_project) = lt_projects[ 1 ].

    CHECK ls_project-projectestimation NOT BETWEEN 0 AND 5.

*    APPEND VALUE #( %tky        = ls_project-%tky
*                    %state_area = 'checkProjectEstimation' )
*       TO reported-project.

    APPEND VALUE #( %tky = ls_project-%tky )
       TO failed-project.

    APPEND VALUE #( %tky                       = ls_project-%tky
                    %state_area                = 'checkProjectEstimation'
                    %msg                       = NEW zcm_buv_t100(
                                                     severity = if_abap_behv_message=>severity-error
                                                     textid   = zcm_buv_t100=>incorrect_estimation )
                    %element-ProjectEstimation = if_abap_behv=>mk-on )
       TO reported-project.

  ENDMETHOD.

  METHOD createProjectWithTask.

    READ ENTITIES OF ZBUV_I_ProjectActive_TP IN LOCAL MODE
      ENTITY Project
        FIELDS ( ProjectID
                 ProjectEstimation )
          WITH CORRESPONDING #( keys )
    RESULT DATA(lt_projects).

   "DATA(ls_project) = lt_projects[ 1 ].

    SELECT
        MAX( projectid )
      FROM zbuv_d_project
      INTO @DATA(lv_maxID).

    DATA(lv_nextID) = condense( val = CONV string( lv_maxID + 1 ) ).

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    DATA lt_create TYPE TABLE FOR CREATE ZBUV_I_ProjectActive_TP.

    lt_create = VALUE #( FOR ls_project IN lt_projects
                         (  %cid              = ls_project-ProjectUUID
                            "%is_draft        = if_abap_behv=>mk-off
                            ProjectID         = lv_nextID
                            ProjectName       = |Project { lv_nextID }|
                            ProjectEstimation = ls_project-ProjectEstimation
                            ProjectStatus     = 'NW' ) ).

    MODIFY ENTITIES OF ZBUV_I_ProjectActive_TP IN LOCAL MODE
      ENTITY Project
           CREATE
             FIELDS ( ProjectID
                      ProjectName
                      ProjectEstimation
                      ProjectStatus )
             WITH lt_create
           CREATE BY \_Task_TP
             FIELDS ( Taskid
                      TaskName
                      TaskEstimation
                      TaskStatus
                      TaskDate )
             WITH VALUE #( FOR ls_project IN lt_projects
                           ( %cid_ref = ls_project-ProjectUUID
                             %target = VALUE #( ( %cid           = 'create_task'
                                                  "%is_draft      = if_abap_behv=>mk-off
                                                  Taskid         = |{ lv_nextID }-DefaultTaskID |
                                                  TaskName       = 'Default Task Name'
                                                  TaskEstimation = 3
                                                  TaskStatus     = 'NW'
                                                  TaskDate       = lv_today ) ) ) )
    MAPPED   DATA(lt_mapped)
    FAILED   DATA(lt_failed)
    REPORTED DATA(lt_reported).

*    READ ENTITIES OF ZBUV_I_ProjectActive_TP IN LOCAL MODE
*      ENTITY Project
*        ALL FIELDS WITH CORRESPONDING #( lt_mapped-project )
*      RESULT DATA(lt_projects_created).

*    result = VALUE #( FOR ls_project_created IN lt_projects_created
*                        ( %tky   = ls_project_created-%tky
*                          %param = ls_project_created ) ).


*    result = CORRESPONDING #( result FROM lt_projects_created USING KEY entity  %key = %param-%key MAPPING %param = %data EXCEPT * ).

    result = VALUE #( FOR ls_result IN lt_projects
                        ( %tky   = ls_result-%tky
                          %param = ls_result ) ).

  ENDMETHOD.

ENDCLASS.
