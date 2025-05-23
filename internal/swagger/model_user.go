/*
 * tbd
 *
 * This is the REST API specification
 *
 * API version: 1.0.0
 * Generated by: Swagger Codegen (https://github.com/swagger-api/swagger-codegen.git)
 */
package swagger

type User struct {
	Id int64 `json:"id"`
	FirstName string `json:"firstName"`
	LastName string `json:"lastName"`
	Birth string `json:"birth"`
	Email string `json:"email"`
	CreatedAt string `json:"createdAt"`
	Activated bool `json:"activated"`
}
