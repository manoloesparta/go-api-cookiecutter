FROM golang:1.24.2-bookworm

WORKDIR /app

COPY go.mod .

COPY go.sum .

COPY . .

RUN touch application.log

RUN go mod download

RUN make build

EXPOSE 3000

CMD [ "./api" ]
