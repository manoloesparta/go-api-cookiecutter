package data

import (
	"database/sql"
	"errors"
)

var (
	ErrRecordNotFound = errors.New("record not found")
)

type Models struct {
	Users   UserModel
	Tokens  TokenModel
	Commons CommonModel
}

func NewModels(db *sql.DB) Models {
	return Models{
		Users:   UserModel{Database: db},
		Tokens:  TokenModel{Database: db},
		Commons: CommonModel{Database: db},
	}
}
