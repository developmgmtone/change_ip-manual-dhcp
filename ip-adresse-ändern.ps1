Write-Host "Willkommen"
Write-Host "__________________________________________________________________________"
Write-Host "Dies in ein Programm um auf DHCP oder eine feste IP Adresse eiunzustellen."
Write-Host "Bitte waehlen Sie das Interface aus:"
Get-NetAdapter
[int] $interface = Read-Host -Prompt "Nummer des Interface Index: (ifIndex): "



Write-Host "Bitte waehlen Sie eine Aktion aus:"
Write-Host "(1) Ip Adresse fest vergeben"
Write-Host "(2) DHCP aktivieren"
[int] $action = Read-Host -Prompt "Aktion waehlen: "


do{


        if ($action -eq '1'){
            $defaultgw = [string] (Get-wmiObject Win32_networkAdapterConfiguration | ?{$_.IPEnabled -and $_.InterfaceIndex -eq $interface}).DefaultIPGateway
            if($defaultgw -eq ""){
                Remove-NetIPAddress -InterfaceIndex $interface -DefaultGateway $defaultgw
                Write-Host "Entferne´alte Gateways des Interfaces"
            }
            
            $ip = Read-Host -Prompt "Bitte IP Adresse eingeben: "
            [int] $submask = Read-Host -Prompt "Bitte Subnetzmaske  als Prefix eingeben: (8-30): "
            $gw = Read-Host -Prompt "Bitte Gateway eingeben: "
            $dns1 = Read-Host -Prompt "Bitte DNS Adresse eingeben: "

            New-NetIPAddress -InterfaceIndex $interface -IPAddress $ip -PrefixLength 24 -DefaultGateway $gw
            Set-DnsClientServerAddress -InterfaceIndex $interface -ServerAddresses $dns1,8.8.8.8
            sleep 1
            Write-Host "Einrichtung Manuelle IP erfolgreich" -ForeGroundColor Green
        
            
           } elseif($action -eq '2'){

               $ethernetObject= Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where {$_.IpEnabled -eq $true -and $_.DhcpEnabled -eq $true -and $_.InterfaceIndex -eq $interface}
               Set-NetIPInterface -InterfaceIndex $interface -Dhcp Enabled
               Set-DnsClientServerAddress -InterfaceIndex $interface -ResetServerAddresses
               sleep 3
               $ethernetObject.ReleaseDHCPLease() 
               $ethernetObject.RenewDHCPLease() 

               Write-Host "Einrichtung DHCP erfolgreich" -ForeGroundColor Green
          }

        else{
            Write-Host "Falsche Eingabe. Bitte erneut versuchen."
            

        }
} while($action -lt '1' -and $action -gt '2' )

Get-NetIPConfiguration -InterfaceIndex $interface
pause