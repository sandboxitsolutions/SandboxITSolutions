# PowerShell Script to Export Named Location Countries to CSV
# This script will output the 2 letter country code as the full country name
# Created by Wilcox Yuen - Sandbox IT Solutions https://www.sandboxitsolutions.com


# Install the Microsoft Graph module if not already installed
# Install-Module -Name Microsoft.Graph -Force

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Policy.Read.All" -NoWelcome -TenantId "<your-tenant-id>"

# Get all cultures to map country codes to full names
$cultures = [System.Globalization.CultureInfo]::GetCultures([System.Globalization.CultureTypes]::SpecificCultures)

# Create a hashtable to store country codes and full names
$countryMapping = @{}

# Populate the hashtable with country codes and full names
$cultures | ForEach-Object {
    $regionInfo = New-Object System.Globalization.RegionInfo $_.Name
    if (-not $countryMapping.ContainsKey($regionInfo.TwoLetterISORegionName)) {
        $countryMapping[$regionInfo.TwoLetterISORegionName] = $regionInfo.EnglishName
    }
}

# Get the named location
$GetLocation = Get-MgIdentityConditionalAccessNamedLocation -Filter "DisplayName eq 'Named Location goes here'"

# Get the list of country codes from the named location and sort them
$countries = $GetLocation.AdditionalProperties.countriesAndRegions | Sort-Object

# Map the country codes to full names and output a custom object
$fullCountryNames = $countries | ForEach-Object {
    [PSCustomObject]@{
        CountryCode = $_
        CountryName = $countryMapping[$_]
    }
}


# Export the full country names to a CSV file
$fullCountryNames | Export-Csv -Path "c:\temp\Sandbox-CountriesListWithFullNames.csv" -NoTypeInformation
 