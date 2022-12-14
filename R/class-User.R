#' Get user information
#'
#' R6 class that allows to get the user information.
#'
#' @param email The email the user started the session with.
#' @param name Name to be inserted as user metadata.
#' @param last_name Last name to be inserted as user metadata.
#' @importFrom ids random_id
#' @importFrom rlang current_env
User <- R6::R6Class(
    classname = "User",
    inherit = DBManager,
    public = list(
        #' @field user List containing the user info.
        user = NULL,
        #' @description Start User
        initialize = function(email) {
            super$initialize()
            private$sync_user_data(email)
        },
        #' @description Change the name and last name of the User
        user_edit_names = function(name, last_name) {
            t_stamp <- super$get_timestamp()
            statement <-
                "UPDATE users
                SET
                    name = {name},
                    last_name = {last_name},
                    time_last_modified = {t_stamp}
                WHERE
                    user_id = {self$user$user_id}"
            super$db_execute_statement(statement, .envir = rlang::current_env())
            private$sync_user_data(self$user$email)
        }
    ),
    private = list(
        sync_user_data = function(email) {
          self$user <- private$ensure_user_data(email)
        },
        ensure_user_data = function(email) {
            user_data <- private$get_user_from_email(email)

            if (nrow(user_data) == 0) {
                private$user_create(email)
                user_data <- private$get_user_from_email(email)
            }

            as.list(user_data)
        },
        get_user_from_email = function(email) {
            query <-
                "SELECT *
                FROM users
                WHERE email = {email}"

            super$db_get_query(query, email = email) # should be 1 row
        },
        user_create = function(email) {
            fields <- list(
                id = ids::random_id(),
                email = email,
                t_stamp = super$get_timestamp()
            )
            statement <- "
                INSERT INTO users
                SET
                    user_id = {id},
                    name = '',
                    last_name = '',
                    email = {email},
                    time_creation = {t_stamp},
                    time_last_modified = {t_stamp}"
            super$db_execute_statement(statement, .envir = fields)
        },
        user_delete = function(user_id) {
            statement <-
                "DELETE FROM users
                WHERE user_id = {id}"

            super$db_execute_statement(statement, id = user_id)
        }
    )
)
