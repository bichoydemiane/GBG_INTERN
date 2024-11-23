#Credentials:
$aws_access_key_id = ""
$aws_secret_access_key = ""
$region="us-east-1"
$ProfileName  = "default"
$SetCredentials = Set-AWSCredential -AccessKey $aws_access_key_id -SecretKey $aws_secret_access_key -StoreAs $P...
$session = Initialize-AWSDefaults -Region $region -ProfileName $ProfileName
##################################################################################################
# Define the choices
$KPchoices = @("New", "Old")
# Define the options for PromptForChoice
$KPoptions = foreach ($KPchoice in $KPchoices) {
    New-Object System.Management.Automation.Host.ChoiceDescription "&$KPchoice", "Choose $KPchoice option"
}
# Prompt the user to select an option
$KPselectedIndex = $Host.UI.PromptForChoice("Select an Option", "Please choose an option:", $KPoptions, 0)
# Get the selected choice
$KPselectedChoice = $KPchoices[$KPselectedIndex]


function ChooseNewKeyPair {
 # Variables
 $keys = Get-EC2KeyPair
 $keyNames= $keys.KeyName
 $keyNameValue =  Read-Host 'Please enter your Key name'
 do {
     write-Host 'this key already exists'
     $keyNameValue =  Read-Host 'Please enter your Key name'
 
 } while ($keyNames -contains $keyNameValue)
 $keyFilePath = "C:\Users\a926818\Downloads\Private\AWSResources\Devops\oooooooooooooo\$keyNameValue.pem"
 # Create Key Pair
 $keyPair = New-EC2KeyPair -KeyName $keyNameValue

 # Save Key Pair to File
 $keyPair.KeyMaterial | Out-File -FilePath $keyFilePath -Encoding ASCII
 # Output the location of the saved key pair
 Write-Host "Key pair saved to: $keyFilePath"
 return $KeyNameValue
}
function ChooseOldKeyPair {
 # Check if there are any key pairs available
 $keyPairs = Get-EC2KeyPair
 if ($keyPairs.Count -eq 0) {
    Write-Host "No key pairs available. Exiting..."
    exit
 }
 # Create choice descriptions
 $choices = @()
 for ($i = 0; $i -lt $keyPairs.Count; $i++) {
    $choice = New-Object System.Management.Automation.Host.ChoiceDescription "&$($i + 1) $($keyPairs[$i].KeyName)", ""
    $choices += $choice
 }
 # Prompt the user to select a key pair
 $selectedIndex = $Host.UI.PromptForChoice("Select a Key Pair", "Please choose a key pair:", $choices, 0)
 $selectedKeyPair = $keyPairs[$selectedIndex]
 $KeyNameValue =  $selectedKeyPair.KeyName
 return $KeyNameValue
}
switch ($KPselectedChoice) {
    "New" { $KeyName = ChooseNewKeyPair
    }
    "Old" {
            $KeyName = ChooseOldKeyPair
    }
    default {
        Write-Output "Invalid"
    }
}
Write-Host "The selected key name is: $keyName"



function WindowsAMI {
    Write-Host "Now Choose your AMI from the menu "
    Write-Host "Loading"
   
    # Get all instance types
    $allInstanceTypes = Get-SSMLatestEC2Image -Path ami-windows-latest -Region "us-east-1"
    $AMIValue = $allInstanceTypes | Out-GridView -PassThru
    return $AMIValue
   }
   function LinuxAMI {
    Write-Host "Now Choose your AMI from the menu "
    Write-Host "Loading"
   
    # Get all instance types
    $allInstanceTypes = Get-SSMLatestEC2Image -Path ami-amazon-linux-latest -Region "us-east-1"
    $AMIValue = $allInstanceTypes | Out-GridView -PassThru
    return $AMIValue
   }
   
   # Define the choices for AMI :
   $WLchoices = @("Windows", "Linux")
   # Define the options for PromptForChoice
   $WLoptions = foreach ($WLchoice in $WLchoices) {
       New-Object System.Management.Automation.Host.ChoiceDescription "&$WLchoice", "Choose $WLchoice option"
   }
   # Prompt the user to select an option
   $WLselectedIndex = $Host.UI.PromptForChoice("Select an Option", "Please choose an option:", $WLoptions, 0)
   # Get the selected choice
   $WLselectedChoice = $WLchoices[$WLselectedIndex]
   
   switch ($WLselectedChoice) {
       "Windows" { $AMI = WindowsAMI
       }
       "Linux"  {
                   $AMI = LinuxAMI
       }
       default {
           Write-Output "Invalid"
       }
   }
   
   $AMIID=$AMI.value
   $AMIName=$AMI.name
   Write-Host "The selected ami name: $AMIName  with ami-id: $AMIID "
   #Choose from Instance type available :
   $ImageAllAtribute= Get-EC2Image -ImageId $AMIID
   $ImageArchitecture=$ImageAllAtribute.Architecture.Value
   $VirtualizationType=$ImageAllAtribute.VirtualizationType.Value
   $Hypervisor=$ImageAllAtribute.Hypervisor.value
   $AllTypesSupported= Get-EC2InstanceType -Filter (@{Name="processor-info.supported-architecture"; Values= $ImageArchitecture},@{Name="supported-virtualization-type"; Values= $VirtualizationType},@{Name="hypervisor"; Values= $Hypervisor} )
   $selectedInstanceType= $AllTypesSupported.InstanceType | Out-GridView -PassThru
   Write-Host "The selected type : $selectedInstanceType "

# Create EC2 Instance : 
#$MyFirstInstance = New-EC2Instance -ImageId $AMIID -InstanceType $selectedInstanceType -KeyName $keyName -SubnetId "subnet-0dec98e621438a1bb"

#Create a LoadBalancer :
# Define the load balancer name
$LoadBalancerName = "NewTestALB"
# Define the IP address type
$IpAddressType = "ipv4"
# Define the scheme
$Scheme = "internet-facing"
# Define the security group
$SecurityGroup = "sg-0e59edfd269a218b2"
# Define the subnets (ensure they are in different Availability Zones)
$Subnets = @("subnet-0e4cfb9a2b23aabaa", "subnet-037a532c854b24015")
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
$VPCID = "vpc-06c9365ae45f74d90"
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
  ImageId = $AMIID
  InstanceType = $selectedInstanceType
  SecurityGroupIds = @("sg-00a698a108448ec01")
  UserData = $MyUserData
  KeyName = $keyName
}
$MyLaunchTemlpate = New-EC2LaunchTemplate `
-LaunchTemplateData $templateData `
-LaunchTemplateName "MyNewLaunchTemplate"
$MyLTName=$MyLaunchTemlpate.LaunchTemplateName
Write-Host "The lauch template $MyLTName has been created successfully"
##########################################################################################################
$SubnetsIDS = "subnet-0aa069120606a111d,subnet-0ad3c77afcbe88cc4"
#Create an autoscaling group : 
$MyAutoScalingGroup = New-ASAutoScalingGroup `
-AutoScalingGroupName "MyAutoscalingGroup" `
-LaunchTemplate_LaunchTemplateName "MyNewLaunchTemplate" `
-MinSize 2 `
-MaxSize 3 `
-DesiredCapacity 2 `
-TargetGroupARNs $MyTargetGroupARN `
-VPCZoneIdentifier $SubnetsIDS
###################################################################################################  