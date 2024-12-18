#Credentials:
$aws_access_key_id = ""
$aws_secret_access_key = ""
$region="us-east-1"
$ProfileName  = "default"
$SetCredentials = Set-AWSCredential -AccessKey $aws_access_key_id -SecretKey $aws_secret_access_key -StoreAs $P...
$session = Initialize-AWSDefaults -Region $region -ProfileName $ProfileName
##################################################################################################


#Create a LoadBalancer :
# Define the load balancer name
$LoadBalancerName = "NewTestALB"
# Define the IP address type
$IpAddressType = "ipv4"
# Define the scheme
$Scheme = "internet-facing"
# Define the security group
$SecurityGroup = "sg-04fcaf879eb1ff9f7"
# Define the subnets (ensure they are in different Availability Zones)
$Subnets = @("subnet-0d21e7affa7805552", "subnet-0bf3417a95fdb0b93")
# Define the load balancer type
$Type = "application"

# Create the load balancer
$MyLoadBalancer = New-ELB2LoadBalancer `
    -IpAddressType $IpAddressType `
    -Name $LoadBalancerName `
    -Scheme $Scheme `
    -SecurityGroup $SecurityGroup `
    -Subnet $Subnets `
    -Type $Type
Write-Host " The Load balancer $LoadBalancerName has been created successfully "
#########################################################################################################

#Create a Target group : 
# Define the target group name
$TargetGroupName = "MyTargetGroup"
# Define the target protocol :
$TargetProtocol = "http"
# Define the target port :
$TargetPort = "80"
# Define the vpc id :
$VPCID = "vpc-067c6da2673a943b5"
$MyTargetGroup =New-ELB2TargetGroup `
-Name $TargetGroupName `
-Port $TargetPort `
-Protocol $TargetProtocol `
-VpcId $VPCID
$MyTargetGroupARN=$MyTargetGroup.TargetGroupArn
Write-Host " The target group $TargetGroupName has been created successfully "
#########################################################################################################
#Create a listner :
$LoadBalancerListnerProtocol= "http"
$LoadBalancerListnerPort= "80"
$defaultAction = [Amazon.ElasticLoadBalancingV2.Model.Action]@{
  ForwardConfig = @{
    TargetGroupStickinessConfig = @{
      DurationSeconds = 900
      Enabled = $true
    }
    #TargetGroups=@{
        #TargetGroupArn = $MyTargetGroupARN
    #}
  }
  Type = "Forward"
  TargetGroupArn=$MyTargetGroupARN
}
$MyListner = New-ELB2Listener `
-LoadBalancerArn $MyLoadBalancer.LoadBalancerArn `
-Port $LoadBalancerListnerPort `
-Protocol $LoadBalancerListnerProtocol `
-DefaultAction $defaultAction 
$MyListnerARN=$MyListner.ListenerArn
Write-Host " The listner $MyListnerARN  has been created successfully "
#########################################################################################################

#Create a launch template : 
# Read the Base64 encoded user data from the file
$MyUserData = Get-Content -Raw -Path ".\encodedscript.txt"

$templateData = @{
  ImageId = "ami-0c101f26f147fa7fd"
  InstanceType = "t2.micro"
  SecurityGroupIds = @("sg-03904eb049a3cfaeb")
  UserData = $MyUserData
  KeyName = "MyNewKeyPair"
}
$MyLaunchTemlpate = New-EC2LaunchTemplate `
-LaunchTemplateData $templateData `
-LaunchTemplateName "MyNewLaunchTemplate"
##########################################################################################################
$SubnetsIDS = "subnet-0fb4abd0227a56149,subnet-02fc32246a730e6de"
#Create an autoscaling group : 
$MyAutoScalingGroup = New-ASAutoScalingGroup `
-AutoScalingGroupName "MyAutoscalingGroup" `
-LaunchTemplate_LaunchTemplateName "MyNewLaunchTemplate" `
-MinSize 1 `
-MaxSize 2 `
-DesiredCapacity 1 `
-TargetGroupARNs $MyTargetGroupARN `
-VPCZoneIdentifier $SubnetsIDS
###################################################################################################
