test_that("Org starts as expected", {
    test_Orgs <- Organisation$new(email = Sys.getenv("REPORTES_EMAIL"))
    
    test_Orgs |> 
        expect_type("environment") |> 
        expect_s3_class("R6") |> 
        expect_s3_class("Organisation")
    
})

test_that("Org can be created, edited and deleted", {
    test_Orgs <- Organisation$new(email = Sys.getenv("REPORTES_EMAIL"))
    
    expect_equal({
        test_id <- test_Orgs$org_add("Test", "")
        
        test_Orgs$org_edit(
            org_id = test_id,
            org_title = "Nuevo título",
            org_description = "Nueva descripción"
        )
        
        test_Orgs$org_delete(org_id = test_id)
        
        "ok"
    }, expected = "ok")
})

test_that("Org data can be retrieved", {
    test_Orgs <- Organisation$new(email = Sys.getenv("REPORTES_EMAIL"))
    
    expect_type(test_Orgs$orgs, "list")
    expect_named(test_Orgs$orgs)
})
