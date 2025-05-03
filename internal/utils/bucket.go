package utils

import (
	"context"
	"io"
	"os"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

func UploadFile(file **os.File, contentType string, objectKey string, bucketArn string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	config, err := config.LoadDefaultConfig(ctx, config.WithRegion("us-east-1"))
	if err != nil {
		return err
	}

	client := s3.NewFromConfig(config)

	_, err = (*file).Seek(0, io.SeekStart)
	if err != nil {
		return err
	}

	input := &s3.PutObjectInput{
		Bucket:      aws.String(bucketArn),
		Key:         aws.String(objectKey),
		Body:        *file,
		ContentType: aws.String(contentType),
	}

	ctx, cancel = context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	_, err = client.PutObject(ctx, input)
	if err != nil {
		return err
	}

	return nil
}

func DownloadFile(objectKey string, bucketArn string) (*os.File, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	cfg, err := config.LoadDefaultConfig(ctx, config.WithRegion("us-east-1"))
	if err != nil {
		return nil, err
	}

	client := s3.NewFromConfig(cfg)

	input := &s3.GetObjectInput{
		Bucket: aws.String(bucketArn),
		Key:    aws.String(objectKey),
	}

	ctx, cancel = context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	output, err := client.GetObject(ctx, input)
	if err != nil {
		return nil, err
	}
	defer output.Body.Close()

	tempFile, err := os.CreateTemp("", "downloaded-*")
	if err != nil {
		return nil, err
	}

	_, err = io.Copy(tempFile, output.Body)
	if err != nil {
		tempFile.Close()
		return nil, err
	}

	_, err = tempFile.Seek(0, io.SeekStart)
	if err != nil {
		tempFile.Close()
		return nil, err
	}

	return tempFile, nil
}
