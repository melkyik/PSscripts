 $service = Get-WmiObject Win32_Service -Filter 'Name="SimpleScadaSrvService"'  -Ea 0
	if ($service)
	{
		if ($service.StartMode -eq "Disabled")
		{
			$result = $service.ChangeStartMode("Auto").ReturnValue
			if($result)
			{
				"Failed to enable the 'SimpleScadaSrvService' service . The return value was $result."
			}
			else {"Success to enable the 'SimpleScadaSrvService' service."}
       } 
			
        if ($service.State -eq "Stopped")
		{
				$result = $service.StartService().ReturnValue
				if ($result)
				{
					"Failed to start the 'SimpleScadaSrvService' service. The return value was $result."
                     .\SendTelegram.ps1 -id 345821176 -message "НЕВОЗМОЖНО ЗАПУСТИТЬ СЛУЖБУ SIMPESCADA!!! ПОВТОРНАЯ ПОПЫТКА ЧЕРЕЗ 2 МИН!" 
				}
				else {"Success to start the 'SimpleScadaSrvService' service."}
		}
		
		else {"The 'SimpleScadaSrvService' service on is already started."}
	}
	else {"Failed to retrieve the service 'SimpleScadaSrvService'."}
