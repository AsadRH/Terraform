provider "google" {
 credentials = "${file("deloitte-ord360-86ba3090ae38.json")}"
 project     = "deloitte-ord360"
 region      = "australia-southeast1"
}
