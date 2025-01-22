terraform{
    backend "s3" {
        
        bucket = "healthcarenorth-s3backendforterraform"
        encrypt = true
        key = "terraform/tfstate"
        region = "eu-west-2"
    }
}
