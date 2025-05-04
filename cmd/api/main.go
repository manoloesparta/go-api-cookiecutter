package main

import (
	"context"
	"database/sql"
	"flag"
	"fmt"
	"net/http"
	"time"

	"github.com/julienschmidt/httprouter"
	"github.com/purpleinkorg/go-api-cookicutter/internal/data"
	"github.com/purpleinkorg/go-api-cookicutter/internal/utils"

	_ "github.com/lib/pq"
)

const version = "0.1.0"

type config struct {
	port       string
	env        string
	bucketName string

	db struct {
		url          string
		maxOpenConns int
		maxIdleConns int
		maxIdleTime  string
	}
}

func (c config) String() string {
	return fmt.Sprintf("{Port=%s,Env=%s,Bucket=%s}", c.port, c.env, c.bucketName)
}

type application struct {
	config config
	logger *utils.Logger
	models data.Models
}

func Hello(w http.ResponseWriter, r *http.Request, ps httprouter.Params) {
	fmt.Fprintf(w, "there")
}

func main() {
	var config config

	env := utils.GetEnvOrDefault("APP_ENV", "local")
	port := utils.GetEnvOrDefault("APP_PORT", "3000")
	bucketArn := utils.MustDefineEnv("APP_BUCKET")
	dbUrl := utils.MustDefineEnv("APP_DB_URL")

	flag.StringVar(&config.env, "env", env, "Environment (local|dev|prod)")
	flag.StringVar(&config.port, "port", port, "API server port")
	flag.StringVar(&config.bucketName, "images-bucket", bucketArn, "Name of the S3 bucket for storing images")
	flag.StringVar(&config.db.url, "db-url", dbUrl, "db connection string")
	flag.IntVar(&config.db.maxOpenConns, "db-max-open-conns", 25, "max open connections")
	flag.IntVar(&config.db.maxIdleConns, "db-max-idle-conns", 25, "max idle connections")
	flag.StringVar(&config.db.maxIdleTime, "db-max-idle-time", "15m", "max connection idle time")
	flag.Parse()

	logger := utils.SetupLogger(config.env)

	db, err := openDatabase(config)
	if err != nil {
		logger.PrintFatal(err, nil)
	}
	defer db.Close()

	app := &application{
		config: config,
		logger: logger,
		models: data.NewModels(db),
	}

	err = app.serve()
	if err != nil {
		logger.PrintFatal(err, nil)
	}
}

func openDatabase(cfg config) (*sql.DB, error) {
	db, err := sql.Open("postgres", cfg.db.url)
	if err != nil {
		return nil, err
	}

	db.SetMaxOpenConns(cfg.db.maxOpenConns)
	db.SetMaxIdleConns(cfg.db.maxIdleConns)

	duration, err := time.ParseDuration(cfg.db.maxIdleTime)
	if err != nil {
		return nil, err
	}
	db.SetConnMaxIdleTime(duration)

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	err = db.PingContext(ctx)
	if err != nil {
		return nil, err
	}

	return db, nil
}
