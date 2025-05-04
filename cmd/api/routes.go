package main

import (
	"net/http"

	"github.com/julienschmidt/httprouter"
)

const (
	defaultPageSize = 15
)

func (app *application) routes() http.Handler {
	router := httprouter.New()

	router.MethodNotAllowed = http.HandlerFunc(nil)
	router.NotFound = http.HandlerFunc(nil)

	router.HandlerFunc(http.MethodGet, "/v1/healthcheck", app.healthcheckHandler)

	router.HandlerFunc(http.MethodPost, "/v1/users", nil)
	router.HandlerFunc(http.MethodPost, "/v1/tokens", nil)

	// authenticate
	return app.enableCORS(router)
}
