package data

import "database/sql"

type CommonModel struct {
	Database *sql.DB
}

func (cm CommonModel) Healthcheck() error {
	query := `SELECT id FROM healthcheck`
	_, err := cm.Database.Exec(query)
	return err
}
