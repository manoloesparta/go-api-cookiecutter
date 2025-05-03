FROM golang:1.24.1-bullseye

WORKDIR /app

COPY go.mod .

COPY go.sum .

COPY . .

RUN go mod download

RUN make build

EXPOSE 3000

CMD [ "./api" ]
