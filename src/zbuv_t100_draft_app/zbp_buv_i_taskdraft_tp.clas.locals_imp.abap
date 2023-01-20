CLASS lhc_ZBUV_I_TaskDraft_TP DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Task RESULT result.

    METHODS completeTaskDraft FOR MODIFY
      IMPORTING keys FOR ACTION Task~completeTaskDraft RESULT result.

    METHODS checkTaskEstimation FOR VALIDATE ON SAVE
      IMPORTING keys FOR Task~checkTaskEstimation.

ENDCLASS.

CLASS lhc_ZBUV_I_TaskDraft_TP IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD completeTaskDraft.

    MODIFY ENTITIES OF ZBUV_I_ProjectDraft_TP IN LOCAL MODE
      ENTITY Task
        UPDATE
          FIELDS ( TaskStatus )
          WITH VALUE #( FOR key IN keys
                          ( %key = key-%key
                            TaskStatus = 'DN' ) )
    FAILED   failed
    REPORTED reported.

    READ ENTITIES OF ZBUV_I_ProjectDraft_TP IN LOCAL MODE
      ENTITY Task
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_tasks).

    result = VALUE #( FOR ls_task IN lt_tasks
                        ( %tky   = ls_task-%tky
                          %param = ls_task ) ).

  ENDMETHOD.

  METHOD checkTaskEstimation.

   READ ENTITIES OF ZBUV_I_ProjectDraft_TP IN LOCAL MODE
      ENTITY Task
        FIELDS ( ProjectUUID
                 TaskEstimation )
          WITH CORRESPONDING #( keys )
    RESULT DATA(lt_tasks).

    DATA(ls_task) = lt_tasks[ 1 ].

    CHECK ls_task-taskestimation NOT BETWEEN 0 AND 5.

    APPEND VALUE #( ProjectUUID = ls_task-ProjectUUID )
       TO failed-project.

    APPEND VALUE #( ProjectUUID = ls_task-ProjectUUID
                    %msg        = NEW zcm_buv_t100(
                                      severity = if_abap_behv_message=>severity-error
                                      textid   = zcm_buv_t100=>incorrect_estimation ) )
       TO reported-project.

  ENDMETHOD.

ENDCLASS.
