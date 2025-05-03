package utils

import (
	"fmt"
	"os"
)

func GetEnvOrDefault(envKey string, defaultValue string) string {
	val := os.Getenv(envKey)
	if val == "" {
		val = defaultValue
	}
	return val
}

func MustDefineEnv(envKey string) string {
	val := os.Getenv(envKey)
	if val == "" {
		panic(fmt.Sprintf("Must define: %s", envKey))
	}
	return val
}

func Limit(pageSize int64) int64 {
	return pageSize
}

func Offset(pageNumber int64, pageSize int64) int64 {
	return (pageNumber - 1) * pageSize
}
