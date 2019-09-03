#Create VPC in different region



#Getting region and CIDR block input from user
$region = Read-Host -Prompt ("Please provide region name to create new VPC")
$CIDR_Block = Read-Host -Prompt("Please provide CIDR block for your VPC")

Start-Sleep -Seconds 1

#If in case require to use credentials for any region

$credential_input = Read-Host -Prompt ("Would you like to specify credentials for this particular region? (Yes or No) ")

if ($credential_input -eq 'Yes')
{
    $Access_Key = Read-Host -Prompt ("Please provide Access Key ")
    $Secret_Key = Read-Host -Prompt ("Please provide Secret Key ") 
    Initialize-AWSDefaults -AccessKey ‘AccessKey’ -SecretKey $Secret_Key
    Write-Output "Credential loaded! Don't Worry, I haven't stored that information"
}
else
{

    Write-Output "Fine ! I will go ahead and obtain from persisted/shell defaults"

}


Initialize-AWSDefaults -AccessKey $Access_Key -SecretKey $Secret_Key

Start-Sleep -Seconds 2

#Creating VPC

Write-Output "Creating new VPC. Wait for a Moment..!"
Start-Sleep -Seconds 2
$VPC_New = New-EC2Vpc -CidrBlock $CIDR_Block -Region $region
$vpcId = $VPC_New.VpcId
Write-Output “New VPC created Successfully in Region $region and VPC ID is $vpcId”


Start-Sleep -Seconds 2

#Enabling DNS hostname and Support enable.

Write-Output “Wait a Sec! Enabling DNS Hostname and and Support..”
Edit-EC2VpcAttribute -VpcId $vpcId -EnableDnsSupport $true
Edit-EC2VpcAttribute -VpcId $vpcId -EnableDnsHostnames $true

Start-Sleep -Seconds 2

Write-Output “Enabled Successfully..!!”

Start-Sleep -Seconds 2

#Create New Internet Gateway

$int_Gateway = Read-Host -Prompt ("Would you like to create New Internet Gateway? (Yes or No) ")

if ($int_Gateway -eq 'Yes')
{

    $New_IGW = New-EC2InternetGateway -Region $region
    $New_IGW_ID = $New_IGW.InternetGatewayId
    Write-Output “Internet Gateway Created Successfully with ID: $New_IGW_ID"
    Start-Sleep -Seconds 2
    #Attach Internet Gateway to VPC

    $IGW_to_VPC = Read-Host -Prompt ("Would you like to attach this Internet Gateway With VPC? (Yes or No) ")
    if ($IGW_to_VPC -eq 'Yes')
    {
        Add-EC2InternetGateway -InternetGatewayId $New_IGW_ID -VpcId $vpcId
    }
    else
    {
        Write-Output "Sure! Exiting to main program"
    }
}
else
{
    Write-Output "Fine! Lets Jump to Next Configuration"
}

#Create New Route Table

$routetable = Read-Host -Prompt ("Would you like to create new Route Table?(Yes or No) ")

if($routetable -eq 'Yes')
    
{
    $numbeof_routingTable = Read-host -Prompt ("How many Routing Tables you would like to create? ")

    for($i = 0; $i -lt $numbeof_routingTable; $i++)
    {

        $route_table = New-EC2RouteTable -VpcId $vpcId
        $route_table_id = $route_table.RouteTableId
        Write-Output "New Route Table ID is $route_table_id"

        $routes_to_add = Read-Host -Prompt ("Lets add some routes to Routing Table $route_table_id, How many Routes you like to add? Please mention number ")

        for($k = 0; $k -lt $routes_to_add; $k++)
        {
            $public_or_private = Read-Host -Prompt ("Would you like to use this Routing table for Internet-Gateway or private? (type: IG or PI) ")
            if ($public_or_private -eq 'IG')
            {
                $des_CIDR_block = Read-Host -Prompt ("Please provide Destination CIDR ")
                New-EC2Route -RouteTableId $route_table_id -GatewayId $New_IGW_ID -DestinationCidrBlock $des_CIDR_block 

            }
            else
            {
                
                Write-Output "Please add manually from AWS Console. Thanks!!" 

            }
        }
    }
}

#Creating Subnet in New VPC create above.

$subnet_creation = Read-Host -Prompt ("Would you like to add New Subnets in Newly create VPC? (Yes or No) ")

if ($subnet_creation -eq 'Yes')
{
    $number_of_subnet = Read-Host -Prompt ("Enter the number of subnets you want to create ")
    
    for($j = 0; $j -lt $number_of_subnet; $j++)
    {
    
        $subnet_CIDR = Read-Host -Prompt ("Please provide New VPC subnet CIDR block ")
        $availability_zone = Read-Host -Prompt ("Please provide Availability Zone ") 
        $new_subnet = New-EC2Subnet -VpcId $vpcId -CidrBlock $subnet_CIDR -AvailabilityZone $availability_zone
        $subnet_id = $new_subnet.SubnetId
        Write-Output "Subnet Created Successfully with ID: $subnet_id"
        Register-EC2RouteTable -RouteTableId $route_table_id -SubnetId $subnet_id
    }

}
else
{
    Write-Output "No Problem! Thank you for your time!"
}

Write-Output "VPC Setup Complete! Have a nice Day!"