$ErrorActionPreference = "Stop"

$SourceUrl = "https://api.macroserver.ru/estate/export/yandex/OzA5_WiGLTOJUuUfZsa-aAnYrqeYWBlO7q97bDXLcTWdInddefntJn-Gx9oKQ2qDosqdi_K_c8t7HhEqgVzInjUi_sG_3P3HqxDZrIROtRuZqBKBbk-f9dF4USIHZkZnW3SzJXh8MTc2ODgwNjkwOHxjOGJiNg/394-yandex.xml?feed_id=8691"
$TargetUrl = "https://ligo-verba.ru"
$OutputFile = "C:\Users\lacri\394-yandex-patched.xml"
$LogFile = "C:\Users\lacri\verba-feed-update.log"

function Write-Log {
    param([string]$Message)
    $line = "{0} {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
}

try {
    Write-Log "Run started."
    [xml]$xml = (Invoke-WebRequest -Uri $SourceUrl -UseBasicParsing -TimeoutSec 90).Content

    $offerCount = 0
    $updatedCount = 0

    foreach ($offer in $xml.'realty-feed'.offer) {
        $offerCount++
        if ($null -eq $offer.url) {
            $newUrlNode = $xml.CreateElement("url", $xml.'realty-feed'.NamespaceURI)
            $newUrlNode.InnerText = $TargetUrl
            [void]$offer.AppendChild($newUrlNode)
            $updatedCount++
        }
        elseif ($offer.url -ne $TargetUrl) {
            $offer.url = $TargetUrl
            $updatedCount++
        }
    }

    $xml.Save($OutputFile)
    Write-Log "Saved: $OutputFile"
    Write-Log "Offers found: $offerCount; Offers updated: $updatedCount"
    Write-Host "Saved: $OutputFile"
    Write-Host "Offers found: $offerCount"
    Write-Host "Offers updated: $updatedCount"
}
catch {
    Write-Log ("ERROR: " + $_.Exception.Message)
    throw
}
