terraform{
    backend "s3"{
        bucket = "terraform-state-bootcamp-fd"
        key = "terraform-state-grafana-bootcamp-fd.tfstate"
        region = "us-east-1"
    }
}