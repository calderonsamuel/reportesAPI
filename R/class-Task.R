#' Get Group data
#'
#' R6 class that allows to get the Group information.
#'
#' @param email The email the user started the session with.
#' @param process_id The id of the process the task belongs to. When used must be paired with activity_id
#' @param activity_id The id of the activity the task belongs to. When used must be paired with process_id
#' @param org_id The id of the organisation on which the statement will be executed
#' @param group_id The id of the group on which the statement will be executed
#' @param user_id The id of the user on which the statement will be executed
#' @param task_id The id of the task on which the statement will be executed
#' @param task_title The new title of the group
#' @param task_description The new description of the group
#' @param assignee The id of the user responsible for the task
#' @param time_due Deadline for the task completion. Datetime
#' @param output_unit Unit of measurement of the task output
#' @param output_goal Number on which which the output will be measured
#' @param status_current Current status of the specified task
#' @param output_current Current output of the specified task
#' @param output_progress Quantity of the progress being reported. Is measured in the unit specified in the creation of the task
#' @param status The status of the task once the new progress is added
#' @param details Explanation of the progress made
#' @importFrom cli cli_alert_success cli_h2
#' @importFrom purrr pmap keep map reduce
Task <- R6::R6Class(
    classname = "Task",
    inherit = Group,
    public = list(
        #' @description Start a Task based on an user email
        initialize = function(email) {
            super$initialize(email)
        },
        #' @description Add a new task for an User
        task_add = function(process_id = NA_character_, activity_id = NA_character_,
                            org_id, group_id,
                            task_title, task_description, assignee, time_due,
                            output_unit, output_goal) {

            private$check_process(process_id, activity_id)

            task_id <- ids::random_id()
            t_stamp <- super$get_timestamp()

            statement <-
                "INSERT INTO tasks
                SET
                    process_id = {process_id},
                    activity_id = {activity_id},
                    org_id = {org_id},
                    group_id = {group_id},
                    task_id = {task_id},
                    task_title = {task_title},
                    task_description = {task_description},
                    assigned_by = {self$user$user_id},
                    assignee = {assignee},
                    time_due = {time_due},
                    output_unit = {output_unit},
                    output_goal = {output_goal},
                    output_current = 0,
                    status_current = 'Pendiente',
                    time_creation = {t_stamp},
                    time_last_modified = {t_stamp}
                "
            super$db_execute_statement(statement, .envir = rlang::current_env())

            cli::cli_h2("Task added")
            cli::cli_alert_info("process_id: {process_id}")
            cli::cli_alert_info("activity_id: {activity_id}")
            cli::cli_alert_info("org_id: {org_id}")
            cli::cli_alert_info("group_id: {group_id}")
            cli::cli_alert_success("task_id: {task_id}")

            self$progress_add(process_id, activity_id,
                              org_id, group_id, task_id,
                              output_progress = 0,
                              status = "Pendiente",
                              details = "Tarea iniciada") |>
                suppressMessages()

        },
        #' @description Delete an user task
        task_delete = function(process_id = NA_character_, activity_id = NA_character_,
                               org_id, group_id, task_id) {

            private$check_process(process_id, activity_id)

            statement <-
                "DELETE FROM tasks
                WHERE
                    org_id = {org_id} AND
                    group_id = {group_id} AND
                    task_id = {task_id}"

            if (!is.na(process_id) && !is.na(activity_id)) {
                statement <-
                    paste0(statement,
                        " AND process_id = {process_id} AND activity_id = {activity_id}")
            }

            super$db_execute_statement(statement, .envir = rlang::current_env())

            cli::cli_h2("Task deleted")
            cli::cli_alert_info("process_id: {process_id}")
            cli::cli_alert_info("activity_id: {activity_id}")
            cli::cli_alert_info("org_id: {org_id}")
            cli::cli_alert_info("group_id: {group_id}")
            cli::cli_alert_danger("task_id: {task_id}")

            self$progress_add(process_id, activity_id,
                              org_id, group_id, task_id,
                              output_progress = 0,
                              status = "Eliminada",
                              details = "Tarea eliminada") |>
                suppressMessages()
        },

        #' @description Report progress on an assigned task
        task_report_progress = function(process_id = NA_character_,
                                        activity_id = NA_character_,
                                        org_id, group_id, task_id,
                                        status_current, output_current, details) {

            private$check_process(process_id, activity_id)

            t_stamp <- super$get_timestamp()

            statement <-
                "UPDATE tasks
                SET
                    status_current = {status_current},
                    output_current = {output_current},
                    time_last_modified = {t_stamp}
                WHERE
                    org_id = {org_id} AND
                    group_id = {group_id} AND
                    task_id = {task_id}"

            if (!is.na(process_id) && !is.na(activity_id)) {
                statement <-
                    paste0(statement,
                           " AND process_id = {process_id} AND activity_id = {activity_id}")
            }

            super$db_execute_statement(statement, .envir = rlang::current_env())

            cli::cli_h2("Task edited")
            cli::cli_alert_info("process_id: {process_id}")
            cli::cli_alert_info("activity_id: {activity_id}")
            cli::cli_alert_info("org_id: {org_id}")
            cli::cli_alert_info("group_id: {group_id}")
            cli::cli_alert_warning("task_id: {task_id}")

            self$progress_add(process_id, activity_id,
                              org_id, group_id, task_id,
                              output_progress = output_current,
                              status = status_current,
                              details = details) |>
                suppressMessages()
        },

        #' @description Edit a task metadata
        task_edit_metadata = function(process_id = NA_character_,
                                      activity_id = NA_character_,
                                      org_id, group_id, task_id,
                                      task_title, task_description) {
            private$check_process(process_id, activity_id)

            t_stamp <- super$get_timestamp()

            statement <-
                "UPDATE tasks
                SET
                    task_title = {task_title},
                    task_description = {task_description},
                    time_last_modified = {t_stamp}
                WHERE
                    org_id = {org_id} AND
                    group_id = {group_id} AND
                    task_id = {task_id}"

            if (!is.na(process_id) && !is.na(activity_id)) {
                statement <-
                    paste0(statement,
                           " AND process_id = {process_id} AND activity_id = {activity_id}")
            }

            super$db_execute_statement(statement, .envir = rlang::current_env())

            cli::cli_h2("Task edited")
            cli::cli_alert_info("process_id: {process_id}")
            cli::cli_alert_info("activity_id: {activity_id}")
            cli::cli_alert_info("org_id: {org_id}")
            cli::cli_alert_info("group_id: {group_id}")
            cli::cli_alert_warning("task_id: {task_id}")

            self$progress_add(process_id, activity_id,
                              org_id, group_id, task_id,
                              output_progress = NA,
                              status = "Sin cambio",
                              details = "Tarea con medatadata modificada") |>
                suppressMessages()
        },
        #' @description Insert progress info on some task
        progress_add = function(process_id = NA_character_,
                                activity_id = NA_character_,
                                org_id, group_id, task_id,
                                output_progress, status, details) {
            private$check_process(process_id, activity_id)

            t_stamp <- super$get_timestamp()

            statement <-
                "INSERT INTO progress
                SET
                    process_id = {process_id},
                    activity_id = {activity_id},
                    org_id = {org_id},
                    group_id = {group_id},
                    task_id = {task_id},
                    reported_by = {self$user$user_id},
                    output_progress = {output_progress},
                    status = {status},
                    time_reported = {t_stamp},
                    details = {details}"

            super$db_execute_statement(statement, .envir = rlang::current_env())

            cli::cli_h2("Progress reported")
            cli::cli_alert_info("process_id: {process_id}")
            cli::cli_alert_info("activity_id: {activity_id}")
            cli::cli_alert_info("org_id: {org_id}")
            cli::cli_alert_info("group_id: {group_id}")
            cli::cli_alert_warning("task_id: {task_id}")
            cli::cli_alert_warning("status: {status}")
        },
        #' @description Get a task's progression history
        task_get_history = function(task_id) {
            subquery_progress <-
                "SELECT reported_by, output_progress, status, time_reported, details
                FROM progress
                WHERE task_id = {task_id}" |>
                super$db_make_query(task_id = task_id)

            query <-
                "SELECT output_progress, status, time_reported, details,
                        CONCAT(name, ' ', last_name) AS user_names
                FROM ({subquery}) AS lhs
                INNER JOIN users rhs ON
                    lhs.reported_by = rhs.user_id"

            super$db_get_query(query, subquery = subquery_progress)
        }
    ),
    private = list(
        get_tasks = function() {
            query_tasks <- super$db_make_query(
                "SELECT *
                FROM tasks
                WHERE org_id IN ({orgs*}) AND
                    group_id IN ({groups*}) AND
                    assignee IN ({assignees*}) AND
                        (status_current != 'Terminado' OR (
                            status_current = 'Terminado' AND
                            time_last_modified BETWEEN date_sub(now(), INTERVAL 2 WEEK) AND now()
                            )
                        )
                ",
                orgs = names(self$orgs),
                groups = names(self$groups),
                assignees = private$get_assignees()
            )

            db_data <- super$db_get_query(
                "SELECT
                    lhs.*,
                    rhs.name AS assignee_name,
                    rhs.last_name AS assignee_last_name,
                    rhs2.name AS assigned_by_name,
                    rhs2.last_name AS assigned_by_last_name,
                    rhs3.user_color AS user_color
                FROM ({query_tasks}) AS lhs
                LEFT JOIN users rhs ON
                    lhs.assignee = rhs.user_id
                LEFT JOIN users rhs2 ON
                    lhs.assigned_by = rhs2.user_id
                LEFT JOIN group_users rhs3 ON
                    lhs.assignee = rhs3.user_id AND
                    lhs.group_id = rhs3.group_id
                ORDER BY lhs.time_last_modified DESC
                ",
                query_tasks = query_tasks
            )

            db_data |>
                purrr::pmap(list) |>
                setNames(nm = db_data$task_id)
        },
        check_process = function(process_id, activity_id) {
            if (xor(is.na(process_id), is.na(activity_id))) {
                rlang::abort("`process_id` y `activity_id` deben ser o NA o chr en simultaneo")
            }
        },
        get_assignees = function() {
            groups_where_admin <- self$groups |>
                purrr::keep(~.x$group_role == "admin") |>
                names()

            users_where_admin <- character()

            if (length(groups_where_admin) > 0) {
                users_where_admin <- self$group_users[groups_where_admin] |>
                    purrr::map(~purrr::map_chr(.x, "user_id")) |>
                    purrr::reduce(union)
            }


            union(users_where_admin, self$user$user_id)
        }
    ),
    active = list(
        #' @field tasks List containing the tasks an User can interact with
        tasks = function() {
            private$get_tasks()
        }
    )
)
