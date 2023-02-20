#' Get Group data
#'
#' R6 class that allows to get the Group information.
#'
#' @param email The email the user started the session with.
#' @param org_id The id of the organisation on which the statement will be executed
#' @param group_id The id of the group on which the statement will be executed
#' @param user_id The id of the user on which the statement will be executed
#' @param user_color The color of the user's cards
#' @param group_title The new title of the group
#' @param group_description The new description of the group
#' @param group_role The role for the user in the group
Group <- R6::R6Class(
    classname = "Group",
    inherit = Organisation,
    public = list(
        #' @field group_selected ID of the group to be used in the board, by default is the favorite group in group_users
        group_selected = NULL,

        #' @description Start a Group based on an user email
        initialize = function(email = Sys.getenv("REPORTES_EMAIL")) {
            super$initialize(email)
            
            favorite_group <- super$db_get_query(
                "SELECT group_id 
                FROM group_users 
                WHERE 
                    user_id = {self$user$user_id} AND
                    favorite_group IS TRUE")
            
            if (length(favorite_group$group_id) == 1) {
                self$group_selected <- favorite_group$group_id
            } else {
                self$group_selected <- self$groups[[1]]$group_id
            }
            
            
        },
        #' @description Initialize a group for a new user
        group_initialize = function(org_id) {
            group_id <- private$group_create(org_id)

            self$group_user_add(
                org_id = org_id,
                group_id = group_id,
                user_id = self$user$user_id,
                group_role = "admin"
            ) |> suppressMessages()

            cli::cli_alert_info("Initialized group '{group_id}' in org '{org_id}' by user '{self$user$user_id}'")
        },
        #' @description Edit group metadata
        group_edit = function(org_id, group_id, group_title, group_description) {
            t_stamp <- super$get_timestamp()
            statement <-
                "UPDATE groups
                SET
                    group_title = {group_title},
                    group_description = {group_description},
                    time_last_modified = {t_stamp}
                WHERE
                    org_id = {org_id} AND
                    group_id = {group_id}"

            super$db_execute_statement(statement, .envir = rlang::current_env())

            cli::cli_alert_info("Edited group '{group_id}' from org '{org_id}'")
        },
        #' @description Add an user to a group
        group_user_add = function(org_id, group_id, user_id, user_color = "white", group_role = "user") {
            t_stamp <- super$get_timestamp()
            statement <-
                "INSERT INTO group_users
                SET
                    org_id = {org_id},
                    group_id = {group_id},
                    user_id = {user_id},
                    user_color = {user_color},
                    group_role = {group_role},
                    time_creation = {t_stamp},
                    time_last_modified = {t_stamp}"

            super$db_execute_statement(statement, .envir = rlang::current_env())

            cli::cli_alert_info("User '{user_id}' inserted into group '{group_id}' in org '{org_id}' with role '{group_role}'")
        },
        #' @description Delete an user from a group
        group_user_delete = function(org_id, group_id, user_id) {
            statement <-
                "DELETE FROM group_users
                WHERE
                    org_id = {org_id} AND
                    group_id = {group_id} AND
                    user_id = {user_id}"

            super$db_execute_statement(statement, .envir = rlang::current_env())

            cli::cli_alert_info("User '{user_id}' deleted from group '{group_id}' in org '{org_id}'")
        },

        #' @description Edit the role of a user inside a group and related information
        group_user_edit = function(org_id, group_id, user_id, user_color, group_role) {
            
            statement <-
                "UPDATE group_users
                SET
                    user_color = {user_color},
                    group_role = {group_role}
                WHERE
                    org_id = {org_id} AND
                    group_id = {group_id} AND
                    user_id = {user_id}"

            super$db_execute_statement(statement, .envir = rlang::current_env())

            cli::cli_alert_info("User '{user_id}' now has role '{group_role}' and color '{user_color}' in group '{group_id}'")
        },
        #' @description Remove the existence of an organisation
        group_finalize = function(org_id, group_id) {
            statement <-
                "DELETE FROM group_users
                WHERE
                    org_id = {org_id} AND
                    group_id = {group_id}"

            super$db_execute_statement(statement, .envir = rlang::current_env())

            private$group_delete(org_id, group_id)

            cli::cli_alert_info("Finalized group '{group_id}' in org '{org_id}'")
        },
        #' @description Select a group for use in the board
        group_select = function(group_id) {
            self$group_selected <- group_id
        },
        
        group_unit_add = function(title, description = "", type, icon = 'file') {
            unit_id <- ids::random_id()
            type <- match.arg(type, c("report", "task"))
            
            statement <- "
                INSERT INTO units
                SET
                    group_id = {self$group_selected},
                    unit_id = {unit_id},
                    unit_title = {title},
                    unit_description = {description},
                    type = {type},
                    icon = {icon},
                    creator = {self$user$user_id},
                    last_modified_by = {self$user$user_id}
            "
            super$db_execute_statement(statement, .envir = rlang::current_env())
            
            cli::cli_alert_info("Inserted unit '{unit_id}' into group '{self$group_selected}'")
        },
        
        group_unit_edit = function(unit_id, title, description, type, icon) {
            type <- match.arg(type, c("report", "task"))
            
            statement <- "
                UPDATE units
                SET 
                    unit_title = {title},
                    unit_description = {description},
                    type = {type},
                    icon = {icon},
                    last_modified_by = {self$user$user_id}
                WHERE
                    unit_id = {unit_id}
            "
            super$db_execute_statement(statement, .envir = rlang::current_env())
            
            cli::cli_alert_info("Edited unit '{unit_id}' from '{self$group_selected}'")
        },
        
        group_unit_delete = function(unit_id) {
            super$db_execute_statement(
                "DELETE FROM units
                WHERE unit_id = {unit_id}",
                .envir = rlang::current_env()
            )
            
            cli::cli_alert_info("Deleted unit '{unit_id}' from group '{self$group_selected}'")
        }
    ),
    private = list(
        get_groups = function() {

            query <-
                "SELECT
                    lhs.org_id, lhs.group_id, lhs.group_role,
                    rhs.group_title, rhs.group_description,
                    rhs.parent_group, rhs.time_creation, rhs.time_last_modified
                FROM (
                    SELECT org_id, group_id, group_role
                    FROM group_users
                    WHERE user_id = {self$user$user_id}
                ) lhs
                LEFT JOIN groups rhs ON
                    lhs.org_id = rhs.org_id AND
                    lhs.group_id = rhs.group_id"

            db_data <- super$db_get_query(query)


            db_data |>
                purrr::pmap(list) |>
                setNames(nm = db_data$group_id)
        },
        get_group_users = function() {
            query <-
                "SELECT
                    rhs.*,
                    rhs2.name, rhs2.last_name
                FROM (
                    SELECT org_id, group_id
                    FROM group_users
                    WHERE user_id = {self$user$user_id}
                ) lhs
                LEFT JOIN group_users rhs ON
                    lhs.org_id = rhs.org_id AND
                    lhs.group_id = rhs.group_id
                LEFT JOIN users rhs2 ON
                    rhs.user_id = rhs2.user_id
                ORDER BY rhs.group_role
                "

            db_data <- super$db_get_query(query)


            db_data |>
                split(~group_id) |>
                purrr::map(
                    ~purrr::pmap(.x, list) |>
                        setNames(.x$user_id)
                )
        },
        group_create = function(org_id, parent_group = "organisation") {
            group_id <- ids::random_id()
            t_stamp <- super$get_timestamp()

            statement <-
                "INSERT INTO groups
                SET
                    org_id = {org_id},
                    group_id = {group_id},
                    group_title = 'Sin nombre',
                    group_description = '',
                    parent_group = {parent_group},
                    time_creation = {t_stamp},
                    time_last_modified = {t_stamp}"
            super$db_execute_statement(statement, .envir = rlang::current_env())

            return(group_id)
        },
        group_delete = function(org_id, group_id) {
            statement <-
                "DELETE FROM groups
                WHERE
                    org_id = {org_id} AND
                    group_id = {group_id}"

            super$db_execute_statement(statement, .envir = rlang::current_env())
        }
    ),
    active = list(
        #' @field groups List containing the group affiliations of the User
        groups = function() {
            private$get_groups()
        },

        #' @field group_users List containing the user list of the group The info is shown following the User's group role.
        group_users = function() {
            private$get_group_users()
        },
        
        #' @field group_units List containing the user list of the group The info is shown following the User's group role.
        group_units = function() {
            super$db_get_query("
                SELECT 
                    lhs.* ,
                    rhs1.name AS creator_name,
                    rhs1.last_name AS creator_last_name,
                    rhs2.name AS last_modifier_name,
                    rhs2.last_name AS last_modifier_last_name
                FROM (
                    SELECT * 
                    FROM units 
                    WHERE group_id = {self$group_selected}
                ) lhs
                LEFT JOIN users rhs1 ON
                    lhs.creator = rhs1.user_id
                LEFT JOIN users rhs2 ON
                    lhs.last_modified_by = rhs2.user_id
                ORDER BY time_creation
            ", .envir = rlang::current_env())
        }
    )
)
