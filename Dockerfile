FROM golang:1.24.1-bullseye

WORKDIR /app

COPY go.mod .

COPY go.sum .

COPY . .

RUN go mod download

RUN CGO_ENABLED=0 GOOS=linux make build

EXPOSE 3000

CMD [ "./api" ]
