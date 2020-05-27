# Basic Usage Example

Here is the basic example of this module usage with minimum input.

1. Generate ssh keypair for the Atlantis EC2 using the following command

    ```shell
    ssh-keygen -t rsa -b 2048 -f ~/.ssh/ec2_atlantis_rsa
    ```

1. Copy public key generated above into `public_key` input for this module.
1. Run `terraform init` to initiliaze terraform project.
1. Run `terraform plan -out=tfplan.out` to generate execution plan and review it.
1. Run `terraform apply tfplan.out` to apply changes.

## Cleaning up

To delete all resources created by this project, run `terraform destroy`