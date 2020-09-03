sub_name="CHANGE_ME_CASE_SENSITIVE"
rg_name="CHANGE_ME_CASE_SENSITIVE"

az login
echo "Setting subscription: $sub_name"
az account set --subscription $sub_name
echo "Getting resource group $rg_name"
rg=$(az group show --name $rg_name --subscription $sub_name --query name -o tsv)
echo "Getting VMs in resource group"
vms=$(az resource list -g $rg --resource-type "Microsoft.Compute/virtualMachines" --query [].name -o tsv)

for name in $vms; do
    echo "Setting pagefile for $name"
    az vm run-command invoke --command-id RunPowerShellScript --name $name -g $rg --scripts @SetPagefileToTempDrive.ps1 &
done

echo "Running all jobs, please wait..."
wait

echo "All done!"
