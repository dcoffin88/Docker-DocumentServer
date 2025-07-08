variable "TAG"              { default = "" }
variable "REPO"             { default = "" }
variable "COMPANY_NAME"     { default = "" }
variable "PRODUCT_NAME"     { default = "" }
variable "PRODUCT_EDITION"  { default = "" }
variable "PACKAGE_VERSION"  { default = "" }
variable "PACKAGE_BASEURL"  { default = "" }
variable "LATEST"           { default = "false" }

target "documentserver" {
  target     = "documentserver"
  dockerfile = "Dockerfile"

  tags = [
    "docker.io/${REPO}/${PRODUCT_NAME}:${TAG}",
    "ghcr.io/${REPO}/${PRODUCT_NAME}:${TAG}",
    equal("true", LATEST) ? "docker.io/${REPO}/${PRODUCT_NAME}:latest" : "",
    equal("true", LATEST) ? "ghcr.io/${REPO}/${PRODUCT_NAME}:latest" : "",
  ]

  platforms = ["linux/amd64", "linux/arm64"]

  args = {
    "COMPANY_NAME"     = "${COMPANY_NAME}"
    "PRODUCT_NAME"     = "${PRODUCT_NAME}"
    "PRODUCT_EDITION"  = "${PRODUCT_EDITION}"
    "PACKAGE_VERSION"  = "${PACKAGE_VERSION}"
    "PACKAGE_BASEURL"  = "${PACKAGE_BASEURL}"
  }
}
