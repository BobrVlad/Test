CLASS lhc_ZBUV_I_ProjectDraft_TP DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Project RESULT result.

    METHODS completeProjectDraft FOR MODIFY
      IMPORTING keys FOR ACTION Project~completeProjectDraft RESULT result.

    METHODS createProjectWithTaskDraft FOR MODIFY
      IMPORTING keys FOR ACTION Project~createProjectWithTaskDraft RESULT result.

    METHODS checkDuplicatetName FOR VALIDATE ON SAVE
      IMPORTING keys FOR Project~checkDuplicatetName.

    METHODS checkProjectEstimation FOR VALIDATE ON SAVE
      IMPORTING keys FOR Project~checkProjectEstimation.

ENDCLASS.

CLASS lhc_ZBUV_I_ProjectDraft_TP IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD completeProjectDraft.

    MODIFY ENTITIES OF ZBUV_I_ProjectDraft_TP IN LOCAL MODE
      ENTITY Project
        UPDATE
          FIELDS ( ProjectStatus )
          WITH VALUE #( FOR key IN keys
                          ( %key = key-%key
                            ProjectStatus = 'DN' ) )
    FAILED   failed
    REPORTED reported.

    READ ENTITIES OF ZBUV_I_ProjectDraft_TP IN LOCAL MODE
      ENTITY Project
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_projects).

    result = VALUE #( FOR ls_project IN lt_projects
                        ( %tky   = ls_project-%tky
                          %param = ls_project ) ).

  ENDMETHOD.

  METHOD createProjectWithTaskDraft.

    READ ENTITIES OF ZBUV_I_ProjectDraft_TP IN LOCAL MODE
      ENTITY Project
        FIELDS ( ProjectID
                 ProjectEstimation )
          WITH CORRESPONDING #( keys )
    RESULT DATA(lt_projects).

    SELECT
        MAX( projectid )
      FROM zbuv_d_project
      INTO @DATA(lv_maxID).

    DATA(lv_nextID) = condense( val = CONV string( lv_maxID + 1 ) ).

    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).

    DATA lt_create TYPE TABLE FOR CREATE ZBUV_I_ProjectDraft_TP.

    lt_create = VALUE #( FOR ls_project IN lt_projects
                         (  %cid              = ls_project-ProjectUUID
                            "%is_draft         = if_abap_behv=>mk-off
                            ProjectID         = lv_nextID
                            ProjectName       = |Project { lv_nextID }|
                            ProjectEstimation = ls_project-ProjectEstimation
                            ProjectStatus     = 'NW' ) ).

    MODIFY ENTITIES OF ZBUV_I_ProjectDraft_TP IN LOCAL MODE
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

    result = VALUE #( FOR ls_result IN lt_projects
                        ( %tky   = ls_result-%tky
                          %param = ls_result ) ).

  ENDMETHOD.

  METHOD checkDuplicatetName.

    READ ENTITIES OF ZBUV_I_ProjectDraft_TP IN LOCAL MODE
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

    APPEND VALUE #( %tky        = ls_project-%tky )
       TO failed-project.

    APPEND VALUE #( %tky                 = ls_project-%tky
                    %is_draft            = if_abap_behv=>mk-on
                    %state_area          = 'checkDuplicatetName'
                    %msg                 = NEW zcm_buv_t100(
                                               severity = if_abap_behv_message=>severity-error
                                               textid   = zcm_buv_t100=>duplicate_project_name )
                    %element-ProjectName = if_abap_behv=>mk-on )
       TO reported-project.

  ENDMETHOD.

  METHOD checkProjectEstimation.

    READ ENTITIES OF ZBUV_I_ProjectDraft_TP IN LOCAL MODE
      ENTITY Project
        FIELDS ( ProjectEstimation )
          WITH CORRESPONDING #( keys )
    RESULT DATA(lt_projects).

    DATA(ls_project) = lt_projects[ 1 ].

    CHECK ls_project-projectestimation NOT BETWEEN 0 AND 5.

*    APPEND VALUE #( %tky = ls_project-%tky )
*       TO failed-project.
*
*    APPEND VALUE #( %tky                       = ls_project-%tky
*                    %state_area                = 'checkProjectEstimation'
*                    %is_draft                  = if_abap_behv=>mk-on
*                    %msg                       = NEW zcm_buv_t100(
*                                                     severity = if_abap_behv_message=>severity-error
*                                                     textid   = zcm_buv_t100=>incorrect_estimation )
*                    %element-ProjectEstimation = if_abap_behv=>mk-on )
*       TO reported-project.

    APPEND VALUE #( ProjectUUID = ls_project-ProjectUUID )
       TO failed-project.

    APPEND VALUE #( ProjectUUID                = ls_project-ProjectUUID
                    %state_area                = 'checkProjectEstimation'
                    %is_draft                  = if_abap_behv=>mk-on
                    %msg                       = NEW zcm_buv_t100(
                                                     severity = if_abap_behv_message=>severity-error
                                                     textid   = zcm_buv_t100=>incorrect_estimation )
                    %element-ProjectEstimation = if_abap_behv=>mk-on )
       TO reported-project.

  ENDMETHOD.

ENDCLASS.
