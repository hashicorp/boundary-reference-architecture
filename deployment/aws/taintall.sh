#!/bin/bash
# run this to deploy new binaries
terraform taint 'module.aws.aws_db_instance.boundary'
terraform taint 'module.aws.aws_instance.controller[0]'
terraform taint 'module.aws.aws_instance.controller[1]'
#terraform taint 'module.aws.aws_instance.controller[2]'
terraform taint 'module.aws.aws_instance.worker[0]'
#terraform taint 'module.aws.aws_instance.worker[1]'
#terraform taint 'module.aws.aws_instance.worker[2]'
