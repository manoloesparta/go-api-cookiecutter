package main

import "net/http"

func (app *application) healthcheckHandler(w http.ResponseWriter, r *http.Request) {
	data := map[string]string{
		"status":      "available",
		"environment": app.config.env,
		"version":     version,
	}

	err := app.models.Commons.Healthcheck()
	if err != nil {
		app.logger.PrintError(err, nil)
		app.sendError(w, http.StatusInternalServerError, "DB health failed", nil)
		return
	}

	err = app.writeJSON(w, http.StatusOK, data, nil)
	if err != nil {
		app.logger.PrintError(err, nil)
		app.sendError(w, http.StatusInternalServerError, "Internal server error", nil)
		return
	}
}
