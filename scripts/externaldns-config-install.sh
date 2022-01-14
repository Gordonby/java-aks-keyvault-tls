KubeletId=$(az aks show -n $AKSNAME -g  $RG --query "identityProfile.kubeletidentity.clientId" -o tsv)
TenantId=$(az account show --query tenantId -o tsv)
SubscriptionId=$(az account show --query id -o tsv)

JSONSECRETPATH="azure.json"
cat<<EOF>$JSONSECRETPATH
{
"userAssignedIdentityID": "$KubeletId",
"tenantId": "$TenantId",
"useManagedIdentityExtension": true,
"subscriptionId": "$SubscriptionId",
"resourceGroup": "$DNSRG"
}
EOF

kubectl create secret generic azure-config-file --dry-run=client -o yaml --from-file=azure.json | kubectl apply -f -

echo "Installing ExternalDns for $DNSDOMAIN"
helm upgrade --install externaldns ${{ inputs.HELMEXTERNALDNSURI }} --set externaldns.domainfilter="$DNSDOMAIN"